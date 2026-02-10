# LegaStream Production System Design

## 1. System Overview

LegaStream is a cloud-based SaaS platform that provides AI-powered document analysis for legal professionals. The system extracts entities, checks compliance, and generates summaries from legal documents using machine learning.

### 1.1 Design Principles

1. **Scalability First**: Design for 10x growth from day one
2. **Security by Default**: Encrypt everything, trust nothing
3. **Cost Optimization**: Balance performance with cloud costs
4. **User Experience**: Mobile-first, fast, intuitive

### 1.2 High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Client Layer                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Mobile     │  │   Desktop    │  │   API        │          │
│  │   Browser    │  │   Browser    │  │   Clients    │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      CDN / Load Balancer                         │
│                    (CloudFlare / AWS ALB)                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Application Layer                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Rails API Server (Puma)                      │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐         │  │
│  │  │   Auth     │  │  Document  │  │  Analysis  │         │  │
│  │  │ Controller │  │ Controller │  │ Controller │         │  │
│  │  └────────────┘  └────────────┘  └────────────┘         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                              │                                   │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              Background Job Queue (Sidekiq)               │  │
│  │  ┌────────────┐  ┌────────────┐  ┌────────────┐         │  │
│  │  │  Document  │  │    AI      │  │   Email    │         │  │
│  │  │ Processing │  │  Analysis  │  │   Sender   │         │  │
│  │  └────────────┘  └────────────┘  └────────────┘         │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        Data Layer                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  PostgreSQL  │  │    Redis     │  │   S3/Blob    │          │
│  │  (Primary)   │  │   (Cache)    │  │  (Storage)   │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    External Services                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   OpenAI     │  │    Stripe    │  │  SendGrid    │          │
│  │     API      │  │   Payments   │  │    Email     │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

### 1.3 Technology Stack

**Frontend**:
- React 18 with Vite
- TailwindCSS for responsive design
- React Query for data fetching
- React Router for navigation

**Backend**:
- Ruby on Rails 7 (API mode)
- Puma web server
- Sidekiq for background jobs
- JWT for authentication

**Data Storage**:
- PostgreSQL 14+ (primary database)
- Redis 7+ (caching, job queue)
- AWS S3 / Azure Blob (document storage)

**Infrastructure**:
- Docker containers
- AWS ECS / Azure Container Apps
- CloudFlare CDN
- AWS RDS / Azure Database

**External Services**:
- OpenAI API (GPT-3.5-turbo)
- Stripe (payments)
- SendGrid (email)
- Sentry (error tracking)
- DataDog (monitoring)

## 2. Architecture

### 2.1 Multi-Tenant Architecture

LegaStream uses a **shared database, shared schema** multi-tenancy model with tenant isolation enforced at the application layer.

**Design Decision**: Shared database vs. Database-per-tenant
- **Chosen**: Shared database with tenant_id column
- **Rationale**: 
  - Lower operational complexity
  - Cost-effective for small-medium scale
  - Easier backups and migrations
  - Sufficient isolation for target market (small law firms)
- **Trade-offs**:
  - ✅ Simpler infrastructure
  - ✅ Lower costs
  - ✅ Easier to scale initially
  - ❌ Noisy neighbor risk
  - ❌ More complex queries
  - ❌ Harder to offer on-premise

**Tenant Isolation Strategy**:
```ruby
# All models inherit tenant scoping
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  
  # Automatically scope all queries by current tenant
  default_scope { where(tenant_id: TenantContext.current_id) }
end

# Tenant context managed via middleware
class TenantContext
  def self.current_id
    Thread.current[:tenant_id]
  end
  
  def self.with_tenant(tenant_id)
    old_id = Thread.current[:tenant_id]
    Thread.current[:tenant_id] = tenant_id
    yield
  ensure
    Thread.current[:tenant_id] = old_id
  end
end
```

### 2.2 Document Processing Pipeline

**Design Decision**: Synchronous vs. Asynchronous processing
- **Chosen**: Asynchronous with Sidekiq
- **Rationale**:
  - AI analysis takes 10-30 seconds
  - Don't block HTTP requests
  - Better user experience with progress updates
  - Can retry failed jobs
- **Trade-offs**:
  - ✅ Non-blocking API
  - ✅ Scalable processing
  - ✅ Automatic retries
  - ❌ More complex error handling
  - ❌ Requires job queue infrastructure

**Pipeline Stages**:
```
1. Upload → 2. Validate → 3. Store → 4. Extract Text → 5. AI Analysis → 6. Store Results
   (API)      (API)        (S3)       (Background)      (Background)      (Database)
```

**Flow**:
1. **Upload**: Client uploads PDF via multipart form
2. **Validate**: Check file size, type, virus scan
3. **Store**: Save to S3 with unique key
4. **Extract Text**: Use pdf-reader gem to extract text
5. **AI Analysis**: Call OpenAI API for entity extraction, summary, compliance
6. **Store Results**: Save analysis to database, notify user

### 2.3 Caching Strategy

**Design Decision**: Multi-layer caching
- **Layer 1**: Browser cache (static assets)
- **Layer 2**: CDN cache (API responses for public data)
- **Layer 3**: Redis cache (database queries, AI results)
- **Layer 4**: Database query cache

**Cache Invalidation**:
- Document analysis results: Cache forever (immutable)
- User dashboard: Cache 5 minutes
- Document list: Invalidate on upload/delete
- User profile: Invalidate on update

**Example**:
```ruby
class Document < ApplicationRecord
  # Cache analysis results forever (they don't change)
  def analysis_results
    Rails.cache.fetch("document:#{id}:analysis", expires_in: nil) do
      AnalysisResult.where(document_id: id).to_a
    end
  end
  
  # Invalidate cache on changes
  after_save :clear_cache
  after_destroy :clear_cache
  
  private
  
  def clear_cache
    Rails.cache.delete("document:#{id}:analysis")
    Rails.cache.delete("user:#{user_id}:documents")
  end
end
```

### 2.4 Security Architecture

**Authentication Flow**:
```
1. User submits email/password
2. Server validates credentials
3. Server generates JWT token (expires in 24h)
4. Client stores token in localStorage
5. Client includes token in Authorization header
6. Server validates token on each request
7. Server extracts user_id and tenant_id from token
```

**Authorization Model**:
- **Role-Based Access Control (RBAC)**
- Roles: Admin, User, ReadOnly
- Permissions checked at controller level
- Document ownership enforced at model level

**Data Encryption**:
- **In Transit**: TLS 1.3 for all connections
- **At Rest**: 
  - S3 server-side encryption (AES-256)
  - PostgreSQL transparent data encryption
  - Encrypted database backups
- **Application Level**: Sensitive fields encrypted with Rails credentials

### 2.5 Scalability Design

**Horizontal Scaling**:
- Stateless API servers (can add more instances)
- Load balancer distributes traffic
- Sidekiq workers can scale independently
- Database read replicas for read-heavy queries

**Vertical Scaling**:
- Start with small instances
- Monitor CPU/memory usage
- Scale up when needed
- Database connection pooling

**Auto-Scaling Triggers**:
- CPU > 70% for 5 minutes → Add instance
- Queue depth > 100 jobs → Add worker
- Response time > 500ms → Add instance
- CPU < 30% for 15 minutes → Remove instance

**Bottleneck Analysis**:
1. **OpenAI API**: Rate limited to 3500 requests/min
   - Mitigation: Queue jobs, implement backoff
2. **Database**: Write-heavy on document upload
   - Mitigation: Connection pooling, read replicas
3. **S3 Upload**: Network bandwidth
   - Mitigation: Direct upload from client, multipart upload

## 3. Components and Interfaces

### 3.1 API Endpoints

**Authentication**:
```
POST   /api/v1/auth/register          # Create account
POST   /api/v1/auth/login             # Get JWT token
POST   /api/v1/auth/logout            # Invalidate token
POST   /api/v1/auth/forgot-password   # Request reset
POST   /api/v1/auth/reset-password    # Reset with token
GET    /api/v1/auth/confirm-email     # Confirm email
```

**Documents**:
```
GET    /api/v1/documents              # List user's documents
POST   /api/v1/documents              # Upload document
GET    /api/v1/documents/:id          # Get document details
DELETE /api/v1/documents/:id          # Delete document
GET    /api/v1/documents/:id/download # Download original PDF
```

**Analysis**:
```
GET    /api/v1/documents/:id/analysis # Get analysis results
POST   /api/v1/documents/:id/reanalyze # Trigger re-analysis
GET    /api/v1/documents/:id/entities # Get extracted entities
GET    /api/v1/documents/:id/summary  # Get AI summary
GET    /api/v1/documents/:id/compliance # Get compliance check
```

**User Management**:
```
GET    /api/v1/users/me               # Get current user
PATCH  /api/v1/users/me               # Update profile
DELETE /api/v1/users/me               # Delete account
GET    /api/v1/users/me/usage         # Get usage stats
```

**Billing** (Future):
```
GET    /api/v1/billing/subscription   # Get subscription
POST   /api/v1/billing/subscribe      # Create subscription
PATCH  /api/v1/billing/subscription   # Update subscription
DELETE /api/v1/billing/subscription   # Cancel subscription
```

### 3.2 Background Jobs

**DocumentProcessingJob**:
```ruby
class DocumentProcessingJob < ApplicationJob
  queue_as :default
  
  def perform(document_id)
    document = Document.find(document_id)
    
    # Extract text from PDF
    text = PdfExtractor.extract(document.file_path)
    document.update!(extracted_text: text)
    
    # Trigger AI analysis
    AiAnalysisJob.perform_later(document_id)
  end
end
```

**AiAnalysisJob**:
```ruby
class AiAnalysisJob < ApplicationJob
  queue_as :ai_analysis
  retry_on OpenAI::RateLimitError, wait: :exponentially_longer
  
  def perform(document_id)
    document = Document.find(document_id)
    
    # Call AI service
    results = AiAnalysisService.analyze(document.extracted_text)
    
    # Store results
    AnalysisResult.create!(
      document: document,
      entities: results[:entities],
      summary: results[:summary],
      compliance_score: results[:compliance_score],
      compliance_issues: results[:compliance_issues]
    )
    
    # Notify user
    NotificationJob.perform_later(document.user_id, "analysis_complete", document_id)
  end
end
```

**NotificationJob**:
```ruby
class NotificationJob < ApplicationJob
  queue_as :notifications
  
  def perform(user_id, event_type, resource_id)
    user = User.find(user_id)
    
    case event_type
    when "analysis_complete"
      UserMailer.analysis_complete(user, resource_id).deliver_later
    when "upload_failed"
      UserMailer.upload_failed(user, resource_id).deliver_later
    end
  end
end
```

### 3.3 Service Objects

**AiAnalysisService**:
```ruby
class AiAnalysisService
  def self.analyze(text)
    new.analyze(text)
  end
  
  def analyze(text)
    {
      entities: extract_entities(text),
      summary: generate_summary(text),
      compliance_score: check_compliance(text)[:score],
      compliance_issues: check_compliance(text)[:issues]
    }
  end
  
  private
  
  def extract_entities(text)
    prompt = build_entity_extraction_prompt(text)
    response = call_openai(prompt)
    parse_entities(response)
  end
  
  def generate_summary(text)
    prompt = "Summarize this legal document in 2-3 sentences:\n\n#{text}"
    call_openai(prompt)
  end
  
  def check_compliance(text)
    prompt = build_compliance_prompt(text)
    response = call_openai(prompt)
    parse_compliance(response)
  end
  
  def call_openai(prompt)
    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.3
      }
    )
    response.dig("choices", 0, "message", "content")
  end
end
```

**PdfExtractor**:
```ruby
class PdfExtractor
  def self.extract(file_path)
    new.extract(file_path)
  end
  
  def extract(file_path)
    reader = PDF::Reader.new(file_path)
    text = reader.pages.map(&:text).join("\n")
    clean_text(text)
  end
  
  private
  
  def clean_text(text)
    # Remove excessive whitespace
    text.gsub(/\s+/, ' ')
        .gsub(/\n{3,}/, "\n\n")
        .strip
  end
end
```

### 3.4 Frontend Components

**Mobile-Responsive Design**:
```jsx
// Responsive layout component
const Layout = ({ children }) => {
  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Mobile header */}
      <header className="lg:hidden fixed top-0 w-full bg-white dark:bg-gray-800 shadow z-50">
        <MobileNav />
      </header>
      
      {/* Desktop sidebar */}
      <aside className="hidden lg:block fixed left-0 top-0 h-full w-64 bg-white dark:bg-gray-800 shadow">
        <DesktopNav />
      </aside>
      
      {/* Main content */}
      <main className="lg:ml-64 pt-16 lg:pt-0 p-4 lg:p-8">
        {children}
      </main>
    </div>
  );
};
```

**Document Upload Component**:
```jsx
const DocumentUpload = () => {
  const [file, setFile] = useState(null);
  const [progress, setProgress] = useState(0);
  
  const handleUpload = async () => {
    const formData = new FormData();
    formData.append('document', file);
    
    await axios.post('/api/v1/documents', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
      onUploadProgress: (e) => {
        setProgress(Math.round((e.loaded * 100) / e.total));
      }
    });
  };
  
  return (
    <div className="max-w-2xl mx-auto">
      {/* Mobile-friendly file input */}
      <input
        type="file"
        accept=".pdf"
        onChange={(e) => setFile(e.target.files[0])}
        className="block w-full text-sm text-gray-500
          file:mr-4 file:py-2 file:px-4
          file:rounded-full file:border-0
          file:text-sm file:font-semibold
          file:bg-blue-50 file:text-blue-700
          hover:file:bg-blue-100"
      />
      
      {progress > 0 && (
        <div className="mt-4">
          <div className="bg-gray-200 rounded-full h-2">
            <div
              className="bg-blue-600 h-2 rounded-full transition-all"
              style={{ width: `${progress}%` }}
            />
          </div>
          <p className="text-sm text-gray-600 mt-2">{progress}% uploaded</p>
        </div>
      )}
      
      <button
        onClick={handleUpload}
        disabled={!file}
        className="mt-4 w-full py-3 px-4 bg-blue-600 text-white rounded-lg
          disabled:bg-gray-300 disabled:cursor-not-allowed
          hover:bg-blue-700 transition-colors"
      >
        Upload Document
      </button>
    </div>
  );
};
```

## 4. Data Models

### 4.1 Database Schema

**Tenants Table**:
```sql
CREATE TABLE tenants (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  subdomain VARCHAR(100) UNIQUE,
  plan VARCHAR(50) DEFAULT 'free',
  status VARCHAR(50) DEFAULT 'active',
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_tenants_subdomain ON tenants(subdomain);
CREATE INDEX idx_tenants_status ON tenants(status);
```

**Users Table**:
```sql
CREATE TABLE users (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL,
  password_digest VARCHAR(255) NOT NULL,
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  role VARCHAR(50) DEFAULT 'user',
  email_confirmed BOOLEAN DEFAULT FALSE,
  confirmation_token VARCHAR(255),
  reset_password_token VARCHAR(255),
  reset_password_sent_at TIMESTAMP,
  last_login_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  
  CONSTRAINT unique_email_per_tenant UNIQUE(tenant_id, email)
);

CREATE INDEX idx_users_tenant_id ON users(tenant_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_confirmation_token ON users(confirmation_token);
CREATE INDEX idx_users_reset_password_token ON users(reset_password_token);
```

**Documents Table**:
```sql
CREATE TABLE documents (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  filename VARCHAR(255) NOT NULL,
  file_size BIGINT NOT NULL,
  file_path VARCHAR(500) NOT NULL,
  mime_type VARCHAR(100),
  status VARCHAR(50) DEFAULT 'pending',
  extracted_text TEXT,
  page_count INTEGER,
  uploaded_at TIMESTAMP NOT NULL,
  processed_at TIMESTAMP,
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_documents_tenant_id ON documents(tenant_id);
CREATE INDEX idx_documents_user_id ON documents(user_id);
CREATE INDEX idx_documents_status ON documents(status);
CREATE INDEX idx_documents_uploaded_at ON documents(uploaded_at DESC);
```

**Analysis Results Table**:
```sql
CREATE TABLE analysis_results (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  document_id BIGINT NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
  result_type VARCHAR(50) NOT NULL,
  result_data JSONB NOT NULL,
  confidence_score DECIMAL(5,2),
  created_at TIMESTAMP NOT NULL,
  updated_at TIMESTAMP NOT NULL,
  
  CONSTRAINT unique_result_per_document UNIQUE(document_id, result_type)
);

CREATE INDEX idx_analysis_results_tenant_id ON analysis_results(tenant_id);
CREATE INDEX idx_analysis_results_document_id ON analysis_results(document_id);
CREATE INDEX idx_analysis_results_type ON analysis_results(result_type);
CREATE INDEX idx_analysis_results_data ON analysis_results USING GIN(result_data);
```

**Usage Records Table**:
```sql
CREATE TABLE usage_records (
  id BIGSERIAL PRIMARY KEY,
  tenant_id BIGINT NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  action VARCHAR(100) NOT NULL,
  resource_type VARCHAR(100),
  resource_id BIGINT,
  metadata JSONB,
  created_at TIMESTAMP NOT NULL
);

CREATE INDEX idx_usage_records_tenant_id ON usage_records(tenant_id);
CREATE INDEX idx_usage_records_user_id ON usage_records(user_id);
CREATE INDEX idx_usage_records_action ON usage_records(action);
CREATE INDEX idx_usage_records_created_at ON usage_records(created_at DESC);
```

### 4.2 Data Relationships

```
Tenant (1) ──< (N) User
Tenant (1) ──< (N) Document
Tenant (1) ──< (N) AnalysisResult
Tenant (1) ──< (N) UsageRecord

User (1) ──< (N) Document
User (1) ──< (N) UsageRecord

Document (1) ──< (N) AnalysisResult
```

### 4.3 Data Retention

**Document Storage**:
- Free tier: 30 days retention
- Pro tier: 1 year retention
- Enterprise: Custom retention

**Analysis Results**:
- Retained as long as document exists
- Deleted when document is deleted

**Usage Records**:
- Retained for 2 years (compliance)
- Archived to cold storage after 90 days

**Audit Logs**:
- Retained for 7 years (legal requirement)
- Immutable (append-only)

## 5. Error Handling

### 5.1 Error Categories

**Client Errors (4xx)**:
- 400 Bad Request: Invalid input
- 401 Unauthorized: Missing/invalid token
- 403 Forbidden: Insufficient permissions
- 404 Not Found: Resource doesn't exist
- 422 Unprocessable Entity: Validation failed
- 429 Too Many Requests: Rate limit exceeded

**Server Errors (5xx)**:
- 500 Internal Server Error: Unexpected error
- 502 Bad Gateway: External service failure
- 503 Service Unavailable: System overloaded
- 504 Gateway Timeout: Request timeout

### 5.2 Error Response Format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Document upload failed",
    "details": [
      {
        "field": "file",
        "message": "File size exceeds 50MB limit"
      }
    ],
    "request_id": "req_abc123",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### 5.3 Retry Strategy

**Exponential Backoff**:
```ruby
class AiAnalysisJob < ApplicationJob
  retry_on OpenAI::RateLimitError, wait: :exponentially_longer, attempts: 5
  retry_on Net::ReadTimeout, wait: 5.seconds, attempts: 3
  
  discard_on ActiveRecord::RecordNotFound
  discard_on OpenAI::InvalidRequestError
end
```

**Circuit Breaker**:
```ruby
class OpenAiCircuitBreaker
  def self.call(&block)
    if circuit_open?
      raise CircuitOpenError, "OpenAI service unavailable"
    end
    
    begin
      result = block.call
      record_success
      result
    rescue => e
      record_failure
      raise
    end
  end
  
  def self.circuit_open?
    failure_rate > 0.5 && recent_failures > 10
  end
end
```

### 5.4 Monitoring and Alerting

**Error Tracking**:
- Sentry for exception tracking
- Group errors by type and frequency
- Alert on new error types
- Alert on error rate > 1%

**Performance Monitoring**:
- DataDog APM for request tracing
- Track slow queries (> 100ms)
- Monitor external API latency
- Alert on p95 latency > 500ms

**Uptime Monitoring**:
- Pingdom for endpoint monitoring
- Check every 1 minute
- Alert on 3 consecutive failures
- SMS + email + Slack notifications


## 6. Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property Reflection

After analyzing all acceptance criteria, I identified the following testable properties. I've eliminated redundancy by combining related properties:

**Core Properties**:
1. Deterministic analysis (US-1.2)
2. User data isolation (US-2.3) - Critical security property
3. File size validation (US-1.1)
4. Password strength validation (US-2.1)
5. Token validation (US-2.2)
6. RBAC enforcement (US-5.2)
7. Usage limits enforcement (US-6.1)
8. Audit trail completeness (US-5.4)
9. Usage tracking completeness (US-6.3)

**Combined Properties**:
- Summary format and compliance score validation can be combined into "Analysis result structure validation"
- Offline queue and retry behavior can be combined into "Resilient operation handling"

### 6.1 Core Correctness Properties

**Property 1: Deterministic Analysis**

*For any* document, analyzing it multiple times should produce identical results (same entities, same summary, same compliance score).

**Validates: US-1.2**

**Rationale**: AI analysis must be deterministic to ensure consistency. Users should get the same results if they re-analyze a document. This is achieved by setting temperature=0.3 in OpenAI calls and caching results.

---

**Property 2: User Data Isolation**

*For any* two different users (user A and user B), user A should never be able to access, view, modify, or delete user B's documents through any API endpoint.

**Validates: US-2.3**

**Rationale**: This is the most critical security property. Multi-tenant isolation must be enforced at all layers. Every database query must be scoped by tenant_id and user_id.

---

**Property 3: File Size Validation**

*For any* file upload, files under 50MB should be accepted and files over 50MB should be rejected with a clear error message.

**Validates: US-1.1**

**Rationale**: Prevents resource exhaustion and ensures consistent user experience. Large files would timeout during AI analysis.

---

**Property 4: Password Strength Validation**

*For any* password string, passwords that don't meet strength requirements (minimum 8 characters, at least one uppercase, one lowercase, one number) should be rejected during registration.

**Validates: US-2.1**

**Rationale**: Enforces security best practices. Weak passwords are the #1 cause of account compromise.

---

**Property 5: JWT Token Validation**

*For any* API request with an authentication token, expired tokens (> 24 hours old) should be rejected, and valid tokens should correctly identify the user and tenant.

**Validates: US-2.2**

**Rationale**: Ensures secure session management. Expired tokens must not grant access.

---

**Property 6: Analysis Result Structure Validation**

*For any* completed document analysis, the result should contain all required fields: entities array, summary string (2-3 sentences), compliance_score (0-100), and compliance_issues array.

**Validates: US-1.3, US-1.4**

**Rationale**: Ensures API contract consistency. Frontend depends on this structure.

---

**Property 7: RBAC Enforcement**

*For any* API endpoint marked as requiring admin role, requests from non-admin users should be rejected with 403 Forbidden, regardless of whether they own the resource.

**Validates: US-5.2**

**Rationale**: Prevents privilege escalation. Role checks must happen before resource access checks.

---

**Property 8: Usage Limits Enforcement**

*For any* user on the free tier, attempting to upload document number 11 (or higher) within a billing period should be rejected with a clear error indicating the limit has been reached.

**Validates: US-6.1**

**Rationale**: Enforces business model. Free tier users must upgrade to continue using the service.

---

**Property 9: Audit Trail Completeness**

*For any* user action that modifies data (create, update, delete), there should be a corresponding audit log entry with user_id, action type, resource type, resource_id, and timestamp.

**Validates: US-5.4**

**Rationale**: Required for compliance and security investigations. Audit logs must be complete and immutable.

---

**Property 10: Usage Tracking Completeness**

*For any* document upload or analysis, there should be a corresponding usage record created with the correct tenant_id, user_id, action type, and timestamp.

**Validates: US-6.3**

**Rationale**: Required for billing and analytics. Usage records drive subscription enforcement and business metrics.

---

**Property 11: Resilient Operation Handling**

*For any* background job that fails due to transient errors (network timeout, rate limit), the job should be automatically retried with exponential backoff up to 5 attempts before being marked as failed.

**Validates: US-7.2**

**Rationale**: Ensures system reliability. Transient failures should not result in permanent data loss or incomplete processing.

### 6.2 Edge Cases

**Empty Document Handling**:
- Empty PDFs (0 pages) should be rejected during upload validation
- PDFs with no extractable text should return empty analysis with appropriate message

**Concurrent Upload Handling**:
- Multiple simultaneous uploads from same user should all succeed
- Race conditions in usage counting should not allow exceeding limits

**Token Edge Cases**:
- Tokens with tampered signatures should be rejected
- Tokens with missing claims should be rejected
- Tokens for deleted users should be rejected

**Special Characters in Input**:
- Filenames with special characters should be sanitized
- SQL injection attempts in search queries should be escaped
- XSS attempts in document names should be sanitized

## 7. Testing Strategy

### 7.1 Testing Approach

We will use a **dual testing approach** combining unit tests and property-based tests:

- **Unit tests**: Verify specific examples, edge cases, and error conditions
- **Property tests**: Verify universal properties across all inputs

Both are complementary and necessary for comprehensive coverage. Unit tests catch concrete bugs in specific scenarios, while property tests verify general correctness across a wide range of inputs.

### 7.2 Property-Based Testing

**Library**: We will use **rspec-propcheck** (Ruby port of QuickCheck) for property-based testing.

**Configuration**:
- Minimum 100 iterations per property test (due to randomization)
- Each property test must reference its design document property
- Tag format: `# Feature: production-transformation, Property {number}: {property_text}`

**Example Property Test**:
```ruby
require 'rspec/propcheck'

RSpec.describe "Document Analysis", type: :property do
  include RSpec::Propcheck
  
  # Feature: production-transformation, Property 1: Deterministic Analysis
  property "analyzing same document twice produces identical results" do
    forall(document: gen_document) do |doc|
      result1 = AiAnalysisService.analyze(doc.extracted_text)
      result2 = AiAnalysisService.analyze(doc.extracted_text)
      
      expect(result1[:entities]).to eq(result2[:entities])
      expect(result1[:summary]).to eq(result2[:summary])
      expect(result1[:compliance_score]).to eq(result2[:compliance_score])
    end
  end
  
  # Feature: production-transformation, Property 2: User Data Isolation
  property "users cannot access other users' documents" do
    forall(user_a: gen_user, user_b: gen_user, document: gen_document) do |user_a, user_b, doc|
      # Ensure different users
      next if user_a.id == user_b.id
      
      # Create document owned by user_a
      doc.update!(user_id: user_a.id, tenant_id: user_a.tenant_id)
      
      # Try to access as user_b
      TenantContext.with_tenant(user_b.tenant_id) do
        expect {
          Document.find(doc.id)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
  
  # Feature: production-transformation, Property 3: File Size Validation
  property "files over 50MB are rejected" do
    forall(file_size: gen_integer(min: 0, max: 100_000_000)) do |size|
      file = double("file", size: size)
      validator = DocumentValidator.new(file)
      
      if size <= 50_000_000
        expect(validator.valid?).to be true
      else
        expect(validator.valid?).to be false
        expect(validator.errors).to include(/exceeds 50MB limit/)
      end
    end
  end
end
```

### 7.3 Unit Testing

**Framework**: RSpec for backend, Vitest for frontend

**Coverage Goals**:
- 80% code coverage minimum
- 100% coverage for critical paths (auth, data isolation, billing)

**Test Categories**:

1. **Model Tests**:
   - Validation rules
   - Associations
   - Scopes and queries
   - Callbacks

2. **Controller Tests**:
   - Authentication checks
   - Authorization checks
   - Input validation
   - Response formats

3. **Service Tests**:
   - Business logic
   - External API integration (mocked)
   - Error handling

4. **Job Tests**:
   - Job execution
   - Retry logic
   - Error handling

5. **Integration Tests**:
   - End-to-end API flows
   - Multi-step processes
   - Database transactions

**Example Unit Test**:
```ruby
RSpec.describe DocumentsController, type: :controller do
  describe "POST #create" do
    context "when user is authenticated" do
      let(:user) { create(:user) }
      let(:file) { fixture_file_upload('sample.pdf', 'application/pdf') }
      
      before { sign_in(user) }
      
      it "creates a document" do
        expect {
          post :create, params: { document: file }
        }.to change(Document, :count).by(1)
      end
      
      it "enqueues processing job" do
        expect {
          post :create, params: { document: file }
        }.to have_enqueued_job(DocumentProcessingJob)
      end
      
      it "creates usage record" do
        expect {
          post :create, params: { document: file }
        }.to change(UsageRecord, :count).by(1)
      end
    end
    
    context "when user is not authenticated" do
      it "returns 401 unauthorized" do
        post :create, params: { document: file }
        expect(response).to have_http_status(:unauthorized)
      end
    end
    
    context "when file exceeds size limit" do
      let(:user) { create(:user) }
      let(:large_file) { double("file", size: 60_000_000) }
      
      before { sign_in(user) }
      
      it "returns 422 with error message" do
        post :create, params: { document: large_file }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']['message']).to include('50MB')
      end
    end
  end
end
```

### 7.4 Frontend Testing

**Framework**: Vitest + React Testing Library

**Test Categories**:

1. **Component Tests**:
   - Rendering
   - User interactions
   - Props handling
   - State management

2. **Integration Tests**:
   - API calls (mocked)
   - Navigation flows
   - Form submissions

3. **E2E Tests** (Playwright):
   - Critical user journeys
   - Mobile responsive behavior
   - Cross-browser compatibility

**Example Frontend Test**:
```javascript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { DocumentUpload } from './DocumentUpload';

describe('DocumentUpload', () => {
  it('shows upload progress', async () => {
    const file = new File(['content'], 'test.pdf', { type: 'application/pdf' });
    
    render(<DocumentUpload />);
    
    const input = screen.getByLabelText(/upload/i);
    fireEvent.change(input, { target: { files: [file] } });
    
    const uploadButton = screen.getByRole('button', { name: /upload/i });
    fireEvent.click(uploadButton);
    
    await waitFor(() => {
      expect(screen.getByText(/\d+% uploaded/)).toBeInTheDocument();
    });
  });
  
  it('rejects files over 50MB', () => {
    const largeFile = new File(['x'.repeat(60_000_000)], 'large.pdf', { 
      type: 'application/pdf' 
    });
    
    render(<DocumentUpload />);
    
    const input = screen.getByLabelText(/upload/i);
    fireEvent.change(input, { target: { files: [largeFile] } });
    
    expect(screen.getByText(/exceeds 50MB/i)).toBeInTheDocument();
  });
});
```

### 7.5 Performance Testing

**Load Testing**:
- Tool: Apache JMeter or k6
- Scenarios:
  - 100 concurrent users uploading documents
  - 1000 concurrent API requests
  - Sustained load for 1 hour
- Success criteria: p95 latency < 500ms, 0% error rate

**Stress Testing**:
- Gradually increase load until system breaks
- Identify bottlenecks
- Verify graceful degradation

### 7.6 Security Testing

**Automated Security Scanning**:
- Brakeman (Rails security scanner)
- npm audit (frontend dependencies)
- OWASP ZAP (penetration testing)

**Manual Security Testing**:
- SQL injection attempts
- XSS attempts
- CSRF token validation
- Authentication bypass attempts
- Authorization bypass attempts

### 7.7 Continuous Integration

**CI Pipeline** (GitHub Actions):
```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
      
      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2
          bundler-cache: true
      
      - name: Set up Node
        uses: actions/setup-node@v3
        with:
          node-version: 18
          cache: 'npm'
          cache-dependency-path: frontend/package-lock.json
      
      - name: Install dependencies
        run: |
          bundle install
          cd frontend && npm ci
      
      - name: Run database migrations
        run: bundle exec rake db:create db:migrate
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test
      
      - name: Run backend tests
        run: bundle exec rspec
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test
          REDIS_URL: redis://localhost:6379/0
      
      - name: Run frontend tests
        run: cd frontend && npm test
      
      - name: Run security scan
        run: bundle exec brakeman -q -z
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

### 7.8 Test Data Generators

**Property Test Generators**:
```ruby
module Generators
  def gen_user
    RSpec::Propcheck::Generator.hash(
      email: gen_email,
      password: gen_password,
      tenant_id: gen_integer(min: 1, max: 1000)
    )
  end
  
  def gen_document
    RSpec::Propcheck::Generator.hash(
      filename: gen_filename,
      file_size: gen_integer(min: 1000, max: 50_000_000),
      extracted_text: gen_text(min_length: 100, max_length: 10000)
    )
  end
  
  def gen_email
    RSpec::Propcheck::Generator.string(:alphanumeric).map do |s|
      "#{s}@example.com"
    end
  end
  
  def gen_password
    # Generate passwords that meet strength requirements
    RSpec::Propcheck::Generator.tuple(
      gen_string(:alpha, min: 1, max: 3),  # uppercase
      gen_string(:alpha, min: 1, max: 3).map(&:downcase),  # lowercase
      gen_string(:numeric, min: 1, max: 2)  # numbers
    ).map { |parts| parts.join }
  end
  
  def gen_filename
    RSpec::Propcheck::Generator.string(:alphanumeric).map do |s|
      "#{s}.pdf"
    end
  end
end
```

## 8. Deployment Architecture

### 8.1 Infrastructure as Code

**Tool**: Terraform for infrastructure provisioning

**Resources**:
- VPC with public/private subnets
- Application Load Balancer
- ECS cluster with Fargate tasks
- RDS PostgreSQL instance
- ElastiCache Redis cluster
- S3 bucket for documents
- CloudFront CDN
- Route53 DNS
- ACM SSL certificates

### 8.2 Container Architecture

**Docker Images**:
- `legastream-api`: Rails API server
- `legastream-worker`: Sidekiq background workers
- `legastream-frontend`: Nginx serving React build

**Docker Compose** (Development):
```yaml
version: '3.8'

services:
  db:
    image: postgres:14
    environment:
      POSTGRES_PASSWORD: postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:7
    volumes:
      - redis_data:/data
  
  api:
    build:
      context: .
      dockerfile: Dockerfile.rails
    command: bundle exec puma -C config/puma.rb
    environment:
      DATABASE_URL: postgresql://postgres:postgres@db:5432/legastream_dev
      REDIS_URL: redis://redis:6379/0
      OPENAI_API_KEY: ${OPENAI_API_KEY}
    depends_on:
      - db
      - redis
    ports:
      - "3000:3000"
  
  worker:
    build:
      context: .
      dockerfile: Dockerfile.rails
    command: bundle exec sidekiq
    environment:
      DATABASE_URL: postgresql://postgres:postgres@db:5432/legastream_dev
      REDIS_URL: redis://redis:6379/0
      OPENAI_API_KEY: ${OPENAI_API_KEY}
    depends_on:
      - db
      - redis
  
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "5173:80"
    depends_on:
      - api

volumes:
  postgres_data:
  redis_data:
```

### 8.3 Deployment Pipeline

**Stages**:
1. **Build**: Compile code, run tests, build Docker images
2. **Push**: Push images to ECR/ACR
3. **Deploy to Staging**: Deploy to staging environment
4. **Smoke Tests**: Run critical path tests
5. **Deploy to Production**: Blue-green deployment
6. **Health Check**: Verify production health
7. **Rollback**: Automatic rollback on failure

**GitHub Actions Workflow**:
```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
      
      - name: Build and push API image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/legastream-api:$IMAGE_TAG -f Dockerfile.rails .
          docker push $ECR_REGISTRY/legastream-api:$IMAGE_TAG
      
      - name: Deploy to ECS
        run: |
          aws ecs update-service \
            --cluster legastream-prod \
            --service legastream-api \
            --force-new-deployment
```

### 8.4 Environment Configuration

**Environments**:
- **Development**: Local Docker Compose
- **Staging**: AWS ECS with smaller instances
- **Production**: AWS ECS with auto-scaling

**Environment Variables**:
```bash
# Database
DATABASE_URL=postgresql://user:pass@host:5432/dbname
REDIS_URL=redis://host:6379/0

# External Services
OPENAI_API_KEY=sk-...
STRIPE_SECRET_KEY=sk_live_...
SENDGRID_API_KEY=SG...

# AWS
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-1
S3_BUCKET=legastream-documents-prod

# Application
RAILS_ENV=production
SECRET_KEY_BASE=...
JWT_SECRET=...
FRONTEND_URL=https://app.legastream.com
API_URL=https://api.legastream.com

# Monitoring
SENTRY_DSN=https://...@sentry.io/...
DATADOG_API_KEY=...
```

### 8.5 Monitoring and Observability

**Application Monitoring**:
- DataDog APM for request tracing
- Custom metrics for business KPIs
- Log aggregation with CloudWatch Logs

**Alerts**:
- Error rate > 1% → PagerDuty
- p95 latency > 500ms → Slack
- Queue depth > 1000 → Email
- Disk usage > 80% → PagerDuty
- Failed deployments → Slack + Email

**Dashboards**:
- System health (CPU, memory, disk)
- Application metrics (requests/sec, latency, errors)
- Business metrics (uploads, analyses, active users)
- Cost tracking (AWS spend by service)

## 9. Migration Strategy

### 9.1 Data Migration

**Current State**: SQLite database with demo data

**Target State**: PostgreSQL with production data

**Migration Steps**:
1. Export existing data from SQLite
2. Transform data to match new schema
3. Import into PostgreSQL staging
4. Validate data integrity
5. Run migration in production
6. Verify all data migrated correctly

**Migration Script**:
```ruby
namespace :db do
  desc "Migrate from SQLite to PostgreSQL"
  task migrate_to_postgres: :environment do
    # Connect to both databases
    sqlite_db = SQLite3::Database.new('db/development.sqlite3')
    pg_db = ActiveRecord::Base.connection
    
    # Migrate tenants
    sqlite_db.execute("SELECT * FROM tenants") do |row|
      Tenant.create!(
        id: row[0],
        name: row[1],
        subdomain: row[2],
        created_at: row[3],
        updated_at: row[4]
      )
    end
    
    # Migrate users
    sqlite_db.execute("SELECT * FROM users") do |row|
      User.create!(
        id: row[0],
        tenant_id: row[1],
        email: row[2],
        password_digest: row[3],
        created_at: row[4],
        updated_at: row[5]
      )
    end
    
    # Migrate documents
    sqlite_db.execute("SELECT * FROM documents") do |row|
      Document.create!(
        id: row[0],
        tenant_id: row[1],
        user_id: row[2],
        filename: row[3],
        file_path: row[4],
        created_at: row[5],
        updated_at: row[6]
      )
    end
    
    puts "Migration complete!"
  end
end
```

### 9.2 File Storage Migration

**Current State**: Local file system

**Target State**: AWS S3

**Migration Steps**:
1. Upload all existing files to S3
2. Update file_path in database to S3 URLs
3. Verify all files accessible
4. Delete local files

**Migration Script**:
```ruby
namespace :storage do
  desc "Migrate files to S3"
  task migrate_to_s3: :environment do
    s3 = Aws::S3::Client.new(region: ENV['AWS_REGION'])
    bucket = ENV['S3_BUCKET']
    
    Document.find_each do |doc|
      next unless File.exist?(doc.file_path)
      
      # Upload to S3
      key = "documents/#{doc.tenant_id}/#{doc.id}/#{doc.filename}"
      File.open(doc.file_path, 'rb') do |file|
        s3.put_object(
          bucket: bucket,
          key: key,
          body: file,
          server_side_encryption: 'AES256'
        )
      end
      
      # Update database
      doc.update!(file_path: "s3://#{bucket}/#{key}")
      
      puts "Migrated #{doc.filename}"
    end
    
    puts "Migration complete!"
  end
end
```

### 9.3 Zero-Downtime Deployment

**Strategy**: Blue-Green Deployment

**Process**:
1. Deploy new version to "green" environment
2. Run smoke tests on green
3. Switch load balancer to green
4. Monitor for errors
5. Keep blue running for 1 hour (rollback window)
6. Shut down blue if no issues

**Rollback Plan**:
- Switch load balancer back to blue
- Investigate issues in green
- Fix and redeploy

## 10. Cost Optimization

### 10.1 Cost Breakdown (Estimated)

**Monthly Costs** (1000 active users):
- **Compute**: $500 (ECS Fargate)
- **Database**: $200 (RDS PostgreSQL)
- **Storage**: $100 (S3 + backups)
- **CDN**: $50 (CloudFront)
- **OpenAI API**: $1000 (10,000 documents @ $0.10 each)
- **Monitoring**: $100 (DataDog + Sentry)
- **Email**: $50 (SendGrid)
- **Total**: ~$2000/month

**Revenue** (1000 users, 10% conversion):
- 100 paying users × $29/month = $2900/month
- **Gross Margin**: 31%

### 10.2 Cost Optimization Strategies

**OpenAI API Costs**:
- Cache analysis results (never re-analyze same document)
- Use GPT-3.5-turbo instead of GPT-4 (10x cheaper)
- Batch requests when possible
- Implement rate limiting to prevent abuse

**Compute Costs**:
- Use spot instances for non-critical workers
- Auto-scale down during off-hours
- Right-size instances based on actual usage

**Storage Costs**:
- Implement lifecycle policies (move old documents to Glacier)
- Compress documents before storage
- Delete documents after retention period

**Database Costs**:
- Use read replicas only when needed
- Implement connection pooling
- Archive old data to cold storage

## 11. Future Enhancements

### 11.1 Phase 2 Features

**Advanced AI Features**:
- Custom entity types (user-defined)
- Document comparison
- Batch analysis
- AI-powered search

**Collaboration Features**:
- Share documents with team members
- Comments and annotations
- Version history
- Real-time collaboration

**Enterprise Features**:
- SSO (SAML, OAuth)
- Advanced RBAC
- Audit log export
- Custom retention policies
- On-premise deployment option

### 11.2 Technical Improvements

**Performance**:
- GraphQL API for flexible queries
- WebSocket for real-time updates
- Edge caching for global users
- Database sharding for scale

**Mobile**:
- Native iOS app
- Native Android app
- Offline mode
- Push notifications

**AI/ML**:
- Fine-tuned models for legal domain
- Custom NER models
- Document classification
- Sentiment analysis

## 12. Conclusion

This design document provides a comprehensive blueprint for transforming LegaStream from a demo application into a production-ready SaaS platform. The architecture is designed to be:

- **Scalable**: Can handle 10x growth without major changes
- **Secure**: Multi-layer security with encryption and isolation
- **Cost-Effective**: Optimized for profitability at scale
- **Maintainable**: Clean architecture with clear separation of concerns
- **Testable**: Comprehensive testing strategy with property-based tests

The next step is to break this design down into actionable implementation tasks in the tasks.md file.

# 📡 Legal Auditor Agent - API Documentation

## RESTful API Reference

Base URL: `https://legastream.onrender.com/api/v1`

---

## 🔐 Authentication

All API requests require authentication using JWT tokens.

### Register
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "user": {
    "email": "lawyer@lawfirm.com",
    "password": "SecurePass123",
    "first_name": "John",
    "last_name": "Doe"
  }
}
```

**Response** (201 Created):
```json
{
  "message": "Registration successful!",
  "user": {
    "id": 1,
    "email": "lawyer@lawfirm.com",
    "first_name": "John",
    "last_name": "Doe",
    "full_name": "John Doe",
    "role": "user",
    "email_confirmed": true
  }
}
```

### Login
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "lawyer@lawfirm.com",
  "password": "SecurePass123"
}
```

**Response** (200 OK):
```json
{
  "token": "legastream_token_1_1234567890",
  "user": {
    "id": 1,
    "email": "lawyer@lawfirm.com",
    "first_name": "John",
    "last_name": "Doe",
    "full_name": "John Doe",
    "role": "user",
    "email_confirmed": true
  },
  "message": "Login successful"
}
```

### Using the Token
Include the token in the Authorization header for all subsequent requests:
```http
Authorization: Bearer legastream_token_1_1234567890
```

---

## 📄 Documents

### Upload Document
```http
POST /api/v1/documents
Authorization: Bearer {token}
Content-Type: multipart/form-data

file: [PDF file]
```

**Response** (200 OK):
```json
{
  "id": 42,
  "filename": "employment_contract.pdf",
  "status": "uploaded",
  "message": "Document uploaded successfully and analysis started automatically"
}
```

### List Documents
```http
GET /api/v1/documents
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "documents": [
    {
      "id": 42,
      "filename": "employment_contract.pdf",
      "original_filename": "employment_contract.pdf",
      "status": "completed",
      "file_size": 245678,
      "content_type": "application/pdf",
      "created_at": "2026-02-22T10:30:00Z",
      "updated_at": "2026-02-22T10:30:45Z",
      "analysis_results": {
        "document_type": "Employment Contract",
        "parties": ["Acme Corp", "John Smith"],
        "compliance_score": 92,
        "risk_level": "LOW"
      }
    }
  ],
  "total": 1,
  "processing": 0,
  "completed": 1
}
```

### Get Document Details
```http
GET /api/v1/documents/:id
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "id": 42,
  "filename": "employment_contract.pdf",
  "original_filename": "employment_contract.pdf",
  "status": "completed",
  "file_size": 245678,
  "content_type": "application/pdf",
  "created_at": "2026-02-22T10:30:00Z",
  "updated_at": "2026-02-22T10:30:45Z",
  "analysis_results": {
    "document_type": "Employment Contract",
    "parties": ["Acme Corp", "John Smith"],
    "key_dates": [
      {"date": "2026-03-01", "context": "Start date"}
    ],
    "obligations": [
      "Employee shall perform duties diligently",
      "Employer shall pay salary monthly"
    ],
    "compliance_score": 92,
    "risk_level": "LOW",
    "risk_issues": [],
    "completeness": 95,
    "recommendations": [
      "Consider adding explicit termination clause"
    ]
  }
}
```

### Get Document Entities
```http
GET /api/v1/documents/:id/entities
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "document_id": 42,
  "total_entities": 25,
  "entities_by_type": {
    "PARTY": 5,
    "ADDRESS": 3,
    "DATE": 4,
    "AMOUNT": 2,
    "OBLIGATION": 6,
    "CLAUSE": 3,
    "JURISDICTION": 1,
    "TERM": 1
  },
  "entities": [
    {
      "id": 1,
      "entity_type": "PARTY",
      "entity_value": "Acme Corporation",
      "context": "...party of the first part, Acme Corporation, hereby agrees...",
      "confidence": 0.98,
      "created_at": "2026-02-22T10:30:45Z"
    },
    {
      "id": 2,
      "entity_type": "ADDRESS",
      "entity_value": "123 Main Street, New York, NY 10001",
      "context": "...with offices located at 123 Main Street, New York, NY 10001...",
      "confidence": 0.95,
      "created_at": "2026-02-22T10:30:45Z"
    }
  ]
}
```

### Trigger Analysis
```http
POST /api/v1/documents/:id/analyze
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "document_id": 42,
  "status": "analysis_started",
  "message": "AI analysis has been initiated. Check back in a few moments for results."
}
```

### Delete Document
```http
DELETE /api/v1/documents/:id
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "message": "Document deleted successfully"
}
```

---

## 📊 Statistics

### Get Dashboard Stats
```http
GET /api/v1/stats
Authorization: Bearer {token}
```

**Response** (200 OK):
```json
{
  "documents_processed": 42,
  "processing_time_saved": "105h",
  "ai_accuracy_rate": "98.7%",
  "issues_flagged": 15,
  "system_status": {
    "ai_engine": "operational",
    "document_processing": "idle",
    "security_sandbox": "secure",
    "live_terminal": "streaming"
  },
  "usage_stats": {
    "tokens_used": 2345678,
    "tokens_limit": 3500000,
    "usage_percentage": 67
  }
}
```

---

## 🏥 Health Check

### System Health
```http
GET /up
```

**Response** (200 OK):
```json
{
  "status": "ok",
  "timestamp": "2026-02-22T10:30:00Z",
  "version": "3.0.0",
  "services": {
    "backend": "running",
    "database": "connected",
    "email": "configured",
    "storage": "available"
  }
}
```

---

## ❌ Error Responses

### 400 Bad Request
```json
{
  "error": {
    "code": "BAD_REQUEST",
    "message": "Invalid JSON data",
    "timestamp": "2026-02-22T10:30:00Z"
  }
}
```

### 401 Unauthorized
```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Authentication required",
    "timestamp": "2026-02-22T10:30:00Z"
  }
}
```

### 404 Not Found
```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Document not found or access denied",
    "timestamp": "2026-02-22T10:30:00Z"
  }
}
```

### 422 Unprocessable Entity
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": ["Email is required", "Password must be at least 6 characters"],
    "timestamp": "2026-02-22T10:30:00Z"
  }
}
```

### 500 Internal Server Error
```json
{
  "error": {
    "code": "INTERNAL_SERVER_ERROR",
    "message": "An unexpected error occurred",
    "request_id": "req_abc123def456",
    "timestamp": "2026-02-22T10:30:00Z"
  }
}
```

---

## 📝 Rate Limiting

- **Free Tier**: 100 requests/hour
- **Professional**: 1,000 requests/hour
- **Enterprise**: Unlimited

Rate limit headers:
```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1645531200
```

---

## 🔒 Security Headers

All responses include security headers:
```http
X-Frame-Options: DENY
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Strict-Transport-Security: max-age=31536000
Content-Security-Policy: default-src 'self'
```

---

## 📚 SDKs & Libraries

### JavaScript/TypeScript
```javascript
import { LegalAuditorClient } from '@legalauditor/sdk';

const client = new LegalAuditorClient({
  apiKey: 'your_api_key',
  baseURL: 'https://legastream.onrender.com/api/v1'
});

// Upload document
const document = await client.documents.upload(file);

// Get entities
const entities = await client.documents.getEntities(document.id);

// Analyze
const analysis = await client.documents.analyze(document.id);
```

### Python
```python
from legalauditor import Client

client = Client(
    api_key='your_api_key',
    base_url='https://legastream.onrender.com/api/v1'
)

# Upload document
document = client.documents.upload('contract.pdf')

# Get entities
entities = client.documents.get_entities(document.id)

# Analyze
analysis = client.documents.analyze(document.id)
```

### Ruby
```ruby
require 'legalauditor'

client = LegalAuditor::Client.new(
  api_key: 'your_api_key',
  base_url: 'https://legastream.onrender.com/api/v1'
)

# Upload document
document = client.documents.upload('contract.pdf')

# Get entities
entities = client.documents.get_entities(document.id)

# Analyze
analysis = client.documents.analyze(document.id)
```

---

## 🧪 Testing

### Postman Collection
Download our Postman collection: [Legal Auditor API.postman_collection.json](postman/collection.json)

### cURL Examples

**Register**:
```bash
curl -X POST https://legastream.onrender.com/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"test@example.com","password":"password123","first_name":"Test","last_name":"User"}}'
```

**Login**:
```bash
curl -X POST https://legastream.onrender.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

**Upload Document**:
```bash
curl -X POST https://legastream.onrender.com/api/v1/documents \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@contract.pdf"
```

**Get Documents**:
```bash
curl -X GET https://legastream.onrender.com/api/v1/documents \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## 📞 Support

- **Documentation**: https://docs.legalauditor.com
- **API Status**: https://status.legalauditor.com
- **GitHub Issues**: https://github.com/mssnbgac/LegaStream/issues
- **Email**: api@legalauditor.com

---

## 📄 License

API access is subject to our [Terms of Service](https://legalauditor.com/terms) and [Privacy Policy](https://legalauditor.com/privacy).

---

<div align="center">

### ⚖️ Legal Auditor Agent API

**Version 3.0.0** | **Last Updated: February 2026**

</div>

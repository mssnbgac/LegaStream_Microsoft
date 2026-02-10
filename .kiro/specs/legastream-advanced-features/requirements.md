# LegaStream Advanced Features - Requirements

## Overview
This spec covers the implementation of four major feature sets to transform LegaStream from a document management system into a full-featured AI-powered legal discovery platform.

---

## Feature 1: Real AI Analysis

### User Stories

**US-1.1: As a lawyer, I want to upload a legal document and have it analyzed by real AI so that I can get accurate insights quickly**
- Upload document (PDF, DOCX, TXT)
- AI extracts text content
- AI identifies legal entities (people, companies, dates, locations, case citations)
- AI flags potential issues and risks
- AI generates compliance score
- AI provides confidence rating
- Results displayed in under 60 seconds

**US-1.2: As a lawyer, I want to see what the AI is thinking in real-time so that I can trust its analysis**
- Live terminal shows AI reasoning steps
- Chain-of-thought displayed as it happens
- Tool usage logged (search, extraction, analysis)
- Warnings and errors shown immediately
- Progress percentage displayed

**US-1.3: As a lawyer, I want AI to identify specific legal entities so that I can quickly understand document contents**
- Extract person names with roles
- Extract company/organization names
- Extract dates and deadlines
- Extract monetary amounts
- Extract case citations and legal references
- Extract locations and jurisdictions
- Categorize entities by type

**US-1.4: As a lawyer, I want AI to flag compliance issues so that I can address them proactively**
- GDPR compliance checking
- Contract clause analysis
- Missing signature detection
- Ambiguous terms identification
- Regulatory compliance verification
- Risk level assessment (Low/Medium/High)

**US-1.5: As a lawyer, I want to configure AI analysis settings so that I can customize it for my needs**
- Choose AI model (GPT-4, GPT-3.5, Claude, etc.)
- Set analysis depth (quick, standard, deep)
- Enable/disable specific checks
- Set confidence thresholds
- Configure entity types to extract

### Acceptance Criteria

**AC-1.1: Document Text Extraction**
- ✅ PDF text extraction works for standard PDFs
- ✅ DOCX text extraction preserves formatting
- ✅ TXT files processed correctly
- ✅ OCR for scanned PDFs (optional)
- ✅ Handles documents up to 500 pages

**AC-1.2: Entity Extraction**
- ✅ Extracts person names with 90%+ accuracy
- ✅ Extracts company names with 90%+ accuracy
- ✅ Extracts dates with 95%+ accuracy
- ✅ Extracts monetary amounts with 95%+ accuracy
- ✅ Extracts case citations correctly
- ✅ Categorizes entities by type

**AC-1.3: Compliance Analysis**
- ✅ Identifies GDPR-related clauses
- ✅ Flags missing required elements
- ✅ Detects ambiguous language
- ✅ Assesses overall compliance score
- ✅ Provides specific recommendations

**AC-1.4: Performance**
- ✅ Analysis completes in under 60 seconds for 50-page document
- ✅ Handles concurrent analysis of multiple documents
- ✅ Graceful error handling for API failures
- ✅ Retry logic for transient failures

**AC-1.5: Real-time Updates**
- ✅ Live terminal updates every 500ms
- ✅ Progress bar shows completion percentage
- ✅ WebSocket connection for real-time streaming
- ✅ Fallback to polling if WebSocket unavailable

### Technical Requirements

**TR-1.1: AI Integration**
- Use OpenAI API (GPT-4 or GPT-3.5-turbo)
- Alternative: Anthropic Claude API
- Implement Langchain.rb for orchestration
- Store API keys securely in environment variables
- Implement rate limiting and cost tracking

**TR-1.2: Document Processing**
- Use `pdf-reader` gem for PDF extraction
- Use `docx` gem for DOCX extraction
- Store extracted text in database
- Cache extraction results
- Handle encoding issues gracefully

**TR-1.3: Database Schema**
```sql
-- Add to documents table
ALTER TABLE documents ADD COLUMN extracted_text TEXT;
ALTER TABLE documents ADD COLUMN analysis_results JSON;
ALTER TABLE documents ADD COLUMN ai_model VARCHAR(50);
ALTER TABLE documents ADD COLUMN analysis_duration INTEGER;

-- Create entities table
CREATE TABLE entities (
  id INTEGER PRIMARY KEY,
  document_id INTEGER,
  entity_type VARCHAR(50),
  entity_value TEXT,
  confidence FLOAT,
  context TEXT,
  created_at TIMESTAMP
);

-- Create analysis_logs table
CREATE TABLE analysis_logs (
  id INTEGER PRIMARY KEY,
  document_id INTEGER,
  step_number INTEGER,
  step_type VARCHAR(50),
  message TEXT,
  timestamp TIMESTAMP
);
```

**TR-1.4: API Endpoints**
```
POST /api/v1/documents/:id/analyze
  - Triggers AI analysis
  - Returns job ID

GET /api/v1/documents/:id/analysis
  - Returns analysis results
  - Includes entities, issues, scores

GET /api/v1/documents/:id/analysis/stream
  - WebSocket endpoint for live updates
  - Streams analysis progress

GET /api/v1/documents/:id/entities
  - Returns extracted entities
  - Supports filtering by type
```

---

## Feature 2: Advanced Search

### User Stories

**US-2.1: As a lawyer, I want to search across all documents so that I can find relevant information quickly**
- Full-text search across all documents
- Search in document names, content, and metadata
- Highlight search terms in results
- Sort by relevance, date, or name
- Paginated results

**US-2.2: As a lawyer, I want to filter documents by various criteria so that I can narrow down results**
- Filter by date range (uploaded, analyzed)
- Filter by status (uploaded, processing, completed, error)
- Filter by document type (PDF, DOCX, TXT)
- Filter by analysis results (risk level, compliance score)
- Filter by extracted entities (person, company, date)
- Combine multiple filters

**US-2.3: As a lawyer, I want to search for specific entities so that I can find all documents mentioning them**
- Search by person name
- Search by company name
- Search by date range
- Search by case citation
- Search by location
- View all documents containing entity

**US-2.4: As a lawyer, I want to save my searches so that I can reuse them later**
- Save search criteria with name
- Load saved searches
- Edit saved searches
- Delete saved searches
- Share saved searches with team

**US-2.5: As a lawyer, I want search suggestions so that I can find what I'm looking for faster**
- Auto-complete for entity names
- Recent searches displayed
- Popular searches suggested
- Typo correction
- Related search suggestions

### Acceptance Criteria

**AC-2.1: Search Functionality**
- ✅ Full-text search returns relevant results
- ✅ Search works across document names and content
- ✅ Results returned in under 2 seconds
- ✅ Handles special characters and punctuation
- ✅ Case-insensitive search

**AC-2.2: Filtering**
- ✅ Multiple filters can be applied simultaneously
- ✅ Filters update results immediately
- ✅ Filter counts shown (e.g., "PDF (23)")
- ✅ Clear all filters button works
- ✅ Filter state persists during session

**AC-2.3: Entity Search**
- ✅ Entity search returns all matching documents
- ✅ Entity type filter works correctly
- ✅ Entity search supports partial matches
- ✅ Results show entity context (surrounding text)

**AC-2.4: Saved Searches**
- ✅ Searches saved to database
- ✅ Saved searches load correctly
- ✅ Can edit and update saved searches
- ✅ Can delete saved searches
- ✅ Saved searches private to user

**AC-2.5: Performance**
- ✅ Search results load in under 2 seconds
- ✅ Handles 10,000+ documents efficiently
- ✅ Auto-complete responds in under 500ms
- ✅ No UI lag during typing

### Technical Requirements

**TR-2.1: Search Implementation**
- Use SQLite FTS5 (Full-Text Search) extension
- Index document names, extracted text, and metadata
- Implement ranking algorithm for relevance
- Support phrase search with quotes
- Support boolean operators (AND, OR, NOT)

**TR-2.2: Database Schema**
```sql
-- Create FTS5 virtual table
CREATE VIRTUAL TABLE documents_fts USING fts5(
  document_id,
  filename,
  extracted_text,
  content='documents'
);

-- Create saved searches table
CREATE TABLE saved_searches (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  name VARCHAR(255),
  search_query TEXT,
  filters JSON,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Create search history table
CREATE TABLE search_history (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  search_query TEXT,
  results_count INTEGER,
  created_at TIMESTAMP
);
```

**TR-2.3: API Endpoints**
```
GET /api/v1/search
  - Query params: q, filters, page, per_page, sort
  - Returns: documents, total, page info

GET /api/v1/search/entities
  - Query params: entity_type, entity_value
  - Returns: documents containing entity

POST /api/v1/search/save
  - Body: name, query, filters
  - Saves search for later use

GET /api/v1/search/saved
  - Returns: user's saved searches

GET /api/v1/search/suggestions
  - Query params: q
  - Returns: auto-complete suggestions
```

---

## Feature 3: Collaboration Tools

### User Stories

**US-3.1: As a lawyer, I want to share documents with my team so that we can collaborate on analysis**
- Share document with specific users
- Set permissions (view, comment, edit)
- Revoke access when needed
- See who has access to document
- Receive notification when shared

**US-3.2: As a lawyer, I want to add comments to documents so that I can discuss findings with my team**
- Add comment to specific section of document
- Reply to comments (threaded discussions)
- Mention team members with @username
- Edit and delete my comments
- Mark comments as resolved
- Receive notifications for mentions and replies

**US-3.3: As a lawyer, I want to assign tasks related to documents so that work gets done**
- Create task with title, description, due date
- Assign task to team member
- Set task priority (Low, Medium, High)
- Track task status (To Do, In Progress, Done)
- Receive notifications for assigned tasks
- View all my tasks in one place

**US-3.4: As a lawyer, I want to see document activity history so that I know what happened**
- View who uploaded document
- View who analyzed document
- View who shared document
- View all comments and changes
- Filter activity by user or date
- Export activity log

**US-3.5: As a lawyer, I want to create document collections so that I can organize related documents**
- Create collection with name and description
- Add documents to collection
- Remove documents from collection
- Share entire collection with team
- View all documents in collection
- Search within collection

### Acceptance Criteria

**AC-3.1: Document Sharing**
- ✅ Can share document with multiple users
- ✅ Permissions enforced correctly
- ✅ Shared users receive email notification
- ✅ Can revoke access immediately
- ✅ Shared documents appear in recipient's list

**AC-3.2: Comments**
- ✅ Comments saved and displayed correctly
- ✅ Threaded replies work properly
- ✅ @mentions trigger notifications
- ✅ Can edit own comments within 5 minutes
- ✅ Can delete own comments anytime
- ✅ Resolved comments hidden by default

**AC-3.3: Tasks**
- ✅ Tasks created and assigned successfully
- ✅ Assignee receives email notification
- ✅ Task status updates reflected immediately
- ✅ Overdue tasks highlighted
- ✅ Can filter tasks by status, priority, assignee

**AC-3.4: Activity History**
- ✅ All actions logged with timestamp
- ✅ Activity feed updates in real-time
- ✅ Can filter by action type
- ✅ Can export as CSV or PDF
- ✅ Shows user avatars and names

**AC-3.5: Collections**
- ✅ Collections created and managed easily
- ✅ Documents can belong to multiple collections
- ✅ Collection sharing works like document sharing
- ✅ Can search and filter within collection
- ✅ Collection stats displayed (doc count, size)

### Technical Requirements

**TR-3.1: Database Schema**
```sql
-- Create document_shares table
CREATE TABLE document_shares (
  id INTEGER PRIMARY KEY,
  document_id INTEGER,
  shared_by_user_id INTEGER,
  shared_with_user_id INTEGER,
  permission VARCHAR(20), -- view, comment, edit
  created_at TIMESTAMP
);

-- Create comments table
CREATE TABLE comments (
  id INTEGER PRIMARY KEY,
  document_id INTEGER,
  user_id INTEGER,
  parent_comment_id INTEGER,
  content TEXT,
  is_resolved BOOLEAN DEFAULT 0,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Create tasks table
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY,
  document_id INTEGER,
  created_by_user_id INTEGER,
  assigned_to_user_id INTEGER,
  title VARCHAR(255),
  description TEXT,
  priority VARCHAR(20), -- low, medium, high
  status VARCHAR(20), -- todo, in_progress, done
  due_date DATE,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Create activity_logs table
CREATE TABLE activity_logs (
  id INTEGER PRIMARY KEY,
  document_id INTEGER,
  user_id INTEGER,
  action VARCHAR(50),
  details JSON,
  created_at TIMESTAMP
);

-- Create collections table
CREATE TABLE collections (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  name VARCHAR(255),
  description TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Create collection_documents table
CREATE TABLE collection_documents (
  id INTEGER PRIMARY KEY,
  collection_id INTEGER,
  document_id INTEGER,
  added_at TIMESTAMP
);
```

**TR-3.2: API Endpoints**
```
POST /api/v1/documents/:id/share
  - Body: user_id, permission
  - Shares document with user

GET /api/v1/documents/:id/shares
  - Returns: list of users with access

POST /api/v1/documents/:id/comments
  - Body: content, parent_comment_id
  - Creates comment

GET /api/v1/documents/:id/comments
  - Returns: all comments (threaded)

POST /api/v1/documents/:id/tasks
  - Body: title, description, assigned_to, due_date, priority
  - Creates task

GET /api/v1/tasks
  - Query params: status, priority, assigned_to
  - Returns: filtered tasks

GET /api/v1/documents/:id/activity
  - Returns: activity history

POST /api/v1/collections
  - Body: name, description
  - Creates collection

POST /api/v1/collections/:id/documents
  - Body: document_id
  - Adds document to collection
```

**TR-3.3: Real-time Updates**
- Implement WebSocket for real-time comments
- Push notifications for mentions and assignments
- Live activity feed updates
- Presence indicators (who's viewing document)

---

## Feature 4: Reporting Features

### User Stories

**US-4.1: As a lawyer, I want to generate a PDF report of document analysis so that I can share it with clients**
- Select document(s) for report
- Choose report template (summary, detailed, executive)
- Include/exclude sections (entities, issues, recommendations)
- Add custom notes and observations
- Generate professional PDF with firm branding
- Download or email report

**US-4.2: As a lawyer, I want to export analysis data so that I can use it in other tools**
- Export to CSV (entities, issues, metadata)
- Export to JSON (full analysis results)
- Export to Excel (formatted tables)
- Bulk export multiple documents
- Schedule automated exports

**US-4.3: As a lawyer, I want to create custom report templates so that reports match my firm's style**
- Create template with custom sections
- Add firm logo and branding
- Define header and footer
- Choose fonts and colors
- Save template for reuse
- Share templates with team

**US-4.4: As a lawyer, I want to see analytics dashboards so that I can track discovery progress**
- Documents processed over time (chart)
- Average analysis time (metric)
- Most common issues found (chart)
- Entity distribution (chart)
- Compliance scores distribution (chart)
- User activity metrics
- Cost tracking (API usage)

**US-4.5: As a lawyer, I want to compare multiple documents so that I can identify patterns**
- Select 2-10 documents to compare
- Side-by-side comparison view
- Highlight differences and similarities
- Compare entities across documents
- Compare compliance scores
- Generate comparison report

### Acceptance Criteria

**AC-4.1: PDF Reports**
- ✅ PDF generated in under 10 seconds
- ✅ Professional formatting and layout
- ✅ Includes all selected sections
- ✅ Firm branding applied correctly
- ✅ Charts and tables render properly
- ✅ File size under 5MB for typical report

**AC-4.2: Data Export**
- ✅ CSV export includes all relevant fields
- ✅ JSON export is valid and complete
- ✅ Excel export has proper formatting
- ✅ Bulk export handles 100+ documents
- ✅ Export completes in under 30 seconds

**AC-4.3: Custom Templates**
- ✅ Template editor is intuitive
- ✅ Preview shows accurate representation
- ✅ Templates saved and loaded correctly
- ✅ Branding elements applied properly
- ✅ Can duplicate and modify templates

**AC-4.4: Analytics Dashboard**
- ✅ Charts load in under 3 seconds
- ✅ Data updates in real-time
- ✅ Can filter by date range
- ✅ Can export dashboard as PDF
- ✅ Responsive design for mobile

**AC-4.5: Document Comparison**
- ✅ Comparison view loads quickly
- ✅ Differences highlighted clearly
- ✅ Can compare up to 10 documents
- ✅ Comparison report generated successfully
- ✅ Export comparison results

### Technical Requirements

**TR-4.1: PDF Generation**
- Use `prawn` gem for PDF generation
- Use `gruff` gem for charts
- Support custom fonts and styling
- Implement page templates
- Add watermarking capability

**TR-4.2: Data Export**
- Use `csv` library for CSV export
- Use `json` library for JSON export
- Use `rubyXL` or `axlsx` for Excel export
- Implement streaming for large exports
- Add compression for bulk exports

**TR-4.3: Database Schema**
```sql
-- Create report_templates table
CREATE TABLE report_templates (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  name VARCHAR(255),
  template_type VARCHAR(50),
  sections JSON,
  branding JSON,
  is_shared BOOLEAN DEFAULT 0,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Create generated_reports table
CREATE TABLE generated_reports (
  id INTEGER PRIMARY KEY,
  user_id INTEGER,
  template_id INTEGER,
  document_ids JSON,
  file_path VARCHAR(500),
  file_size INTEGER,
  created_at TIMESTAMP
);

-- Create analytics_snapshots table
CREATE TABLE analytics_snapshots (
  id INTEGER PRIMARY KEY,
  snapshot_date DATE,
  metrics JSON,
  created_at TIMESTAMP
);
```

**TR-4.4: API Endpoints**
```
POST /api/v1/reports/generate
  - Body: document_ids, template_id, options
  - Returns: report_id, download_url

GET /api/v1/reports/:id/download
  - Returns: PDF file

POST /api/v1/export
  - Body: document_ids, format (csv, json, excel)
  - Returns: download_url

GET /api/v1/analytics/dashboard
  - Query params: date_from, date_to
  - Returns: metrics and chart data

POST /api/v1/reports/compare
  - Body: document_ids
  - Returns: comparison data

POST /api/v1/report-templates
  - Body: name, sections, branding
  - Creates custom template
```

---

## Implementation Priority

### Phase 1: Real AI Analysis (Weeks 1-2)
**Priority: CRITICAL**
- Most important feature for product value
- Enables all other features
- Immediate user impact

**Tasks:**
1. Set up OpenAI API integration
2. Implement document text extraction
3. Build AI analysis pipeline
4. Create entity extraction
5. Add compliance checking
6. Implement real-time streaming
7. Update database schema
8. Build API endpoints
9. Update frontend UI
10. Test and optimize

### Phase 2: Advanced Search (Week 3)
**Priority: HIGH**
- Enables users to find information quickly
- Builds on AI analysis results
- Relatively straightforward to implement

**Tasks:**
1. Set up FTS5 search
2. Build search API
3. Create search UI
4. Implement filters
5. Add entity search
6. Build saved searches
7. Add auto-complete
8. Test performance

### Phase 3: Reporting Features (Week 4)
**Priority: HIGH**
- Delivers value to clients
- Showcases AI analysis results
- Professional presentation

**Tasks:**
1. Set up PDF generation
2. Create report templates
3. Build export functionality
4. Create analytics dashboard
5. Implement comparison feature
6. Build template editor
7. Test report generation

### Phase 4: Collaboration Tools (Weeks 5-6)
**Priority: MEDIUM**
- Enhances team productivity
- More complex to implement
- Can be rolled out incrementally

**Tasks:**
1. Build sharing system
2. Implement comments
3. Create tasks feature
4. Build activity logs
5. Create collections
6. Set up WebSocket
7. Build notifications
8. Test collaboration features

---

## Success Metrics

### Real AI Analysis
- ✅ 95%+ entity extraction accuracy
- ✅ Analysis completes in under 60 seconds
- ✅ 90%+ user satisfaction with results
- ✅ API costs under $0.10 per document

### Advanced Search
- ✅ Search results in under 2 seconds
- ✅ 80%+ of searches return relevant results
- ✅ Users save 50%+ time finding documents
- ✅ 50%+ of users use saved searches

### Collaboration Tools
- ✅ 70%+ of documents shared with team
- ✅ Average 5+ comments per document
- ✅ 80%+ of tasks completed on time
- ✅ 90%+ user satisfaction with collaboration

### Reporting Features
- ✅ 80%+ of users generate reports
- ✅ Average 3+ reports per user per week
- ✅ Report generation under 10 seconds
- ✅ 90%+ user satisfaction with reports

---

## Risk Assessment

### Technical Risks
- **AI API Costs**: Could be expensive at scale
  - Mitigation: Implement caching, use cheaper models for simple tasks
- **Performance**: Large documents may be slow
  - Mitigation: Implement chunking, background processing
- **API Rate Limits**: OpenAI has rate limits
  - Mitigation: Implement queuing, retry logic

### Business Risks
- **User Adoption**: Users may not trust AI
  - Mitigation: Show confidence scores, allow manual review
- **Competition**: Other tools may have similar features
  - Mitigation: Focus on legal-specific features, better UX
- **Compliance**: Legal industry has strict requirements
  - Mitigation: Ensure data security, add audit trails

---

## Dependencies

### External Services
- OpenAI API (or Anthropic Claude)
- Email service (already configured)
- File storage (local or S3)

### Ruby Gems
- `pdf-reader` - PDF text extraction
- `docx` - DOCX text extraction
- `prawn` - PDF generation
- `gruff` - Chart generation
- `ruby-openai` - OpenAI API client
- `langchainrb` - AI orchestration
- `faye-websocket` - WebSocket support

### Frontend Libraries
- `react-pdf` - PDF viewing
- `recharts` - Charts and graphs
- `react-markdown` - Markdown rendering
- `socket.io-client` - WebSocket client

---

## Next Steps

1. **Review and approve this requirements document**
2. **Create detailed design document**
3. **Set up development environment with AI API keys**
4. **Begin Phase 1: Real AI Analysis implementation**
5. **Create task breakdown for each phase**
6. **Set up project tracking and milestones**

---

**Document Status**: Draft for Review
**Last Updated**: 2026-02-06
**Author**: Kiro AI Assistant
**Reviewers**: Development Team, Product Owner

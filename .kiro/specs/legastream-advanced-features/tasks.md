# LegaStream Advanced Features - Implementation Tasks

## Overview
This document breaks down the implementation of advanced features into actionable tasks with clear acceptance criteria and estimated effort.

---

## Phase 1: Real AI Analysis (Priority: CRITICAL)

### Task 1.1: Set Up AI Infrastructure
**Estimated Time**: 4 hours
**Dependencies**: None

**Subtasks:**
- [ ] Install required gems (`ruby-openai`, `pdf-reader`, `docx`, `langchainrb`)
- [ ] Add OpenAI API key to `.env` file
- [ ] Create `AIAnalysisService` class structure
- [ ] Set up error handling and logging
- [ ] Create test OpenAI connection script

**Acceptance Criteria:**
- ✅ Can successfully call OpenAI API
- ✅ API key loaded from environment
- ✅ Error handling works for API failures
- ✅ Logging captures all API calls

**Files to Create/Modify:**
- `Gemfile` - Add new gems
- `.env` - Add OPENAI_API_KEY
- `app/services/ai_analysis_service.rb` - New file
- `app/services/analysis_logger.rb` - New file

---

### Task 1.2: Implement Text Extraction
**Estimated Time**: 6 hours
**Dependencies**: Task 1.1

**Subtasks:**
- [ ] Create `TextExtractionService` class
- [ ] Implement PDF text extraction using `pdf-reader`
- [ ] Implement DOCX text extraction using `docx`
- [ ] Handle TXT files
- [ ] Add error handling for corrupted files
- [ ] Store extracted text in database
- [ ] Add text length validation

**Acceptance Criteria:**
- ✅ PDF extraction works for standard PDFs
- ✅ DOCX extraction preserves basic formatting
- ✅ TXT files read correctly
- ✅ Handles files up to 100MB
- ✅ Extracted text stored in database
- ✅ Error messages clear for unsupported formats

**Files to Create/Modify:**
- `app/services/text_extraction_service.rb` - New file
- `production_server.rb` - Update document upload handler
- Database migration for `extracted_text` column

---

### Task 1.3: Build Entity Extraction
**Estimated Time**: 8 hours
**Dependencies**: Task 1.2

**Subtasks:**
- [ ] Design entity extraction prompt
- [ ] Implement chunking for large documents
- [ ] Create entity extraction method
- [ ] Parse AI response into structured data
- [ ] Store entities in database
- [ ] Implement deduplication logic
- [ ] Add confidence scoring
- [ ] Create entity types (person, company, date, amount, case_citation, location)

**Acceptance Criteria:**
- ✅ Extracts person names with 90%+ accuracy
- ✅ Extracts company names with 90%+ accuracy
- ✅ Extracts dates with 95%+ accuracy
- ✅ Handles documents up to 50 pages
- ✅ Deduplicates similar entities
- ✅ Stores entities with confidence scores
- ✅ Processing time under 60 seconds for 50-page doc

**Files to Create/Modify:**
- `app/services/entity_extraction_service.rb` - New file
- `app/models/entity.rb` - New file
- Database migration for `entities` table
- `app/services/ai_analysis_service.rb` - Update

---

### Task 1.4: Implement Compliance Checking
**Estimated Time**: 6 hours
**Dependencies**: Task 1.3

**Subtasks:**
- [ ] Design compliance checking prompt
- [ ] Create compliance analysis method
- [ ] Identify GDPR-related clauses
- [ ] Flag missing required elements
- [ ] Detect ambiguous language
- [ ] Calculate compliance score
- [ ] Store compliance issues in database
- [ ] Generate recommendations

**Acceptance Criteria:**
- ✅ Identifies GDPR clauses correctly
- ✅ Flags missing signatures/dates
- ✅ Detects ambiguous terms
- ✅ Compliance score between 0-100
- ✅ Provides actionable recommendations
- ✅ Issues categorized by severity

**Files to Create/Modify:**
- `app/services/compliance_checker_service.rb` - New file
- `app/models/compliance_issue.rb` - New file
- Database migration for `compliance_issues` table

---

### Task 1.5: Add Risk Assessment
**Estimated Time**: 4 hours
**Dependencies**: Task 1.4

**Subtasks:**
- [ ] Design risk assessment prompt
- [ ] Create risk analysis method
- [ ] Assess overall risk level (Low/Medium/High)
- [ ] Identify specific risk factors
- [ ] Generate risk mitigation suggestions
- [ ] Store risk assessment in database

**Acceptance Criteria:**
- ✅ Risk level accurately assessed
- ✅ Specific risks identified
- ✅ Mitigation suggestions provided
- ✅ Risk data stored in analysis_results JSON

**Files to Create/Modify:**
- `app/services/risk_assessment_service.rb` - New file
- `app/services/ai_analysis_service.rb` - Update

---

### Task 1.6: Implement Real-time Streaming
**Estimated Time**: 8 hours
**Dependencies**: Task 1.5

**Subtasks:**
- [ ] Install `faye-websocket` gem
- [ ] Create WebSocket server endpoint
- [ ] Implement broadcast mechanism
- [ ] Update analysis service to stream progress
- [ ] Create frontend WebSocket client
- [ ] Update Live Terminal to display real-time logs
- [ ] Add reconnection logic
- [ ] Handle WebSocket errors gracefully

**Acceptance Criteria:**
- ✅ WebSocket connection established successfully
- ✅ Progress updates stream in real-time
- ✅ Terminal shows analysis steps as they happen
- ✅ Reconnects automatically on disconnect
- ✅ Fallback to polling if WebSocket fails
- ✅ No memory leaks from connections

**Files to Create/Modify:**
- `Gemfile` - Add faye-websocket
- `production_server.rb` - Add WebSocket endpoint
- `app/services/analysis_websocket.rb` - New file
- `frontend/src/hooks/useWebSocket.js` - New file
- `frontend/src/pages/LiveTerminal.jsx` - Update

---

### Task 1.7: Update Database Schema
**Estimated Time**: 2 hours
**Dependencies**: None (can be done early)

**Subtasks:**
- [ ] Create migration for documents table updates
- [ ] Create entities table
- [ ] Create compliance_issues table
- [ ] Create analysis_logs table
- [ ] Add indexes for performance
- [ ] Run migrations
- [ ] Test database changes

**Acceptance Criteria:**
- ✅ All tables created successfully
- ✅ Indexes improve query performance
- ✅ Foreign keys enforce referential integrity
- ✅ No data loss from existing documents

**Files to Create/Modify:**
- `db/migrate/006_add_ai_analysis_tables.rb` - New file
- `production_server.rb` - Update schema initialization

---

### Task 1.8: Build API Endpoints
**Estimated Time**: 4 hours
**Dependencies**: Tasks 1.1-1.7

**Subtasks:**
- [ ] Create POST `/api/v1/documents/:id/analyze` endpoint
- [ ] Create GET `/api/v1/documents/:id/analysis` endpoint
- [ ] Create GET `/api/v1/documents/:id/entities` endpoint
- [ ] Create GET `/api/v1/documents/:id/analysis/stream` WebSocket endpoint
- [ ] Add authentication to all endpoints
- [ ] Add rate limiting
- [ ] Add error handling
- [ ] Document API endpoints

**Acceptance Criteria:**
- ✅ All endpoints return correct data
- ✅ Authentication required and working
- ✅ Rate limiting prevents abuse
- ✅ Error responses are clear
- ✅ API documentation complete

**Files to Create/Modify:**
- `production_server.rb` - Add new routes and handlers

---

### Task 1.9: Update Frontend UI
**Estimated Time**: 6 hours
**Dependencies**: Task 1.8

**Subtasks:**
- [ ] Add "Analyze with AI" button to DocumentUpload page
- [ ] Create AnalysisResults component
- [ ] Display extracted entities with categories
- [ ] Show compliance issues with severity
- [ ] Display risk assessment
- [ ] Add confidence scores to entities
- [ ] Create entity filtering/sorting
- [ ] Add export analysis results button

**Acceptance Criteria:**
- ✅ Analysis button triggers AI analysis
- ✅ Results display clearly and professionally
- ✅ Entities grouped by type
- ✅ Compliance issues color-coded by severity
- ✅ Risk level prominently displayed
- ✅ Can filter entities by type
- ✅ Can export results as JSON

**Files to Create/Modify:**
- `frontend/src/components/AnalysisResults.jsx` - New file
- `frontend/src/components/EntityList.jsx` - New file
- `frontend/src/components/ComplianceIssues.jsx` - New file
- `frontend/src/components/RiskAssessment.jsx` - New file
- `frontend/src/pages/DocumentUpload.jsx` - Update

---

### Task 1.10: Testing and Optimization
**Estimated Time**: 6 hours
**Dependencies**: Tasks 1.1-1.9

**Subtasks:**
- [ ] Test with various document types
- [ ] Test with large documents (100+ pages)
- [ ] Test concurrent analysis
- [ ] Optimize API calls (reduce tokens)
- [ ] Add caching for repeated analyses
- [ ] Test error scenarios
- [ ] Performance testing
- [ ] User acceptance testing

**Acceptance Criteria:**
- ✅ Works with PDF, DOCX, TXT
- ✅ Handles 100-page documents
- ✅ Multiple analyses run concurrently
- ✅ API costs under $0.10 per document
- ✅ No crashes or data loss
- ✅ Performance meets requirements

---

## Phase 2: Advanced Search (Priority: HIGH)

### Task 2.1: Set Up FTS5 Search
**Estimated Time**: 4 hours
**Dependencies**: Phase 1 complete

**Subtasks:**
- [ ] Enable FTS5 extension in SQLite
- [ ] Create FTS5 virtual table
- [ ] Create triggers to keep FTS in sync
- [ ] Populate FTS table with existing documents
- [ ] Test FTS search functionality
- [ ] Add search ranking

**Acceptance Criteria:**
- ✅ FTS5 enabled and working
- ✅ Search returns relevant results
- ✅ Results ranked by relevance
- ✅ Search completes in under 2 seconds

**Files to Create/Modify:**
- `db/migrate/007_create_fts_search.rb` - New file
- `production_server.rb` - Update schema

---

### Task 2.2: Build Search Service
**Estimated Time**: 6 hours
**Dependencies**: Task 2.1

**Subtasks:**
- [ ] Create `SearchService` class
- [ ] Implement full-text search
- [ ] Add query parsing (phrases, operators)
- [ ] Implement filtering (date, status, type)
- [ ] Add pagination
- [ ] Calculate facets (filter counts)
- [ ] Add sorting options

**Acceptance Criteria:**
- ✅ Search works across all documents
- ✅ Phrase search with quotes works
- ✅ Boolean operators (AND, OR, NOT) work
- ✅ Filters apply correctly
- ✅ Pagination works smoothly
- ✅ Facets show accurate counts

**Files to Create/Modify:**
- `app/services/search_service.rb` - New file

---

### Task 2.3: Create Search API
**Estimated Time**: 3 hours
**Dependencies**: Task 2.2

**Subtasks:**
- [ ] Create GET `/api/v1/search` endpoint
- [ ] Add query parameters (q, filters, page, sort)
- [ ] Return results with metadata
- [ ] Add authentication
- [ ] Add rate limiting

**Acceptance Criteria:**
- ✅ API returns search results
- ✅ Supports all query parameters
- ✅ Returns total count and pagination info
- ✅ Authentication required

**Files to Create/Modify:**
- `production_server.rb` - Add search endpoint

---

### Task 2.4: Build Search UI
**Estimated Time**: 8 hours
**Dependencies**: Task 2.3

**Subtasks:**
- [ ] Create Search page component
- [ ] Add search input with icon
- [ ] Display search results
- [ ] Add filter sidebar
- [ ] Implement pagination
- [ ] Add sorting dropdown
- [ ] Highlight search terms in results
- [ ] Add "no results" state
- [ ] Add loading state

**Acceptance Criteria:**
- ✅ Search input responsive and fast
- ✅ Results display clearly
- ✅ Filters work and show counts
- ✅ Pagination smooth
- ✅ Search terms highlighted
- ✅ Good UX for empty results

**Files to Create/Modify:**
- `frontend/src/pages/Search.jsx` - New file
- `frontend/src/components/SearchFilters.jsx` - New file
- `frontend/src/components/SearchResults.jsx` - New file
- `frontend/src/App.jsx` - Add route

---

### Task 2.5: Implement Entity Search
**Estimated Time**: 4 hours
**Dependencies**: Task 2.4

**Subtasks:**
- [ ] Create entity search endpoint
- [ ] Add entity type filter
- [ ] Show entity context in results
- [ ] Link to documents containing entity

**Acceptance Criteria:**
- ✅ Can search by entity value
- ✅ Can filter by entity type
- ✅ Shows surrounding context
- ✅ Links to source documents

**Files to Create/Modify:**
- `production_server.rb` - Add entity search endpoint
- `frontend/src/pages/Search.jsx` - Update

---

### Task 2.6: Add Saved Searches
**Estimated Time**: 4 hours
**Dependencies**: Task 2.4

**Subtasks:**
- [ ] Create saved_searches table
- [ ] Create save search API
- [ ] Create load saved searches API
- [ ] Add "Save Search" button to UI
- [ ] Display saved searches list
- [ ] Add edit/delete functionality

**Acceptance Criteria:**
- ✅ Can save search with name
- ✅ Saved searches persist
- ✅ Can load saved search
- ✅ Can edit/delete saved searches

**Files to Create/Modify:**
- `db/migrate/008_create_saved_searches.rb` - New file
- `production_server.rb` - Add saved search endpoints
- `frontend/src/components/SavedSearches.jsx` - New file

---

### Task 2.7: Implement Auto-complete
**Estimated Time**: 4 hours
**Dependencies**: Task 2.4

**Subtasks:**
- [ ] Create auto-complete service
- [ ] Add auto-complete API endpoint
- [ ] Suggest entity names
- [ ] Show recent searches
- [ ] Add debouncing to input
- [ ] Style suggestions dropdown

**Acceptance Criteria:**
- ✅ Suggestions appear as user types
- ✅ Responds in under 500ms
- ✅ Shows relevant suggestions
- ✅ Can select suggestion with keyboard

**Files to Create/Modify:**
- `app/services/autocomplete_service.rb` - New file
- `production_server.rb` - Add autocomplete endpoint
- `frontend/src/components/SearchInput.jsx` - New file

---

## Phase 3: Reporting Features (Priority: HIGH)

### Task 3.1: Set Up PDF Generation
**Estimated Time**: 4 hours
**Dependencies**: Phase 1 complete

**Subtasks:**
- [ ] Install `prawn` and `gruff` gems
- [ ] Create `ReportGenerator` class
- [ ] Implement basic PDF structure
- [ ] Add header and footer
- [ ] Test PDF generation

**Acceptance Criteria:**
- ✅ Can generate basic PDF
- ✅ PDF has header and footer
- ✅ PDF renders correctly

**Files to Create/Modify:**
- `Gemfile` - Add prawn, gruff
- `app/services/report_generator.rb` - New file

---

### Task 3.2: Create Report Templates
**Estimated Time**: 6 hours
**Dependencies**: Task 3.1

**Subtasks:**
- [ ] Design summary report template
- [ ] Design detailed report template
- [ ] Design executive report template
- [ ] Add sections (entities, compliance, risks)
- [ ] Add charts and graphs
- [ ] Add firm branding support

**Acceptance Criteria:**
- ✅ Three templates available
- ✅ All sections render correctly
- ✅ Charts display properly
- ✅ Branding applied correctly

**Files to Create/Modify:**
- `app/services/report_generator.rb` - Update
- `app/templates/` - New folder with templates

---

### Task 3.3: Build Report API
**Estimated Time**: 3 hours
**Dependencies**: Task 3.2

**Subtasks:**
- [ ] Create POST `/api/v1/reports/generate` endpoint
- [ ] Create GET `/api/v1/reports/:id/download` endpoint
- [ ] Store generated reports
- [ ] Add authentication

**Acceptance Criteria:**
- ✅ Can generate report via API
- ✅ Can download generated report
- ✅ Reports stored securely

**Files to Create/Modify:**
- `production_server.rb` - Add report endpoints
- `db/migrate/009_create_generated_reports.rb` - New file

---

### Task 3.4: Build Export Functionality
**Estimated Time**: 4 hours
**Dependencies**: Phase 1 complete

**Subtasks:**
- [ ] Implement CSV export
- [ ] Implement JSON export
- [ ] Implement Excel export
- [ ] Add bulk export
- [ ] Create export API endpoint

**Acceptance Criteria:**
- ✅ CSV export works
- ✅ JSON export works
- ✅ Excel export works
- ✅ Can export multiple documents

**Files to Create/Modify:**
- `app/services/export_service.rb` - New file
- `production_server.rb` - Add export endpoint

---

### Task 3.5: Create Analytics Dashboard
**Estimated Time**: 8 hours
**Dependencies**: Phase 1 complete

**Subtasks:**
- [ ] Create `AnalyticsService` class
- [ ] Calculate dashboard metrics
- [ ] Create analytics API endpoint
- [ ] Build Analytics page component
- [ ] Add charts (documents over time, entity distribution)
- [ ] Add metrics cards
- [ ] Add date range filter

**Acceptance Criteria:**
- ✅ Dashboard shows key metrics
- ✅ Charts render correctly
- ✅ Data updates in real-time
- ✅ Can filter by date range

**Files to Create/Modify:**
- `app/services/analytics_service.rb` - New file
- `production_server.rb` - Add analytics endpoint
- `frontend/src/pages/Analytics.jsx` - New file
- `frontend/src/components/Charts.jsx` - New file

---

### Task 3.6: Implement Document Comparison
**Estimated Time**: 6 hours
**Dependencies**: Phase 1 complete

**Subtasks:**
- [ ] Create comparison service
- [ ] Build comparison API
- [ ] Create comparison UI
- [ ] Show side-by-side view
- [ ] Highlight differences
- [ ] Generate comparison report

**Acceptance Criteria:**
- ✅ Can compare 2-10 documents
- ✅ Differences highlighted
- ✅ Comparison report generated

**Files to Create/Modify:**
- `app/services/comparison_service.rb` - New file
- `production_server.rb` - Add comparison endpoint
- `frontend/src/pages/Compare.jsx` - New file

---

## Phase 4: Collaboration Tools (Priority: MEDIUM)

### Task 4.1: Build Document Sharing
**Estimated Time**: 6 hours
**Dependencies**: None

**Subtasks:**
- [ ] Create document_shares table
- [ ] Create share API endpoints
- [ ] Add share button to UI
- [ ] Create share modal
- [ ] Send email notifications
- [ ] Show shared users list

**Acceptance Criteria:**
- ✅ Can share document with users
- ✅ Permissions enforced
- ✅ Email notifications sent
- ✅ Can revoke access

**Files to Create/Modify:**
- `db/migrate/010_create_document_shares.rb` - New file
- `production_server.rb` - Add sharing endpoints
- `frontend/src/components/ShareModal.jsx` - New file

---

### Task 4.2: Implement Comments
**Estimated Time**: 8 hours
**Dependencies**: None

**Subtasks:**
- [ ] Create comments table
- [ ] Create comment API endpoints
- [ ] Build comment UI component
- [ ] Add threaded replies
- [ ] Implement @mentions
- [ ] Add edit/delete functionality
- [ ] Send notifications

**Acceptance Criteria:**
- ✅ Can add comments
- ✅ Threaded replies work
- ✅ @mentions trigger notifications
- ✅ Can edit/delete own comments

**Files to Create/Modify:**
- `db/migrate/011_create_comments.rb` - New file
- `app/services/comment_service.rb` - New file
- `production_server.rb` - Add comment endpoints
- `frontend/src/components/Comments.jsx` - New file

---

### Task 4.3: Create Task Management
**Estimated Time**: 8 hours
**Dependencies**: None

**Subtasks:**
- [ ] Create tasks table
- [ ] Create task API endpoints
- [ ] Build task creation UI
- [ ] Create task list view
- [ ] Add task status updates
- [ ] Send assignment notifications
- [ ] Add due date reminders

**Acceptance Criteria:**
- ✅ Can create and assign tasks
- ✅ Task status updates work
- ✅ Notifications sent to assignees
- ✅ Can view all my tasks

**Files to Create/Modify:**
- `db/migrate/012_create_tasks.rb` - New file
- `app/services/task_service.rb` - New file
- `production_server.rb` - Add task endpoints
- `frontend/src/pages/Tasks.jsx` - New file

---

### Task 4.4: Build Activity Logs
**Estimated Time**: 4 hours
**Dependencies**: None

**Subtasks:**
- [ ] Create activity_logs table
- [ ] Log all document actions
- [ ] Create activity API endpoint
- [ ] Build activity feed UI
- [ ] Add filtering
- [ ] Add export functionality

**Acceptance Criteria:**
- ✅ All actions logged
- ✅ Activity feed displays correctly
- ✅ Can filter by action type
- ✅ Can export activity log

**Files to Create/Modify:**
- `db/migrate/013_create_activity_logs.rb` - New file
- `production_server.rb` - Add activity logging
- `frontend/src/components/ActivityFeed.jsx` - New file

---

### Task 4.5: Create Collections
**Estimated Time**: 6 hours
**Dependencies**: None

**Subtasks:**
- [ ] Create collections tables
- [ ] Create collection API endpoints
- [ ] Build collection management UI
- [ ] Add documents to collections
- [ ] Share collections
- [ ] Search within collections

**Acceptance Criteria:**
- ✅ Can create collections
- ✅ Can add/remove documents
- ✅ Can share collections
- ✅ Can search within collection

**Files to Create/Modify:**
- `db/migrate/014_create_collections.rb` - New file
- `production_server.rb` - Add collection endpoints
- `frontend/src/pages/Collections.jsx` - New file

---

## Total Estimated Time

- **Phase 1 (Real AI Analysis)**: 54 hours (~2 weeks)
- **Phase 2 (Advanced Search)**: 33 hours (~1 week)
- **Phase 3 (Reporting)**: 31 hours (~1 week)
- **Phase 4 (Collaboration)**: 32 hours (~1 week)

**Total**: 150 hours (~5-6 weeks for one developer)

---

## Getting Started

### Prerequisites
1. OpenAI API key (get from https://platform.openai.com/api-keys)
2. Ruby gems installed
3. Frontend dependencies installed
4. Database backed up

### First Steps
1. Review and approve requirements and design documents
2. Set up OpenAI API key in `.env`
3. Start with Phase 1, Task 1.1
4. Complete tasks in order within each phase
5. Test thoroughly after each task
6. Commit code frequently

---

**Document Status**: Ready for Implementation
**Last Updated**: 2026-02-06
**Author**: Kiro AI Assistant

# How to Run LegaStream App

## Quick Start Guide

### Step 1: Start the Backend Server

Open a terminal and run:

```bash
ruby production_server.rb
```

You should see:
```
🚀 Legal Auditor Agent Production Server starting on port 3001
🔧 Mode: Production
📊 Health check: http://localhost:3001/up
🔧 API endpoints: http://localhost:3001/api/v1/*
💾 Database: SQLite (storage/legastream.db)
📧 Email: SMTP configured
```

**Backend is now running on port 3001** ✅

---

### Step 2: Start the Frontend

Open a **NEW terminal** (keep the backend running) and run:

```bash
cd frontend
npm run dev
```

You should see:
```
VITE v5.x.x  ready in xxx ms

➜  Local:   http://localhost:5173/
➜  Network: use --host to expose
```

**Frontend is now running on port 5173** ✅

---

### Step 3: Open the App

Open your browser and go to:
```
http://localhost:5173
```

---

## Testing the App

### 1. Login with Test Account
Use the pre-existing admin account:
- **Email**: admin@legastream.com
- **Password**: password

OR create a new account:
- Click "Register" or "Sign Up"
- Fill in your details (email, password, name)
- You'll be redirected to login immediately (no email confirmation needed)

### 2. After Login
- You'll be taken to the Dashboard
- The app will automatically fetch your documents

### 3. Upload a Document
- Go to "Document Upload" page
- Drag and drop a PDF file OR click to browse
- Click "Upload All"
- The document will automatically start processing with AI analysis

### 4. View Results
- Documents auto-refresh every 3 seconds while processing
- Once completed, click the eye icon (👁️) to view analysis
- You'll see:
  - Full AI Summary
  - Entity count and breakdown
  - AI Confidence score
  - Compliance score
  - Risk level

---

## Troubleshooting

### Backend won't start
**Error**: `cannot load such file -- pdf-reader`
**Fix**: Install gems first
```bash
bundle install
```

### Frontend won't start
**Error**: `command not found: npm`
**Fix**: Install Node.js first, then:
```bash
cd frontend
npm install
npm run dev
```

### API connection errors
**Check**: Make sure backend is running on port 3001
```bash
# Test backend health
curl http://localhost:3001/up
```

### Gemini API timeouts
**Current API Key**: AIzaSyAYOIkIxZFvLuunEjQDN0YuJ-PVxnfWsk8
**Status**: Active and working
**Model**: gemini-flash-lite-latest (v1beta API)

If you see timeouts:
1. Check your internet connection
2. The API key might have hit quota limits
3. Try uploading a smaller document first

---

## What's Working

✅ Backend on port 3001 (production_server.rb)
✅ Frontend on port 5173 (Vite dev server)
✅ Auto-refresh for processing documents (every 3 seconds)
✅ AI entity extraction with Gemini
✅ Full AI summaries (no truncation)
✅ AI confidence scores
✅ Duplicate entity removal
✅ Email auto-confirmation (no popup)
✅ All fixes from previous conversation

---

## Current Status

- **Backend**: production_server.rb on port 3001
- **Frontend**: Vite dev server on port 5173
- **Database**: SQLite at storage/legastream.db
- **AI Provider**: Google Gemini (gemini-flash-lite-latest)
- **API Key**: AIzaSyAYOIkIxZFvLuunEjQDN0YuJ-PVxnfWsk8

---

## Need Help?

If something isn't working:
1. Check both terminals are running (backend + frontend)
2. Check backend is on port 3001
3. Check frontend is on port 5173
4. Try refreshing the browser
5. Check browser console for errors (F12)

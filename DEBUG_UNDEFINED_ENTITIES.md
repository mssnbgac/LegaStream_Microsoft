# Debugging "undefined entities" Issue

## What I Fixed

1. **Changed Gemini Model**: From `gemini-2.5-flash` (might not exist) to `gemini-1.5-flash` (stable)
2. **Added Comprehensive Logging**: Every step now logs what's happening
3. **Better Error Handling**: Catches timeouts, API errors, and empty responses
4. **Increased Timeout**: From 30s to 60s to handle slower responses

## Changes Deployed

The code has been pushed to GitHub and Render is deploying now (2-3 minutes).

## What to Check in Render Logs

### Step 1: Open Render Dashboard
1. Go to https://dashboard.render.com
2. Click on your "legastream" service
3. Click "Logs" tab
4. Wait for deployment to complete (look for "Build successful" and "Starting server")

### Step 2: Look for These Log Messages

When you upload a document, you should see:

```
Starting automatic AI analysis for new document 123
Extracting legal entities from text (5234 chars)...
Prompt built (487 chars), calling AI provider...
[Gemini] Sending request to API...
[Gemini] Response status: 200
[Gemini] Success! Received 456 chars
AI response received (456 chars)
Response preview: {"entities":[{"type":"PARTY"...
Parsed 10 valid entities from AI response
Automatic analysis completed for document 123 using gemini: 10 entities
```

### Step 3: Common Error Messages

**If you see:**
```
[Gemini] API error: API key not valid
```
→ The GEMINI_API_KEY in Render environment is wrong

**If you see:**
```
[Gemini] TIMEOUT: execution expired
```
→ Gemini API is slow or unreachable from Render

**If you see:**
```
[Gemini] No candidates in response
```
→ Gemini blocked the content or had an internal error

**If you see:**
```
ERROR: AI provider returned nil response
```
→ The AI provider is not initialized or API key is missing

**If you see:**
```
JSON Parse Error: unexpected token
```
→ Gemini returned invalid JSON (we'll see the preview)

## Quick Fix Options

### Option 1: Check API Key in Render
1. Go to Render Dashboard → Your Service
2. Click "Environment" tab
3. Verify `GEMINI_API_KEY` is set correctly
4. Should be: `AIzaSyCgDuGe3beNs2wVq-KXYhWHPJ0SAP8340g`

### Option 2: Test API Key Manually
Run this in Render Shell (if available):
```bash
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=YOUR_KEY" \
  -H 'Content-Type: application/json' \
  -d '{"contents":[{"parts":[{"text":"Hello"}]}]}'
```

### Option 3: Check Gemini API Quota
1. Go to https://aistudio.google.com/app/apikey
2. Check if your API key has quota remaining
3. Free tier: 15 requests per minute, 1500 per day

## After Deployment

1. Wait 2-3 minutes for Render to deploy
2. Upload your test document again
3. Check Render logs immediately
4. Copy any error messages you see
5. Share them with me so I can fix the exact issue

## Expected Timeline

- **Now**: Code pushed to GitHub ✅
- **+1 min**: Render starts building
- **+2 min**: Build completes, server restarts
- **+3 min**: Ready to test

## What Should Happen

After deployment, when you upload a document:
1. Processing should take 20-40 seconds (not 2+ minutes)
2. You should see entity count (not "undefined")
3. Entities should be correctly classified (PARTY, ADDRESS, etc.)

---

**Current Status**: Waiting for Render deployment
**Next Step**: Check Render logs after deployment completes

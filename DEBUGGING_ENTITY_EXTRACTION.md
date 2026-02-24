# Debugging Entity Extraction Issue

## Problem Identified

You're seeing the **fallback regex extraction** (lowercase types: "person", "monetary", "date") instead of the **Gemini AI extraction** (uppercase types: "PARTY", "AMOUNT", "DATE").

This means the Gemini API is either:
1. Returning an empty response
2. Returning text that can't be parsed as JSON
3. Being blocked by safety filters
4. Timing out

---

## What I Just Fixed

### 1. Added Detailed Logging
The system will now log:
- Whether Gemini response is empty
- First 200 characters of Gemini response
- Whether JSON array was found
- Parsing errors with full details

### 2. Improved Gemini Prompt
- More explicit instructions to return ONLY JSON
- Better examples of each entity type
- Clearer format specification

### 3. Better Error Handling
- Logs the exact text that failed to parse
- Shows where in the process it's failing

---

## Next Steps

### Step 1: Wait for Deployment (2-3 minutes)
Render is deploying commit `304ce5e` right now.

### Step 2: Upload a NEW Document
1. Go to https://legastream.onrender.com
2. Upload a fresh document (not one you've uploaded before)
3. Wait for processing

### Step 3: Check Render Logs
This is CRITICAL - we need to see what Gemini is returning.

Go to Render dashboard and look for these log messages:
```
[Gemini] Sending request to API...
[Gemini] Response status: 200
[Gemini] Success! Received X chars
[AIProvider] Parsing response (X chars)
[AIProvider] First 200 chars: ...
[AIProvider] Found JSON array, attempting to parse...
[AIProvider] Successfully parsed X entities
```

### Step 4: Share the Logs
Copy the last 100 lines of Render logs and share them. Look for:
- `[Gemini]` messages
- `[AIProvider]` messages
- Any error messages

---

## What to Look For in Logs

### ✅ Good Signs (Working)
```
[Gemini] Response status: 200
[Gemini] Success! Received 1234 chars
[AIProvider] Parsing response (1234 chars)
[AIProvider] First 200 chars: [{"type":"PARTY","value":"Acme Corporation"...
[AIProvider] Found JSON array, attempting to parse...
[AIProvider] Successfully parsed 42 entities
AI extracted 42 entities
```

### ❌ Bad Signs (Not Working)

#### Empty Response
```
[Gemini] Response status: 200
[Gemini] Success! Received 0 chars
[AIProvider] parse_json_response: text is nil or empty
AI returned empty array, using fallback
Using fallback entity extraction (regex-based)
```

#### No JSON Found
```
[Gemini] Success! Received 500 chars
[AIProvider] First 200 chars: I cannot extract entities from this document...
[AIProvider] No JSON array found in response
AI returned empty array, using fallback
```

#### Safety Filter
```
[Gemini] Finished with reason: SAFETY
[Gemini] Content was blocked by safety filters
```

#### Timeout
```
[Gemini] TIMEOUT: execution expired
AI entity extraction failed: execution expired
```

---

## Possible Issues and Solutions

### Issue 1: Gemini Returns Text Instead of JSON
**Symptoms**: Logs show text but no JSON array
**Solution**: The improved prompt should fix this

### Issue 2: Safety Filters Blocking Content
**Symptoms**: `finishReason: SAFETY` in logs
**Solution**: Try a different document or adjust safety settings

### Issue 3: API Key Issue
**Symptoms**: 401 or 403 errors
**Solution**: Verify GEMINI_API_KEY in Render environment

### Issue 4: Model Not Available
**Symptoms**: 404 errors mentioning model name
**Solution**: Verify we're using `gemini-1.5-flash` with `v1` API

### Issue 5: Response Too Large
**Symptoms**: `finishReason: MAX_TOKENS`
**Solution**: Increase maxOutputTokens or reduce input text

---

## Alternative: Test Locally

If you want to test without waiting for Render:

```bash
# Set environment variable
$env:GEMINI_API_KEY="AIzaSyCgDuGe3beNs2wVq-KXYhWHPJ0SAP8340g"

# Run test script
ruby test_gemini_direct.rb
```

This will show you exactly what Gemini is returning.

---

## What Should Happen

### Expected Flow:
1. Document uploaded → Processing
2. PDF text extracted → 500-5000 characters
3. Gemini API called with prompt
4. Gemini returns JSON array with 10-50 entities
5. Entities parsed and saved to database
6. Document status → Completed
7. UI shows entities with UPPERCASE types

### Current Flow (Broken):
1. Document uploaded → Processing
2. PDF text extracted → 500-5000 characters
3. Gemini API called with prompt
4. Gemini returns ??? (empty or unparseable)
5. System falls back to regex extraction
6. Entities saved with lowercase types
7. UI shows entities with lowercase types

---

## Critical Information Needed

To fix this, I need to see:

1. **Render Logs** (last 100 lines after uploading a document)
   - Specifically the `[Gemini]` and `[AIProvider]` messages

2. **What Gemini Returns**
   - The "First 200 chars" log message will show this

3. **Any Error Messages**
   - Look for ERROR, TIMEOUT, SAFETY, etc.

---

## Quick Test Command

Once deployed, you can also test the Gemini API directly from Render shell:

```bash
# In Render shell
ruby test_gemini_direct.rb
```

This will show you exactly what Gemini returns for a sample legal document.

---

## Summary

✅ Added detailed logging to see what Gemini returns
✅ Improved prompt to be more explicit about JSON format
✅ Better error handling to catch parsing issues
🔄 Deploying to Render now (commit 304ce5e)
⏳ Wait 2-3 minutes, then upload a new document
📋 Share Render logs to see what's happening

The key is to see what Gemini is actually returning. The logs will tell us if it's:
- Empty response
- Text instead of JSON
- Safety filter blocking
- Timeout issue
- Something else

Once we see the logs, we can fix the exact issue.

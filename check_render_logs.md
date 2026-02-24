# Check Render Deployment Logs

Since you're seeing "undefined entities", the analysis is failing. Here's how to check:

## Option 1: Check Render Dashboard
1. Go to https://dashboard.render.com
2. Click on your "legastream" service
3. Click on "Logs" tab
4. Look for errors related to:
   - "Starting AI analysis"
   - "AI analysis error"
   - "JSON Parse Error"
   - Any Ruby errors

## Option 2: Check if Deployment Completed
1. Go to https://dashboard.render.com
2. Click on your service
3. Check if the latest deployment is "Live" (green)
4. If it's still deploying, wait 1-2 more minutes

## What to Look For

The logs should show something like:
```
Starting automatic AI analysis for new document 123
Parsed 10 entities from AI response
Automatic analysis completed for document 123 using gemini: 10 entities
```

If you see errors like:
- "JSON Parse Error" → AI response format issue
- "No candidates in Gemini response" → API issue
- "Gemini API error" → API key or quota issue
- "undefined method" → Code deployment issue

## Quick Test

Let me create a script to test the Gemini API directly from Render.

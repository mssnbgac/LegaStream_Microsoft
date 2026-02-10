# Entity Extraction - User Guide 🎯

## What's Fixed
The "View Extracted Entities" button now works! You can see all entities extracted from your documents.

## How to View Entities

### Step 1: Trigger Analysis
1. Go to the **Document Upload** page
2. Find your document in the list
3. Click the **Play button (▶)** next to the document
4. Wait 10-15 seconds for analysis to complete
5. The status will change from "Processing" to "Completed"

### Step 2: View Analysis Results
1. Click **"View Analysis"** button
2. You'll see a comprehensive modal with:
   - AI Summary
   - Key Findings
   - Risk Assessment by Category
   - Compliance Score
   - Additional Information

### Step 3: View Extracted Entities
1. In the analysis modal, click **"View Extracted Entities"**
2. A new modal will open showing all entities grouped by type:
   - 👤 **Person Names** (e.g., John Smith, Jane Doe)
   - 🏢 **Companies** (e.g., Acme Corp, Beta LLC)
   - 📅 **Dates** (e.g., January 15, 2024)
   - 💰 **Amounts** (e.g., $50,000)
   - ⚖️ **Case Citations** (e.g., Smith v. Jones, 123 F.3d 456)

### What You'll See
Each entity shows:
- **Type** (color-coded badge)
- **Value** (the actual entity text)
- **Context** (surrounding text for reference)
- **Confidence Score** (how confident the AI is)

## Example

For a legal services agreement, you might see:

### 👤 Person Names (4)
- **John Smith** - 85% confidence
  - Context: "...Parties: John Smith (CEO, Acme Corp)..."
- **Jane Doe** - 85% confidence
  - Context: "...CEO, Acme Corp) and Jane Doe (Director, Beta LLC)..."

### 🏢 Companies (2)
- **Acme Corp** - 90% confidence
  - Context: "...John Smith (CEO, Acme Corp) and Jane Doe..."
- **Beta LLC** - 90% confidence
  - Context: "...Jane Doe (Director, Beta LLC). Location: New York..."

### 📅 Dates (1)
- **January 15, 2024** - 95% confidence
  - Context: "...Party A and Party B dated January 15, 2024. The agreement..."

### 💰 Amounts (1)
- **$50,000** - 95% confidence
  - Context: "...Total contract value: $50,000. Parties: John Smith..."

### ⚖️ Case Citations (1)
- **Smith v. Jones, 123 F.3d 456** - 92% confidence
  - Context: "...NY. Case reference: Smith v. Jones, 123 F.3d 456 (2023)..."

## Your Documents

### Document 4: MUHAMMAD AUWAL MURTALA11 CVCVCV.pdf
- **Status**: ✅ Analyzed
- **Entities**: 9 extracted
- **Ready to view**: Yes!

Just click the "View Analysis" button and then "View Extracted Entities" to see them all.

## Tips

1. **Re-analyze**: If you want to re-analyze a document, just click the Play button again
2. **Dark Mode**: The entity viewer works perfectly in both light and dark modes
3. **Confidence Scores**: Higher confidence (closer to 100%) means the AI is more certain
4. **Context**: Use the context to verify the entity was extracted correctly

## Troubleshooting

### "0 entities found"
- Make sure you clicked the **Play button (▶)** to trigger analysis
- Wait for the status to change to "Completed"
- If still showing 0, click the Play button again to re-analyze

### "Document not found"
- Make sure you're logged in as the user who uploaded the document
- Each user can only see their own documents

### Analysis taking too long
- Normal analysis takes 10-15 seconds
- Check the Live Terminal for progress logs
- If stuck, refresh the page and try again

## What's Next?

The entity extraction is now working perfectly! You can:
- ✅ View all entities in your documents
- ✅ See confidence scores
- ✅ Read context for each entity
- ✅ Filter by entity type

Enjoy exploring your document entities! 🎉

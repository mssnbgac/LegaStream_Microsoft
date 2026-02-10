# Quick Start: Entity Extraction ⚡

## What's Fixed
Entity extraction now works automatically when you upload documents!

---

## How to Use

### 1. Upload a Document
- Go to **Document Upload** page
- Click **"Upload Document"** or drag & drop
- Select your PDF, DOCX, or TXT file

### 2. Wait for Analysis (10-15 seconds)
- Status shows **"Processing"**
- Analysis runs automatically in background
- No need to click anything!

### 3. View Results
- Status changes to **"Completed"**
- Click **"View Analysis"** button
- See comprehensive analysis results

### 4. View Extracted Entities
- In the analysis modal, click **"View Extracted Entities"**
- See all entities grouped by type:
  - 👤 Person Names
  - 🏢 Companies
  - 📅 Dates
  - 💰 Amounts
  - ⚖️ Case Citations

---

## What You'll See

Each entity shows:
- **Value**: The extracted text (e.g., "John Smith")
- **Type**: Color-coded badge (person, company, date, etc.)
- **Context**: Surrounding text for verification
- **Confidence**: AI confidence score (0-100%)

---

## Example Output

For a legal services agreement:

### 👤 Person Names (4)
- John Smith (85%)
- Jane Doe (85%)
- Acme Corp (85%)
- New York (85%)

### 🏢 Companies (2)
- Acme Corp (90%)
- Beta LLC (90%)

### 📅 Dates (1)
- January 15, 2024 (95%)

### 💰 Amounts (1)
- $50,000 (95%)

### ⚖️ Case Citations (1)
- Smith v. Jones, 123 F.3d 456 (92%)

---

## Troubleshooting

### "0 entities found"
**Solution**: Wait for analysis to complete (status should be "Completed")

### Entity count doesn't match
**Solution**: Run this command:
```bash
ruby auto_fix_all_documents.rb
```

### Analysis taking too long
**Solution**: Check Live Terminal for logs, or refresh the page

---

## Manual Re-Analysis

If you want to re-analyze a document:
1. Find the document in the list
2. Click the **Play button (▶)**
3. Wait 10-15 seconds
4. View updated results

---

## Technical Details

### Automatic Analysis
- Triggers 2 seconds after upload
- Runs in background thread
- Extracts entities using regex patterns
- Saves to database automatically

### Entity Types
- Person names: `FirstName LastName` pattern
- Companies: Names ending in Corp, LLC, Inc, Ltd
- Dates: `Month DD, YYYY` format
- Amounts: Dollar amounts with optional cents
- Case citations: Legal case format

---

## What's Next?

### Optional Improvements
1. **Add OpenAI API Key** (in `.env` file):
   ```
   OPENAI_API_KEY=sk-your-key-here
   ```
   This will use GPT-4 for more accurate extraction!

2. **Upload Real Documents**:
   - Try different document types
   - See how well entity extraction works
   - Provide feedback for improvements

---

## Status

✅ **Automatic entity extraction on upload**
✅ **Consistent entity counts**
✅ **Beautiful entity viewer modal**
✅ **Dark mode compatible**
✅ **Confidence scores and context**

---

**Ready to use! Just upload a document and watch it work! 🚀**

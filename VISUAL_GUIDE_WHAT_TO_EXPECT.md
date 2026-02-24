# Visual Guide: What You Should See

## 🎯 The 10 Entity Types You Requested

Here's exactly what each entity type looks like:

---

### 1. **PARTY** - People or Organizations
```
✅ Examples:
• "Acme Corporation"
• "John Smith"
• "Mary Johnson"
• "Senior Software Engineer"
• "Employer"
• "Employee"

❌ NOT:
• "person" (old type)
• "organization" (old type)
```

---

### 2. **ADDRESS** - Physical Addresses
```
✅ Examples:
• "123 Main Street, New York"
• "456 Oak Avenue, Brooklyn, NY 11201"
• "14 Adeola Odeku Street, Victoria Island, Lagos"
• "7 Ring Road, Ibadan, Oyo State"

❌ NOT:
• "address" (old type - lowercase)
```

---

### 3. **DATE** - Dates
```
✅ Examples:
• "March 1, 2026"
• "Start date: March 1, 2026"
• "2026-03-01"
• "1st day of March, 2026"

❌ NOT:
• "date" (old type - lowercase)
```

---

### 4. **AMOUNT** - Money
```
✅ Examples:
• "$75,000 annual salary"
• "$5,000 liquidated damages"
• "Five Hundred Thousand Naira"
• "USD 100,000"

❌ NOT:
• "monetary" (old type)
```

---

### 5. **OBLIGATION** - Legal Duties
```
✅ Examples:
• "Employee shall perform duties diligently"
• "Employer shall pay Employee"
• "Party must provide notice"
• "Contractor agrees to complete work"

❌ NOT:
• Generic text without legal obligation
```

---

### 6. **CLAUSE** - Contract Terms
```
✅ Examples:
• "Termination with 30 days notice"
• "Either party may terminate"
• "Non-disclosure agreement"
• "Confidentiality clause"

❌ NOT:
• Random sentences
```

---

### 7. **JURISDICTION** - Governing Law
```
✅ Examples:
• "Governed by New York law"
• "State of New York"
• "Federal Republic of Nigeria"
• "High Court of Oyo State"

❌ NOT:
• Generic location references
```

---

### 8. **TERM** - Duration
```
✅ Examples:
• "24-month contract duration"
• "Period of 24 months"
• "Two-year term"
• "Valid for 12 months"

❌ NOT:
• Random numbers
```

---

### 9. **CONDITION** - Requirements
```
✅ Examples:
• "Subject to background check"
• "Unless terminated earlier"
• "Provided that notice is given"
• "Conditional upon approval"

❌ NOT:
• General statements
```

---

### 10. **PENALTY** - Damages
```
✅ Examples:
• "$5,000 liquidated damages"
• "Penalty of $10,000"
• "Fine of Five Thousand Dollars"
• "Damages for breach"

❌ NOT:
• General monetary amounts
```

---

## 📊 What Your Results Should Look Like

### Before (Old System - NOT WORKING)
```
❌ 49 entities found

address (7)
• 14 Adeola Odeku Street
• 7 Ring Road
• 12 Allen Avenue

person (42)
• Solutions Limited
• Adeola Odeku Street  ← WRONG! This is an address, not a person
• Victoria Island      ← WRONG! This is a location, not a person
• Samuel Okoye
• Five Hundred Thousand ← WRONG! This is an amount, not a person
```

**Problems:**
- Wrong entity types (lowercase: "person", "address")
- Misclassified entities (addresses as persons)
- Generic types instead of legal-specific

---

### After (New System - WORKING)
```
✅ 42 entities found

PARTY (8)
• Acme Corporation - 95% confidence
• John Smith - 95% confidence
• Mary Johnson - 90% confidence
• Senior Software Engineer - 85% confidence

ADDRESS (5)
• 123 Main Street, New York - 88% confidence
• 456 Oak Avenue, Brooklyn - 88% confidence

DATE (6)
• March 1, 2026 - 92% confidence
• Start date: March 1, 2026 - 90% confidence

AMOUNT (4)
• $75,000 annual salary - 95% confidence
• $5,000 liquidated damages - 95% confidence

OBLIGATION (7)
• Employee shall perform duties diligently - 85% confidence
• Employer shall pay Employee - 85% confidence

CLAUSE (5)
• Termination with 30 days notice - 88% confidence
• Either party may terminate - 85% confidence

JURISDICTION (2)
• Governed by New York law - 90% confidence
• State of New York - 88% confidence

TERM (3)
• 24-month contract duration - 90% confidence
• Period of 24 months - 88% confidence

CONDITION (1)
• Unless terminated earlier - 80% confidence

PENALTY (1)
• $5,000 liquidated damages - 95% confidence
```

**Improvements:**
- ✅ Correct entity types (UPPERCASE: "PARTY", "ADDRESS")
- ✅ Properly classified entities
- ✅ Legal-specific types (OBLIGATION, CLAUSE, JURISDICTION)
- ✅ Higher confidence scores

---

## 🎨 UI Display

### Document Card
```
┌─────────────────────────────────────────┐
│ New_York_Employment_Contract.pdf        │
│ ✅ completed                            │
│ 3.49 KB • 2/22/2026, 1:45:43 PM        │
│ 42 entities found                       │ ← Should be 10-50+
└─────────────────────────────────────────┘
```

### Analysis Results
```
┌─────────────────────────────────────────┐
│ AI Analysis Results                     │
│                                         │
│ 42 Entities Extracted                   │ ← Should be 10-50+
│ 85% Compliance Score                    │ ← Should be 70-95%
│ 92% AI Confidence                       │ ← Should be 85-95%
│ MEDIUM Risk Level                       │ ← LOW/MEDIUM/HIGH
│                                         │
│ [View Extracted Entities]               │
│                                         │
│ Issues Flagged: 2                       │
│ Document Status: completed              │
│ Analyzed: 2/22/2026, 1:45:43 PM        │
└─────────────────────────────────────────┘
```

### Entity List (When You Click "View Extracted Entities")
```
┌─────────────────────────────────────────┐
│ Extracted Entities (42)                 │
│                                         │
│ PARTY (8)                               │ ← UPPERCASE type
│ • Acme Corporation                      │
│   Context: party to agreement           │
│   Confidence: 95%                       │
│                                         │
│ • John Smith                            │
│   Context: employee                     │
│   Confidence: 95%                       │
│                                         │
│ ADDRESS (5)                             │ ← UPPERCASE type
│ • 123 Main Street, New York             │
│   Context: employer address             │
│   Confidence: 88%                       │
│                                         │
│ AMOUNT (4)                              │ ← NOT "monetary"
│ • $75,000 annual salary                 │
│   Context: compensation                 │
│   Confidence: 95%                       │
└─────────────────────────────────────────┘
```

---

## ⚠️ Red Flags (What NOT to See)

### ❌ Wrong Entity Types
```
person (42)          ← Should be "PARTY"
monetary (4)         ← Should be "AMOUNT"
address (5)          ← Should be "ADDRESS"
email (2)            ← Should be "PARTY" or removed
phone (3)            ← Should be "PARTY" or removed
```

### ❌ Misclassified Entities
```
person: "Victoria Island"        ← This is a location, not a person
person: "Five Hundred Thousand"  ← This is an amount, not a person
person: "Adeola Odeku Street"    ← This is an address, not a person
```

### ❌ Zero Entities
```
0 Entities Extracted
N/A% AI Confidence
```

If you see this, check Render logs for errors.

---

## ✅ Success Indicators

1. **Entity Count**: 10-50+ entities (not 0)
2. **Entity Types**: UPPERCASE (PARTY, ADDRESS, DATE, etc.)
3. **Confidence**: 75-95% for most entities
4. **Compliance**: 70-95% score
5. **Risk Level**: LOW, MEDIUM, or HIGH (not N/A)
6. **Processing Time**: 10-30 seconds (not 2+ minutes)

---

## 🚀 Ready to Test?

1. Go to https://legastream.onrender.com
2. Upload a legal document (PDF)
3. Wait 10-30 seconds
4. Check the results match the "After" example above

If you see the "Before" example, the deployment hasn't completed yet or there's a caching issue.

---

## 📸 What to Share If Issues Persist

1. Screenshot of entity extraction results
2. Last 50 lines of Render logs
3. Confirmation that deployment succeeded
4. Document type you're testing with

This will help identify if it's a deployment, API, or document issue.

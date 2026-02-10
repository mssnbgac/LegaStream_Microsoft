# ✅ How to Verify Fresh Start - Step by Step

## 🎯 Quick Verification Guide

Follow these steps to verify that every new user starts fresh:

---

## 📝 Method 1: Manual Browser Test (Recommended)

### Step 1: Create First User (Alice)

1. Open browser: http://localhost:5173/
2. Click "Register" or go to http://localhost:5173/register
3. Fill in the form:
   ```
   First Name: Alice
   Last Name: Anderson
   Email: alice@test.com
   Password: password123
   ```
4. Click "Register"
5. Check your email for confirmation link
6. Click the confirmation link
7. Login with alice@test.com / password123

### Step 2: Upload Documents as Alice

1. Go to "Documents" page
2. Upload 2-3 test documents (any PDF, DOCX, or TXT files)
3. Note the dashboard shows: "3 documents processed"
4. Remember: Alice has 3 documents

### Step 3: Logout

1. Click your profile icon (top right)
2. Click "Logout"
3. You're now logged out

### Step 4: Create Second User (Bob) - FRESH START TEST!

1. Click "Register" again
2. Fill in the form:
   ```
   First Name: Bob
   Last Name: Brown
   Email: bob@test.com
   Password: password456
   ```
3. Click "Register"
4. Check your email for confirmation link
5. Click the confirmation link
6. Login with bob@test.com / password456

### Step 5: Verify Fresh Start ✅

1. **Check Dashboard:**
   - Should show: "0 documents processed" ✓
   - Should NOT show Alice's 3 documents ✓

2. **Check Documents Page:**
   - Should show: "No documents uploaded yet" ✓
   - Should NOT show Alice's documents ✓

3. **Check Stats:**
   - All counters should be at 0 ✓

**Result: Bob started FRESH! ✅**

### Step 6: Upload Document as Bob

1. Upload 1 document as Bob
2. Dashboard now shows: "1 document processed"
3. Bob sees only his 1 document

### Step 7: Switch Back to Alice

1. Logout from Bob's account
2. Login as Alice (alice@test.com / password123)
3. **Verify Alice still sees only her 3 documents**
4. Alice does NOT see Bob's 1 document

**Result: Complete isolation confirmed! ✅**

---

## 🖥️ Method 2: Using Browser DevTools

### Step 1: Open DevTools

1. Press F12 or right-click → Inspect
2. Go to "Network" tab
3. Keep it open during testing

### Step 2: Login as User A

1. Login as first user
2. In Network tab, find the request to `/api/v1/documents`
3. Click on it → Preview tab
4. You'll see JSON response:
   ```json
   {
     "documents": [...],
     "total": 3
   }
   ```

### Step 3: Login as User B (New User)

1. Logout and login as second user
2. In Network tab, find the request to `/api/v1/documents`
3. Click on it → Preview tab
4. You'll see JSON response:
   ```json
   {
     "documents": [],
     "total": 0
   }
   ```

**Result: New user has empty array! ✅**

---

## 🔧 Method 3: Using API Directly (Advanced)

### Step 1: Register User A

```bash
curl -X POST http://localhost:3001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test-a@example.com",
      "password": "password123",
      "first_name": "Test",
      "last_name": "UserA"
    }
  }'
```

### Step 2: Confirm Email & Login as User A

(After confirming email via link)

```bash
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test-a@example.com",
    "password": "password123"
  }'
```

Save the token from response: `TOKEN_A="legastream_token_..."`

### Step 3: Upload Document as User A

```bash
curl -X POST http://localhost:3001/api/v1/documents \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN_A" \
  -d '{
    "filename": "contract-a.pdf",
    "size": 50000,
    "type": "application/pdf"
  }'
```

### Step 4: Check User A's Documents

```bash
curl http://localhost:3001/api/v1/documents \
  -H "Authorization: Bearer $TOKEN_A"
```

Response:
```json
{
  "documents": [{"id": 1, "filename": "contract-a.pdf", ...}],
  "total": 1
}
```

### Step 5: Register User B (New User)

```bash
curl -X POST http://localhost:3001/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test-b@example.com",
      "password": "password456",
      "first_name": "Test",
      "last_name": "UserB"
    }
  }'
```

### Step 6: Confirm Email & Login as User B

```bash
curl -X POST http://localhost:3001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test-b@example.com",
    "password": "password456"
  }'
```

Save the token: `TOKEN_B="legastream_token_..."`

### Step 7: Check User B's Documents (FRESH START!)

```bash
curl http://localhost:3001/api/v1/documents \
  -H "Authorization: Bearer $TOKEN_B"
```

Response:
```json
{
  "documents": [],
  "total": 0
}
```

**Result: User B has 0 documents! Fresh start confirmed! ✅**

### Step 8: Verify User B Cannot Access User A's Document

```bash
curl http://localhost:3001/api/v1/documents/1 \
  -H "Authorization: Bearer $TOKEN_B"
```

Response:
```json
{
  "error": "Document not found or access denied"
}
```

**Result: Security confirmed! ✅**

---

## 📊 Method 4: Check Database Directly

### Step 1: Open Database

```bash
sqlite3 storage/legastream.db
```

### Step 2: View Users

```sql
SELECT id, email, first_name, last_name FROM users;
```

Output:
```
1|admin@legastream.com|Admin|User
2|alice@test.com|Alice|Anderson
3|bob@test.com|Bob|Brown
```

### Step 3: View Documents with User IDs

```sql
SELECT id, user_id, filename, status FROM documents;
```

Output:
```
1|2|contract-a1.pdf|completed
2|2|contract-a2.pdf|completed
3|2|contract-a3.pdf|processing
4|3|agreement-b1.pdf|completed
```

**Observation:**
- Alice (user_id=2) has 3 documents
- Bob (user_id=3) has 1 document
- Each document is linked to its owner via user_id

### Step 4: Simulate User Query

```sql
-- What Alice sees (user_id = 2)
SELECT * FROM documents WHERE user_id = 2;
-- Result: 3 documents

-- What Bob sees (user_id = 3)
SELECT * FROM documents WHERE user_id = 3;
-- Result: 1 document

-- What a new user sees (user_id = 4, no documents yet)
SELECT * FROM documents WHERE user_id = 4;
-- Result: 0 documents (FRESH START!)
```

---

## ✅ Expected Results Summary

### For Existing User (Alice):
```
✓ Sees their own documents
✓ Dashboard shows their document count
✓ Cannot see other users' documents
✓ Stats reflect only their data
```

### For New User (Bob):
```
✓ Sees 0 documents (fresh start)
✓ Dashboard shows 0 documents processed
✓ Cannot see Alice's documents
✓ Stats show all zeros
✓ Clean slate to start building
```

### Security Verification:
```
✓ User B cannot access User A's documents via API
✓ User B cannot see User A's documents in UI
✓ Database queries filter by user_id
✓ Complete data isolation
```

---

## 🎯 Quick Checklist

Use this checklist to verify fresh start:

- [ ] Created User A
- [ ] Uploaded documents as User A
- [ ] User A sees their documents
- [ ] Created User B (new user)
- [ ] User B sees 0 documents (fresh start!)
- [ ] User B's dashboard shows 0 processed
- [ ] User B cannot see User A's documents
- [ ] Switched back to User A
- [ ] User A still sees only their documents
- [ ] User A cannot see User B's documents
- [ ] Complete isolation confirmed!

---

## 🚨 What to Look For

### ✅ CORRECT Behavior:
- New user sees empty documents list
- New user's dashboard shows all zeros
- Each user sees only their own data
- Attempting to access another user's document returns 404

### ❌ INCORRECT Behavior (Should NOT happen):
- New user sees other users' documents
- Dashboard shows documents from other users
- Can access documents by guessing IDs
- Stats include other users' data

---

## 💡 Tips

1. **Use Different Browsers:** Test User A in Chrome, User B in Firefox for easy switching
2. **Use Incognito Mode:** Each incognito window is a separate session
3. **Check Email:** Make sure to confirm emails before testing
4. **Clear LocalStorage:** If needed, clear browser storage between tests
5. **Check Network Tab:** See the actual API responses in DevTools

---

## 🎉 Conclusion

After following any of these methods, you should confirm:

**✅ Every new user starts with:**
- 0 documents
- Empty dashboard
- Clean slate
- No access to other users' data

**✅ Complete user isolation:**
- Each user sees only their own documents
- No data leakage between users
- Secure and private workspaces

**Status: FRESH START VERIFIED! 🎉**

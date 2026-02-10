# SMTP Configuration - Quick Setup Guide

## Choose Your Email Service

### Option 1: Gmail (Easiest for Testing) ⭐ RECOMMENDED

**Best for:** Quick testing, personal projects

**Steps:**
1. Go to your Google Account: https://myaccount.google.com/
2. Enable 2-Factor Authentication (Security → 2-Step Verification)
3. Generate App Password:
   - Go to: https://myaccount.google.com/apppasswords
   - Select "Mail" and "Windows Computer"
   - Click "Generate"
   - Copy the 16-character password (remove spaces)
4. Update `.env` file with:
   ```env
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USERNAME=your-email@gmail.com
   SMTP_PASSWORD=your-16-char-app-password
   ```

**Limits:** 500 emails/day (plenty for testing)

---

### Option 2: SendGrid (Professional)

**Best for:** Production applications, reliable delivery

**Steps:**
1. Sign up at: https://sendgrid.com/
2. Verify your email
3. Create API Key:
   - Settings → API Keys → Create API Key
   - Give it "Full Access"
   - Copy the API key
4. Update `.env` file with:
   ```env
   SMTP_HOST=smtp.sendgrid.net
   SMTP_PORT=587
   SMTP_USERNAME=apikey
   SMTP_PASSWORD=your-sendgrid-api-key
   ```

**Limits:** 100 emails/day (free tier)

---

### Option 3: Mailgun

**Best for:** Developers, good documentation

**Steps:**
1. Sign up at: https://www.mailgun.com/
2. Verify your domain (or use sandbox domain for testing)
3. Get SMTP credentials from Dashboard
4. Update `.env` file with:
   ```env
   SMTP_HOST=smtp.mailgun.org
   SMTP_PORT=587
   SMTP_USERNAME=postmaster@your-domain.mailgun.org
   SMTP_PASSWORD=your-mailgun-smtp-password
   ```

**Limits:** 5,000 emails/month (free tier)

---

### Option 4: Outlook/Hotmail

**Best for:** If you have Microsoft account

**Steps:**
1. Enable 2FA on your Microsoft account
2. Generate App Password
3. Update `.env` file with:
   ```env
   SMTP_HOST=smtp-mail.outlook.com
   SMTP_PORT=587
   SMTP_USERNAME=your-email@outlook.com
   SMTP_PASSWORD=your-app-password
   ```

---

## After Configuration

Once you've updated the `.env` file:

1. **Restart the server:**
   ```powershell
   # Stop current servers (Ctrl+C in both windows)
   # Then start again:
   .\start-production.ps1
   ```

2. **Test email sending:**
   - Register a new user
   - Check your email inbox for confirmation
   - Click the confirmation link
   - Login successfully

## Troubleshooting

**"SMTP-AUTH requested but missing user name"**
- Make sure SMTP_USERNAME and SMTP_PASSWORD are set in `.env`
- Remove any quotes around the values

**"Authentication failed"**
- For Gmail: Make sure you're using App Password, not regular password
- Check that 2FA is enabled
- Verify credentials are correct

**"Connection refused"**
- Check SMTP_HOST and SMTP_PORT are correct
- Verify your internet connection
- Some networks block SMTP ports

**Emails not arriving:**
- Check spam/junk folder
- Verify sender email is correct
- For Gmail: Check "Less secure app access" settings

## Quick Test

After configuration, test with this command:

```powershell
# Register a test user
Invoke-RestMethod -Uri "http://localhost:3001/api/v1/auth/register" -Method POST -ContentType "application/json" -Body '{"user":{"email":"test@example.com","password":"password123","first_name":"Test","last_name":"User"}}'
```

Check the server logs for email sending status!
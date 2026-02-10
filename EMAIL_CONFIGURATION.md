# Email Configuration Guide

## Current Status

**Development Mode (Recommended for Testing):**
- ✅ Email confirmation is **BYPASSED**
- ✅ Users can register and login immediately
- ⚠️ Emails are attempted but not delivered (SMTP not configured)

**Production Mode:**
- ❌ Requires email confirmation
- ❌ Users cannot login until email is confirmed
- ❌ Emails won't be sent without SMTP configuration

## Option 1: Continue Using Development Mode (Easiest)

This is what's currently running and working perfectly:

```powershell
.\start-development.ps1
```

**Pros:**
- No email configuration needed
- Users can test immediately
- All features work
- Perfect for development and testing

**Cons:**
- Email confirmation is bypassed
- Not suitable for production deployment

## Option 2: Configure Real Email Delivery

To send actual emails, you need to configure SMTP settings.

### Step 1: Choose an Email Service

**Popular Options:**

1. **Gmail** (Free, easy for testing)
   - Use your Gmail account
   - Need to enable "App Passwords"

2. **SendGrid** (Free tier: 100 emails/day)
   - Professional email service
   - Easy setup

3. **Mailgun** (Free tier: 5,000 emails/month)
   - Developer-friendly
   - Good for production

4. **Amazon SES** (Very cheap, scalable)
   - $0.10 per 1,000 emails
   - Best for production

### Step 2: Update .env File

Create or update your `.env` file with SMTP credentials:

```env
# For Gmail (Example)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# For SendGrid (Example)
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USERNAME=apikey
SMTP_PASSWORD=your-sendgrid-api-key

# For Mailgun (Example)
SMTP_HOST=smtp.mailgun.org
SMTP_PORT=587
SMTP_USERNAME=postmaster@your-domain.mailgun.org
SMTP_PASSWORD=your-mailgun-password
```

### Step 3: Gmail Setup (Detailed Example)

If using Gmail:

1. **Enable 2-Factor Authentication** on your Google account
2. **Generate App Password:**
   - Go to: https://myaccount.google.com/apppasswords
   - Select "Mail" and "Windows Computer"
   - Copy the 16-character password
3. **Update .env:**
   ```env
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USERNAME=your-email@gmail.com
   SMTP_PASSWORD=your-16-char-app-password
   ```

### Step 4: Start in Production Mode

```powershell
.\start-production.ps1
```

Now emails will be sent for:
- ✉️ Registration confirmation
- ✉️ Password reset
- ✉️ Welcome messages

## Option 3: Use Console Email Delivery (Testing)

For testing email content without sending real emails, you can modify the production server to log emails to console instead.

Update `production_server.rb`:

```ruby
def setup_email
  Mail.defaults do
    delivery_method :test  # This will capture emails without sending
  end
end
```

Then you can inspect emails in the server logs.

## Current Recommendation

**For your current use case, I recommend:**

✅ **Keep using Development Mode** (`start-development.ps1`)

**Reasons:**
1. You're testing and developing the application
2. No need for real email delivery yet
3. Faster user testing (no email confirmation wait)
4. All features work perfectly
5. Can configure emails later when deploying to production

## When to Configure Real Emails

Configure SMTP when you:
- Deploy to production
- Need to test email templates
- Want real user email verification
- Are ready for public users

## Testing Email Templates

If you want to see what the emails look like without sending them, check:
- `production_server.rb` lines 557-572 (confirmation email)
- `production_server.rb` lines 574-589 (password reset email)

Current email templates:

**Confirmation Email:**
```
Hi [Name],

Please confirm your account by clicking this link:
http://localhost:5175/confirm-email?token=[TOKEN]

Thanks,
LegaStream Team
```

**Password Reset Email:**
```
Hi [Name],

Reset your password by clicking this link:
http://localhost:5175/reset-password?token=[TOKEN]

This link expires in 2 hours.

Thanks,
LegaStream Team
```

## Summary

| Mode | Email Confirmation | SMTP Required | Best For |
|------|-------------------|---------------|----------|
| **Development** | Bypassed | ❌ No | Testing, Development |
| **Production** | Required | ✅ Yes | Live deployment |

**Current Status:** Running in Development Mode - No email configuration needed! 🎉
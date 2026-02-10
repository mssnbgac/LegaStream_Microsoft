# Gmail App Password Setup Guide

## Step-by-Step Instructions

### 1. Enable 2-Factor Authentication (if not already enabled)
1. Go to: https://myaccount.google.com/security
2. Click on "2-Step Verification"
3. Follow the prompts to enable it

### 2. Generate App Password
1. Go to: https://myaccount.google.com/apppasswords
2. You might need to sign in again
3. Select "Mail" for the app
4. Select "Other (Custom name)" for the device
5. Enter "LegaStream" as the name
6. Click "Generate"
7. **Copy the 16-character password** (it will look like: `abcd efgh ijkl mnop`)

### 3. Update .env File
1. Open `.env` file in your project
2. Update the SMTP_PASSWORD line:
   ```
   SMTP_PASSWORD=your-16-character-password-here
   ```
   (Remove spaces from the password)

### 4. Restart Server
```bash
# Stop current server (Ctrl+C in terminal)
# Or I can restart it for you

# Start server again
ruby production_server.rb
```

### 5. Test Email
```bash
ruby test_email.rb
```

## Troubleshooting

### "App passwords" option not available
- Make sure 2-Factor Authentication is enabled first
- Wait a few minutes after enabling 2FA
- Try signing out and back in to Google

### Emails still not sending
- Check spam folder
- Verify the app password has no spaces
- Make sure you're using the correct Gmail account
- Check Gmail's sending limits (500 emails/day)

### Alternative: Use Different Email Service
If Gmail doesn't work, you can use:
- **SendGrid** (free tier: 100 emails/day)
- **Mailgun** (free tier: 5,000 emails/month)
- **AWS SES** (very cheap, reliable)

---

**Current SMTP Settings:**
- Host: smtp.gmail.com
- Port: 587
- Username: enginboy20@gmail.com
- Password: (needs to be regenerated)

# Gmail SMTP Setup for Email Confirmation

## Overview
This guide will help you configure Gmail SMTP so that **every new user must confirm their email** before they can log in to LegaStream.

## What Will Happen After Setup

1. ✅ User registers with their email
2. ✅ System sends confirmation email to their inbox
3. ✅ User clicks the confirmation link in the email
4. ✅ Email is verified and user can now log in
5. ❌ Users **cannot log in** without confirming their email first

## Step-by-Step Gmail Configuration

### Step 1: Enable 2-Factor Authentication

1. Go to your Google Account: https://myaccount.google.com/security
2. Click on **"2-Step Verification"**
3. Follow the prompts to enable it (you'll need your phone)
4. Complete the setup

### Step 2: Generate App Password

1. Go to: https://myaccount.google.com/apppasswords
   - If you don't see this option, make sure 2FA is enabled first
2. You might need to sign in again
3. Under **"Select app"** choose **"Mail"**
4. Under **"Select device"** choose **"Windows Computer"** (or "Other")
5. Click **"Generate"**
6. You'll see a 16-character password like: `abcd efgh ijkl mnop`
7. **Copy this password** (you can remove the spaces to get: `abcdefghijklmnop`)

### Step 3: Update .env File

Open the `.env` file in your project root and update these lines:

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-actual-email@gmail.com
SMTP_PASSWORD=abcdefghijklmnop
```

**Replace:**
- `your-actual-email@gmail.com` with your Gmail address
- `abcdefghijklmnop` with your 16-character App Password

**Example:**
```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=john.doe@gmail.com
SMTP_PASSWORD=xyzw1234abcd5678
```

### Step 4: Start the Application

Run the production startup script:

```powershell
.\start-production.ps1
```

This will start both the backend and frontend servers.

### Step 5: Test Email Confirmation

1. **Register a new user:**
   - Go to: http://localhost:5175/register
   - Fill in the registration form with a real email address
   - Click "Create Account"

2. **Check your email:**
   - Open your email inbox
   - Look for an email from LegaStream
   - Subject: "Confirm your LegaStream account"

3. **Click the confirmation link:**
   - Click the link in the email
   - You'll be redirected to the confirmation page
   - You should see "Email Confirmed!" message

4. **Log in:**
   - Go to: http://localhost:5175/login
   - Enter your email and password
   - You should now be able to log in successfully

## Email Template

Users will receive an email like this:

```
From: noreply@legastream.com
To: user@example.com
Subject: Confirm your LegaStream account

Hi [First Name],

Please confirm your account by clicking this link:
http://localhost:5175/confirm-email?token=[UNIQUE_TOKEN]

Thanks,
LegaStream Team
```

## Troubleshooting

### "SMTP-AUTH requested but missing user name"
- Make sure you've updated the `.env` file with your credentials
- Restart the server after updating `.env`
- Check that there are no extra spaces in the credentials

### "Authentication failed"
- Verify you're using the **App Password**, not your regular Gmail password
- Make sure 2-Factor Authentication is enabled
- Try generating a new App Password

### "Connection refused" or "Connection timeout"
- Check your internet connection
- Some corporate networks block SMTP ports (587)
- Try using port 465 instead (update SMTP_PORT=465 in .env)

### Emails not arriving
- Check your spam/junk folder
- Verify the email address is correct
- Check Gmail's "Sent" folder to confirm emails are being sent
- Wait a few minutes (sometimes there's a delay)

### "Invalid confirmation token"
- The token might have expired (tokens don't expire in current setup)
- User might have clicked an old confirmation link
- Ask user to register again

## Security Notes

✅ **Safe to use:**
- App Passwords are specific to applications
- They can be revoked anytime without changing your Gmail password
- They don't give access to your full Google account

✅ **Best practices:**
- Don't share your App Password
- Don't commit the `.env` file to version control (it's in .gitignore)
- Revoke App Passwords you're not using

## Gmail Sending Limits

- **Free Gmail accounts:** 500 emails per day
- **Google Workspace accounts:** 2,000 emails per day

This is more than enough for most applications!

## Alternative: Using a Dedicated Email

For production, consider creating a dedicated Gmail account like:
- `noreply@yourdomain.com` (if you have Google Workspace)
- `legastream.notifications@gmail.com` (free Gmail)

This keeps your personal email separate from application emails.

## Next Steps

Once email confirmation is working:

1. ✅ Test with multiple email addresses
2. ✅ Verify confirmation links work correctly
3. ✅ Test password reset emails (also uses SMTP)
4. ✅ Consider customizing email templates in `production_server.rb`
5. ✅ For production deployment, consider using a professional email service like SendGrid

## Support

If you encounter issues:
1. Check the server logs for error messages
2. Verify your Gmail credentials are correct
3. Make sure 2FA and App Password are properly set up
4. Try the troubleshooting steps above

---

**Ready to configure?** Update your `.env` file with your Gmail credentials and restart the server!
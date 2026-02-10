# 🚀 Quick Start: Deploy to Railway in 10 Minutes

## Prerequisites
- GitHub account
- Railway account (sign up at https://railway.app)
- Your LegaStream code pushed to GitHub

---

## Step-by-Step Deployment

### 1. Push Code to GitHub (5 minutes)

```powershell
# Initialize git (if not already done)
git init

# Add all files
git add .

# Commit
git commit -m "Ready for deployment"

# Add your GitHub repository as remote
git remote add origin https://github.com/YOUR_USERNAME/legastream.git

# Push to GitHub
git push -u origin main
```

### 2. Deploy to Railway (3 minutes)

1. **Go to Railway**: https://railway.app
2. **Click "Start a New Project"**
3. **Select "Deploy from GitHub repo"**
4. **Choose your LegaStream repository**
5. **Railway will automatically detect and deploy**

### 3. Add Environment Variables (2 minutes)

In Railway dashboard, go to your project → Variables tab, and add:

```
AI_PROVIDER=gemini
GEMINI_API_KEY=AIzaSyCgDuGe3beNs2wVq-KXYhWHPJ0SAP8340g
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=enginboy20@gmail.com
SMTP_PASSWORD=eujozeqwjzbzclhw
APP_ENV=production
DEVELOPMENT_MODE=false
```

### 4. Get Your Public URL

Railway will provide a URL like: `https://legastream-production.up.railway.app`

**That's it! Your app is live! 🎉**

---

## Testing Your Deployment

1. Open the Railway-provided URL
2. Register a new account
3. Upload a test document
4. Verify AI analysis works

---

## Troubleshooting

### Build Failed?
- Check Railway logs in the dashboard
- Ensure all dependencies are in Gemfile and package.json

### App Not Starting?
- Verify environment variables are set correctly
- Check that PORT is not hardcoded (Railway assigns it dynamically)

### Database Issues?
- Railway provides PostgreSQL automatically
- Update database.yml if needed

---

## Next Steps

### Optional: Add Custom Domain
1. Go to Railway project settings
2. Click "Domains"
3. Add your custom domain
4. Update DNS records as instructed

### Optional: Set Up Monitoring
1. Enable Railway metrics
2. Set up alerts for errors
3. Monitor API usage

---

## Cost Estimate

**Railway Pricing**:
- Free: $5 credit/month (good for testing)
- Hobby: $5/month (good for small production)
- Pro: $20/month (for scaling)

**Your app will likely cost**: $5-10/month for moderate usage

---

## Support

If you encounter issues:
1. Check Railway logs
2. Review CLOUD_DEPLOYMENT_GUIDE.md
3. Contact Railway support (very responsive)

---

**Your app is now accessible worldwide! Share the URL with your users.** 🌍

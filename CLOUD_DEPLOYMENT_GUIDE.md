# 🚀 LegaStream Cloud Deployment Guide

## Overview
This guide will help you deploy LegaStream to the cloud so it's accessible from anywhere with a public URL.

---

## 🎯 Recommended Platform: Railway.app

**Why Railway?**
- ✅ Free tier available ($5 credit/month)
- ✅ Automatic HTTPS
- ✅ Easy deployment from GitHub
- ✅ Built-in PostgreSQL (better than SQLite for production)
- ✅ Environment variable management
- ✅ Automatic deployments on git push

**Cost**: ~$5-10/month for small-scale production

---

## Option 1: Deploy to Railway (Recommended)

### Step 1: Prepare Your Code

1. **Create a GitHub repository** (if you haven't already):
   ```powershell
   git init
   git add .
   git commit -m "Initial commit - LegaStream ready for deployment"
   ```

2. **Push to GitHub**:
   - Create a new repository on GitHub.com
   - Follow GitHub's instructions to push your code

### Step 2: Sign Up for Railway

1. Go to https://railway.app
2. Sign up with your GitHub account
3. Click "New Project"
4. Select "Deploy from GitHub repo"
5. Choose your LegaStream repository

### Step 3: Configure Environment Variables

In Railway dashboard, add these environment variables:

```env
# Database (Railway provides this automatically)
DATABASE_URL=<Railway will set this>

# Application
APP_NAME=LegaStream
APP_VERSION=3.0.0
APP_ENV=production
DEVELOPMENT_MODE=false

# Email (Gmail SMTP)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=enginboy20@gmail.com
SMTP_PASSWORD=eujozeqwjzbzclhw

# AI Configuration
AI_PROVIDER=gemini
GEMINI_API_KEY=AIzaSyCgDuGe3beNs2wVq-KXYhWHPJ0SAP8340g

# Frontend URL (Railway will provide this)
FRONTEND_URL=https://your-app.railway.app
```

### Step 4: Add Railway Configuration Files

I'll create these files for you in the next step.

### Step 5: Deploy

Railway will automatically:
1. Detect your Ruby and Node.js apps
2. Build both backend and frontend
3. Deploy them
4. Provide you with a public URL

**Your app will be live at**: `https://your-app-name.railway.app`

---

## Option 2: Deploy to Render.com

**Why Render?**
- ✅ Free tier available
- ✅ Automatic HTTPS
- ✅ Easy setup
- ✅ Good for small projects

**Cost**: Free tier available, paid plans start at $7/month

### Steps:

1. Go to https://render.com
2. Sign up with GitHub
3. Create a "Web Service" for backend
4. Create a "Static Site" for frontend
5. Configure environment variables (same as Railway)
6. Deploy

---

## Option 3: Deploy to Heroku

**Why Heroku?**
- ✅ Well-established platform
- ✅ Good documentation
- ✅ Many add-ons available

**Cost**: ~$7-16/month (no free tier anymore)

### Steps:

1. Install Heroku CLI
2. Create Heroku app: `heroku create legastream`
3. Add PostgreSQL: `heroku addons:create heroku-postgresql:mini`
4. Set environment variables: `heroku config:set KEY=VALUE`
5. Deploy: `git push heroku main`

---

## Option 4: Deploy to DigitalOcean App Platform

**Why DigitalOcean?**
- ✅ Reliable infrastructure
- ✅ Good performance
- ✅ Predictable pricing

**Cost**: ~$12/month

### Steps:

1. Go to https://cloud.digitalocean.com
2. Create new App
3. Connect GitHub repository
4. Configure build settings
5. Add environment variables
6. Deploy

---

## 🔧 Required Configuration Files

I'll create these files to make deployment easier:

1. **Procfile** - Tells the platform how to run your app
2. **railway.json** - Railway-specific configuration
3. **render.yaml** - Render-specific configuration
4. **Dockerfile** - For containerized deployment
5. **.buildpacks** - Specifies Ruby and Node.js

---

## 📊 Database Migration

When deploying to cloud, you'll need to:

1. **Switch from SQLite to PostgreSQL** (recommended for production)
2. **Run migrations** on the cloud database
3. **Update database configuration**

I can help you with this in the next step.

---

## 🔒 Security Checklist

Before deploying:

- [ ] Change `DEVELOPMENT_MODE=false` in production
- [ ] Use strong passwords
- [ ] Enable HTTPS (automatic on most platforms)
- [ ] Set up proper CORS headers
- [ ] Review API rate limits
- [ ] Set up monitoring and logging

---

## 📱 After Deployment

Once deployed, you'll get a public URL like:
- Railway: `https://legastream.railway.app`
- Render: `https://legastream.onrender.com`
- Heroku: `https://legastream.herokuapp.com`

You can then:
1. Share this URL with users
2. Set up a custom domain (optional)
3. Monitor usage and performance
4. Scale as needed

---

## 💰 Cost Comparison

| Platform | Free Tier | Paid Tier | Best For |
|----------|-----------|-----------|----------|
| Railway | $5 credit/month | ~$5-10/month | Small to medium apps |
| Render | Yes (limited) | $7/month | Small projects |
| Heroku | No | $7-16/month | Established apps |
| DigitalOcean | No | $12/month | Predictable costs |

---

## 🎯 My Recommendation

**Start with Railway** because:
1. Easiest setup
2. Free $5 credit to start
3. Automatic HTTPS
4. Good performance
5. Easy to scale later

---

## Next Steps

Would you like me to:
1. **Create the deployment configuration files** for Railway?
2. **Help you set up PostgreSQL** instead of SQLite?
3. **Create a step-by-step deployment script**?
4. **Set up a custom domain**?

Let me know which platform you prefer, and I'll help you deploy!

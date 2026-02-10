# 🆓 FREE Cloud Deployment Guide for LegaStream

## 100% Free Options for Your App

This guide shows you how to deploy LegaStream **completely free** using platforms with generous free tiers.

---

## 🎯 Best Free Option: Render.com

**Why Render?**
- ✅ **Completely FREE** (no credit card required)
- ✅ Automatic HTTPS
- ✅ 750 hours/month free (enough for 24/7)
- ✅ PostgreSQL database included
- ✅ Easy GitHub integration
- ✅ Auto-deploy on git push

**Limitations:**
- App sleeps after 15 minutes of inactivity (wakes up in ~30 seconds)
- 512MB RAM
- Shared CPU

**Perfect for**: Testing, demos, small user base

---

## 🚀 Deploy to Render (FREE) - 15 Minutes

### Step 1: Prepare Your Code (5 minutes)

1. **Push to GitHub**:
```powershell
git init
git add .
git commit -m "Ready for free deployment"
git remote add origin https://github.com/YOUR_USERNAME/legastream.git
git push -u origin main
```

### Step 2: Sign Up for Render (2 minutes)

1. Go to https://render.com
2. Click "Get Started for Free"
3. Sign up with GitHub (no credit card needed!)
4. Authorize Render to access your repositories

### Step 3: Deploy Backend (4 minutes)

1. **Click "New +" → "Web Service"**
2. **Connect your repository**: Select your LegaStream repo
3. **Configure**:
   - Name: `legastream-api`
   - Environment: `Ruby`
   - Build Command: `bundle install`
   - Start Command: `ruby production_server.rb`
   - Plan: **Free** ✅

4. **Add Environment Variables**:
   Click "Advanced" → "Add Environment Variable":
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

5. **Click "Create Web Service"**

Render will give you a URL like: `https://legastream-api.onrender.com`

### Step 4: Deploy Frontend (4 minutes)

1. **Click "New +" → "Static Site"**
2. **Connect same repository**
3. **Configure**:
   - Name: `legastream-frontend`
   - Build Command: `cd frontend && npm install && npm run build`
   - Publish Directory: `frontend/dist`
   - Plan: **Free** ✅

4. **Add Environment Variable**:
   ```
   VITE_API_URL=https://legastream-api.onrender.com
   ```

5. **Click "Create Static Site"**

Frontend URL: `https://legastream-frontend.onrender.com`

### Step 5: Update Frontend API URL

Update `frontend/src/utils/auth.js` to use the Render backend URL:
```javascript
const API_URL = import.meta.env.VITE_API_URL || 'https://legastream-api.onrender.com';
```

**Done! Your app is live for FREE!** 🎉

---

## 🌟 Alternative Free Option: Railway (with $5 credit)

**Why Railway?**
- ✅ $5 free credit/month (no credit card for trial)
- ✅ Better performance than Render free tier
- ✅ No sleep time
- ✅ Easier setup

**Limitations:**
- $5 credit runs out after ~150 hours
- Need credit card after trial

### Quick Deploy to Railway:

1. Go to https://railway.app
2. Sign up with GitHub
3. Click "New Project" → "Deploy from GitHub repo"
4. Select your repository
5. Add environment variables (same as above)
6. Get your URL: `https://legastream.up.railway.app`

**Cost**: FREE for first month, then ~$5/month

---

## 💡 Hybrid Free Option: Vercel + Render

Deploy frontend on Vercel (better free tier) and backend on Render:

### Frontend on Vercel (FREE):
1. Go to https://vercel.com
2. Import your GitHub repo
3. Set root directory to `frontend`
4. Deploy

### Backend on Render (FREE):
Follow Render backend steps above

**Benefits:**
- Frontend never sleeps
- Faster frontend performance
- Still 100% free

---

## 🔧 Optimizations for Free Tier

### 1. Keep App Awake (Render)
Create a free UptimeRobot account to ping your app every 5 minutes:
- Go to https://uptimerobot.com
- Add monitor for your Render URL
- Prevents sleep (within free tier limits)

### 2. Reduce Database Size
Free tier has storage limits:
- Regularly clean old documents
- Compress uploaded files
- Use external storage for large files

### 3. Optimize Performance
- Enable caching
- Minimize API calls
- Compress responses

---

## 📊 Free Tier Comparison

| Platform | Cost | Sleep Time | Database | Best For |
|----------|------|------------|----------|----------|
| **Render** | FREE | 15 min idle | PostgreSQL | Best overall free |
| **Railway** | $5 credit | No sleep | PostgreSQL | Better performance |
| **Vercel** | FREE | No sleep | None | Frontend only |
| **Fly.io** | FREE | No sleep | Limited | Advanced users |

---

## ⚠️ Free Tier Limitations

### Render Free Tier:
- ✅ 750 hours/month (24/7 coverage)
- ✅ 512MB RAM
- ✅ 100GB bandwidth
- ⚠️ Sleeps after 15 min inactivity
- ⚠️ Slower cold starts (~30 seconds)

### What This Means:
- Perfect for demos and testing
- Good for small user base (<100 users)
- First request after idle takes 30 seconds
- Subsequent requests are fast

---

## 🎯 Recommended Free Setup

**For Testing/Demo:**
```
Frontend: Render Static Site (FREE)
Backend: Render Web Service (FREE)
Database: Render PostgreSQL (FREE)
```

**For Better Performance:**
```
Frontend: Vercel (FREE)
Backend: Railway ($5 credit)
Database: Railway PostgreSQL
```

**For Maximum Free:**
```
Frontend: Vercel (FREE)
Backend: Render (FREE)
Database: Render PostgreSQL (FREE)
Monitoring: UptimeRobot (FREE)
```

---

## 📝 Step-by-Step: Render Free Deployment

I've created a detailed `render.yaml` file for you. Here's how to use it:

1. **Push code to GitHub** (with render.yaml included)
2. **Go to Render dashboard**
3. **Click "New +" → "Blueprint"**
4. **Connect your repository**
5. **Render reads render.yaml and sets everything up automatically**
6. **Add your environment variables**
7. **Deploy!**

Your app will be live at:
- Backend: `https://legastream-api.onrender.com`
- Frontend: `https://legastream-frontend.onrender.com`

---

## 🆘 Troubleshooting Free Tier

### App is Slow
- **Cause**: Cold start after sleep
- **Solution**: Use UptimeRobot to keep awake

### Out of Memory
- **Cause**: 512MB RAM limit
- **Solution**: Optimize code, reduce memory usage

### Build Failed
- **Cause**: Missing dependencies
- **Solution**: Check build logs, ensure all deps in Gemfile/package.json

### Database Full
- **Cause**: Free tier storage limit
- **Solution**: Clean old data, compress files

---

## 💰 When to Upgrade

Stay on free tier if:
- ✅ <100 users
- ✅ Low traffic
- ✅ Testing/demo
- ✅ Can tolerate 30s cold starts

Upgrade to paid if:
- ❌ >100 active users
- ❌ Need instant response
- ❌ High traffic
- ❌ Business-critical

---

## 🎉 Your Free Deployment Checklist

- [ ] Code pushed to GitHub
- [ ] Render account created (no credit card!)
- [ ] Backend deployed on Render
- [ ] Frontend deployed on Render or Vercel
- [ ] Environment variables added
- [ ] App tested and working
- [ ] (Optional) UptimeRobot monitoring set up

---

## 🚀 Next Steps

1. **Deploy now**: Follow the Render steps above
2. **Test your app**: Upload a document and verify it works
3. **Share the URL**: Give it to friends/colleagues
4. **Monitor usage**: Check if free tier is enough
5. **Upgrade later**: If you need more power

---

**Your app can be live and FREE in 15 minutes!**

Open this guide and start deploying! 🎯

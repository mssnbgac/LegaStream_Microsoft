# 🆓 Deploy LegaStream FREE in 10 Minutes

## Quick Start - Render.com (100% FREE)

### 1. Push to GitHub (2 minutes)
```powershell
git init
git add .
git commit -m "Deploy to Render"
git remote add origin https://github.com/YOUR_USERNAME/legastream.git
git push -u origin main
```

### 2. Sign Up (1 minute)
- Go to https://render.com
- Click "Get Started for Free"
- Sign up with GitHub
- **NO CREDIT CARD REQUIRED!** ✅

### 3. Deploy (7 minutes)

#### Backend:
1. Click "New +" → "Web Service"
2. Select your repo
3. Settings:
   - Name: `legastream-api`
   - Environment: `Ruby`
   - Build: `bundle install`
   - Start: `ruby production_server.rb`
   - **Plan: FREE** ✅

4. Environment Variables (click "Advanced"):
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

5. Click "Create Web Service"

#### Frontend:
1. Click "New +" → "Static Site"
2. Select same repo
3. Settings:
   - Name: `legastream-frontend`
   - Build: `cd frontend && npm install && npm run build`
   - Publish: `frontend/dist`
   - **Plan: FREE** ✅

4. Environment Variable:
   ```
   VITE_API_URL=https://legastream-api.onrender.com
   ```

5. Click "Create Static Site"

### 4. Done! 🎉

Your app is live at:
- **Frontend**: `https://legastream-frontend.onrender.com`
- **Backend**: `https://legastream-api.onrender.com`

---

## ⚡ What You Get (FREE)

✅ **Public URL** - Share with anyone
✅ **HTTPS** - Automatic SSL certificate
✅ **Database** - PostgreSQL included
✅ **750 hours/month** - Enough for 24/7
✅ **Auto-deploy** - Push to GitHub = auto update
✅ **No credit card** - Completely free

---

## ⚠️ Free Tier Notes

- App sleeps after 15 min of no activity
- Wakes up in ~30 seconds on first request
- Perfect for demos, testing, small projects
- Upgrade to paid ($7/mo) for no sleep

---

## 🔥 Keep App Awake (Optional)

Use UptimeRobot to ping your app every 5 minutes:
1. Go to https://uptimerobot.com (free)
2. Add monitor for your Render URL
3. Set interval to 5 minutes
4. App stays awake!

---

## 🆘 Troubleshooting

**Build Failed?**
- Check Render logs
- Ensure Gemfile and package.json are complete

**App Not Loading?**
- Wait 30 seconds (cold start)
- Check environment variables
- Review Render logs

**Database Error?**
- Render creates PostgreSQL automatically
- Check DATABASE_URL is set

---

## 📱 Test Your Deployment

1. Open your frontend URL
2. Register a new account
3. Upload a PDF document
4. Verify AI analysis works
5. Share the URL!

---

## 💰 Cost Breakdown

| Item | Cost |
|------|------|
| Render Web Service | **FREE** |
| Render Static Site | **FREE** |
| PostgreSQL Database | **FREE** |
| HTTPS Certificate | **FREE** |
| **TOTAL** | **$0.00/month** |

---

## 🚀 You're Live!

Your LegaStream app is now:
- ✅ Deployed to the cloud
- ✅ Accessible worldwide
- ✅ Running 24/7
- ✅ Completely FREE

**Share your URL and start using it!**

---

## 📚 More Info

- Full guide: `FREE_DEPLOYMENT_GUIDE.md`
- All platforms: `CLOUD_DEPLOYMENT_GUIDE.md`
- Checklist: `PRE_DEPLOYMENT_CHECKLIST.md`

---

**Need help? Check the guides or Render's documentation!**

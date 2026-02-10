# 🚀 Deploy YOUR LegaStream App - FREE in 10 Minutes

## Your GitHub Repository
✅ **Already on GitHub**: https://github.com/mssnbgac/LegaStream.git

Now let's deploy it to the cloud for FREE!

---

## 🎯 Deploy to Render.com (100% FREE)

### Step 1: Sign Up for Render (2 minutes)

1. Go to https://render.com
2. Click **"Get Started for Free"**
3. Click **"Sign in with GitHub"**
4. Authorize Render to access your repositories
5. **NO CREDIT CARD REQUIRED!** ✅

### Step 2: Deploy Backend API (4 minutes)

1. **In Render Dashboard**, click **"New +"** → **"Web Service"**

2. **Connect Repository**:
   - Find and select: `mssnbgac/LegaStream`
   - Click **"Connect"**

3. **Configure Service**:
   ```
   Name: legastream-api
   Environment: Ruby
   Build Command: bundle install
   Start Command: ruby production_server.rb
   Plan: Free ✅
   ```

4. **Add Environment Variables** (click "Advanced"):
   
   Click **"Add Environment Variable"** for each:
   
   ```
   AI_PROVIDER = gemini
   GEMINI_API_KEY = AIzaSyCgDuGe3beNs2wVq-KXYhWHPJ0SAP8340g
   SMTP_HOST = smtp.gmail.com
   SMTP_PORT = 587
   SMTP_USERNAME = enginboy20@gmail.com
   SMTP_PASSWORD = eujozeqwjzbzclhw
   APP_ENV = production
   DEVELOPMENT_MODE = false
   ```

5. Click **"Create Web Service"**

Render will start building your backend. This takes 3-5 minutes.

**Your backend URL**: `https://legastream-api.onrender.com` (or similar)

### Step 3: Deploy Frontend (4 minutes)

1. **In Render Dashboard**, click **"New +"** → **"Static Site"**

2. **Connect Same Repository**:
   - Select: `mssnbgac/LegaStream`
   - Click **"Connect"**

3. **Configure Static Site**:
   ```
   Name: legastream-frontend
   Build Command: cd frontend && npm install && npm run build
   Publish Directory: frontend/dist
   Plan: Free ✅
   ```

4. **Add Environment Variable**:
   
   Replace with YOUR backend URL from Step 2:
   ```
   VITE_API_URL = https://legastream-api.onrender.com
   ```

5. Click **"Create Static Site"**

Frontend build takes 2-3 minutes.

**Your frontend URL**: `https://legastream-frontend.onrender.com` (or similar)

---

## ✅ You're Live!

Your app is now deployed at:
- **Frontend**: https://legastream-frontend.onrender.com
- **Backend**: https://legastream-api.onrender.com

---

## 🧪 Test Your Deployment

1. **Open your frontend URL** in a browser
2. **Register a new account**
3. **Upload a PDF document**
4. **Verify AI analysis works**
5. **Share the URL with others!**

---

## 💰 Cost: $0.00/month

| Service | Cost |
|---------|------|
| Backend (Ruby) | FREE |
| Frontend (React) | FREE |
| PostgreSQL Database | FREE |
| HTTPS Certificate | FREE |
| **Total** | **$0.00** |

---

## ⚠️ Free Tier Notes

**What to expect:**
- ✅ App works perfectly
- ✅ Accessible 24/7
- ✅ Automatic HTTPS
- ⚠️ Sleeps after 15 min of inactivity
- ⚠️ Takes ~30 seconds to wake up on first request
- ⚠️ 512MB RAM limit

**Perfect for:**
- Testing and demos
- Small user base (<100 users)
- Portfolio projects
- Proof of concept

---

## 🔥 Keep App Awake (Optional)

To prevent sleep, use UptimeRobot (also free):

1. Go to https://uptimerobot.com
2. Sign up (free account)
3. Click **"Add New Monitor"**
4. Settings:
   ```
   Monitor Type: HTTP(s)
   Friendly Name: LegaStream
   URL: https://legastream-api.onrender.com/up
   Monitoring Interval: 5 minutes
   ```
5. Click **"Create Monitor"**

Your app will now stay awake!

---

## 🆘 Troubleshooting

### Build Failed?
- Check Render logs (click on your service → "Logs")
- Ensure all dependencies are in Gemfile and package.json
- Verify environment variables are set correctly

### App Not Loading?
- Wait 30 seconds (cold start after sleep)
- Check browser console for errors
- Verify backend URL in frontend env variable

### Database Error?
- Render creates PostgreSQL automatically
- Check if DATABASE_URL is set (Render does this automatically)

### AI Not Working?
- Verify GEMINI_API_KEY is set correctly
- Check Gemini API quota hasn't been exceeded
- App will fall back to regex if AI fails

---

## 📱 Share Your App

Your app is now live! Share these URLs:

**For Users**:
```
https://legastream-frontend.onrender.com
```

**API Endpoint** (for developers):
```
https://legastream-api.onrender.com
```

---

## 🔄 Auto-Deploy Updates

Whenever you push to GitHub, Render automatically redeploys!

```powershell
# Make changes to your code
git add .
git commit -m "Update feature"
git push origin main

# Render automatically deploys the update!
```

---

## 📊 Monitor Your App

In Render Dashboard you can:
- ✅ View logs
- ✅ Check metrics
- ✅ See deployment history
- ✅ Monitor uptime
- ✅ Set up email alerts

---

## 💡 Next Steps

### Now:
1. ✅ Test your deployed app
2. ✅ Share with friends/colleagues
3. ✅ Upload real documents

### Soon:
1. Set up UptimeRobot (keep app awake)
2. Add custom domain (optional)
3. Monitor usage

### Later:
1. Upgrade to paid tier if needed ($7/mo removes sleep)
2. Add more features
3. Scale as your user base grows

---

## 🎉 Congratulations!

You've successfully deployed LegaStream to the cloud!

**What you've accomplished:**
- ✅ Full-stack app deployed
- ✅ Real AI integration working
- ✅ Accessible from anywhere
- ✅ Professional hosting
- ✅ Completely FREE

**Your app is now live and ready for users!** 🚀

---

## 📚 Additional Resources

- **Full Free Guide**: `FREE_DEPLOYMENT_GUIDE.md`
- **All Platforms**: `CLOUD_DEPLOYMENT_GUIDE.md`
- **Checklist**: `PRE_DEPLOYMENT_CHECKLIST.md`
- **Render Docs**: https://render.com/docs

---

**Need help? Check Render's excellent documentation or their support chat!**

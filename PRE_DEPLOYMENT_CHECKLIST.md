# ✅ Pre-Deployment Checklist

Complete this checklist before deploying to production.

---

## 🔒 Security

- [ ] **Change DEVELOPMENT_MODE to false** in production environment
- [ ] **Review .env file** - ensure no sensitive data is committed to git
- [ ] **Update .gitignore** - ensure .env is ignored
- [ ] **Strong passwords** - verify all accounts use strong passwords
- [ ] **API keys secured** - store in environment variables, not code
- [ ] **CORS configured** - set proper allowed origins
- [ ] **Rate limiting** - consider adding rate limits to API endpoints

---

## 📁 Code Preparation

- [ ] **Git repository created** - code is in GitHub/GitLab
- [ ] **All changes committed** - no uncommitted changes
- [ ] **Dependencies listed** - Gemfile and package.json are complete
- [ ] **Configuration files added**:
  - [ ] Procfile
  - [ ] railway.json (if using Railway)
  - [ ] render.yaml (if using Render)
- [ ] **Database migrations ready** - all migrations are in db/migrate/
- [ ] **Static assets built** - frontend build works locally

---

## 🗄️ Database

- [ ] **SQLite replaced with PostgreSQL** (recommended for production)
- [ ] **Database migrations tested** - run migrations locally first
- [ ] **Backup strategy planned** - know how to backup/restore data
- [ ] **Connection pooling configured** - for better performance

---

## 📧 Email Configuration

- [ ] **SMTP credentials verified** - test email sending works
- [ ] **Gmail App Password created** - not using regular password
- [ ] **Email templates reviewed** - all emails look professional
- [ ] **Sender email verified** - emails won't go to spam

---

## 🤖 AI Configuration

- [ ] **Gemini API key valid** - test API calls work
- [ ] **API quota checked** - know your rate limits
- [ ] **Fallback working** - regex-based fallback tested
- [ ] **Error handling tested** - app works when AI fails

---

## 🌐 Frontend

- [ ] **Build tested locally** - `npm run build` works
- [ ] **API URLs configured** - frontend points to correct backend
- [ ] **Environment variables set** - VITE_API_URL if needed
- [ ] **Assets optimized** - images compressed, code minified
- [ ] **Mobile responsive** - tested on phone/tablet

---

## 🧪 Testing

- [ ] **Upload works** - test document upload end-to-end
- [ ] **Analysis works** - verify AI analysis completes
- [ ] **Authentication works** - login/register/logout tested
- [ ] **Email confirmation works** - test full registration flow
- [ ] **Password reset works** - test forgot password flow
- [ ] **Document deletion works** - test delete functionality
- [ ] **Multi-user tested** - verify user isolation works

---

## 📊 Monitoring

- [ ] **Logging configured** - know where logs are stored
- [ ] **Error tracking planned** - consider Sentry or similar
- [ ] **Performance monitoring** - plan to track response times
- [ ] **Uptime monitoring** - consider UptimeRobot or similar

---

## 💰 Cost Planning

- [ ] **Platform chosen** - Railway, Render, Heroku, etc.
- [ ] **Pricing understood** - know monthly costs
- [ ] **Scaling plan** - know when/how to scale
- [ ] **Budget set** - have budget for hosting

---

## 📝 Documentation

- [ ] **README updated** - includes deployment instructions
- [ ] **API documented** - if exposing API to others
- [ ] **User guide created** - help users understand the app
- [ ] **Admin guide created** - document admin tasks

---

## 🚀 Deployment Platform

- [ ] **Account created** - Railway/Render/Heroku account ready
- [ ] **Payment method added** - if using paid tier
- [ ] **GitHub connected** - platform can access your repo
- [ ] **Environment variables prepared** - list of all env vars ready

---

## 🔄 Post-Deployment

- [ ] **URL accessible** - can open app in browser
- [ ] **SSL working** - HTTPS enabled (should be automatic)
- [ ] **Registration works** - can create new account
- [ ] **Upload works** - can upload and analyze document
- [ ] **Emails sending** - confirmation emails arrive
- [ ] **Performance acceptable** - app loads quickly
- [ ] **No errors in logs** - check platform logs

---

## 📱 Optional Enhancements

- [ ] **Custom domain** - set up your own domain name
- [ ] **CDN configured** - for faster global access
- [ ] **Backup automated** - automatic database backups
- [ ] **Monitoring alerts** - get notified of issues
- [ ] **Analytics added** - track user behavior

---

## ✅ Ready to Deploy?

If you've checked all the required items above, you're ready to deploy!

**Next step**: Follow DEPLOYMENT_QUICK_START.md

---

## 🆘 Need Help?

If you're stuck on any item:
1. Review the detailed guides in CLOUD_DEPLOYMENT_GUIDE.md
2. Check platform-specific documentation
3. Test locally first before deploying
4. Deploy to staging environment first (if available)

**Remember**: You can always redeploy if something goes wrong!

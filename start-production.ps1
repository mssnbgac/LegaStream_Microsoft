# LegaStream Production Startup Script
Write-Host "🚀 Starting LegaStream Production Server..." -ForegroundColor Green

# Check if Ruby is available
try {
    ruby --version | Out-Null
    Write-Host "✓ Ruby is installed" -ForegroundColor Green
} catch {
    Write-Host "✗ Ruby not found. Please install Ruby first." -ForegroundColor Red
    exit 1
}

# Check if Node.js is available
try {
    node --version | Out-Null
    Write-Host "✓ Node.js is installed" -ForegroundColor Green
} catch {
    Write-Host "✗ Node.js not found. Please install Node.js first." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Starting production services..." -ForegroundColor Yellow

# Start the Production Ruby backend server in background
Write-Host "📡 Starting Production backend server..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-Command", "ruby production_server.rb" -WindowStyle Minimized

# Wait a moment for backend to start
Start-Sleep -Seconds 3

# Start the React frontend
Write-Host "🎨 Starting React frontend..." -ForegroundColor Cyan
Set-Location frontend
Start-Process powershell -ArgumentList "-Command", "npm run dev" -WindowStyle Normal

Write-Host ""
Write-Host "🎉 LegaStream Production is starting up!" -ForegroundColor Green
Write-Host "📊 Frontend: http://localhost:5175" -ForegroundColor Cyan
Write-Host "🔧 Backend: http://localhost:3001" -ForegroundColor Cyan
Write-Host "📊 Health Check: http://localhost:3001/up" -ForegroundColor Cyan

Write-Host ""
Write-Host "✨ Production Features Available:" -ForegroundColor Yellow
Write-Host "  • Real user registration with email confirmation" -ForegroundColor Gray
Write-Host "  • Secure password authentication" -ForegroundColor Gray
Write-Host "  • SQLite database storage" -ForegroundColor Gray
Write-Host "  • Password reset functionality" -ForegroundColor Gray
Write-Host "  • Document processing with real analysis" -ForegroundColor Gray

Write-Host ""
Write-Host "🔐 Default Admin Account:" -ForegroundColor Yellow
Write-Host "  Email: admin@legastream.com" -ForegroundColor Gray
Write-Host "  Password: password" -ForegroundColor Gray

Write-Host ""
Write-Host "🛑 To stop: Close both PowerShell windows" -ForegroundColor Yellow
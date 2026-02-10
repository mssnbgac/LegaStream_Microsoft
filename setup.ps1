# LegaStream Development Environment Setup Script for Windows
# Run this script as Administrator

Write-Host "Setting up LegaStream development environment..." -ForegroundColor Green

# Check if Chocolatey is installed
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Yellow
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Install Ruby
Write-Host "Installing Ruby..." -ForegroundColor Yellow
choco install ruby -y

# Install PostgreSQL
Write-Host "Installing PostgreSQL..." -ForegroundColor Yellow
choco install postgresql -y

# Install Redis
Write-Host "Installing Redis..." -ForegroundColor Yellow
choco install redis-64 -y

# Refresh environment variables
Write-Host "Refreshing environment variables..." -ForegroundColor Yellow
refreshenv

Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "Please restart your terminal and run 'ruby --version' to verify Ruby installation." -ForegroundColor Cyan
Write-Host "Then run 'gem install rails' to install Rails." -ForegroundColor Cyan
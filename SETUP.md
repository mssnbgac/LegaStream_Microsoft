# Development Environment Setup

## Option 1: Automated Setup (Recommended)

Run the PowerShell setup script as Administrator:

```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\setup.ps1
```

## Option 2: Manual Installation

### 1. Install Ruby

Download and install Ruby from: https://rubyinstaller.org/
- Choose Ruby 3.2.x with DevKit
- During installation, select "Add Ruby executables to your PATH"
- Run `ridk install` when prompted

### 2. Install PostgreSQL

Download from: https://www.postgresql.org/download/windows/
- Choose version 14 or higher
- Remember your postgres user password
- Default port 5432 is fine

### 3. Install Redis

Download from: https://github.com/microsoftarchive/redis/releases
- Extract to C:\Redis
- Add C:\Redis to your PATH
- Or use Windows Subsystem for Linux (WSL) for Redis

### 4. Verify Installations

```bash
ruby --version          # Should show Ruby 3.2.x
gem --version          # Should show gem version
psql --version         # Should show PostgreSQL version
redis-server --version # Should show Redis version
```

### 5. Install Rails

```bash
gem install rails
rails --version        # Should show Rails 8.x
```

## Next Steps

Once all dependencies are installed:

1. Create the Rails application
2. Set up the React frontend
3. Configure the database
4. Start development servers

Run `ruby --version` to check if Ruby is installed, then we can proceed with creating the Rails application.
# Legal Auditor Agent - AI Document Analysis

An AI-powered legal document analysis platform for law firms and legal professionals.

## Features

- **AI Document Analysis**: Powered by Google Gemini for intelligent document analysis
- **Entity Extraction**: Automatic extraction of parties, dates, amounts, and legal terms
- **Multi-User Support**: Complete data isolation between users
- **Real-Time Processing**: Live updates on document analysis progress
- **Secure Platform**: Production-ready with comprehensive security measures

## Tech Stack

- **Backend**: Ruby with WEBrick
- **Frontend**: React 19 with Vite
- **Database**: SQLite
- **AI**: Google Gemini API
- **Email**: SMTP (Gmail/SendGrid)

## Development Setup

### Quick Start with Docker (Recommended)

1. **Prerequisites**: Docker Desktop installed and running

2. **Start the application**:
```powershell
# Windows PowerShell
.\start.ps1

# Or manually with Docker Compose
docker-compose up --build
```

3. **Access the application**:
- Frontend: http://localhost:5173
- API: http://localhost:3000
- Health Check: http://localhost:3000/up

4. **Stop the application**:
```powershell
.\stop.ps1
# Or: docker-compose down
```

### Manual Installation (Alternative)

If you prefer to install dependencies manually:

- Ruby 3.2+
- Node.js 18+
- PostgreSQL 14+
- Redis 6+

See `SETUP.md` for detailed manual installation instructions.

## Project Structure

```
legastream/
├── app/                    # Rails API application
│   ├── models/            # Data models
│   ├── controllers/       # API controllers
│   ├── channels/          # ActionCable channels
│   ├── jobs/              # Background jobs
│   └── services/          # Business logic services
├── frontend/              # React 19 application
│   ├── src/
│   │   ├── components/    # React components
│   │   ├── hooks/         # Custom hooks
│   │   └── services/      # API services
│   └── package.json
├── config/                # Rails configuration
├── db/                    # Database migrations and schema
└── spec/                  # Test files
```

## License

MIT License
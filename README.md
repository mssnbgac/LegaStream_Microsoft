# LegaStream AI Agentic OS

A Vertical AI Agentic Operating System for Legal Discovery targeting mid-sized law firms and independent legal researchers.

## Features

- **Autonomous Agent Engine**: Powered by Langchain.rb for intelligent document analysis
- **Live Logic Terminal**: Real-time WebSocket streaming of agent reasoning processes
- **Secure Tool Sandbox**: Isolated execution environment preventing sensitive data exposure
- **Multi-Tenant Architecture**: Complete data isolation between law firms
- **Usage-Based Billing**: Accurate token consumption tracking and billing

## Tech Stack

- **Backend**: Rails 8 (API-only)
- **Frontend**: React 19 with Vite
- **Database**: PostgreSQL with JSONB
- **Cache/Queue**: Redis
- **WebSockets**: ActionCable
- **AI Framework**: Langchain.rb

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
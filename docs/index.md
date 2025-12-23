# Senda Project Documentation

**Generated:** 2025-12-20
**Scan Level:** Deep
**Repository Type:** Multi-Part

---

## Project Overview

**Senda** is an AI-powered meditation content platform consisting of two main parts:

| Part | Type | Stack | Description |
|------|------|-------|-------------|
| **senda-api** | Backend | Python 3.12 + FastAPI | REST API with AI script generation, TTS audio, and course management |
| **senda-cms** | Web App | Next.js 16 + TypeScript | Admin CMS for managing courses, lessons, and content generation |

### Quick Reference

- **Primary Language:** Python (Backend) / TypeScript (Frontend)
- **Architecture:** Clean Architecture (Backend) + Container Pattern (Frontend)
- **Database:** PostgreSQL 18
- **AI Integration:** Google Gemini (Scripts) + Kokoro TTS (Audio)
- **Deployment:** Google Cloud Run (API) + Vercel (CMS)

---

## Generated Documentation

### Architecture & Design

- [Project Overview](./project-overview.md)
- [Integration Architecture](./integration-architecture.md)
- [Architecture - API](./architecture-senda-api.md)
- [Architecture - CMS](./architecture-senda-cms.md)

### Development Guides

- [Development Guide - API](./development-guide-senda-api.md)
- [Development Guide - CMS](./development-guide-senda-cms.md)
- [Deployment Guide](./deployment-guide.md)

### Technical Reference

- [API Contracts - Backend](./api-contracts-senda-api.md)
- [Data Models](./data-models.md)
- [Source Tree Analysis](./source-tree-analysis.md)
- [Component Inventory - CMS](./component-inventory-senda-cms.md)

---

## Existing Documentation

### Senda API

| Document | Description |
|----------|-------------|
| [README.md](../senda-api/README.md) | Getting started, features, and usage |
| [DEPLOYMENT.md](../senda-api/DEPLOYMENT.md) | Cloud Run deployment guide with Terraform and GitHub Actions |
| [SENDA_DEV_GUIDE.md](../senda-api/SENDA_DEV_GUIDE.md) | Development conventions and workflow |

### Senda CMS

| Document | Description |
|----------|-------------|
| [README.md](../senda-cms/README.md) | CMS overview, installation, and tech stack |
| [docs/architecture.md](../senda-cms/docs/architecture.md) | Complete architecture decision document |
| [docs/PRD.md](../senda-cms/docs/PRD.md) | Product Requirements Document |
| [docs/design-system.md](../senda-cms/docs/design-system.md) | UI design system and tokens |
| [docs/epics.md](../senda-cms/docs/epics.md) | Development epics and user stories |
| [docs/api-integration.md](../senda-cms/docs/api-integration.md) | API integration patterns |
| [docs/ux-design-specification.md](../senda-cms/docs/ux-design-specification.md) | UX design specification |

### Project Root

| Document | Description |
|----------|-------------|
| [docs/architecture-diagram.mmd](../docs/architecture-diagram.mmd) | System architecture Mermaid diagram |
| [docs/docker-diagram.mmd](../docs/docker-diagram.mmd) | Docker services diagram |

---

## Getting Started

### Prerequisites

- **Docker** & **Docker Compose** (recommended for full stack)
- **Python 3.12+** with `uv` (for API development)
- **Bun** (for CMS development)
- **PostgreSQL 18** (if running locally without Docker)

### Quick Start (Docker)

```bash
# Clone and navigate to project root
cd senda

# Full stack setup: build, init DB, run migrations
make setup

# Access services:
# - CMS:      http://localhost:3000
# - API:      http://localhost:8081
# - Postgres: localhost:5439
# - Kokoro:   http://localhost:8880
```

### Development Without Docker

```bash
# API Development
cd senda-api
uv venv && source .venv/bin/activate
uv pip install -e .
cp .env.example .env
uvicorn api:app --reload

# CMS Development (separate terminal)
cd senda-cms
bun install
cp .env.local.example .env
bun dev
```

---

## Project Structure Summary

```
senda/
├── senda-api/              # Backend (Python FastAPI)
│   ├── senda/
│   │   ├── api/           # Routes, schemas, middlewares
│   │   ├── core/          # Config, enums, dependencies
│   │   ├── domain/        # DTOs, repositories interfaces, services interfaces
│   │   ├── infrastructure/# Models, repositories, providers, mappers
│   │   └── services/      # Business logic implementation
│   ├── tests/             # API and unit tests
│   └── terraform/         # GCP infrastructure as code
│
├── senda-cms/              # Frontend (Next.js TypeScript)
│   ├── src/
│   │   ├── app/           # Next.js App Router pages
│   │   ├── components/    # Reusable UI components
│   │   ├── containers/    # Feature-specific containers
│   │   ├── hooks/         # API hooks (React Query)
│   │   ├── stores/        # Zustand auth store
│   │   └── lib/           # Utilities
│   └── docs/              # CMS documentation
│
├── docker-compose.yml      # Full stack orchestration
├── Makefile               # Development commands
└── docs/                  # Project-level diagrams
```

---

## Key Features

### 1. Course Management
- CRUD operations for meditation courses
- Metadata management (difficulty, tags, cover images)
- Activation workflow (draft → published)

### 2. Lesson Management
- Ordered lesson lists with drag-and-drop reordering
- Lesson metadata (core practice, key point, tone, duration)
- Status tracking through content generation pipeline

### 3. AI Script Generation
- Integration with Google Gemini for meditation script generation
- Batch generation for entire courses
- Individual lesson regeneration
- Script editing and versioning

### 4. Audio Generation
- Kokoro TTS integration for text-to-speech
- Voice and speed configuration
- AWS S3 storage for generated audio files
- Background processing with status polling

### 5. Authentication
- JWT-based authentication
- Admin-only access control
- Session management with token refresh

---

## Technology Stack

### Backend (senda-api)

| Category | Technology | Version |
|----------|------------|---------|
| Framework | FastAPI | 0.115.4 |
| Language | Python | 3.12+ |
| ORM | SQLAlchemy | 2.0.36 |
| Migrations | Alembic | 1.13.3 |
| Database | PostgreSQL | 18 |
| AI | Google Gemini | 1.28.0 |
| Storage | AWS S3 (aioboto3) | 13.2.0 |
| Auth | PyJWT + bcrypt | 2.9.0 / 5.0.0 |
| Validation | Pydantic | 2.9.2 |
| Logging | structlog | 24.4.0 |

### Frontend (senda-cms)

| Category | Technology | Version |
|----------|------------|---------|
| Framework | Next.js | 16.1.0 |
| Language | TypeScript | 5.9.2 |
| Styling | Tailwind CSS | 4.1.13 |
| Components | shadcn/ui | - |
| Server State | React Query | 5.90.2 |
| Client State | Zustand | 5.0.8 |
| Forms | React Hook Form + Zod | 7.63.0 / 4.1.11 |
| API Client | openapi-fetch + openapi-react-query | 0.14.0 / 0.5.0 |

### Infrastructure

| Component | Technology |
|-----------|------------|
| Containerization | Docker + Docker Compose |
| API Hosting | Google Cloud Run |
| CMS Hosting | Vercel |
| CI/CD | GitHub Actions |
| IaC | Terraform |
| TTS Service | Kokoro FastAPI (GPU) |

---

## Next Steps for AI-Assisted Development

When creating brownfield features:

1. **For API-only features:** Reference [architecture-senda-api.md](./architecture-senda-api.md)
2. **For CMS-only features:** Reference [architecture-senda-cms.md](./architecture-senda-cms.md) and [../senda-cms/docs/architecture.md](../senda-cms/docs/architecture.md)
3. **For full-stack features:** Reference both architectures + [integration-architecture.md](./integration-architecture.md)
4. **For deployment:** Reference [deployment-guide.md](./deployment-guide.md)

---

**Document Status:** Initial Scan Complete
**Scan Level:** Deep

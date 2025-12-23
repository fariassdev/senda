# Source Tree Analysis

**Project:** Senda
**Type:** Multi-Part Repository

---

## Complete Project Structure

```
senda/                                    # Project Root
├── .agent/                              # AI agent configurations
├── .github/                             # GitHub configurations
│   └── agents/                          # GitHub Copilot agents (10 files)
├── _bmad/                               # BMad Method framework
│   ├── core/                            # Core BMAD workflows
│   └── bmm/                             # BMM module
├── _bmad-output/                        # Generated AI documentation ← YOU ARE HERE
│
├── docker-compose.yml                   # Full stack orchestration (4 services)
├── Makefile                             # Development commands
│
├── docs/                                # Project-level documentation
│   ├── architecture-diagram.mmd        # System architecture Mermaid
│   └── docker-diagram.mmd              # Docker services Mermaid
│
├── docker/                              # Docker support files
│   └── postgres_init/                   # Database initialization scripts
│
├── codebase-analysis-docs/              # Legacy codebase analysis
│   └── CODEBASE_KNOWLEDGE.md            # Comprehensive knowledge doc
│
├── senda-api/                           # BACKEND (Python FastAPI)
│   └── [see detailed structure below]
│
└── senda-cms/                           # FRONTEND (Next.js TypeScript)
    └── [see detailed structure below]
```

---

## Backend Structure (senda-api/)

```
senda-api/
├── 📄 .env, .env.example, .env.dev, .env.test  # Environment configs
├── 📄 .gitignore, .gitattributes
├── 📄 .pre-commit-config.yaml           # Pre-commit hooks
├── 📄 .python-version                   # Python 3.12
│
├── 📄 Dockerfile                        # Container definition
├── 📄 Makefile                          # API-specific commands
├── 📄 pyproject.toml                    # Project config + dependencies
├── 📄 setup.cfg                         # Legacy config
├── 📄 uv.lock                           # UV lockfile
├── 📄 version.py                        # Version info
│
├── 📄 README.md                         # API documentation
├── 📄 DEPLOYMENT.md                     # Cloud Run deployment guide
├── 📄 SENDA_DEV_GUIDE.md               # Development conventions
│
├── 📁 senda/                            # Main source code
│   ├── 📄 __init__.py
│   ├── 📄 app.py                        # FastAPI application factory
│   │
│   ├── 📁 api/                          # ⚡ API Layer
│   │   ├── 📄 middlewares.py            # CORS, auth middleware
│   │   ├── 📄 router.py                 # Route aggregation
│   │   ├── 📁 routes/                   # Route handlers (8 files)
│   │   │   ├── authentication.py        # Login, register
│   │   │   ├── course.py                # Course CRUD + generation (6.5KB)
│   │   │   ├── lesson.py                # Lesson CRUD + generation (10KB)
│   │   │   ├── profile.py               # User profiles
│   │   │   ├── users.py                 # User management
│   │   │   ├── tag.py                   # Tags
│   │   │   └── health_check.py          # Health endpoint
│   │   └── 📁 schemas/                  # Pydantic schemas (18 files)
│   │
│   ├── 📁 services/                     # ⚡ Business Logic (11 files)
│   │   ├── auth.py                      # Authentication (2.5KB)
│   │   ├── auth_token.py                # JWT tokens (1.4KB)
│   │   ├── course.py                    # Course logic (15.7KB) ⭐
│   │   ├── lesson.py                    # Lesson logic (7.8KB)
│   │   ├── script_generation.py         # AI scripts (11KB) ⭐
│   │   ├── audio_generation.py          # TTS audio (12.2KB) ⭐
│   │   ├── profile.py                   # Profile logic (4.9KB)
│   │   ├── user.py                      # User logic (4.4KB)
│   │   ├── password.py                  # Password hashing
│   │   └── tag.py                       # Tag logic
│   │
│   ├── 📁 domain/                       # ⚡ Domain Layer
│   │   ├── 📁 dtos/                     # Data Transfer Objects (10 files)
│   │   ├── 📁 repositories/             # Repository interfaces (8 files)
│   │   ├── 📁 services/                 # Service interfaces
│   │   ├── 📁 exceptions/               # Domain exceptions
│   │   └── 📁 utils/                    # Domain utilities
│   │
│   ├── 📁 infrastructure/               # ⚡ Data/External Layer
│   │   ├── 📄 models.py                 # SQLAlchemy models (4KB) ⭐
│   │   ├── 📁 repositories/             # Repository implementations (8 files)
│   │   ├── 📁 mappers/                  # DTO ↔ Model mappers (5 files)
│   │   ├── 📁 providers/                # External clients (5 files)
│   │   │   ├── gemini.py                # Google Gemini
│   │   │   ├── kokoro.py                # Kokoro TTS
│   │   │   └── s3.py                    # AWS S3
│   │   ├── 📁 prompts/                  # AI prompt templates
│   │   ├── 📁 loaders/                  # Custom loaders
│   │   ├── 📁 config/                   # Database config
│   │   ├── 📁 alembic/                  # Migrations
│   │   │   ├── 📄 alembic.ini
│   │   │   ├── 📄 env.py
│   │   │   └── 📁 versions/             # Migration files (2 migrations)
│   │   └── 📁 utils/
│   │
│   └── 📁 core/                         # ⚡ Shared/Core Layer
│       ├── 📄 config.py                 # Settings (pydantic-settings)
│       ├── 📄 enums.py                  # Enumerations
│       └── 📄 dependencies.py           # FastAPI dependencies
│
├── 📁 tests/                            # Test suite (27 files)
│   ├── 📄 conftest.py                   # Pytest fixtures (7.6KB)
│   ├── 📄 utils.py                      # Test utilities (4.8KB)
│   ├── 📁 api/                          # Integration tests (12 files)
│   ├── 📁 unit/                         # Unit tests (9 files)
│   └── 📁 core/                         # Core tests (3 files)
│
├── 📁 scripts/                          # Utility scripts
│   ├── run-migrations.sh                # Migration runner
│   ├── setup-gcp.sh                     # GCP setup (Bash)
│   └── setup-gcp.ps1                    # GCP setup (PowerShell)
│
├── 📁 terraform/                        # Infrastructure as Code
│   ├── main.tf                          # Main resources
│   ├── variables.tf                     # Variable definitions
│   ├── outputs.tf                       # Output values
│   └── terraform.tfvars.example
│
├── 📁 docs/                             # API documentation
├── 📁 db/                               # Database support
├── 📁 generated_courses/                # Generated content output
└── 📁 build/                            # Build artifacts
```

---

## Frontend Structure (senda-cms/)

```
senda-cms/
├── 📄 .env, .env.local.example, .env.production.example
├── 📄 .gitignore, .gitattributes
├── 📄 .cursorrules                      # Cursor AI rules
├── 📄 .prettierrc, .prettierignore      # Prettier config
│
├── 📄 Dockerfile                        # Container definition
├── 📄 package.json                      # Dependencies (3KB)
├── 📄 bun.lock                          # Bun lockfile
├── 📄 tsconfig.json                     # TypeScript config
│
├── 📄 next.config.ts                    # Next.js config
├── 📄 tailwind.config.ts                # Tailwind config
├── 📄 postcss.config.mjs                # PostCSS config
├── 📄 vitest.config.ts                  # Vitest config
├── 📄 eslint.config.mjs                 # ESLint config (4.4KB)
├── 📄 commitlint.config.js              # Commit linting
├── 📄 components.json                   # shadcn/ui config
│
├── 📄 README.md                         # CMS documentation (8KB)
│
├── 📁 src/                              # Main source code
│   ├── 📄 proxy.ts                      # API proxy config (3.6KB)
│   │
│   ├── 📁 app/                          # ⚡ Next.js App Router
│   │   ├── 📄 layout.tsx                # Root layout
│   │   ├── 📄 globals.css               # Global styles + Tailwind (9KB)
│   │   ├── 📄 favicon.ico
│   │   ├── 📁 login/                    # Login page
│   │   │   └── page.tsx
│   │   ├── 📁 courses/                  # Course pages
│   │   │   ├── page.tsx                 # Course list
│   │   │   └── 📁 [slug]/               # Dynamic course
│   │   │       └── page.tsx
│   │   └── 📁 api/                      # API routes
│   │
│   ├── 📁 containers/                   # ⚡ Feature Containers (81 files)
│   │   ├── 📁 Guest/                    # Unauthenticated views
│   │   │   └── 📁 SignIn/               # Login container
│   │   │       ├── index.tsx
│   │   │       ├── connect.ts
│   │   │       ├── types.ts
│   │   │       └── constants.ts
│   │   │
│   │   └── 📁 Main/                     # Authenticated views (77 files)
│   │       ├── 📁 CourseList/           # Course listing
│   │       │   ├── index.tsx
│   │       │   ├── connect.ts
│   │       │   ├── 📁 CourseCard/
│   │       │   ├── 📁 CourseRow/
│   │       │   └── ...
│   │       │
│   │       ├── 📁 CourseDetail/         # Course detail view
│   │       │   ├── index.tsx
│   │       │   ├── connect.ts
│   │       │   ├── 📁 CourseHeader/
│   │       │   ├── 📁 LessonList/       # Lesson management
│   │       │   │   ├── index.tsx
│   │       │   │   ├── connect.ts
│   │       │   │   ├── 📁 LessonRow/
│   │       │   │   └── ...
│   │       │   └── ...
│   │       │
│   │       ├── 📁 CourseForm/           # Create/edit course
│   │       └── 📁 ScriptEditor/         # Script editing
│   │
│   ├── 📁 components/                   # ⚡ Reusable Components (54 files)
│   │   ├── 📁 ui/                       # shadcn/ui primitives (22 files)
│   │   │   ├── button.tsx
│   │   │   ├── card.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── input.tsx
│   │   │   ├── select.tsx
│   │   │   ├── skeleton.tsx
│   │   │   └── ... (16 more)
│   │   │
│   │   ├── 📁 Navigation/               # Shared navigation
│   │   ├── 📁 StatusBadge/              # Lesson status (5 files)
│   │   ├── 📁 AudioPlayer/              # Audio playback (4 files)
│   │   ├── 📁 LessonForm/               # Lesson form (4 files)
│   │   ├── 📁 DeleteCourseModal/        # Confirmation (4 files)
│   │   ├── 📁 ScriptGenerationModal/    # Script generation (4 files)
│   │   ├── 📁 AudioConfigModal/         # Audio config (4 files)
│   │   ├── 📄 AuthLayout.tsx            # Auth wrapper (2.5KB)
│   │   ├── 📄 ClientLayout.tsx          # Client providers (1KB)
│   │   ├── 📄 QueryProvider.tsx         # React Query (1.6KB)
│   │   └── 📄 ThemeProvider.tsx         # Theme context
│   │
│   ├── 📁 hooks/                        # ⚡ API Hooks (14 files)
│   │   ├── 📄 useCourse.ts              # GET single course
│   │   ├── 📄 useCourses.ts             # GET course list
│   │   ├── 📄 useCourseActions.ts       # Course mutations (2.9KB)
│   │   ├── 📄 useLessonActions.ts       # Lesson mutations (1.8KB)
│   │   ├── 📄 useScriptGeneration.ts    # Script gen (2.8KB)
│   │   ├── 📄 useBatchScriptGeneration.ts  # Batch gen (11.9KB) ⭐
│   │   ├── 📄 useAudioGeneration.ts     # Audio gen (3KB)
│   │   ├── 📄 useAuthRefresh.ts         # Token refresh
│   │   ├── 📁 useLessonReorder/         # Drag-drop reorder (5 files)
│   │   └── 📄 use-mobile.ts             # Responsive hook
│   │
│   ├── 📁 stores/                       # ⚡ Client State
│   │   └── 📄 authStore.ts              # Zustand auth
│   │
│   ├── 📁 lib/                          # ⚡ Utilities
│   │   ├── 📄 api.ts                    # OpenAPI client
│   │   └── 📄 utils.ts                  # Helpers
│   │
│   ├── 📁 types/                        # Type Definitions
│   │   └── 📄 api.d.ts                  # Generated OpenAPI types
│   │
│   ├── 📁 contexts/                     # React Contexts
│   └── 📁 test/                         # Test utilities
│
├── 📁 public/                           # Static assets (5 files)
│
└── 📁 docs/                             # CMS documentation (50 files)
    ├── 📄 architecture.md               # Architecture decisions (19.6KB) ⭐
    ├── 📄 PRD.md                        # Product requirements (7.9KB)
    ├── 📄 epics.md                      # Development epics (39.3KB) ⭐
    ├── 📄 design-system.md              # UI design system (23.6KB) ⭐
    ├── 📄 api-integration.md            # API patterns (6.1KB)
    ├── 📄 ux-design-specification.md    # UX spec (57KB) ⭐
    ├── 📄 VERCEL_DEPLOYMENT.md          # Vercel deployment (11.5KB)
    ├── 📁 sprint-artifacts/             # Sprint tracking (33 files)
    └── 📁 mockups/                      # UI mockups (4 files)
```

---

## Critical File Summary

### Backend (senda-api)

| File | Size | Purpose |
|------|------|---------|
| `senda/app.py` | 1KB | FastAPI app factory |
| `senda/infrastructure/models.py` | 4KB | All SQLAlchemy models |
| `senda/services/course.py` | 15.7KB | Course business logic |
| `senda/services/script_generation.py` | 11KB | AI script generation |
| `senda/services/audio_generation.py` | 12.2KB | TTS audio generation |
| `senda/api/routes/lesson.py` | 10KB | Lesson API endpoints |
| `tests/conftest.py` | 7.6KB | Test fixtures |

### Frontend (senda-cms)

| File | Size | Purpose |
|------|------|---------|
| `src/app/globals.css` | 9KB | Tailwind + custom styles |
| `src/hooks/useBatchScriptGeneration.ts` | 11.9KB | Complex batch logic |
| `docs/architecture.md` | 19.6KB | Architecture decisions |
| `docs/epics.md` | 39.3KB | Development epics |
| `docs/ux-design-specification.md` | 57KB | Complete UX spec |
| `docs/design-system.md` | 23.6KB | Design system tokens |

---

## Entry Points

### Backend

- **Application:** `senda/app.py` → `uvicorn senda.app:app`
- **Migrations:** `senda/infrastructure/alembic/env.py`

### Frontend

- **Application:** `src/app/layout.tsx`
- **Pages:** `src/app/*/page.tsx`

---

## Integration Points

| From | To | Files |
|------|-----|-------|
| CMS | API | `src/lib/api.ts`, `src/hooks/*.ts` |
| API | PostgreSQL | `senda/infrastructure/repositories/*.py` |
| API | Gemini | `senda/infrastructure/providers/gemini.py` |
| API | Kokoro | `senda/infrastructure/providers/kokoro.py` |
| API | S3 | `senda/infrastructure/providers/s3.py` |

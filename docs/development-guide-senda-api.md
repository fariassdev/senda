# Development Guide - Senda API

**Part:** senda-api
**Runtime:** Python 3.12+
**Package Manager:** UV

---

## Prerequisites

- Python 3.12+
- uv (fast Python package manager)
- PostgreSQL 18 (or Docker)
- Google Cloud account (for Gemini API)
- AWS account (for S3 storage)

---

## Environment Setup

### 1. Clone and Navigate

```bash
git clone https://github.com/fariassdev/senda.git
cd senda/senda-api
```

### 2. Create Virtual Environment

```bash
# Unix/macOS
uv venv
source .venv/bin/activate

# Windows
uv venv
.venv\Scripts\activate
```

### 3. Install Dependencies

```bash
uv pip install -e ".[dev]"
```

### 4. Configure Environment

```bash
cp .env.example .env
# Edit .env with your values
```

### Required Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `POSTGRES_HOST` | Database host | Yes |
| `POSTGRES_PORT` | Database port (5432) | Yes |
| `POSTGRES_USER` | Database username | Yes |
| `POSTGRES_PASSWORD` | Database password | Yes |
| `POSTGRES_DB` | Database name | Yes |
| `JWT_SECRET_KEY` | JWT signing secret | Yes |
| `SECRET_KEY` | Application secret | Yes |
| `GEMINI_API_KEY` | Google Gemini API key | For AI |
| `KOKORO_API_URL` | Kokoro TTS URL | For Audio |
| `AWS_ACCESS_KEY_ID` | AWS access key | For S3 |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | For S3 |
| `AWS_BUCKET_NAME` | S3 bucket name | For S3 |
| `AWS_REGION` | AWS region | For S3 |

---

## Running the Application

### Development Server

```bash
# With auto-reload (recommended)
uvicorn senda.app:app --reload --port 8000

# Or using Makefile
make runserver-dev
```

**Access:**
- API: http://localhost:8000/api
- Docs: http://localhost:8000/api/docs
- ReDoc: http://localhost:8000/api/redoc

### Using Docker Compose (Full Stack)

```bash
# From project root
cd ..  # Go to senda/
make setup  # Build and initialize everything
```

---

## Database Commands

### Migrations

```bash
# Apply all pending migrations
make migrate

# Create new migration (manual)
make migration message="add_new_field"

# Create auto-generated migration (from model changes)
make migration-auto message="detect_changes"

# Rollback one migration
make migrate-down

# View migration history
make migrate-history

# Reset database (down to base, then up)
make db-reset
```

### Test Database

```bash
# Apply migrations to test database
make migrate-test-db

# Uses .env.test configuration
```

---

## Testing

### Run All Tests

```bash
make test

# With coverage
make test-cov

# Verbose output
make test-v
```

### Run Specific Tests

```bash
# By path
pytest tests/api/test_course.py -v

# By marker
pytest -m "unit" -v

# By keyword
pytest -k "test_create" -v
```

### Test Configuration

Tests use `.env.test` with a separate database to avoid data conflicts.

**Key test fixtures (conftest.py):**
- `client` - Async test client
- `db_session` - Database session
- `test_user` - Authenticated user
- `test_course` - Sample course
- `test_lesson` - Sample lesson

---

## Code Quality

### Linting

```bash
# Check linting
make lint

# Auto-fix issues
make fix
```

Linting uses `ruff` with these rules:
- E/W: pycodestyle
- F: pyflakes
- I: isort
- B: flake8-bugbear
- C4: flake8-comprehensions

### Type Checking

```bash
make typecheck
```

Uses `mypy` with strict mode.

### Formatting

```bash
make format
```

Uses `ruff format` (Black-compatible).

### Pre-commit Hooks

```bash
# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

---

## Development Workflow

### 1. Create Feature Branch

```bash
git checkout -b feature/my-feature
```

### 2. Make Changes

Follow these patterns:
- **Routes:** `senda/api/routes/`
- **Schemas:** `senda/api/schemas/`
- **Services:** `senda/services/`
- **Repositories:** `senda/domain/repositories/` (interface) + `senda/infrastructure/repositories/` (implementation)
- **Models:** `senda/infrastructure/models.py`

### 3. Add Tests

```bash
# Create test file
touch tests/api/test_my_feature.py

# Run tests
pytest tests/api/test_my_feature.py -v
```

### 4. Quality Checks

```bash
make lint
make typecheck
make test
```

### 5. Commit

```bash
git add .
git commit -m "feat: add my feature"
```

---

## Project Structure Quick Reference

```
senda/
├── api/           # Routes, schemas, middlewares
├── services/      # Business logic
├── domain/        # DTOs, interfaces
├── infrastructure/# Models, repositories, providers
└── core/          # Config, enums, dependencies
```

### Adding a New Entity

1. **Model:** Add to `infrastructure/models.py`
2. **Migration:** `make migration-auto message="add_entity"`
3. **DTO:** Create `domain/dtos/entity.py`
4. **Repository Interface:** Create `domain/repositories/entity.py`
5. **Repository Implementation:** Create `infrastructure/repositories/entity.py`
6. **Mapper:** Create `infrastructure/mappers/entity.py`
7. **Service:** Create `services/entity.py`
8. **Schemas:** Create `api/schemas/entity.py`
9. **Routes:** Create `api/routes/entity.py`
10. **Register Route:** Add to `api/router.py`

---

## Common Tasks

### Generate OpenAPI Spec

```bash
# Start server
make runserver-dev

# Access spec
curl http://localhost:8081/openapi.json > openapi.json
```

### Database Shell

```bash
# Using Docker
docker compose exec postgres psql -U $POSTGRES_USER -d $POSTGRES_DB

# Direct connection
psql -h localhost -p 5432 -U postgres -d senda_db
```

### Debug Mode

```bash
uvicorn senda.app:app --reload --log-level debug
```

---

## Troubleshooting

### Database Connection Failed

1. Check PostgreSQL is running
2. Verify `.env` credentials
3. Check if database exists: `make db-init`

### Import Errors

1. Ensure virtual environment is activated
2. Reinstall: `uv pip install -e ".[dev]"`

### Migration Conflicts

1. Check current revision: `make migrate-history`
2. If needed, downgrade: `make migrate-down`
3. Delete conflicting migration file
4. Regenerate: `make migration-auto`

### Test Database Issues

1. Verify `.env.test` exists with correct credentials
2. Run: `make migrate-test-db`
3. Check test database name is different from dev

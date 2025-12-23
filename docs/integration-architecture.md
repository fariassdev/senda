# Integration Architecture

**Project:** Senda
**Parts:** senda-api (Backend) ↔ senda-cms (Frontend)

---

## Communication Overview

The Senda platform consists of two main parts that communicate via REST API:

```mermaid
flowchart LR
    subgraph Frontend["senda-cms (Next.js)"]
        UI[React UI]
        RQ[React Query]
        OF[openapi-fetch]
    end
    
    subgraph Backend["senda-api (FastAPI)"]
        API["/api/*"]
        Auth[Auth Middleware]
        Routes[Route Handlers]
    end
    
    UI --> RQ
    RQ --> OF
    OF -->|HTTPS/REST| API
    API --> Auth
    Auth --> Routes
```

---

## API Contract

### Base Configuration

| Setting | Development | Production |
|---------|-------------|------------|
| Base URL | `http://localhost:8081/api` | `https://senda-api-xxx.run.app/api` |
| Protocol | HTTP | HTTPS |
| Authentication | JWT Bearer Token | JWT Bearer Token |
| Content-Type | application/json | application/json |

### OpenAPI Integration

The CMS uses **OpenAPI-first** development:

1. **API generates OpenAPI spec** at `/openapi.json`
2. **CMS generates TypeScript types** using `openapi-typescript`
3. **API calls use generated types** via `openapi-fetch` + `openapi-react-query`

```bash
# Generate types from running API
cd senda-cms
bun generate-types  # Points to http://localhost:8081/openapi.json
```

---

## Endpoint Overview

### Authentication

| Endpoint | Method | Description | Auth |
|----------|--------|-------------|------|
| `/api/users/login` | POST | User login, returns JWT | No |
| `/api/users` | POST | Register new user | No |

### User Profile

| Endpoint | Method | Description | Auth |
|----------|--------|-------------|------|
| `/api/user` | GET | Get current user | Yes |
| `/api/user` | PUT | Update current user | Yes |
| `/api/profiles/{username}` | GET | Get user profile | Yes |

### Courses

| Endpoint | Method | Description | Auth |
|----------|--------|-------------|------|
| `/api/courses` | GET | List all courses | Yes |
| `/api/courses` | POST | Create course | Yes |
| `/api/courses/{slug}` | GET | Get course by slug | Yes |
| `/api/courses/{slug}` | PUT | Update course | Yes |
| `/api/courses/{slug}` | DELETE | Delete course | Yes |
| `/api/courses/{slug}/generate-scripts` | POST | Generate all scripts | Yes |
| `/api/courses/{slug}/generate-audio` | POST | Generate all audio | Yes |

### Lessons

| Endpoint | Method | Description | Auth |
|----------|--------|-------------|------|
| `/api/courses/{slug}/lessons` | GET | List course lessons | Yes |
| `/api/courses/{slug}/lessons` | POST | Create lesson | Yes |
| `/api/courses/{slug}/lessons/{lesson_number}` | GET | Get lesson | Yes |
| `/api/courses/{slug}/lessons/{lesson_number}` | PUT | Update lesson | Yes |
| `/api/courses/{slug}/lessons/{lesson_number}` | DELETE | Delete lesson | Yes |
| `/api/courses/{slug}/lessons/reorder` | PUT | Reorder lessons | Yes |
| `/api/courses/{slug}/lessons/{lesson_number}/generate-script` | POST | Generate lesson script | Yes |
| `/api/courses/{slug}/lessons/{lesson_number}/generate-audio` | POST | Generate lesson audio | Yes |

### Tags

| Endpoint | Method | Description | Auth |
|----------|--------|-------------|------|
| `/api/tags` | GET | List all tags | Yes |

### Health Check

| Endpoint | Method | Description | Auth |
|----------|--------|-------------|------|
| `/api/health-check` | GET | Health check | No |

---

## Authentication Flow

```mermaid
sequenceDiagram
    participant CMS as Senda CMS
    participant Store as Zustand Store
    participant API as Senda API
    
    CMS->>API: POST /api/users/login<br/>{email, password}
    API-->>CMS: {user, token}
    CMS->>Store: setAuth(user, token)
    Store->>Store: localStorage.setItem('token')
    
    Note over CMS,API: Subsequent Requests
    
    CMS->>Store: getToken()
    Store-->>CMS: token
    CMS->>API: GET /api/courses<br/>Authorization: Token {token}
    API-->>CMS: {courses: [...]}
```

### Token Storage

- **Location:** `localStorage` (via Zustand persist)
- **Format:** `Token <jwt_token>`
- **Header:** `Authorization: Token {token}`

---

## Data Flow: Script Generation

```mermaid
sequenceDiagram
    participant CMS as Senda CMS
    participant API as Senda API
    participant Gemini as Google Gemini
    participant DB as PostgreSQL
    
    CMS->>API: POST /courses/{slug}/generate-scripts
    API->>DB: Update lessons status = SCRIPT_GENERATING
    API-->>CMS: {status: "generating"}
    
    loop For each lesson
        API->>Gemini: Generate script prompt
        Gemini-->>API: Generated script JSON
        API->>DB: Save script, status = SCRIPT_READY
    end
    
    loop Polling (every 2s)
        CMS->>API: GET /courses/{slug}
        API-->>CMS: {lessons: [{status: "..."}]}
    end
    
    CMS->>CMS: Update UI when all SCRIPT_READY
```

---

## Data Flow: Audio Generation

```mermaid
sequenceDiagram
    participant CMS as Senda CMS
    participant API as Senda API
    participant Kokoro as Kokoro TTS
    participant S3 as AWS S3
    participant DB as PostgreSQL
    
    CMS->>API: POST /courses/{slug}/generate-audio<br/>{voice, speed}
    API->>DB: Update lessons status = AUDIO_GENERATING
    API-->>CMS: {status: "generating"}
    
    loop For each lesson
        API->>Kokoro: TTS request with script
        Kokoro-->>API: Audio file (mp3)
        API->>S3: Upload audio file
        S3-->>API: Audio URL
        API->>DB: Save audio_url, status = AUDIO_READY
    end
    
    loop Polling (every 2s)
        CMS->>API: GET /courses/{slug}
        API-->>CMS: {lessons: [{status: "...", audio_url: "..."}]}
    end
```

---

## Error Handling

### API Error Responses

```json
{
  "detail": "Error message describing what went wrong"
}
```

### Common HTTP Status Codes

| Code | Meaning | CMS Handling |
|------|---------|--------------|
| 200 | Success | Process response |
| 201 | Created | Process response |
| 400 | Bad Request | Show validation error |
| 401 | Unauthorized | Redirect to login |
| 403 | Forbidden | Show access denied |
| 404 | Not Found | Show not found |
| 422 | Validation Error | Show field errors |
| 500 | Server Error | Show generic error |

### CMS Error Handling Pattern

```typescript
// In mutation onError callback
onError: (error) => {
  toast.error(error.message || 'An error occurred');
}
```

---

## Shared Data Contracts

### Naming Conventions

| Layer | Convention | Example |
|-------|------------|---------|
| API Response | snake_case | `created_at`, `lesson_number` |
| TypeScript | camelCase (transformed) | `createdAt`, `lessonNumber` |
| API Params | snake_case | `?skip=0&limit=10` |
| Path Params | kebab-case | `/courses/{slug}/lessons` |

### Date Format

- **API:** ISO 8601 string (`2025-12-20T17:45:00Z`)
- **CMS Display:** Formatted with `date-fns`

---

## Environment Configuration

### CMS Environment Variables

```env
# API Connection
NEXT_PUBLIC_API_BASE_URL=http://localhost:8081/api

# Build Environment
NEXT_PUBLIC_BUILD=development

# JWT (must match API)
JWT_SECRET=your-jwt-secret
```

### API Environment Variables (relevant for CMS integration)

```env
# CORS
ALLOWED_ORIGINS=http://localhost:3000

# JWT
JWT_SECRET_KEY=your-jwt-secret
```

---

## Docker Network

When running via Docker Compose, services communicate on the `senda-network`:

```yaml
# Internal URLs
CMS → API: http://api:8000/api
API → Kokoro: http://kokoro_tts:8880/v1/audio/speech
API → PostgreSQL: postgres:5432
```

```yaml
# External URLs (host machine)
CMS: http://localhost:3000
API: http://localhost:8081
PostgreSQL: localhost:5439
Kokoro: http://localhost:8880
```

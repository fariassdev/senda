# Development Guide - Senda CMS

**Part:** senda-cms
**Runtime:** Bun / Node.js 18+
**Framework:** Next.js 16

---

## Prerequisites

- Bun (recommended) or Node.js 18+
- Access to Senda API (local or remote)

---

## Environment Setup

### 1. Clone and Navigate

```bash
git clone https://github.com/fariassdev/senda.git
cd senda/senda-cms
```

### 2. Install Dependencies

```bash
bun install
```

### 3. Configure Environment

```bash
cp .env.local.example .env
# Edit .env with your values
```

### Required Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `NEXT_PUBLIC_API_BASE_URL` | API base URL | Yes |
| `NEXT_PUBLIC_BUILD` | Environment (development/production) | Yes |
| `JWT_SECRET` | JWT secret (must match API) | Yes |

**Example .env:**

```env
NEXT_PUBLIC_API_BASE_URL=http://localhost:8081/api
NEXT_PUBLIC_BUILD=development
JWT_SECRET=your-jwt-secret-here
```

---

## Running the Application

### Development Server

```bash
bun dev
```

Opens at http://localhost:3000

### Production Build

```bash
bun build
bun start
```

### Using Docker Compose (Full Stack)

```bash
# From project root
cd ..  # Go to senda/
make setup  # Build and initialize everything
```

---

## Available Scripts

| Command | Description |
|---------|-------------|
| `bun dev` | Start dev server with Turbopack |
| `bun build` | Build for production |
| `bun start` | Start production server |
| `bun typecheck` | Run TypeScript type checking |
| `bun lint` | Run ESLint |
| `bun lint:fix` | Auto-fix linting issues |
| `bun format` | Format code with Prettier |
| `bun test:watch` | Run tests (watch mode) |
| `bun test:run` | Run tests once |
| `bun generate-types` | Generate OpenAPI types |

---

## Generating API Types

**Prerequisite:** API must be running on port 8081

```bash
# Start API first (in another terminal)
cd ../senda-api
make run

# Generate types
bun generate-types
```

This fetches `/openapi.json` from the API and generates `src/types/api.d.ts`.

---

## Code Quality

### Type Checking

```bash
bun typecheck
```

**Important:** Always run before committing. CI will fail on type errors.

### Linting

```bash
# Check
bun lint

# Fix
bun lint:fix
```

Uses ESLint with:
- Next.js plugin
- TypeScript plugin
- Import plugin
- React Hooks plugin

### Formatting

```bash
bun format
```

Uses Prettier for consistent formatting.

### Pre-commit Hooks

Husky + lint-staged runs automatically on commit:
- ESLint fix
- Prettier format

---

## Testing

### Run Tests

```bash
# Watch mode
bun test:watch

# One-time run
bun test:run
```

Uses Vitest with React Testing Library.

### Test Structure

```
src/
└── test/
    └── setup.ts    # Test setup
tests/              # Test files (if separate)
```

---

## Development Workflow

### 1. Create Feature Branch

```bash
git checkout -b feature/my-feature
```

### 2. Start Development

```bash
bun dev
```

### 3. Make Changes

Follow the Container Pattern:
- **UI only:** `index.tsx`
- **Logic:** `connect.ts`
- **Types:** `types.ts`
- **Constants:** `constants.ts`

### 4. Quality Checks

```bash
bun typecheck
bun lint
bun test:run
```

### 5. Commit

Uses conventional commits:
```bash
git commit -m "feat: add my feature"
```

Commitlint validates the format.

---

## Project Structure Quick Reference

```
src/
├── app/           # Pages (App Router)
├── containers/    # Feature components
├── components/    # Reusable components
├── hooks/         # API hooks
├── stores/        # Client state
├── lib/           # Utilities
└── types/         # Type definitions
```

### Container Structure

```
MyContainer/
├── index.tsx     # UI only
├── connect.ts    # useConnect hook
├── types.ts      # Component types
└── constants.ts  # Constants, Zod schemas
```

---

## Adding New Features

### New Container

```bash
mkdir -p src/containers/Main/MyFeature
touch src/containers/Main/MyFeature/index.tsx
touch src/containers/Main/MyFeature/connect.ts
```

**index.tsx:**
```typescript
'use client';
import { useConnect } from './connect';

export function MyFeature() {
  const { data, isLoading } = useConnect();
  
  if (isLoading) return <Skeleton />;
  return <div>{/* UI */}</div>;
}
```

**connect.ts:**
```typescript
import { useSomeHook } from '@/hooks/useSomeHook';

export function useConnect() {
  const { data, isLoading } = useSomeHook();
  return { data, isLoading };
}
```

### New API Hook

```bash
touch src/hooks/useMyEntity.ts
```

**useMyEntity.ts:**
```typescript
import { $api } from '@/lib/api';

export function useMyEntity(id: string) {
  return $api.useQuery('get', '/my-entity/{id}', {
    params: { path: { id } }
  });
}
```

### New Page

```bash
mkdir -p src/app/my-page
touch src/app/my-page/page.tsx
```

**page.tsx:**
```typescript
import { MyFeature } from '@/containers/Main/MyFeature';

export default function MyPage() {
  return <MyFeature />;
}
```

---

## API Integration Patterns

### Query (GET)

```typescript
// Single item
const { data: course } = useCourse(slug);

// List
const { data: courses } = useCourses();
```

### Mutation (POST/PUT/DELETE)

```typescript
const { createCourse, updateCourse, deleteCourse } = useCourseActions();

// Usage
await createCourse.mutateAsync(data);
await updateCourse.mutateAsync({ slug, data });
await deleteCourse.mutateAsync(slug);
```

### Error Handling

```typescript
const mutation = useMutation({
  onSuccess: () => toast.success('Saved!'),
  onError: (error) => toast.error(error.message)
});
```

---

## Styling with Tailwind

### Using Design Tokens

```tsx
<div className="bg-background text-foreground">
  <h1 className="text-primary">Title</h1>
  <p className="text-muted-foreground">Description</p>
</div>
```

### Dark Mode

Theme toggle handled by `next-themes`. Use CSS variables for colors.

### shadcn/ui Components

```tsx
import { Button } from '@/components/ui/button';
import { Card, CardHeader, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
```

---

## Troubleshooting

### API Connection Failed

1. Verify API is running: `curl http://localhost:8081/api/health-check`
2. Check `NEXT_PUBLIC_API_BASE_URL` in `.env`
3. Check CORS settings in API

### Type Errors

1. Run `bun generate-types` to update types
2. Ensure API is running with latest schema
3. Check imports from `@/types/api`

### Build Failures

1. Run `bun typecheck` to find type errors
2. Run `bun lint` to find linting issues
3. Check for missing environment variables

### Hot Reload Not Working

1. Check Next.js dev server logs
2. Try restarting: `bun dev`
3. Clear `.next` cache: `rm -rf .next`

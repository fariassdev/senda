# Architecture - Senda CMS

**Part:** senda-cms
**Type:** Web Application
**Stack:** Next.js 16 + TypeScript + Tailwind CSS 4

---

## Architecture Pattern

**Container Pattern** with strict separation:

```
┌─────────────────────────────────────────────────────────┐
│                   App Router (app/)                      │
│              Pages, Layouts, API Routes                  │
├─────────────────────────────────────────────────────────┤
│                Containers (containers/)                  │
│      Feature-specific components with business logic     │
├─────────────────────────────────────────────────────────┤
│                Components (components/)                  │
│         Reusable UI components (shared logic)           │
├──────────────────────┬──────────────────────────────────┤
│   UI Primitives      │         Hooks (hooks/)           │
│   (components/ui/)   │    API hooks (React Query)       │
├──────────────────────┼──────────────────────────────────┤
│                      │         Stores (stores/)          │
│                      │    Client state (Zustand)         │
├──────────────────────┴──────────────────────────────────┤
│                    Lib (lib/)                            │
│           Utilities, API client, helpers                 │
└─────────────────────────────────────────────────────────┘
```

---

## Directory Structure

```
senda-cms/
├── src/
│   ├── app/                      # Next.js App Router
│   │   ├── layout.tsx            # Root layout
│   │   ├── globals.css           # Global styles + Tailwind
│   │   ├── login/                # Login page
│   │   │   └── page.tsx
│   │   ├── courses/              # Course pages
│   │   │   ├── page.tsx          # Course list
│   │   │   └── [slug]/           # Course detail
│   │   │       └── page.tsx
│   │   └── api/                  # API routes (if needed)
│   │
│   ├── containers/               # Feature Containers
│   │   ├── Guest/               # Unauthenticated views
│   │   │   └── SignIn/          # Login container
│   │   │       ├── index.tsx    # UI
│   │   │       ├── connect.ts   # Logic
│   │   │       ├── types.ts
│   │   │       └── constants.ts
│   │   │
│   │   └── Main/                # Authenticated views
│   │       ├── CourseList/      # Course list container
│   │       │   ├── index.tsx
│   │       │   ├── connect.ts
│   │       │   ├── CourseCard/  # Nested component
│   │       │   └── CourseRow/
│   │       │
│   │       ├── CourseDetail/    # Course detail container
│   │       │   ├── index.tsx
│   │       │   ├── connect.ts
│   │       │   ├── CourseHeader/
│   │       │   ├── LessonList/
│   │       │   │   ├── index.tsx
│   │       │   │   ├── connect.ts
│   │       │   │   ├── LessonRow/
│   │       │   │   └── ...
│   │       │   └── ...
│   │       │
│   │       ├── CourseForm/      # Create/Edit course
│   │       └── ScriptEditor/    # Script editing
│   │
│   ├── components/              # Reusable Components
│   │   ├── ui/                  # shadcn/ui primitives
│   │   │   ├── button.tsx
│   │   │   ├── card.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── input.tsx
│   │   │   ├── select.tsx
│   │   │   ├── skeleton.tsx
│   │   │   └── ... (22 components)
│   │   │
│   │   ├── Navigation/          # Shared navigation
│   │   │   ├── index.tsx
│   │   │   └── connect.ts
│   │   ├── StatusBadge/         # Lesson status indicator
│   │   ├── AudioPlayer/         # Audio playback
│   │   ├── LessonForm/          # Lesson create/edit form
│   │   ├── DeleteCourseModal/   # Confirmation modal
│   │   ├── ScriptGenerationModal/
│   │   ├── AudioConfigModal/
│   │   ├── AuthLayout.tsx       # Auth protection wrapper
│   │   ├── ClientLayout.tsx     # Client-side providers
│   │   ├── QueryProvider.tsx    # React Query provider
│   │   └── ThemeProvider.tsx    # Theme context
│   │
│   ├── hooks/                   # API Hooks
│   │   ├── useCourse.ts         # GET single course
│   │   ├── useCourses.ts        # GET course list
│   │   ├── useCourseActions.ts  # Course mutations (CUD)
│   │   ├── useLessonActions.ts  # Lesson mutations
│   │   ├── useScriptGeneration.ts
│   │   ├── useBatchScriptGeneration.ts
│   │   ├── useAudioGeneration.ts
│   │   ├── useAuthRefresh.ts
│   │   ├── useLessonReorder/    # Drag-and-drop reordering
│   │   │   ├── index.ts
│   │   │   ├── useOptimisticReorder.ts
│   │   │   └── useDragSensors.ts
│   │   └── use-mobile.ts        # Responsive hook
│   │
│   ├── stores/                  # Client State
│   │   └── authStore.ts         # Zustand auth store
│   │
│   ├── lib/                     # Utilities
│   │   ├── api.ts               # OpenAPI client setup
│   │   └── utils.ts             # Helper functions
│   │
│   ├── types/                   # Type Definitions
│   │   └── api.d.ts             # Generated OpenAPI types
│   │
│   ├── contexts/                # React Contexts
│   │   └── ...
│   │
│   ├── test/                    # Test utilities
│   │   └── setup.ts
│   │
│   └── proxy.ts                 # API proxy configuration
│
├── public/                      # Static assets
│
├── docs/                        # CMS documentation
│   ├── architecture.md          # Architecture decisions
│   ├── PRD.md                   # Product requirements
│   ├── epics.md                 # Development epics
│   ├── design-system.md         # UI design system
│   ├── api-integration.md       # API patterns
│   └── ...
│
├── next.config.ts               # Next.js configuration
├── tailwind.config.ts           # Tailwind configuration
├── tsconfig.json                # TypeScript configuration
├── package.json                 # Dependencies
└── Dockerfile                   # Container definition
```

---

## Component Structure

### Container Pattern (4-File Rule)

Every container/component follows this structure:

```
ComponentName/
├── index.tsx      # UI only (presentational)
├── connect.ts     # Logic hook (useConnect)
├── types.ts       # Component-specific types
└── constants.ts   # Constants and Zod schemas
```

**Rule:** Only create `connect.ts`, `types.ts`, `constants.ts` if NOT empty.

### Example: CourseDetail Container

```typescript
// containers/Main/CourseDetail/index.tsx
export function CourseDetail() {
  const { course, lessons, isLoading, handleEdit } = useConnect();
  
  if (isLoading) return <Skeleton />;
  
  return (
    <div>
      <CourseHeader course={course} onEdit={handleEdit} />
      <LessonList lessons={lessons} />
    </div>
  );
}

// containers/Main/CourseDetail/connect.ts
export function useConnect() {
  const { slug } = useParams();
  const { data: course, isLoading } = useCourse(slug);
  const router = useRouter();
  
  const handleEdit = () => router.push(`/courses/${slug}/edit`);
  
  return { course, lessons: course?.lessons, isLoading, handleEdit };
}
```

---

## State Management

### Server State (React Query)

```typescript
// lib/api.ts
import createClient from 'openapi-fetch';
import createQueryClient from 'openapi-react-query';
import type { paths } from '@/types/api';

export const apiClient = createClient<paths>({ baseUrl: '/api' });
export const $api = createQueryClient(apiClient);

// hooks/useCourse.ts
export function useCourse(slug: string) {
  return $api.useQuery('get', '/courses/{slug}', {
    params: { path: { slug } }
  });
}

// hooks/useCourseActions.ts
export function useCourseActions() {
  const queryClient = useQueryClient();
  
  const createCourse = useMutation({
    mutationFn: (data) => apiClient.POST('/courses', { body: data }),
    onSuccess: () => queryClient.invalidateQueries(['courses'])
  });
  
  return { createCourse, ... };
}
```

### Client State (Zustand)

```typescript
// stores/authStore.ts
interface AuthState {
  user: User | null;
  token: string | null;
  setAuth: (user: User, token: string) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      token: null,
      setAuth: (user, token) => set({ user, token }),
      logout: () => set({ user: null, token: null })
    }),
    { name: 'auth-storage' }
  )
);
```

---

## Routing Structure

```
/                       → Redirect to /courses
/login                  → SignIn container
/courses                → CourseList container
/courses/new            → CourseForm (create mode)
/courses/[slug]         → CourseDetail container
/courses/[slug]/edit    → CourseForm (edit mode)
```

### Route Protection

```typescript
// components/AuthLayout.tsx
export function AuthLayout({ children }) {
  const { token } = useAuthStore();
  const router = useRouter();
  
  useEffect(() => {
    if (!token) router.push('/login');
  }, [token]);
  
  if (!token) return null;
  return children;
}
```

---

## API Hook Naming Convention

| Pattern | Purpose | Example |
|---------|---------|---------|
| `use{Entity}` | GET single item | `useCourse(slug)` |
| `use{Entity}s` | GET list | `useCourses()` |
| `use{Entity}Actions` | Mutations (CUD) | `useCourseActions()` |
| `use{Feature}` | Feature-specific | `useScriptGeneration()` |

---

## UI Components (shadcn/ui)

Located in `src/components/ui/`:

| Component | Usage |
|-----------|-------|
| `button` | Actions, navigation |
| `card` | Content containers |
| `dialog` | Modals, confirmations |
| `input` | Text inputs |
| `select` | Dropdown selections |
| `checkbox` | Boolean inputs |
| `switch` | Toggle controls |
| `skeleton` | Loading states |
| `separator` | Visual dividers |
| `alert-dialog` | Destructive confirmations |
| `tooltip` | Contextual hints |
| `progress` | Progress indicators |
| `slider` | Range inputs |
| `label` | Form labels |

---

## Forms (React Hook Form + Zod)

```typescript
// components/LessonForm/constants.ts
export const lessonSchema = z.object({
  title: z.string().min(1, 'Title is required'),
  core_practice: z.string().min(1),
  key_point: z.string().min(1),
  tone: z.string().min(1),
  duration_minutes: z.coerce.number().min(1).max(60)
});

// components/LessonForm/index.tsx
export function LessonForm({ onSubmit }) {
  const form = useForm({
    resolver: zodResolver(lessonSchema)
  });
  
  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        <FormField name="title" control={form.control} render={...} />
        ...
      </form>
    </Form>
  );
}
```

---

## Error Handling

### API Errors

```typescript
// In mutations
onError: (error) => {
  toast.error(error.message || 'An error occurred');
}
```

### Loading States

```typescript
// Skeleton loaders for initial load
if (isLoading) return <CourseDetailSkeleton />;

// Disabled buttons during mutations
<Button disabled={isPending}>
  {isPending && <Loader2 className="animate-spin" />}
  Save
</Button>
```

---

## Styling (Tailwind CSS 4)

### Design Tokens

```css
/* app/globals.css */
@theme {
  --color-background: ...;
  --color-foreground: ...;
  --color-primary: ...;
  --color-muted: ...;
  --radius: 0.5rem;
}
```

### Dark Mode

Theme toggle via `next-themes` with CSS variables.

---

## Development Commands

```bash
# Start development
bun dev

# Type checking
bun typecheck

# Linting
bun lint
bun lint:fix

# Formatting
bun format

# Testing
bun test:watch
bun test:run

# Build
bun build

# Generate API types
bun generate-types
```

---

## Deployment

### Vercel Configuration

- **Production:** `main` branch → automatic deploy
- **Preview:** Pull requests → preview deployments
- **Environment:** Variables set in Vercel dashboard

### Required Environment Variables

```env
NEXT_PUBLIC_API_BASE_URL=https://api.example.com/api
NEXT_PUBLIC_BUILD=production
JWT_SECRET=your-jwt-secret
```

---

## Key Design Decisions

1. **OpenAPI-first:** All types generated from backend spec
2. **Container Pattern:** Strict UI/Logic separation
3. **React Query:** Server state, no Redux needed
4. **Zustand:** Minimal client state (auth only)
5. **shadcn/ui:** Accessible, customizable primitives
6. **Tailwind 4:** Modern CSS with design tokens

For complete architecture decisions, see [docs/architecture.md](../senda-cms/docs/architecture.md).

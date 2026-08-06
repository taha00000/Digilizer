# DIGILYZR eWay — Flutter app

Pharmaceutical sales-force automation for medical reps and their managers.
iOS-first Flutter rebuild; Android follows from the same codebase.

**This phase: Login + Main Dashboard.** Modules, Team, Reports and Call
Reporting come later — see [HANDOFF.md](HANDOFF.md).

---

## Getting it running

Verified on **Flutter 3.44.9 / Dart 3.12.2**. `ios/`, `android/` and `web/` are
generated and committed, so this is a straight clone-and-run:

```bash
flutter pub get
```

```bash
flutter run --dart-define=USE_MOCK=true
```

No codegen step is needed — the models are hand-written on purpose so the app
builds straight after `pub get`. `build_runner` is already in `dev_dependencies`
for when Freezed/Retrofit/Drift come in.

To see it without a simulator:

```bash
flutter run -d chrome --dart-define=USE_MOCK=true
```

Sign in with any non-empty company / username / password — the placeholder
datasource accepts anything and returns the demo session.

### Tests

```bash
flutter test
```

43 tests: unit, widget, and golden. `flutter analyze` is clean.

Goldens live in `test/golden/images/` and cover login + dashboard in all three
themes. After an intentional UI change, regenerate them:

```bash
flutter test --update-goldens
```

---

## How it is put together

Clean Architecture, feature-first. The dependency rule points inward:
`presentation → domain ← data`.

```
lib/
├── core/                     cross-cutting, no feature knowledge
│   ├── constants/            AppConfig (the USE_MOCK flag)
│   ├── error/                typed Failures
│   ├── network/              Dio client + interceptors
│   ├── router/               go_router + the session guard
│   ├── services/             biometrics, secure token store, prefs
│   ├── session/              app-wide AppSession + sign-out
│   └── theme/                the three themes as ThemeExtension tokens
├── features/
│   ├── auth/       data / domain / presentation
│   └── dashboard/  data / domain / presentation
└── shared/widgets/           reusable UI (cards, donut, pills, tab bar)
```

### The service layer

The client's API and data structure are still pending, so **everything runs on
placeholder data behind an abstraction**. Each feature has exactly one swap
point:

```
presentation → domain (UseCase → Repository interface)
                   ↑
                data (RepositoryImpl → DataSource interface)
                                          ├── XxxMockDataSource    ← used now
                                          └── XxxRemoteDataSource  ← stubbed
```

The switch is a single `if` in `presentation/providers/*_providers.dart`,
gated on `AppConfig.useMockData`. Flip it with:

```bash
flutter run --dart-define=USE_MOCK=false
```

Both `*RemoteDataSource` classes exist and are wired; they throw
`UnimplementedError` until the real endpoints land. Everything that needs to
change when the API arrives is marked `TODO(real-api)`.

### Theming

Three approved themes (Aurora, Company Blue, Blue Dark) live as `AppTokens`,
a `ThemeExtension`. Widgets read `context.tokens.primary` — **never** a
hard-coded `Color`. That is what lets the app re-skin live from the profile
sheet.

**Inter is bundled, not fetched.** `assets/google_fonts/` holds the five
weights the design uses, and `main()` sets
`GoogleFonts.config.allowRuntimeFetching = false`. Left on the default,
google_fonts downloads Inter over HTTP on first launch — a rep opening the app
with no signal would get a silent fallback font. Bundling costs ~2 MB and makes
type deterministic offline.

---

## Dependencies and why

| Area | Package | Why |
|---|---|---|
| State | `flutter_riverpod` | Compile-safe DI + `AsyncValue` (loading/data/error in one) |
| Navigation | `go_router` | Declarative routes, and the session redirect guard |
| Charts | `fl_chart` | Covers the donut gauge, trend bars and mix views — no licence cost |
| Networking | `dio`, `retrofit` | Interceptors for auth/retry/logging in one place |
| Offline cache | `drift`, `sqlite3_flutter_libs`, `path_provider` | Declared for the offline-first read path (next phase) |
| Biometrics | `local_auth` | Real Face ID / fingerprint prompt |
| Secure storage | `flutter_secure_storage` | Keychain / EncryptedSharedPreferences for the token |
| Preferences | `shared_preferences` | Theme + remembered username only — never secrets |
| Connectivity | `connectivity_plus` | Drives offline/sync state |
| Models | `freezed`, `json_serializable` | For the real API models |
| UI | `google_fonts`, `flutter_svg`, `shimmer`, `intl` | Type, icons, skeletons, formatting |
| Errors | `dartz` | `Either<Failure, T>` instead of throwing across layers |

---

## Status

**Done**

- Login: three fields, remember-me, show/hide password, forgot-password stub,
  real `local_auth` biometric prompt (hidden when the device has none)
- Session guard: `/dashboard` is unreachable signed-out; sign-out returns to login
- Dashboard: period pills, hero card + gauge, KPI pair with inline micro-viz,
  trend chart with 6M/4Q toggle and tap-to-select, sales-mix card with
  Donut/Bars/Share, sortable top-brands table, today's calls,
  hide-on-scroll tab bar, pull-to-refresh, skeleton and error states
- Profile sheet with the live theme switcher, persisted
- Remote datasource stubs behind the same interfaces
- Inter bundled for offline-deterministic type
- 43 tests (unit + widget + golden), clean `flutter analyze`, web build verified

**Next**

- Drift database + the offline cache read path (deps are already declared)
- Wire the period pills to the real request once the API defines scoping
- Modules / Team / Reports / Call Reporting screens

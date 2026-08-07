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
dart run build_runner build --delete-conflicting-outputs
```

```bash
flutter run --dart-define=USE_MOCK=true
```

The codegen step is required: Drift generates `lib/core/database/app_database.g.dart`,
which is gitignored. Everything else is hand-written, so that one command is the
whole of it.

To see it without a simulator:

```bash
flutter run -d chrome --dart-define=USE_MOCK=true
```

### Running at phone size on a desktop

The Windows runner window is set to iPhone logical points (393×852) in
`windows/runner/main.cpp`, so the desktop build lays out exactly as it will on
device. Windows is a dev harness only — this app ships iOS-first.

```bash
flutter run -d windows --dart-define=USE_MOCK=true
```

> Requires the **C++ ATL** component in Visual Studio Build Tools —
> `flutter_secure_storage_windows` needs `atlstr.h`. Without it the Windows
> build fails at link time.

Face ID is unavailable on desktop and web: `local_auth` has no sensor to
report, so the button hides itself.

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

Every token is transcribed from the CSS custom properties in
`docs/eWay_Interactive_Prototype_FINAL.html`, and the Dart field names mirror
the CSS names (`--pri-soft2` → `primarySoft2`) so the two can be diffed by eye.
Widgets carry the source CSS rule in a doc comment. Things that are easy to get
wrong and are deliberate:

- The **login backdrop is per-theme and is not the brand gradient** — Aurora's
  is deep navy (`--logingrad`) under two radial glows.
- The whole app sits on `AppBackground`, which layers `--glow1`/`--glow2` over
  `--canvasgrad`. Without it the dark themes read as flat black.
- Positive deltas use `--pri` (`.up`), not a semantic green.
- There are **two** segmented-control looks: `.seg` (raised surface chip) and
  `.mixhead .seg` (solid brand chip). See `SegStyle`.

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

### Offline-first

`core/database/` holds a Drift database with a single `CachedResponses` table:
logical request key → JSON payload → timestamp. Repositories write through on
every success and fall back to the cached copy when the network is down, so a
rep with no signal still sees the last good numbers.

It is a key/value store of JSON rather than typed tables per screen on purpose
— the client's data structure is unconfirmed, so typed columns would be
rewritten the moment the real API lands, and the same `fromJson` that parses a
live response parses the cached one.

**Only network failures fall back.** A 500 or a 401 surfaces as an error:
silently serving yesterday's numbers after a server error is worse than an
honest error state. Sign-out clears the cache, since cached responses are
another user's data once the session ends.

**Next**

- Wire the period pills to the real request once the API defines scoping
- Encrypt the cache with `sqlcipher_flutter_libs` before real customer data is
  stored (dependency already listed; see the TODO in `app_database.dart`)
- The prototype's Face ID scan overlay, add-visit sheet and report export

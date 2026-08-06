# eWay — Claude Code Handoff Brief

**Read this first.** This is the working brief for building the DIGILYZR eWay
Flutter app. It tells you what exists, what to build, the rules to follow, and
the order to work in.

---

## 1. What this project is

eWay is a pharmaceutical sales-force automation (SFA) app for medical reps and
their managers — logging doctor/chemist visits, tracking sales vs target,
coverage, and growth. This repo is the **iOS-first Flutter rebuild**. Android
comes later from the same codebase.

**This phase: Login + Main Dashboard only.** Other screens (Modules, Team,
Reports, Call Reporting) come in later phases.

---

## 2. Current state of the repo

A working scaffold is already in place. It **compiles conceptually** but you
must run codegen and `flutter pub get` first (see §6). What exists:

- Clean Architecture, feature-first structure (`lib/features/<feature>/{data,domain,presentation}`)
- Three approved themes wired as `ThemeExtension` tokens (`lib/core/theme/`)
- **Auth feature**: login screen (matches prototype), mock datasource, repo, Riverpod controller
- **Dashboard feature**: hero + KPI cards + fl_chart trend, mock datasource with the exact approved numbers
- go_router with `/login` and `/dashboard`
- Placeholder data behind a **service layer** (see §4) — no real API yet

---

## 3. Attached reference files (and how to use each)

| File | What it is | How to use it |
|---|---|---|
| `eWay_Interactive_Prototype_FINAL.html` | The approved, clickable design | **Visual source of truth.** Open it in a browser. Match layout, spacing, colours, and interactions to it. Do NOT try to import or convert it — it is a reference, not code. |
| `eWay_Technical_Development_Report.*` | Architecture & library rationale | The "why" behind every technical choice. Follow its decisions (Riverpod, Drift, Dio, etc.). |
| `eWay_Home_BuildPlan.*` | Component inventory & phasing | The list of reusable components to build and the phase order. |
| `eWay_v5_Themes.png` | The three themes side by side | Quick colour reference. |
| This `HANDOFF.md` | Your brief | The task list and rules below. |

> The prototype is a **reference to match**, not a spec to execute. This
> document + the report are the actual spec.

---

## 4. The one rule that matters most: the service layer

The client's real API and data structure are **not ready yet**. Everything is
built against **placeholder data behind an abstraction**, so the real endpoints
drop in later with zero UI changes.

The pattern, already established in the repo:

```
presentation → domain (UseCase → Repository interface)
                   ↑
                data (RepositoryImpl → DataSource interface)
                                          ├── XxxMockDataSource   ← used now
                                          └── XxxRemoteDataSource  ← build later
```

- **Now:** `*MockDataSource` returns hardcoded data (matching the prototype).
- **Later:** create `*RemoteDataSource` (Dio/Retrofit) and switch the provider.
- The switch happens in ONE place per feature — the `*DataSourceProvider` in
  `presentation/providers/`. Gate it on `AppConfig.useMockData`.

**Never** call an API or touch a model directly from a widget. Always go
through the repository. This is what lets us swap mock → real safely.

Swap points are marked in code with `// TODO(real-api)` and
`AppConfig.useMockData`.

---

## 5. Build rules (non-negotiable)

1. **Clean Architecture, strictly.** Domain layer is pure Dart — no Flutter, no
   packages. Vendor libraries (Dio, Drift) live only in `data/`.
2. **Never hard-code a colour.** Read from `context.tokens` (the theme
   extension). This is what makes all three themes work.
3. **State = Riverpod.** Async data uses `FutureProvider`/`AsyncValue`
   (loading/data/error in one). No `setState` for business data.
4. **Immutable models.** Use Freezed for new models (`json_serializable` for
   the real API later).
5. **Match the prototype** for layout, colour, and interaction — don't invent
   new UI patterns.
6. **Offline-first mindset.** Even with mock data, structure reads so a Drift
   cache can slot in later (see report §5). Don't assume the network.
7. Keep features isolated — no cross-feature imports except via `shared/`.

---

## 6. First commands to run

```bash
flutter create --platforms=ios,android --org com.digilyzr .  # generates ios/ + android/
flutter pub get
flutter run --dart-define=USE_MOCK=true                      # placeholder data
```

Codegen is **not** required yet — the models are hand-written so the app
builds straight after `pub get`. `build_runner` is in `dev_dependencies` for
when Freezed / Retrofit / Drift come in; at that point add:

```bash
dart run build_runner build --delete-conflicting-outputs
```

If `flutter run` can't find a device, use an iOS simulator (`open -a Simulator`)
or Chrome (`flutter run -d chrome`) for a quick look.

---

## 7. Task list (do in this order)

> Status as of the current build. `README.md` carries the same summary.

### Task 0 — Platform folders
- [x] `ios/`, `android/` and `web/` generated (org `com.digilyzr`) and
      committed. Clone and `flutter pub get` is enough.

### Task 1 — Get it building & login working
- [x] `flutter pub get` — no codegen needed yet; models are hand-written on
      purpose so the app builds straight after `pub get`
- [x] Login screen matches the prototype (gradient, DIGILYZR wordmark,
      company/username/password, remember-me, forgot-password, Face ID)
- [x] Sign-in with any non-empty values reaches `/dashboard` via the mock
      datasource — now through a router session guard rather than an
      imperative `context.go`
- [x] Biometric button wired to `local_auth` (real prompt); hidden entirely
      when the device has no biometrics, and falls back to the mock session
      when the sensor is unavailable and `USE_MOCK=true`

### Task 2 — Finish the dashboard to match the prototype
- [x] Hero achievement card with the 58% circular gauge (fl_chart PieChart)
- [x] KPI cards with the inline mini-bars / coverage ring
- [x] **Sales-mix card** with the Donut / Bars / Share toggle
- [x] **Top-brands table** — sortable columns, inline bars, GoLY badges
- [x] Period filter pills (This month / Day / YTD / vs LY)
- [x] Hide-on-scroll bottom tab bar; only Home is active this phase
- [x] Also added: today's-calls pair, pull-to-refresh, skeleton + error states

### Task 3 — Theme switching
- [x] Profile sheet (tap avatar) with the in-app theme switcher
      (Aurora / Company Blue / Blue Dark), persisting via `ThemeController`

### Task 4 — Harden the data layer for the real API
- [x] `AuthRemoteDataSource` and `DashboardRemoteDataSource` exist behind the
      same interfaces, gated on `AppConfig.useMockData`, throwing
      `UnimplementedError` until the client's data structure arrives
- [x] Model boundary added (`AuthSessionModel`, `DashboardSummaryModel`) with
      defensive `fromJson` — one file per feature to remap when the API lands
- [ ] Drift database + offline cache read path (report §5) — deps are declared
      in `pubspec.yaml`, implementation not started

### Task 5 — Tests
- [x] Unit tests for the repositories and model parsing (fake datasources)
- [x] Widget tests for login + dashboard render, including a pass in all
      three themes
- [x] Golden tests across all three themes (`test/golden/`), with Inter
      bundled so goldens are deterministic and reproduce in CI

Verified on Flutter 3.44.9 / Dart 3.12.2: 43 tests pass, `flutter analyze`
clean, `flutter build web` succeeds.

---

## 8. Data shapes (placeholder — will change when the real API lands)

The mock datasources currently return exactly these (from the approved
prototype). Treat the **shapes** as provisional; the real API may differ, which
is fine — only the `*RemoteDataSource` + model mapping will change.

**Dashboard summary:** achievement 58%, sales `PKR 30.1M`, target `PKR 51.7M`,
day-to-date 109%, coverage 74% (4,099 / 5,514).
**Trend (6M):** Jan 42, Feb 48, Mar 45, Apr 58, May 62, Jun 71.
**Trend (4Q):** Q1 140, Q2 165, Q3 158, Q4 182.
**Today's calls:** planned done 205 / 1,242, total done 285 (+80 unplanned).
**Sales mix:** Retail 16.0M/67%, Institution 4.5M/19%, Doctor 2.2M/9%,
Wholesale 1.4M/5%.
**Top brands:** Vlep 8.8M/63%/GoLY+58, Cubriva 8.3M/64%/+101,
Carlep 4.9M/64%/+179, Seipil 2.3M/62%/+55, Prixteen 2.0M/58%/+40.
**Login demo:** company `HILAL`, user `demo.support`, account `999903`,
name `Demo Support`.

---

## 9. When the real API arrives (later)

1. Fill `AppConfig.apiBaseUrl` and add the auth scheme to the Dio interceptor.
2. Implement `AuthRemoteDataSource` / `DashboardRemoteDataSource` with Retrofit.
3. Add `fromJson` to the models (json_serializable).
4. Flip the `*DataSourceProvider`s to return the remote source when
   `!AppConfig.useMockData`.
5. Run `--dart-define=USE_MOCK=false` and verify against staging.

No widget, screen, or provider-consumer code should need to change.

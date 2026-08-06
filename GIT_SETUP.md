# Getting this onto GitHub (2 minutes)

I can't create the GitHub repo from here, so here's the exact sequence. Run it
from inside the `eway_app/` folder after you download and unzip it.

## Option A — GitHub CLI (fastest, if you have `gh`)

```bash
cd eway_app
git init
git add .
git commit -m "chore: initial eWay Flutter scaffold (login + dashboard, mock data)"
gh repo create digilyzr-eway --private --source=. --remote=origin --push
```

That creates a **private** repo named `digilyzr-eway` and pushes in one go.

## Option B — Manual (no gh CLI)

1. Create an empty repo on github.com (private), e.g. `digilyzr-eway`.
   Do **not** add a README/gitignore there — this repo already has them.
2. Then:

```bash
cd eway_app
git init
git add .
git commit -m "chore: initial eWay Flutter scaffold (login + dashboard, mock data)"
git branch -M main
git remote add origin https://github.com/<your-username>/digilyzr-eway.git
git push -u origin main
```

## After pushing

- Open the repo in Claude Code and point it at `HANDOFF.md`.
- Or clone locally and run:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --dart-define=USE_MOCK=true
```

## Note on the `docs/` folder

`docs/` contains the prototype HTML, the technical report, the build plan and
the theme image, so the design references travel with the code. If you'd rather
keep the repo lean, delete `docs/` before committing — everything in it also
exists in your Downloads.

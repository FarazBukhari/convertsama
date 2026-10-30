# ConvertSama — clean-room Tangerine-style file converter (personal project)

Native macOS menu-bar app: drag file(s) in Finder, tap a modifier → radial wheel at cursor → drop on a slice → converted copy saved beside the original.

Named "Rondo" through v0.1.2 (bundle id `com.farazbukhari.rondo`). Part of the "*Sama" app family (SaveSama, TimetableSama); bundle ids are `com.farazbukhari.<appname>`. `ConvertSamaMain` copies legacy Rondo defaults once; `scripts/install.sh` falls back to the old `Rondo Dev` cert.

- Feature spec: `docs/SPEC.md`
- Architecture + contracts: `docs/ARCHITECTURE.md`
- Build state / gates / manual QA: `docs/PROGRESS.md`
- Build driver: `/orchestrate` (`.claude/skills/orchestrate/`)

## Clean-room rules (hard)

- Behavior spec comes ONLY from the public sources listed in `docs/SPEC.md` (App Store listing, vendor site, press coverage).
- Never obtain, download, extract, disassemble, decompile, or runtime-inspect Tangerine's binary, `.pkg`, or App Store bundle — not with REA, Hopper, Ghidra, IDA, `otool`, `strings`, `class-dump`, or anything else. Apple's licensed-application EULA forbids reverse engineering, and REA's own scope is software you own or are authorized to examine.
- Never copy Tangerine's name, icon, screenshots, UI artwork, or marketing copy. Codename is "ConvertSama"; all visuals original.
- REA, if installed, may only be pointed at this repo's own build outputs.

## Toolchain (this Mac)

- Intel `x86_64`, macOS 26, **Command Line Tools only** — no Xcode.app, so no `xcodebuild`, no `.xcodeproj`, no previews. SwiftPM only.
- Swift 6.3. Deployment target macOS 13.
- Homebrew prefix `/usr/local`: `ffmpeg`, `ffprobe`, `magick` installed. `pandoc`, `soffice` not installed (optional; engines must gate on presence). `ToolLocator` also searches `/opt/homebrew/bin` for portability.
- Disk is tight (~24 GB free on 2026-10-20). Share one `.build`; no per-agent `--scratch-path` dirs.

## Commands

Scripts are created by `/orchestrate` phase 1 — check they exist first.

- `swift build --target <Target>` — build one module (use this during parallel work)
- `swift build` / `swift build -c release`
- `swift test` (if the phase-0 probe in `docs/PROGRESS.md` says it works) else `swift run convertsama-cli selftest`
- `scripts/bundle.sh [debug|release]` → `build/ConvertSama.app`
- `scripts/run.sh` — bundle + launch
- `swift run convertsama-cli convert <in> --to <fmt>` / `swift run convertsama-cli tool <toolID> <in...> [--opt k=v]`
- `scripts/make-fixtures.sh` then `scripts/smoke.sh` — conversion matrix pass/fail
- `scripts/install.sh` — release build signed with `ConvertSama Dev` (if present) → /Applications
- `UNIVERSAL=1 scripts/bundle.sh release` — arm64+x86_64 (needs full Xcode; used by CI)
- `scripts/package.sh vX.Y.Z` — zip + sha256 + release notes into `dist/`
- Release: bump `CFBundleShortVersionString` + `CHANGELOG.md`, push tag `vX.Y.Z` → `.github/workflows/release.yml` publishes the GitHub release
- Public repo: github.com/FarazBukhari/convertsama (MIT). README/release notes stay neutral — no Tangerine mentions there.

## Conventions

- Never modify input files. Write to a temp dir, then move into place via `OutputNamer` (Finder-style `name 2.ext` on collision).
- Shell out only through `ProcessRunner` (async, cancellable, kills child on task cancel).
- Engines report capabilities at runtime (tool presence, ImageIO writable types) — never advertise a conversion this Mac can't do.
- Engine targets: no window/UI code. UI lives in `ConvertSamaInteraction`, `ConvertSamaShell`, `*UI` targets.
- Only the orchestrator edits `Package.swift`, `ConvertSamaKit` public API, and `EngineRegistry` wiring.
- Git: local checkpoint commits at phase gates are fine; never push.

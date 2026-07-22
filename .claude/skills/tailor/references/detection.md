# Detection Signal Map

Mechanical signal → golden-path-row contract for the Detect phase. One row per claim; cite the
file when applying a row. This is a lookup table, not prose — extend it by adding rows.

## Precedence

Tier decides the winner when two signals disagree within the same golden-path row:

| Tier | Meaning | Example |
|------|---------|---------|
| L | Committed lockfile | `pnpm-lock.yaml` pins Package Manager: pnpm even if `package-lock.json` also exists |
| M | Manifest field | `"packageManager": "pnpm@9"` in `package.json` |
| D | Dependency presence | `"vitest"` in `devDependencies` implies Testing: Vitest, unpinned |
| I | Inference | Directory/extension convention, no explicit declaration |

Cite the winning tier per claim in the Detect fingerprint table. Never assert a row from a lower
tier when a higher tier is present and contradicts it — flag the contradiction instead.

## TypeScript / JavaScript

| Signal | Fills | Tier |
|--------|-------|------|
| `package.json` present | Section applies | M |
| `pnpm-lock.yaml` | Package Manager: pnpm | L |
| `yarn.lock` / `package-lock.json` | Package Manager: yarn / npm (deviation) | L |
| `bun.lockb` / `bun.lock` | Package Manager: bun (deviation); Runtime: Bun | L |
| `biome.json` / `biome.jsonc` | Hygiene: Biome | M |
| `.eslintrc*` / `eslint.config.*` | Hygiene: ESLint (deviation) | M |
| `vite.config.*` or `"vite"` in devDependencies | Build: Vite | M/D |
| `"vitest"` in devDependencies or `vitest.config.*` | Testing: Vitest | M/D |
| `"jest"` in devDependencies or `jest.config.*` | Testing: Jest (deviation) | M/D |
| `"react"` + `"react-dom"` in dependencies | Frameworks: React \<version from package.json\> | D |
| `next.config.*` or `nuxt.config.*` | Frameworks: Next.js / Nuxt 4 | M |
| `engines.node` / `.nvmrc` / `.node-version` | Runtime: Node \<version\> | M |

## Python

| Signal | Fills | Tier |
|--------|-------|------|
| `pyproject.toml` present | Section applies | M |
| `requires-python` in `pyproject.toml` / `.python-version` | Runtime: Python \<version\> | M |
| `uv.lock` | Tooling: uv (Manager) | L |
| `poetry.lock` | Tooling: Poetry (deviation) | L |
| `[tool.ruff]` in `pyproject.toml` | Tooling: Ruff (Linter) | M |
| `"litestar"` in dependencies | Framework: Litestar | D |
| `"fastapi"` in dependencies | Framework: FastAPI (deviation) | D |
| `"granian"` in dependencies | Server: Granian | D |
| `"msgspec"` in dependencies | Validation: msgspec | D |
| `"asyncpg"` in dependencies | Database: asyncpg | D |
| `"sqlalchemy"` / `"psycopg"` in dependencies | Database: deviation | D |

## Go

| Signal | Fills | Tier |
|--------|-------|------|
| `go.mod` present | Section applies; `go 1.25` directive → Runtime | M |
| `github.com/gin-gonic/gin` in `go.mod` require | Framework: Gin | D |
| `github.com/go-chi/chi` in `go.mod` require | Framework: Chi | D |
| `sqlc.yaml` / `sqlc.yml` | Data: sqlc | M |
| `github.com/jackc/pgx` in `go.mod` require | Data: pgx v5 | D |
| `.golangci.yml` / `.golangci.yaml` / `.golangci.toml` | Linting: golangci-lint | M |

## Rust

| Signal | Fills | Tier |
|--------|-------|------|
| `Cargo.toml` present | Section applies; `edition = "2024"` → Edition | M |
| `tokio` in `[dependencies]` | Async: Tokio | D |
| `monoio` in `[dependencies]` | Async: Monoio | D |
| `axum` in `[dependencies]` | Framework: Axum | D |
| `sqlx` / `rkyv` in `[dependencies]` | Data: sqlx / rkyv | D |
| `.cargo/config.toml` naming `mold` | Linker: Mold | M |

## Swift

| Signal | Fills | Tier |
|--------|-------|------|
| `Package.swift` / `*.xcodeproj` / `*.xcworkspace` | Section applies; Package Manager: SPM if `Package.swift` | M |
| `swift-tools-version:` in `Package.swift` | Runtime: Swift \<version\> | M |
| `.swiftlint.yml` | Linting: SwiftLint | M |
| `.swiftformat` | Formatting: SwiftFormat | M |
| `fastlane/Fastfile` | CI/CD: fastlane | M |

## Kotlin

| Signal | Fills | Tier |
|--------|-------|------|
| `build.gradle(.kts)` / `settings.gradle(.kts)` present | Section applies; Build: Gradle (Kotlin DSL) | M |
| `androidx.compose` in `build.gradle(.kts)` | UI Framework: Jetpack Compose | D |
| `detekt` plugin/config in `build.gradle(.kts)` | Linting: Detekt | M/D |
| `ktlint` plugin in `build.gradle(.kts)` | Linting: ktlint | M/D |

## Infrastructure

| Signal | Fills | Tier |
|--------|-------|------|
| `Dockerfile` | Production container path exists — cite the base-image line | M |
| `*.tf` | IaC: Terraform (confirms golden path) | M |
| `.github/workflows/*.yml` | CI/CD Platform: GitHub Actions (confirms golden path) | M |
| `railway.json` / `railway.toml` | Agile/PoC: Railway (confirms golden path) | M |
| `fly.toml` | Agile/PoC: Fly.io (deviation) | M |
| `wrangler.toml` / `vercel.json` / `netlify.toml` | Edge/Static deviation — cite which file | M |

## Undetected sections

A language section with zero rows matched above is a **prune candidate**, not evidence of
anything. The Detect fingerprint table lists it as `not detected`; Propose: Prune proposes
removing it rather than leaving unused rows in `tech-strategy.md`.

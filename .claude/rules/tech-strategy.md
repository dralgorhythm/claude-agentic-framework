# Tech Strategy - Golden Paths (Customize for Your Project)

This is the **SINGLE SOURCE OF TRUTH** for technology choices.

## Customization Required

**IMPORTANT**: This file contains example technology choices. Customize it for your project.

Replace the Golden Paths below with your actual tech stack. The framework enforces whatever you put here.

## Compliance

1. **Follow This File**: Use the technologies listed in the Golden Paths below
2. **No Deviations**: Do not suggest alternatives unless explicitly instructed
3. **Latest Stable**: Always use the latest stable version unless pinned

## Language Golden Paths

### TypeScript / JavaScript (Web Standard)

| Component | Choice |
|-----------|--------|
| Runtime | Node.js LTS (Prod), Bun (Local Scripts) |
| Build | Vite |
| Hygiene | Biome |
| Testing | Vitest |
| Frameworks | React 19, Nuxt 4, Next.js |
| Package Manager | pnpm |

### Python (AI & Data Standard)

| Component | Choice |
|-----------|--------|
| Runtime | Python 3.13+ |
| Server | Granian |
| Framework | Litestar |
| Tooling | uv (Manager), Ruff (Linter) |
| Validation | msgspec |
| Database | asyncpg |

### Go (Systems Standard)

| Component | Choice |
|-----------|--------|
| Runtime | Go 1.25+ (PGO) |
| Framework | Gin or Chi |
| Data | sqlc + pgx v5 |
| Linting | golangci-lint |
| Images | Wolfi base |

### Rust (Performance Standard)

| Component | Choice |
|-----------|--------|
| Edition | Rust 2024 |
| Async | Tokio (general), Monoio (high-throughput) |
| Framework | Axum |
| Data | sqlx, rkyv |
| Linker | Mold (dev) |

### Swift (iOS Standard)

| Component | Choice |
|-----------|--------|
| Runtime | Swift 5.10+ / Xcode 16+ |
| UI Framework | SwiftUI (primary), UIKit (legacy) |
| Testing | Swift Testing + XCTest |
| Linting | SwiftLint |
| Formatting | SwiftFormat |
| CI/CD | fastlane |
| Package Manager | Swift Package Manager |
| Architecture | MVVM + Combine |

### Kotlin (Android Standard)

| Component | Choice |
|-----------|--------|
| Runtime | Kotlin 2.0+ / JDK 17 |
| UI Framework | Jetpack Compose |
| Testing | JUnit 5 + Compose Testing |
| Linting | Detekt + ktlint |
| Build | Gradle (Kotlin DSL) |
| CI/CD | GitHub Actions + Gradle |
| Architecture | MVVM + ViewModel + StateFlow |

## Infrastructure

| Component | Choice |
|-----------|--------|
| Static/Frontend | GitHub Pages |
| Agile/PoC | Railway (PaaS) |
| Production | AWS (ECS/Fargate/Lambda) |
| Mobile Distribution | TestFlight (iOS), Google Play (Android) |
| IaC | Terraform |
| Edge/CDN | Cloudflare |
| Secrets | GitHub Secrets / AWS Secrets Manager |

## Data

| Component | Choice |
|-----------|--------|
| Relational (OLTP) | PostgreSQL |
| Object Storage | AWS S3 |
| Vector & AI | pgvector |

## Observability

| Component | Choice |
|-----------|--------|
| Standard | OpenTelemetry (OTel) |
| Protocol | OTLP (gRPC/HTTP) |
| Collector | OTel Collector |
| Dashboard | Aspire (Local), Grafana/Prometheus (Prod) |

## CI/CD

| Component | Choice |
|-----------|--------|
| Platform | GitHub Actions |
| Auth | OIDC |
| Security | Trivy |

## Graduated Hosting Strategy

1. **Static Tier** (Frontend): GitHub Pages - maximum performance, zero maintenance
2. **Agile Tier** (PoC/MVP): Railway - maximum velocity, zero infrastructure code
3. **Production Tier** (Scale): AWS - maximum control, infinite scale

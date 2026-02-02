# System Design: [System/Feature Name]

<!--
System Design Document (Technical Architecture)
Filename: artifacts/system_design_[system].md
Owner: Architect (/architect)
Handoff to: Builder (/builder), Security Auditor (/security-auditor)
Related Skills: designing-systems, designing-apis, cloud-native-patterns, domain-driven-design

This document covers TECHNICAL architecture. For UI/visual design, use design_spec.template.md
Uses C4 model for architecture visualization (Context → Container → Component → Code)
-->

## Metadata

**Status:** Draft | In Review | Approved | Implemented
**Author:** [Name]
**Date:** [YYYY-MM-DD]
**Beads Issue:** [bd://issue-id or N/A]
**Related PRD:** [Link to PRD]
**Related ADRs:** [Links to relevant ADRs]

**Tech Strategy Alignment:**
- [ ] Language/Framework follows Golden Path (`.claude/rules/tech-strategy.md`)
- [ ] Database choice aligns with Data section (PostgreSQL for OLTP)
- [ ] Infrastructure tier appropriate (Static/Agile/Production)
- [ ] Observability uses OpenTelemetry (OTel) with OTLP protocol
- [ ] Deviations documented in ADR with justification

## Executive Summary

[2-3 sentences describing the system, its purpose, and the problem it solves. What does this system do and why does it exist?]

---

## 1. Context (C4 Level 1)

### System Context Diagram

```mermaid
graph TB
    subgraph External
        User[("👤 User")]
        ExtSystem1["🔲 External System 1"]
        ExtSystem2["🔲 External System 2"]
    end

    System["🟦 [System Name]<br/>Description"]

    User -->|"uses"| System
    System -->|"integrates with"| ExtSystem1
    System -->|"sends data to"| ExtSystem2
```

### Actors & External Systems

| Actor/System | Type | Description | Interaction |
|--------------|------|-------------|-------------|
| [User Persona] | Person | [Description] | [How they interact] |
| [External System] | System | [Description] | [Integration type] |

---

## 2. Containers (C4 Level 2)

### Container Diagram

```mermaid
graph TB
    subgraph System ["System Boundary"]
        WebApp["🌐 Web Application<br/>React/Next.js"]
        API["⚙️ API Server<br/>Node.js/Python"]
        Worker["🔄 Background Worker<br/>Node.js/Python"]
        DB[("🗄️ Database<br/>PostgreSQL")]
        Cache[("⚡ Cache<br/>Redis")]
        Queue["📬 Message Queue<br/>SQS/RabbitMQ"]
    end

    User[("👤 User")] -->|"HTTPS"| WebApp
    WebApp -->|"REST/gRPC"| API
    API -->|"SQL"| DB
    API -->|"Read/Write"| Cache
    API -->|"Publish"| Queue
    Queue -->|"Subscribe"| Worker
    Worker -->|"SQL"| DB
```

### Container Descriptions

| Container | Technology | Purpose | Scaling Strategy |
|-----------|------------|---------|------------------|
| Web Application | [Tech stack] | [Purpose] | [How it scales] |
| API Server | [Tech stack] | [Purpose] | [How it scales] |
| Database | [Tech stack] | [Purpose] | [How it scales] |
| Cache | [Tech stack] | [Purpose] | [How it scales] |

---

## 3. Components (C4 Level 3)

### API Server Components

```mermaid
graph TB
    subgraph API ["API Server"]
        Router["Router<br/>Express/FastAPI"]
        AuthMiddleware["Auth Middleware<br/>JWT Validation"]
        Controllers["Controllers<br/>Request Handlers"]
        Services["Services<br/>Business Logic"]
        Repositories["Repositories<br/>Data Access"]
    end

    Router --> AuthMiddleware
    AuthMiddleware --> Controllers
    Controllers --> Services
    Services --> Repositories
```

### Component Responsibilities

| Component | Responsibility | Dependencies |
|-----------|---------------|--------------|
| [Component 1] | [Single responsibility] | [What it depends on] |
| [Component 2] | [Single responsibility] | [What it depends on] |

---

## 4. Key Design Decisions

| Decision | Options Considered | Chosen | Rationale |
|----------|-------------------|--------|-----------|
| Database | PostgreSQL, MongoDB, DynamoDB | PostgreSQL | ACID compliance, relational data |
| Caching | Redis, Memcached | Redis | Data structures, pub/sub support |
| Queue | SQS, RabbitMQ, Kafka | SQS | Managed service, AWS integration |

**For detailed decision rationale, see related ADRs.**

---

## 5. API Design

### Endpoints Overview

| Method | Endpoint | Purpose | Auth Required |
|--------|----------|---------|---------------|
| GET | `/api/v1/resources` | List resources | Yes |
| GET | `/api/v1/resources/:id` | Get single resource | Yes |
| POST | `/api/v1/resources` | Create resource | Yes |
| PUT | `/api/v1/resources/:id` | Update resource | Yes |
| DELETE | `/api/v1/resources/:id` | Delete resource | Yes |

### Request/Response Examples

```typescript
// GET /api/v1/resources/:id
// Response 200 OK
interface Resource {
  id: string;
  name: string;
  createdAt: string;  // ISO 8601
  updatedAt: string;  // ISO 8601
  metadata: Record<string, unknown>;
}

// POST /api/v1/resources
// Request Body
interface CreateResourceRequest {
  name: string;
  metadata?: Record<string, unknown>;
}

// Error Response (4xx/5xx)
interface ErrorResponse {
  error: {
    code: string;
    message: string;
    details?: unknown;
  };
}
```

### API Versioning Strategy

[Describe versioning approach: URL path, header, query param]

---

## 6. Data Model

### Entity Relationship Diagram

```mermaid
erDiagram
    USER ||--o{ RESOURCE : owns
    RESOURCE ||--o{ AUDIT_LOG : generates

    USER {
        uuid id PK
        string email UK
        string name
        timestamp created_at
        timestamp updated_at
    }

    RESOURCE {
        uuid id PK
        uuid user_id FK
        string name
        jsonb metadata
        timestamp created_at
        timestamp updated_at
    }

    AUDIT_LOG {
        uuid id PK
        uuid resource_id FK
        string action
        jsonb changes
        timestamp created_at
    }
```

### Key Entities

| Entity | Description | Retention Policy |
|--------|-------------|------------------|
| User | System users | Indefinite |
| Resource | Core business entity | [Policy] |
| Audit Log | Change tracking | [X] days |

### Data Migration Strategy

[How will data be migrated? What's the rollback plan?]

---

## 7. Security Architecture

### Authentication & Authorization

| Mechanism | Implementation | Notes |
|-----------|----------------|-------|
| Authentication | JWT / OAuth 2.0 | [Details] |
| Authorization | RBAC / ABAC | [Details] |
| API Security | Rate limiting, WAF | [Details] |

### Data Protection

- **In Transit:** TLS 1.3 minimum
- **At Rest:** AES-256 encryption
- **PII Handling:** [Approach]
- **Secrets Management:** [AWS Secrets Manager / HashiCorp Vault]

### Security Considerations

| STRIDE Threat | Mitigation |
|---------------|------------|
| Spoofing | [Mitigation strategy] |
| Tampering | [Mitigation strategy] |
| Repudiation | [Mitigation strategy] |
| Information Disclosure | [Mitigation strategy] |
| Denial of Service | [Mitigation strategy] |
| Elevation of Privilege | [Mitigation strategy] |

---

## 8. Non-Functional Requirements

### Performance

| Metric | Target | Measurement |
|--------|--------|-------------|
| API Response Time (p50) | < 100ms | [Tool] |
| API Response Time (p99) | < 500ms | [Tool] |
| Throughput | [X] req/sec | [Tool] |
| Database Query Time | < 50ms | [Tool] |

### Scalability

| Dimension | Current Capacity | Target Capacity | Strategy |
|-----------|------------------|-----------------|----------|
| Users | [X] | [Y] | [How to scale] |
| Requests/sec | [X] | [Y] | [How to scale] |
| Data Volume | [X] GB | [Y] TB | [How to scale] |

### Availability & Reliability

| Metric | Target | Strategy |
|--------|--------|----------|
| Availability | 99.9% (3 nines) | Multi-AZ deployment |
| RTO | [X] hours | [Recovery strategy] |
| RPO | [X] minutes | [Backup strategy] |

### Observability

| Pillar | Implementation | Tools |
|--------|----------------|-------|
| Metrics | OpenTelemetry | Prometheus/Grafana |
| Logging | Structured JSON logs | [ELK/CloudWatch] |
| Tracing | Distributed tracing | Jaeger/X-Ray |
| Alerting | SLO-based alerts | [PagerDuty/OpsGenie] |

---

## 9. Infrastructure

### Deployment Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        AWS Region                        │
│  ┌──────────────────────────────────────────────────┐   │
│  │                      VPC                          │   │
│  │  ┌─────────────┐  ┌─────────────┐               │   │
│  │  │  Public     │  │  Public     │               │   │
│  │  │  Subnet AZ1 │  │  Subnet AZ2 │               │   │
│  │  │  ┌───────┐  │  │  ┌───────┐  │               │   │
│  │  │  │  ALB  │  │  │  │  ALB  │  │               │   │
│  │  │  └───────┘  │  │  └───────┘  │               │   │
│  │  └─────────────┘  └─────────────┘               │   │
│  │  ┌─────────────┐  ┌─────────────┐               │   │
│  │  │  Private    │  │  Private    │               │   │
│  │  │  Subnet AZ1 │  │  Subnet AZ2 │               │   │
│  │  │  ┌───────┐  │  │  ┌───────┐  │               │   │
│  │  │  │  ECS  │  │  │  │  ECS  │  │               │   │
│  │  │  └───────┘  │  │  └───────┘  │               │   │
│  │  └─────────────┘  └─────────────┘               │   │
│  │  ┌─────────────────────────────────────────┐    │   │
│  │  │           RDS Multi-AZ                   │    │   │
│  │  └─────────────────────────────────────────┘    │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### Environment Configuration

| Environment | Purpose | Infrastructure |
|-------------|---------|----------------|
| Development | Local development | Docker Compose |
| Staging | Pre-production testing | [Reduced AWS setup] |
| Production | Live system | [Full AWS setup] |

### CI/CD Pipeline

```
Code Push → Lint/Test → Build → Security Scan → Deploy Staging → Integration Tests → Deploy Prod
```

---

## 10. Dependencies

### Internal Dependencies

| Service | Purpose | Criticality | Fallback |
|---------|---------|-------------|----------|
| [Service 1] | [Purpose] | High/Medium/Low | [Fallback strategy] |

### External Dependencies

| Service | Purpose | SLA | Fallback |
|---------|---------|-----|----------|
| [External API] | [Purpose] | [SLA] | [Fallback strategy] |

### Dependency Diagram

```mermaid
graph LR
    ThisSystem["This System"]
    InternalSvc["Internal Service"]
    ExternalAPI["External API"]

    ThisSystem --> InternalSvc
    ThisSystem --> ExternalAPI
```

---

## 11. Risks & Mitigations

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| [Risk 1] | High/Med/Low | High/Med/Low | [Strategy] |
| [Risk 2] | High/Med/Low | High/Med/Low | [Strategy] |

---

## 12. Implementation Phases

### Phase 1: Foundation
- [ ] Infrastructure setup (IaC)
- [ ] Database schema
- [ ] Basic API scaffolding
- [ ] CI/CD pipeline

### Phase 2: Core Features
- [ ] Core business logic
- [ ] API endpoints
- [ ] Authentication/Authorization

### Phase 3: Polish & Launch
- [ ] Performance optimization
- [ ] Security hardening
- [ ] Documentation
- [ ] Monitoring & alerting

---

## 13. Open Questions

- [ ] [Question 1]
- [ ] [Question 2]

---

## Appendix

### Glossary

| Term | Definition |
|------|------------|
| [Term] | [Definition] |

### References

- [Link to related documentation]
- [Link to external resources]

---

## Approval

| Role | Name | Date | Status |
|------|------|------|--------|
| Architect | | | Pending |
| Engineering Lead | | | Pending |
| Security | | | Pending |

---

## Changelog

| Date | Author | Change |
|------|--------|--------|
| [Date] | [Name] | Initial design |

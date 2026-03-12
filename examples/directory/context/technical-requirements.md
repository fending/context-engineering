# Technical Requirements

This file captures constraints that shape implementation decisions: performance targets, compliance requirements, platform support, and operational boundaries.

## What Belongs Here

- Performance and reliability targets (SLAs, latency budgets, uptime)
- Compliance and regulatory requirements (HIPAA, SOC 2, GDPR, PCI DSS)
- Platform and browser support requirements
- Security requirements and threat model boundaries
- Infrastructure constraints (budget, vendor lock-in rules, approved services)

## Example Content

---

### Performance

| Metric | Target | Current | Notes |
| ------ | ------ | ------- | ----- |
| API response time (p95) | < 200ms | [measured] | Excludes background job endpoints |
| Page load (LCP) | < 2.5s | [measured] | Core Web Vitals target |
| Uptime | 99.9% | [measured] | Excludes scheduled maintenance windows |
| Background job completion | < 5 min | [measured] | For standard analytics computations |

### Compliance

[List applicable frameworks and what they require. Be specific about which parts of the system are in scope.]

- **[Framework]:** [What's in scope, key controls, audit frequency]
- **[Framework]:** [What's in scope, key controls, audit frequency]

**Practical implications for development:**

- [e.g., All PII must be encrypted at rest and in transit]
- [e.g., Access logs must be retained for 12 months]
- [e.g., Third-party libraries must be reviewed for known vulnerabilities before adoption]

### Platform Support

| Platform | Support Level | Notes |
| -------- | ------------- | ----- |
| [browsers] | [versions] | [testing approach] |
| [mobile] | [scope] | [responsive vs. native] |
| [accessibility] | [standard] | [WCAG level, testing tools] |

### Security

[Not a full threat model, but the security posture that affects daily development decisions.]

- **Authentication:** [mechanism, provider, token handling]
- **Authorization:** [model, enforcement points]
- **Data classification:** [what's sensitive, what's not, handling rules]
- **Dependency management:** [vulnerability scanning, update cadence, approval process]
- **Secrets management:** [where secrets live, how they're accessed, rotation policy]

### Infrastructure Constraints

[Budget limits, approved vendors, architectural boundaries that aren't negotiable.]

- [e.g., All services must run on approved cloud provider]
- [e.g., No new SaaS tools without security review]
- [e.g., Database must support point-in-time recovery]

---

## Why This File Exists Separately

Technical requirements are externally imposed -- by regulators, by SLAs, by infrastructure constraints. They change when contracts change, when you enter new markets, or when compliance requirements are updated. They don't change because someone preferred a different CSS framework.

Mixing these with code standards or architecture decisions obscures the distinction between "we chose this" (architecture) and "we must do this" (requirements). An AI needs to know the difference -- architecture decisions can be reconsidered; compliance requirements cannot.

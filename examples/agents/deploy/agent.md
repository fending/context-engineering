# Deploy Agent

Domain-specific agent for deployment workflows. Manages pre-flight checks, deployment execution, and verification.

## Capabilities

| Capability | Description | Trigger |
| ---------- | ----------- | ------- |
| **Pre-flight** | Run all checks before deployment | "deploy check", "pre-flight" |
| **Deploy** | Execute deployment to target environment | "deploy to [environment]" |
| **Verify** | Post-deployment health checks | Automatic after deploy |
| **Rollback** | Revert to previous version | "rollback [environment]" |

## Autonomous Actions (NEVER ASK PERMISSION)

- Run test suite before deployment -- just execute, don't ask
- Update `state.json` with deployment status as it changes
- Run post-deployment health checks automatically
- Notify on failure (update state, surface error)

## Workflow: Deploy to Environment

**Trigger:** "deploy to [staging|production]"

**Order of operations:**

### Step 1: Pre-Flight Checks

All checks must pass before proceeding. If any fail, stop and report.

| Check | Method | Pass Criteria |
| ----- | ------ | ------------- |
| Tests | Run test suite | All pass, no skipped |
| Build | Run production build | Exits 0, no warnings |
| Branch | Check current branch | Must be `main` for production |
| Diff | Check for uncommitted changes | Working tree clean |
| Dependencies | Check for vulnerabilities | No critical/high CVEs |

```bash
# Execute in order; stop on first failure
npm test
npm run build
git status --porcelain  # Must be empty
npm audit --audit-level=high
```

### Step 2: Deploy

**Staging:**

```bash
[staging deploy command]
```

**Production:**

```bash
# Production requires passing staging verification first
# Check state.json for staging_verified = true
[production deploy command]
```

Update `state.json` with:

- `deploying: true`
- `deploy_started: [timestamp]`
- `target_environment: [environment]`
- `deploy_version: [git SHA]`

### Step 3: Verify

Run health checks against the deployed environment:

| Check | Method | Pass Criteria |
| ----- | ------ | ------------- |
| Health endpoint | `curl [url]/health` | 200 OK |
| Smoke test | Hit key endpoints | Expected responses |
| Error rate | Check monitoring | No spike in errors |

Update `state.json` with:

- `deploying: false`
- `last_deploy: [timestamp]`
- `last_deploy_status: success|failed`
- `staging_verified: true` (if staging deploy)

### Step 4: Rollback (If Needed)

**Trigger:** "rollback [environment]" or automatic on verification failure

```bash
[rollback command -- redeploy previous version]
```

Update state with rollback details.

## Boundaries

- Never deploy to production without passing staging verification
- Never skip pre-flight checks
- Never deploy with uncommitted changes
- Never force-push as part of a deployment
- If any health check fails post-deploy, surface the failure immediately -- do not retry silently

## Config Reference

See `config.json` for:

- Environment URLs
- Health check endpoints
- Deployment commands per environment
- Notification settings

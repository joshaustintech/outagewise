# OutageWise Product Roadmap

## Product Vision

OutageWise helps customers detect HTTP outages quickly, understand uptime
history, communicate current service status, and expose read-only operational
context to their own agentic tools.

The product should remain AI-vendor-agnostic. Runtime services, hosting
providers, observability tools, and MCP clients should be replaceable behind
documented interfaces. The application stack decisions below are intentional
product constraints and should be assumed by implementation agents.

## Product Principles

- Detect customer-impacting HTTP failures with clear evidence.
- Prefer understandable incidents over noisy alerts.
- Make every major capability demoable locally before external integrations are
  added.
- Keep customer data isolated by account and authorization boundary.
- Treat status-page and MCP access as read-only publication channels.
- Build analytics from recorded checks and incidents, not from transient UI
  state.
- Design APIs and task specs so Claude, Gemini, GPT, or other agents can work
  from the same repository context.
- Prefer boring Linux-native operations over container-first delivery for the
  first deployable product.

## Technical Direction

### Application Runtime

- Ruby on Rails 8 is the application framework.
- Use built-in Rails 8 authentication features unless a documented product need
  requires a different authentication boundary.
- Use built-in Rails 8 job processing for background work.
- Use Rails conventions first: resourceful controllers, service objects for
  domain operations, plain query objects for reusable reads, and tests close to
  the behavior being changed.

### Data Storage

- Use SQLite.
- Use one catalog database for global records such as accounts, users, customer
  database registry records, deployment metadata, and cross-customer operational
  state.
- Use per-customer SQLite databases for customer-owned monitoring data such as
  monitors, check runs, outages, analytics rollups, notification records, status
  page settings, and MCP audit events.
- Treat the catalog database as the source of truth for routing a request or job
  to the correct customer database.
- Keep customer data isolation explicit in code and tests. A task that reads or
  writes customer data must say which customer database it uses.

### HTTP Checking

- Use the `http.rb` gem for high-performance HTTP requests.
- Check execution must respect method, timeout, expected status range, and
  redirects according to documented monitor settings.
- Store normalized evidence from every check before deriving outages or
  analytics.

### Frontend

- Use Elm, Tailwind CSS, and DaisyUI for frontend work.
- Use Vite as the unified local frontend build tool.
- Elm is not a monolithic single-page app. Rails renders the main page structure;
  Elm is used for individual interactives, AJAX-driven widgets, and focused
  stateful UI.
- Tailwind and DaisyUI should provide the design system primitives. Avoid large
  custom CSS unless it is needed for layout or product-specific states.
- Follow Elm best practices: small modules, explicit ports only when needed,
  typed API payloads, narrow update functions, and focused components mounted
  into server-rendered pages.

### Local Development

- `bin/dev` must run a frontend build before starting local services.
- If the frontend build fails, `bin/dev` must fail instead of starting a stale
  app.
- When `bin/dev` is running, a file watcher must rebuild frontend assets when
  any ERB, Elm, or CSS file changes.
- Local development should expose failures clearly in terminal output so agents
  and humans do not miss broken assets.

### Testing

- Use Capybara for frontend/system tests.
- Test Rails models, services, jobs, controllers, and request boundaries with
  the narrowest test type that proves the behavior.
- Use Capybara for browser-visible flows, including monitor CRUD, manual check
  runs, status page embed behavior, analytics rendering, and Elm interactives.
- Prefer deterministic fixtures and explicit timestamps for outage and analytics
  tests.

### Deployment and Operations

- The first deployable product runs as Linux native services. A Docker container
  is not needed for the deliverable.
- Deploy multiple application and worker instances to a large shared server with
  internal load balancing before pursuing many small servers.
- Use Linux service management to start, stop, restart, and supervise web,
  worker, scheduler, frontend build/watch, and MCP services as needed.
- If a service fails or crashes, Linux service management should automatically
  restart it or roll back to a previous known-good release.
- Releases should be structured so rollback can switch the active release and
  service definitions without manual database surgery.

## Core Concepts

- Account: A customer organization that owns monitored endpoints, users,
  status-page settings, API tokens, and MCP credentials.
- User: An authenticated person who manages account configuration.
- Monitor: A configured HTTP target with URL, method, expected status range,
  timeout, check interval, and enablement state.
- Check Run: One attempt to evaluate a monitor at a point in time, including
  timing, HTTP status, error category, response size, and result state.
- Outage: A period where a monitor is considered down or degraded based on
  consecutive failed check runs and recovery rules.
- Status Page: A public or token-protected read-only page summarizing current
  monitor state and recent incidents. It must be iframe-friendly.
- Analytics: Aggregated uptime, latency, failure, and incident metrics derived
  from check runs and outages.
- MCP Server: An authenticated read-only interface that exposes current status,
  incidents, monitor metadata, and analytics to customer agents.

## Roadmap Phases

### Phase 0: Product Foundation

Goal: Establish the domain model, local development flow, and documentation
needed to build incrementally.

Capabilities:

- Domain model for accounts, users, monitors, check runs, and outages.
- Catalog SQLite database and per-customer SQLite database routing foundation.
- Local seed data for manual demos.
- Basic navigation and empty states.
- Rails 8 authentication and job-processing baseline.
- Vite, Elm, Tailwind, and DaisyUI local build baseline.
- Clear environment setup and test commands.
- Agent-friendly task documentation.

Exit criteria:

- A developer can run the app locally, sign in or use a seeded account, and see
  the monitor list.
- Database records can represent a monitor, a check result, and an outage.
- Documentation explains how to demo the current product.

### Phase 1: Manual HTTP Monitoring

Goal: Let a user create monitors and manually run HTTP checks from the UI.

Capabilities:

- Create, edit, disable, and delete HTTP monitors.
- Validate monitor URL, timeout, method, expected status range, and interval.
- Run a check on demand using `http.rb`.
- Store each check run with result state, timing, status code, and error details.
- Show latest status and recent check history on the monitor detail page.

Exit criteria:

- A local demo can add a healthy URL and a failing URL, run checks, and display
  accurate results.
- Check history persists across page reloads.

### Phase 2: Outage Detection

Goal: Convert raw failed checks into meaningful outage records.

Capabilities:

- Consecutive failure threshold before an outage opens.
- Consecutive success threshold before an outage resolves.
- Outage timeline per monitor.
- Current account-level status derived from monitor states.
- Manual check runs feed the same detection path as scheduled checks.

Exit criteria:

- A demo can force repeated failures, open an outage, then force recoveries and
  resolve it.
- Incident state is deterministic and covered by tests.

### Phase 3: Scheduled Checks

Goal: Run monitors automatically at configured intervals.

Capabilities:

- Background job that selects due monitors.
- Per-monitor scheduling metadata.
- Check execution job with timeout and error handling.
- Basic retry/backoff for transient worker failures using Rails 8 job features.
- Admin or developer page showing due and recently checked monitors.

Exit criteria:

- A local demo can start the app and observe check runs being created without
  pressing a manual button.
- Disabled monitors are skipped.

### Phase 4: Customer Status Page

Goal: Provide a read-only status page customers can share or embed.

Capabilities:

- Public status page route per account.
- Iframe-compatible rendering with a compact embed mode.
- Current status summary, component list, and recent incidents.
- Status-page settings for display name, visibility, and included monitors.
- Safe HTTP headers for iframe embedding by customer sites.

Exit criteria:

- A demo can open a status page in a browser and as an iframe in a test page.
- The page accurately reflects active and resolved outages.

### Phase 5: Analytics

Goal: Turn monitoring history into actionable uptime and performance insights.

Capabilities:

- Uptime percentage by monitor and account.
- Latency percentiles over selectable time windows.
- Incident count, mean time to detect, and mean time to recover.
- Failure breakdown by HTTP status, timeout, DNS, TLS, and connection errors.
- Exportable summary endpoints for UI and MCP reuse.

Exit criteria:

- A demo can seed check history and show meaningful charts or tables.
- Analytics match deterministic fixture calculations.

### Phase 6: Authenticated Read-Only MCP Server

Goal: Give customer agents realtime visibility into outages without write
access.

Capabilities:

- Account-scoped MCP authentication with revocable tokens.
- Read-only tools/resources for current status, monitors, active outages,
  incident history, and analytics summary.
- Strict authorization tests to prevent cross-account access.
- Structured responses with stable schemas and timestamps.
- Audit log for MCP token usage.

Exit criteria:

- A local MCP client can authenticate and read current outage state.
- Attempts to mutate data or read another account are rejected.

### Phase 7: Notifications and Escalation

Goal: Notify customers when outages open, update, and resolve.

Capabilities:

- Notification contact model.
- Email and webhook notification adapters behind vendor-neutral interfaces.
- Alert rules per monitor and account.
- Deduplication and rate limiting.
- Notification delivery history.

Exit criteria:

- A demo can open and resolve an outage and show notification records with
  payload previews.
- Provider-specific integrations can be added without changing outage logic.

### Phase 8: Reliability, Security, and Scale

Goal: Harden the service for real customers.

Capabilities:

- Tenant isolation review.
- Token rotation and least-privilege access.
- Check worker concurrency limits.
- Retention policies for check runs and analytics rollups.
- Operational dashboards and internal health checks.
- Abuse protection for public status pages and MCP endpoints.

Exit criteria:

- Security tests cover account boundaries and public/private data exposure.
- Load tests validate the target number of monitors and check intervals.

## Non-Goals for the First Release

- Global multi-region checking.
- Synthetic browser monitoring.
- SMS or phone-call escalation.
- Write-capable MCP tools.
- Customer-defined incident messaging workflows.
- Full incident postmortem authoring.

## Release Slices

### Local Alpha

Includes phases 0 through 2. Intended for developer demos and correctness
testing of the monitoring and outage state machine.

### Private Beta

Includes phases 3 through 6. Intended for trusted customers who can use hosted
checks, embedded status pages, analytics, and read-only MCP visibility.

### Public Beta

Includes phases 7 and 8 hardening. Intended for wider usage with notifications,
security review, retention, and operational controls.

## Vendor-Agnostic Architecture Guidelines

- Define application interfaces by business capability, not provider name.
- Keep background jobs idempotent so job execution can be retried safely by
  Rails job processing and Linux service restarts.
- Store normalized check results before deriving analytics.
- Use application-owned token records for MCP authentication.
- Keep public status pages independent from the authenticated dashboard.
- Prefer standard HTTP, JSON, Markdown, SQL, and MCP concepts over proprietary
  formats.
- Document assumptions in task files so any coding agent can continue work.
- Do not introduce Docker as a required deliverable unless the roadmap is
  explicitly changed.

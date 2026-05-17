# Agent Task Breakdown

This document breaks the roadmap into small tasks for compact coding agents. It
is intentionally vendor-agnostic: tasks should work for Claude, Gemini, GPT, or
other agents that can read the repository and edit files.

## Universal Task Instructions

Every implementation task should include:

- Repository context: Rails 8 application in this repository.
- Constraints: Keep changes scoped to the task. Do not add provider-specific
  services unless the task asks for an adapter boundary.
- Expected output: Code, tests, and any small docs updates needed for the task.
- Verification: Run the narrowest relevant automated tests. If tests cannot be
  run, explain why and provide manual verification steps.
- Safety: Do not remove unrelated files or revert unrelated user changes.

Default stack assumptions for every task:

- Data storage is SQLite, with a catalog database plus per-customer SQLite
  databases.
- Use Rails 8 built-in authentication and job processing features.
- Use Capybara for browser-visible frontend/system tests.
- Use Elm, Tailwind CSS, DaisyUI, and Vite for frontend assets.
- Use Rails-rendered pages as the main app structure; mount Elm only for
  individual interactives and AJAX widgets.
- Use the `http.rb` gem for HTTP monitor checks.
- The deployable target is Linux native services, not Docker.
- Follow Rails best practices and Elm best practices unless a local pattern
  gives a more specific answer.

Preferred task shape:

```markdown
## Task: Short imperative title

Context:
- What exists now.
- Which files or concepts are likely involved.

Goal:
- One complete user-visible or test-visible outcome.

Implementation notes:
- Specific guidance without prescribing every line of code.

Acceptance criteria:
- Observable outcomes.

Manual test:
- Browser or console steps a human can perform.
```

## Milestone 0 Tasks: Local Product Skeleton

### Task 0.1: Add Product Routes and Placeholder Controllers

Context:

- The app is a Rails application.
- Product docs define dashboard, monitors, and account status as the first
  navigable areas.

Goal:

- Add routes and minimal controller actions for dashboard, monitors index, and
  account status.

Implementation notes:

- Use conventional Rails controllers and views.
- Keep content minimal; this is a skeleton, not final UI.
- Link pages together from the layout or dashboard.

Acceptance criteria:

- Visiting `/`, `/monitors`, and `/status` renders without errors.
- Navigation links allow moving between the pages.

Manual test:

- Start the app, visit each route, and confirm the page title matches the area.

### Task 0.2: Create Account and User Foundation

Context:

- Future monitors, status pages, analytics, and MCP tokens need account scope.

Goal:

- Add account and user models with enough fields for local demos.

Implementation notes:

- Use Rails 8 built-in authentication features as the default authentication
  path.
- Include account name and user email.
- Add associations so a user belongs to an account.

Acceptance criteria:

- Database migrations create accounts and users.
- Models validate required fields.
- Seeds create one demo account and user.

Manual test:

- Run database setup, then inspect the seeded account and user in the Rails
  console.

### Task 0.3: Add Basic Product Layout

Context:

- The app needs a simple dashboard-oriented shell before detailed features.

Goal:

- Add a shared layout with product name, navigation, and main content area.

Implementation notes:

- Keep styling lightweight and responsive.
- Avoid marketing hero content; this is an operational tool.

Acceptance criteria:

- Navigation is visible on dashboard, monitors, and status pages.
- Content remains readable at desktop and mobile widths.

Manual test:

- Resize the browser from desktop width to narrow width and confirm navigation
  and page content do not overlap.

### Task 0.4: Configure SQLite Catalog and Customer Databases

Context:

- OutageWise uses one catalog SQLite database and one SQLite database per
  customer.
- Account-scoped customer data must not be stored only in a shared application
  database.

Goal:

- Add the database configuration, connection naming, and seed conventions needed
  for a local catalog database and one demo customer database.

Implementation notes:

- Keep the catalog responsible for account records and customer database
  registry metadata.
- Keep customer-owned monitoring data ready to live in the customer database.
- Document the local file paths for catalog and demo customer databases.

Acceptance criteria:

- Local database setup creates or prepares a catalog database.
- Seeds create a demo account with a customer database registry entry.
- A developer can identify which database should hold account metadata versus
  monitor data.

Manual test:

- Run database setup, inspect the catalog database, and confirm the demo
  customer database file exists or can be prepared.

### Task 0.5: Configure Vite, Elm, Tailwind, and DaisyUI

Context:

- Rails renders pages, while Elm provides focused interactives and AJAX widgets.
- Vite is the unified local frontend build path.

Goal:

- Add a minimal frontend build that compiles Elm, Tailwind CSS, and DaisyUI.

Implementation notes:

- Create one small Elm mount only as a smoke test or focused widget.
- Keep Tailwind and DaisyUI configuration minimal.
- Do not convert the app into a monolithic Elm single-page app.

Acceptance criteria:

- A frontend build command compiles successfully.
- Rails layout includes the built assets.
- A minimal Elm interactive can mount on a Rails-rendered page.

Manual test:

- Run the frontend build, start the app, and confirm the Rails page loads the
  compiled CSS and Elm mount without browser console errors.

### Task 0.6: Make `bin/dev` Frontend-Build-Aware

Context:

- Local development must fail fast when frontend assets do not build.

Goal:

- Update `bin/dev` so it runs a frontend build before starting services and
  exits if the build fails.

Implementation notes:

- Keep terminal output clear.
- Do not start the Rails server or workers after a failed frontend build.

Acceptance criteria:

- `bin/dev` starts normally after a successful frontend build.
- Intentionally breaking an Elm or CSS file causes `bin/dev` to fail before
  starting the app.

Manual test:

- Run `bin/dev` once with valid frontend code, then introduce a temporary
  frontend syntax error and confirm startup fails.

### Task 0.7: Add Frontend File Watch Rebuilds

Context:

- When `bin/dev` is running, frontend assets should rebuild after relevant file
  changes.

Goal:

- Add a watcher that rebuilds when ERB, Elm, or CSS files change.

Implementation notes:

- Watch Rails view files, Elm source files, and CSS/Tailwind files.
- Keep watcher behavior local-development only.

Acceptance criteria:

- Touching an ERB file triggers a rebuild.
- Touching an Elm file triggers a rebuild.
- Touching a CSS file triggers a rebuild.
- Rebuild failures are visible in terminal output.

Manual test:

- Start `bin/dev`, touch one file of each type, and observe rebuild output.

### Task 0.8: Configure Capybara System Tests

Context:

- Browser-visible flows should be covered with Capybara.

Goal:

- Add Capybara setup and one smoke system test for the product shell.

Implementation notes:

- Keep the first test simple: visit the dashboard or monitor index and assert
  visible text.
- Use the app's existing test framework conventions.

Acceptance criteria:

- Capybara is available in the test suite.
- One system test passes locally.
- The test does not depend on external network access.

Manual test:

- Run the system test command and confirm it passes.

## Milestone 1 Tasks: Monitor CRUD

### Task 1.1: Add Monitor Model

Context:

- A monitor represents one HTTP target owned by an account.

Goal:

- Add a monitor model and migration.

Implementation notes:

- Fields should include account reference, name, URL, HTTP method, expected
  status minimum and maximum, timeout seconds, interval seconds, enabled flag,
  and timestamps.
- Start with common methods such as `GET` and `HEAD`.
- Store monitor records in the owning customer's SQLite database, while keeping
  account/customer routing metadata in the catalog database.

Acceptance criteria:

- Monitor belongs to account.
- Required fields and numeric ranges are validated.
- Invalid URLs and unsupported methods are rejected.
- Tests prove monitors for one account are not loaded from another customer's
  database.

Manual test:

- Use Rails console to create a valid monitor and confirm invalid values fail.

### Task 1.2: Build Monitor List and Detail Pages

Context:

- Users need to inspect configured monitors before check execution exists.

Goal:

- Render monitor index and show pages.

Implementation notes:

- Scope monitors to the demo/current account.
- Show name, URL, enabled state, method, timeout, and interval.

Acceptance criteria:

- Monitor index lists all account monitors.
- Monitor detail shows persisted monitor fields.
- Empty state appears when no monitors exist.

Manual test:

- Seed or create two monitors, visit `/monitors`, then open each detail page.

### Task 1.3: Add Monitor Create and Edit Forms

Context:

- Monitor configuration should be manageable from the browser.

Goal:

- Add new, create, edit, and update flows.

Implementation notes:

- Reuse one form partial if that matches app style.
- Show validation errors next to the form.

Acceptance criteria:

- Valid monitor submissions persist and redirect to detail.
- Invalid submissions re-render with errors.
- Edit updates only the selected monitor.

Manual test:

- Create a monitor, edit its interval, submit an invalid URL, and confirm the
  app handles all three cases correctly.

### Task 1.4: Add Disable and Delete Behavior

Context:

- Users need to stop checks without losing history.

Goal:

- Add disable/enable and delete actions.

Implementation notes:

- Prefer disable for the primary path.
- Delete may be implemented as a normal destroy only if no check history exists
  yet.

Acceptance criteria:

- Enabled monitors can be disabled and re-enabled.
- Deleted monitors no longer appear in the list.
- Disabled monitors remain visually distinct.

Manual test:

- Disable a monitor, refresh the index, re-enable it, then delete a test
  monitor.

## Milestone 2 Tasks: Manual Check Runs

### Task 2.1: Add Check Run Model

Context:

- Check runs are immutable evidence for monitoring, outage detection, and
  analytics.

Goal:

- Add a check run model and migration.

Implementation notes:

- Fields should include monitor reference, result state, started_at,
  completed_at, duration milliseconds, HTTP status code, error category, error
  message, and response bytes if available.
- Result states should at least include `up` and `down`.

Acceptance criteria:

- Check run belongs to monitor.
- Required timing and result fields are validated.
- Recent check runs can be queried by monitor.

Manual test:

- Create check runs in Rails console and confirm they appear in descending
  order by completion time.

### Task 2.2: Implement HTTP Check Service

Context:

- Manual and scheduled checks should use the same execution path.

Goal:

- Create a service object that performs one HTTP check and returns or persists a
  check run.

Implementation notes:

- Use standard library or existing project dependencies.
- Prefer the `http.rb` gem; add it if it is not already present.
- Respect monitor method, timeout, and expected status range.
- Categorize status mismatch, timeout, DNS, TLS, and connection errors where
  possible.

Acceptance criteria:

- Healthy expected responses produce `up`.
- Unexpected HTTP statuses produce `down` with status code.
- Network failures produce `down` with an error category.
- Tests or implementation references show that `http.rb` performs the request.

Manual test:

- Run the service against `https://example.com` and a known invalid local host.

### Task 2.3: Add Manual Run Check Action

Context:

- Users need a browser button to create check evidence.

Goal:

- Add a `Run check` action on monitor detail.

Implementation notes:

- The action should call the HTTP check service.
- Redirect back to monitor detail with a concise success or failure message.

Acceptance criteria:

- Clicking `Run check` creates exactly one check run.
- The latest result appears after redirect.
- Errors are captured as check runs instead of unhandled exceptions.

Manual test:

- Click `Run check` on healthy and failing monitors, then refresh and confirm
  history persists.

### Task 2.4: Render Recent Check History

Context:

- Check runs are only useful if users can inspect recent evidence.

Goal:

- Show recent check runs on the monitor detail page.

Implementation notes:

- Include result, status code, duration, checked-at time, and error category.
- Keep long error messages truncated or visually contained.

Acceptance criteria:

- Recent history updates after a manual check.
- Empty history state appears before first check.
- Rows are ordered newest first.

Manual test:

- Run several checks and confirm order, fields, and persistence after reload.

## Milestone 3 Tasks: Outage State Machine

### Task 3.1: Add Outage Model

Context:

- Outages represent durable incident periods derived from check results.

Goal:

- Add an outage model and migration.

Implementation notes:

- Fields should include monitor reference, status, started_at, resolved_at,
  trigger_check_run reference, recovery_check_run reference, and summary.
- Status should distinguish active and resolved.

Acceptance criteria:

- Outage belongs to monitor.
- Active outages require a start time.
- Resolved outages require a resolved time after start time.

Manual test:

- Create active and resolved outages in Rails console and confirm validations.

### Task 3.2: Add Outage Transition Service

Context:

- Outage decisions must be deterministic and shared by manual and scheduled
  checks.

Goal:

- Create a service that evaluates a monitor after each check run.

Implementation notes:

- Use configurable or constant failure and recovery thresholds.
- Open an outage after consecutive failures meet threshold.
- Resolve an active outage after consecutive successes meet threshold.
- Run against the monitor's customer database.

Acceptance criteria:

- One failure below threshold does not open an outage.
- Threshold failures open exactly one active outage.
- Threshold successes resolve the active outage.

Manual test:

- Create check runs in order and call the transition service after each one;
  confirm active outage state changes only at thresholds.

### Task 3.3: Integrate Outage Transitions with Manual Checks

Context:

- Manual checks should exercise the same incident logic as future scheduled
  checks.

Goal:

- Call the outage transition service after a manual check completes.

Implementation notes:

- Keep check execution and outage evaluation separate services.
- Ensure failures in outage evaluation are visible in tests.

Acceptance criteria:

- Manual repeated failures open an outage.
- Manual repeated recoveries resolve it.
- Check run creation still succeeds for ordinary HTTP errors.

Manual test:

- Use a monitor pointed at a failing endpoint, run checks to open an outage,
  change it to a healthy endpoint, and run checks to resolve.

### Task 3.4: Show Current Status on Dashboard

Context:

- Customers need quick account-level visibility.

Goal:

- Show overall account status and active outage count on the dashboard.

Implementation notes:

- Derive account status from active outages and monitor latest state.
- Keep this read-only.

Acceptance criteria:

- Dashboard shows operational state when no outages exist.
- Dashboard shows degraded or outage state when active outages exist.
- Active outage count links to relevant monitor or outage views.

Manual test:

- Open and resolve an outage, refreshing the dashboard after each state change.

## Milestone 4 Tasks: Scheduled Monitoring

### Task 4.1: Add Scheduling Fields to Monitors

Context:

- The scheduler needs to know when monitors are due.

Goal:

- Add fields for last checked time and next check time if not already present.

Implementation notes:

- Update check completion to advance scheduling metadata.
- Disabled monitors should not be considered due.

Acceptance criteria:

- New monitors get an initial next check time.
- Successful check completion updates last and next check times.
- Disabled monitors are excluded from due queries.

Manual test:

- Inspect monitor records before and after a check in Rails console.

### Task 4.2: Implement Due Monitor Query

Context:

- Scheduling should be testable independently of background worker choice.

Goal:

- Add a query method or object that returns enabled due monitors.

Implementation notes:

- Accept a clock or timestamp argument for deterministic tests.
- Order due monitors predictably.

Acceptance criteria:

- Enabled due monitors are returned.
- Future, disabled, and deleted monitors are excluded.
- Tests cover boundary timestamps.

Manual test:

- Create monitors with past and future next check times and inspect query
  results in console.

### Task 4.3: Add Check Job

Context:

- Scheduled checks should use the same service as manual checks.

Goal:

- Add a background job that checks one monitor by ID.

Implementation notes:

- Return quietly if the monitor is missing or disabled.
- Call HTTP check service and outage transition service.
- Use Rails 8 job processing conventions.

Acceptance criteria:

- Performing the job creates one check run for an enabled monitor.
- Disabled monitor jobs do not create check runs.
- Outage transitions still occur.

Manual test:

- Enqueue or perform the job from console for enabled and disabled monitors.

### Task 4.4: Add Scheduler Job

Context:

- A recurring process should enqueue due monitor checks.

Goal:

- Add a scheduler job that finds due monitors and enqueues check jobs.

Implementation notes:

- Keep provider-specific scheduling outside the core query logic.
- Make duplicate scheduler runs tolerable.
- Use Rails 8 job processing for enqueueing due checks.

Acceptance criteria:

- Scheduler enqueues jobs for due monitors.
- Scheduler skips disabled and future monitors.
- Tests verify enqueue behavior.

Manual test:

- Mark a monitor due, run the scheduler job, then confirm a check job is queued
  or performed depending on local job configuration.

## Milestone 5 Tasks: Embeddable Status Page

### Task 5.1: Add Status Page Settings

Context:

- Each account controls what its public status page displays.

Goal:

- Add status page configuration scoped to account.

Implementation notes:

- Include display name, public visibility flag, and embed visibility flag.
- Defer custom domains until a later release.

Acceptance criteria:

- Settings belong to account or are stored on account.
- Defaults are created for seeded accounts.
- Private status pages return a safe not-found or forbidden response.

Manual test:

- Toggle visibility and confirm public status route behavior changes.

### Task 5.2: Render Public Status Page

Context:

- Customers need a read-only page for current status and recent incidents.

Goal:

- Add a public status route and view.

Implementation notes:

- Show account display name, overall status, monitor/component status, and
  recent resolved outages.
- Do not show dashboard navigation or management controls.
- Use Rails-rendered HTML. Use Elm only for focused interactive regions if the
  page needs client-side behavior.

Acceptance criteria:

- Public page renders without authentication when visible.
- Page includes active and recent resolved outage data.
- Page excludes private configuration fields.

Manual test:

- Trigger and resolve an outage, then confirm the public page reflects both
  states.

### Task 5.3: Add Iframe Embed Mode

Context:

- Customers want to embed status on their own site.

Goal:

- Add compact iframe-friendly status rendering.

Implementation notes:

- Use a query parameter or dedicated route for embed mode.
- Keep layout compact and responsive.
- Set headers intentionally for embedding.

Acceptance criteria:

- Embed mode omits full-page chrome.
- Embed route is read-only.
- A local HTML file can display the iframe successfully.

Manual test:

- Create a temporary local HTML page with an iframe pointing to the embed URL
  and confirm it renders.

### Task 5.4: Add Status Page Data Presenter

Context:

- Status page, dashboard, analytics, and MCP will share status summary logic.

Goal:

- Create a presenter or query object for current account status.

Implementation notes:

- Return plain structured data rather than view-specific HTML.
- Include overall state, monitor states, active outages, and updated timestamp.

Acceptance criteria:

- Public status page uses the presenter.
- Dashboard can also use the presenter or equivalent structured output.
- Tests cover operational and outage states.

Manual test:

- Inspect presenter output in console for accounts with and without active
  outages.

## Milestone 6 Tasks: Analytics Summary

### Task 6.1: Define Analytics Summary Object

Context:

- Analytics should be reusable by UI and MCP.

Goal:

- Add a service object that accepts account, optional monitor, and time window.

Implementation notes:

- Return structured data for uptime percentage, latency metrics, incidents, and
  failure categories.
- Use explicit start and end times.

Acceptance criteria:

- Empty windows return zeros or nulls consistently.
- Monitor-specific and account-wide summaries are supported.
- Output is serializable.

Manual test:

- Call the service from console with a time window that has no data.

### Task 6.2: Calculate Uptime Percentage

Context:

- Uptime is the core customer-facing metric.

Goal:

- Implement uptime calculation from check runs or outage duration.

Implementation notes:

- Pick one calculation method and document it in code or docs.
- Keep deterministic tests with fixed timestamps.

Acceptance criteria:

- All-up history returns 100 percent.
- All-down history returns 0 percent if using check-run ratio.
- Mixed history returns the expected fixture value.

Manual test:

- Seed known check runs and compare displayed uptime to hand calculation.

### Task 6.3: Calculate Latency and Failure Breakdown

Context:

- Customers need to distinguish slow responses from outright failures.

Goal:

- Add latency percentile and failure category summaries.

Implementation notes:

- Include at least average and p95 latency for successful checks.
- Count failures by error category and HTTP status family.

Acceptance criteria:

- Successful checks contribute to latency metrics.
- Failed checks contribute to failure breakdown.
- Empty latency windows do not crash.

Manual test:

- Seed successful and failed check runs and inspect summary output.

### Task 6.4: Render Analytics Page

Context:

- Manual demos need a browser-visible analytics surface.

Goal:

- Add an analytics page with summary metrics and simple tables.

Implementation notes:

- Charts are optional for first pass; tables are acceptable.
- Include selectable or linkable time windows if simple.
- If filters or charts need client-side state, mount a focused Elm component
  for that region only.

Acceptance criteria:

- Page shows uptime, latency, incident count, and failure breakdown.
- Empty state appears with no check history.
- Data matches analytics service output.

Manual test:

- Seed history, open analytics page, and verify at least one metric manually.

## Milestone 7 Tasks: Read-Only MCP Visibility

### Task 7.1: Add MCP Token Model

Context:

- MCP access must be authenticated and account-scoped.

Goal:

- Add a token model for read-only MCP clients.

Implementation notes:

- Store token digest, account reference, label, last used timestamp, and revoked
  timestamp.
- Show generated plaintext token only once if implementing UI.

Acceptance criteria:

- Tokens belong to accounts.
- Revoked tokens cannot authenticate.
- Token lookup does not require storing plaintext.

Manual test:

- Create a token, authenticate it in console, revoke it, and confirm lookup
  fails.

### Task 7.2: Add MCP Authentication Boundary

Context:

- All MCP resources and tools must be scoped to one account.

Goal:

- Implement request authentication for MCP endpoints.

Implementation notes:

- Use bearer token or equivalent MCP transport authentication supported by the
  app's chosen server implementation.
- Keep auth code independent from specific AI vendors.
- Resolve the account in the catalog database, then read customer data from the
  matching per-customer SQLite database.

Acceptance criteria:

- Missing token is rejected.
- Invalid or revoked token is rejected.
- Valid token resolves exactly one account.

Manual test:

- Use HTTP or local MCP client requests with missing, invalid, revoked, and
  valid tokens.

### Task 7.3: Expose Current Status Through MCP

Context:

- Customer agents need realtime status visibility.

Goal:

- Add a read-only MCP tool or resource for current account status.

Implementation notes:

- Reuse the status presenter from the status page milestone.
- Return structured data with timestamps and monitor states.

Acceptance criteria:

- Valid token receives only its account status.
- Response schema is stable and documented in tests or docs.
- No write operations are exposed.

Manual test:

- Connect a local MCP client and call the current status resource/tool.

### Task 7.4: Expose Outages and Analytics Through MCP

Context:

- Agents need context beyond current status.

Goal:

- Add read-only MCP tools/resources for active outages, recent incidents, and
  analytics summary.

Implementation notes:

- Reuse outage queries and analytics summary service.
- Accept explicit time window parameters for analytics.

Acceptance criteria:

- Active outage responses include monitor, start time, and summary.
- Recent incident responses include resolved outages.
- Analytics response matches analytics page calculations.

Manual test:

- Trigger outages and call each MCP endpoint or tool from a local client.

### Task 7.5: Add MCP Usage Audit

Context:

- Customers and operators need visibility into token usage.

Goal:

- Record read-only MCP access events.

Implementation notes:

- Include token, account, operation name, timestamp, and success or failure.
- Avoid logging sensitive token plaintext.

Acceptance criteria:

- Successful MCP reads create audit records.
- Failed authentication attempts are counted or logged without leaking secrets.
- Audit records are account-scoped.

Manual test:

- Call MCP operations and inspect audit records in the app or console.

## Milestone 8 Tasks: Notification Records and Provider Interfaces

### Task 8.1: Add Notification Contact Model

Context:

- Customers need configurable alert destinations.

Goal:

- Add contacts scoped to account.

Implementation notes:

- Include contact type, destination, enabled flag, and label.
- Keep provider names out of the core model where possible.

Acceptance criteria:

- Contacts belong to account.
- Invalid destinations are rejected based on contact type.
- Disabled contacts are skipped by notification generation.

Manual test:

- Create enabled and disabled contacts and inspect validation behavior.

### Task 8.2: Add Notification Event and Delivery Models

Context:

- Notification history should be visible and testable without sending real
  messages.

Goal:

- Persist notification events and delivery attempts.

Implementation notes:

- Events represent outage opened/resolved.
- Deliveries represent attempts to send an event to a contact.

Acceptance criteria:

- Events link to outage and account.
- Deliveries link to event and contact.
- Duplicate events for the same outage transition are prevented.

Manual test:

- Create an outage transition and inspect created notification records.

### Task 8.3: Add Provider-Neutral Notification Adapter

Context:

- Email, webhook, or future channels should not leak into outage logic.

Goal:

- Define an adapter interface and a local preview adapter.

Implementation notes:

- The preview adapter should record payloads without sending externally.
- Keep external providers as future implementations.

Acceptance criteria:

- Notification delivery can call an adapter through one interface.
- Preview payload is persisted for manual inspection.
- Tests do not require network access.

Manual test:

- Trigger notification delivery and inspect the preview payload.

### Task 8.4: Generate Notifications from Outage Transitions

Context:

- Notifications should follow durable outage state changes.

Goal:

- Enqueue or create notification work when outages open and resolve.

Implementation notes:

- Integrate at the outage transition service boundary.
- Deduplicate by outage and transition type.

Acceptance criteria:

- Opening an outage creates one open event.
- Resolving an outage creates one resolved event.
- Re-running transition logic does not duplicate events.

Manual test:

- Force open and resolved transitions, then confirm exactly one event per
  transition exists.

## Milestone 9 Tasks: Linux Native Deployment

### Task 9.1: Document Linux Release Layout

Context:

- The deployable target is Linux native services, not Docker.
- Releases should support explicit rollback to a previous known-good release.

Goal:

- Add deployment documentation for release directories, shared files, database
  paths, frontend build artifacts, and rollback links.

Implementation notes:

- Describe a layout with timestamped or versioned release directories and a
  `current` pointer.
- Include catalog SQLite and per-customer SQLite database storage locations.
- Include where logs, environment files, and built assets live.

Acceptance criteria:

- Documentation explains first deploy, upgrade, and rollback paths.
- Documentation does not require a Docker container.
- Documentation identifies which paths must persist across releases.

Manual test:

- Read the docs and trace how a release would move from staged to current, then
  how it would roll back.

### Task 9.2: Add Linux Service Definitions

Context:

- Web, worker, scheduler, and MCP processes should run under Linux service
  management.

Goal:

- Add example service unit files or templates for required processes.

Implementation notes:

- Include restart behavior for crashes.
- Use environment files for deploy-specific settings.
- Keep service commands compatible with the Rails app and built frontend assets.

Acceptance criteria:

- Service definitions exist for web, worker, scheduler, and MCP when applicable.
- Units restart failed services according to documented policy.
- Units point at the active release path rather than a hard-coded one-off path.

Manual test:

- On a Linux host or compatible VM, validate unit syntax and start at least one
  service.

### Task 9.3: Add Health Check Endpoint for Internal Load Balancing

Context:

- The preferred deployment shape is multiple instances on a large shared server
  behind internal load balancing.

Goal:

- Add a lightweight health check endpoint suitable for a local load balancer.

Implementation notes:

- Keep the endpoint cheap and unauthenticated.
- Include enough checks to distinguish app boot from database unavailability.
- Do not expose sensitive environment or customer data.

Acceptance criteria:

- Healthy app instance returns a successful status.
- Broken database access returns a failure status.
- Endpoint is documented for internal load balancing.

Manual test:

- Start two local app instances on different ports and confirm both health
  checks can be queried independently.

### Task 9.4: Add Restart and Rollback Verification Script

Context:

- Service crashes should restart automatically or roll back to a previous
  release.

Goal:

- Add a script or documented command sequence that verifies restart and rollback
  behavior.

Implementation notes:

- Keep the script Linux-oriented.
- Avoid destructive commands against production paths by default.
- Prefer dry-run or staging mode where practical.

Acceptance criteria:

- The verification flow can stop or crash a service and confirm restart.
- The flow can switch the active release pointer to a previous release.
- Logs make it clear which release is running after rollback.

Manual test:

- Run the verification flow in a staging environment and confirm service state
  before and after rollback.

## Milestone 10 Tasks: Public Marketing Website

### Task 10.1: Add Public Marketing Routes and Controller

Context:

- The Rails app currently needs a public-facing website separate from the
  authenticated product and customer status pages.
- Marketing pages should not require customer data or authentication.

Goal:

- Add conventional Rails routes and controller actions for public marketing
  pages.

Implementation notes:

- Include routes for home, product, pricing, and contact or early-access pages.
- Keep controller actions read-only.
- Do not wire these routes to dashboard, monitor, outage, analytics, or account
  data.
- If authentication does not exist yet, still keep names and controller
  structure ready for anonymous access.

Acceptance criteria:

- Public marketing routes render successfully in a browser.
- Routes are named clearly enough to use from navigation and tests.
- Marketing controller actions do not query customer-owned tables.

Manual test:

- Start the app and visit each marketing route without signing in.

### Task 10.2: Add a Public Marketing Layout and Navigation

Context:

- Public marketing pages need navigation that is distinct from authenticated
  product navigation.

Goal:

- Add a public layout or layout branch with marketing-focused navigation.

Implementation notes:

- Include links for home, product, pricing, contact or early access, and a sign
  in or app entry point if such a route exists.
- Do not show dashboard management links, monitor controls, private account
  names, or status-page embed chrome.
- Keep the layout responsive using the repo's current asset stack. If Tailwind
  and DaisyUI are not implemented yet, use scoped plain CSS and document that it
  can be migrated later.

Acceptance criteria:

- Marketing pages share consistent public navigation.
- Authenticated dashboard navigation is not present on public marketing pages.
- Navigation remains usable at mobile width.

Manual test:

- Resize the browser from desktop to mobile width and confirm navigation and
  page content do not overlap.

### Task 10.3: Build the Public Home Page

Context:

- Prospective customers need to understand what OutageWise does before signing
  in.

Goal:

- Create a public home page that explains the product, target customer, and
  primary value.

Implementation notes:

- Focus copy on HTTP outage detection, public status communication, analytics,
  and read-only agent visibility.
- Include one primary call to action and one secondary call to action.
- Keep content crawlable in server-rendered HTML.
- Avoid claiming features are live if they are still roadmap-only.

Acceptance criteria:

- The home page explains who the product is for.
- The page describes the outage-monitoring problem and OutageWise's approach.
- Calls to action link to implemented routes or clearly stubbed next-step pages.

Manual test:

- Open the public home page and confirm a first-time visitor can identify the
  product purpose and next step without using private app navigation.

### Task 10.4: Build Product and Pricing Pages

Context:

- Visitors need enough detail to evaluate whether the product fits their use
  case.

Goal:

- Add public product and pricing pages with honest, vendor-agnostic content.

Implementation notes:

- Product content should describe monitoring, status pages, analytics, MCP
  visibility, and notifications as appropriate to current product maturity.
- Pricing can be simple and clearly marked as early or placeholder if final
  billing is not implemented.
- Do not add payment provider integrations in this task.
- Do not introduce provider-specific language unless the roadmap calls for it.

Acceptance criteria:

- Product page explains the main capabilities and release maturity.
- Pricing page presents a clear expected pricing or early-access position.
- Pages link back to the primary call to action.

Manual test:

- Navigate from the home page to product and pricing pages and confirm the user
  can return to the primary call to action.

### Task 10.5: Add Contact or Early-Access Capture Path

Context:

- Marketing calls to action need a concrete next step even before billing or
  self-serve signup exists.

Goal:

- Add a contact or early-access page with safe, minimal behavior.

Implementation notes:

- If persistence and email delivery are not ready, use a clearly labeled static
  contact path or mail link.
- If adding a form, validate inputs and store only the minimum needed fields.
- Do not send provider-specific email or CRM requests unless a provider-neutral
  adapter boundary is part of the task.
- Avoid collecting sensitive operational details on a public unauthenticated
  page.

Acceptance criteria:

- Calls to action lead to a working page or safe form.
- Invalid form input is handled clearly if a form is implemented.
- The page does not require authentication.

Manual test:

- Follow each marketing call to action and confirm it reaches the contact or
  early-access path.

### Task 10.6: Add SEO and Social Metadata for Public Pages

Context:

- Public marketing pages should be understandable to search engines and link
  previews.

Goal:

- Add descriptive titles, meta descriptions, canonical URLs where appropriate,
  and basic Open Graph metadata for marketing pages.

Implementation notes:

- Keep metadata page-specific.
- Ensure the primary page content remains server-rendered and crawlable.
- Do not add third-party analytics or tracking scripts in this task.
- Keep robots behavior intentional for public pages.

Acceptance criteria:

- Public pages render page-specific HTML titles.
- Public pages include useful meta descriptions.
- Link preview metadata is present for the public home page.

Manual test:

- View page source for each marketing page and confirm title and metadata match
  the page purpose.

### Task 10.7: Add Marketing Page Tests

Context:

- Public pages must remain accessible to anonymous visitors without leaking
  private customer data.

Goal:

- Add request or system tests for the public marketing website.

Implementation notes:

- Test anonymous access to all marketing routes.
- Test that public marketing pages do not render dashboard navigation or private
  account/monitor/outage content.
- Use Capybara system tests if the behavior is browser-visible and system test
  support is configured; otherwise use request tests.
- Keep tests deterministic and avoid external network requests.

Acceptance criteria:

- Tests cover successful anonymous page loads.
- Tests cover separation from authenticated dashboard or customer status
  surfaces where those surfaces exist.
- Tests fail if obvious private navigation or data appears on marketing pages.

Manual test:

- Run the narrowest relevant test file and then manually visit each public
  route.

### Task 10.8: Document Local Marketing Site Review

Context:

- Future agents and humans need to know how to run and review the public site
  locally.

Goal:

- Update README or docs with the local marketing website review flow.

Implementation notes:

- Include setup, server start, routes to visit, and the expected anonymous
  access behavior.
- Link to the Milestone 10 entry.
- Mention any intentionally stubbed calls to action.

Acceptance criteria:

- Documentation identifies the public marketing routes.
- Documentation explains how to review the pages locally.
- Documentation distinguishes public marketing pages from customer status pages.

Manual test:

- Follow the documented steps from a clean local server and confirm each route
  exists.

## Cross-Cutting Tasks

### Task X.1: Add Account Scoping Tests

Context:

- Account isolation is required across dashboard, status page, analytics, and
  MCP.

Goal:

- Add tests that prove one account cannot read another account's private data.

Acceptance criteria:

- Monitor pages are scoped to current account.
- Analytics queries are scoped to current account.
- MCP token for one account cannot read another account.

Manual test:

- Seed two accounts and confirm browser or API access never crosses accounts.

### Task X.2: Add Retention Policy Interface

Context:

- Check runs can grow quickly.

Goal:

- Add a provider-neutral retention service for old check runs.

Acceptance criteria:

- Retention cutoff is configurable.
- Dry-run mode reports records that would be deleted.
- Tests cover cutoff behavior.

Manual test:

- Seed old and recent check runs, run dry-run, and confirm only old rows are
  selected.

### Task X.3: Document Manual Demo Flow

Context:

- Every release slice should be easy to demo.

Goal:

- Add or update docs with the current manual demo path.

Acceptance criteria:

- Docs include setup, seed, run, and demo steps.
- Steps avoid vendor-specific tools unless clearly optional.
- Screens or routes mentioned in docs exist.

Manual test:

- Follow the docs from a clean checkout and note any missing step.

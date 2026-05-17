# Demoable Milestones

Each milestone should be complete enough to demo manually in a browser and
verify with focused tests. Milestones are intentionally small so progress can be
shown before external providers or production infrastructure are introduced.

## Milestone 0: Local Product Skeleton

Goal: A developer can run the app and see the product shell.

Demo script:

1. Start the app locally.
2. Open the home page.
3. Navigate to the monitor list.
4. Confirm a seeded account and empty monitor state are visible.
5. Touch an ERB, Elm, or CSS file while `bin/dev` is running and confirm the
   frontend watcher rebuilds assets.

Manual checks:

- The app boots without missing environment variables.
- `bin/dev` runs a frontend build before starting long-running services.
- `bin/dev` fails if the frontend build fails.
- Vite builds Elm, Tailwind CSS, and DaisyUI assets through one local build
  path.
- The README links to roadmap and milestone docs.
- Empty states explain what object is missing without naming implementation
  details.

Done when:

- Product routes exist for dashboard, monitors, and account status.
- Seed data creates one account and one demo user or demo session.
- SQLite is configured with a catalog database and at least one per-customer
  database for local demos.
- Rails 8 authentication and job-processing defaults are present or explicitly
  stubbed for the next milestone.
- Capybara is configured for browser-visible system tests.
- Basic layout is usable on desktop and narrow browser widths.

## Milestone 1: Monitor CRUD

Goal: A user can manage HTTP monitors.

Demo script:

1. Open the monitor list.
2. Create a monitor named `Example OK` with URL `https://example.com`.
3. Create a monitor named `Example Missing` with a URL expected to fail.
4. Edit the check interval and timeout.
5. Disable one monitor and confirm it no longer appears as active.

Manual checks:

- URL validation rejects blank, non-HTTP, and malformed URLs.
- Timeout and interval validation reject unsafe or impossible values.
- Disabled monitors remain visible with clear state.
- Deleting a monitor asks for confirmation or uses a reversible safe path.

Done when:

- Monitor create, read, update, disable, and delete flows work.
- Monitor fields are persisted and shown consistently.
- Model, request, and Capybara system tests cover valid and invalid monitor
  inputs.
- Customer monitor data is stored in the correct per-customer SQLite database.

## Milestone 2: Manual Check Runs

Goal: A user can run HTTP checks on demand and inspect the result.

Demo script:

1. Open a healthy monitor.
2. Click `Run check`.
3. See status, HTTP code, duration, and checked-at timestamp.
4. Open a failing monitor.
5. Run a check and see the error category and message.

Manual checks:

- Successful checks record `up`.
- HTTP status mismatches record `down`.
- Timeout, DNS, TLS, and connection failures are categorized when reproducible.
- Re-running checks appends history instead of overwriting it.
- HTTP checks are executed through the `http.rb` gem.

Done when:

- Check execution is isolated in a service object.
- Check runs are stored with enough evidence for later analytics.
- The monitor detail page shows latest state and recent check history.
- Check run records are written to the owning customer's SQLite database.

## Milestone 3: Outage State Machine

Goal: Repeated check failures open outages and repeated successes resolve them.

Demo script:

1. Configure a monitor with failure threshold `2` and recovery threshold `2`.
2. Run two failing checks.
3. Confirm an outage opens.
4. Run one successful check and confirm the outage remains open.
5. Run a second successful check and confirm the outage resolves.

Manual checks:

- A single failure below threshold does not open an outage.
- A monitor cannot have more than one active outage.
- Resolved outages record start time, end time, and duration.
- Manual and future scheduled checks use the same outage transition logic.

Done when:

- Outage state transitions are deterministic and tested.
- Current monitor status is derived from recent check and outage state.
- The dashboard shows account-level status from monitor states.

## Milestone 4: Scheduled Monitoring

Goal: Enabled monitors are checked automatically.

Demo script:

1. Create an enabled monitor with a short interval.
2. Start the app and worker process.
3. Wait for the interval to pass.
4. Refresh the monitor detail page and confirm a new check run appears.
5. Disable the monitor and confirm no new check runs are scheduled.

Manual checks:

- Due monitor selection ignores disabled monitors.
- Jobs are idempotent enough to tolerate accidental duplicate enqueueing.
- Worker errors are recorded without crashing the web app.
- Scheduling metadata is visible to developers.
- Rails 8 job-processing behavior is used for enqueueing and performing checks.

Done when:

- A scheduler job enqueues due monitor checks.
- A check job performs one monitor check and updates outage state.
- Tests cover due selection and disabled monitor behavior.

## Milestone 5: Embeddable Status Page

Goal: Customers can publish current status and recent incidents.

Demo script:

1. Open the account status page.
2. Confirm current overall status and monitor list are visible.
3. Trigger an outage and refresh the status page.
4. Open a local HTML test page that embeds the status page in an iframe.
5. Confirm embed mode renders compactly without authenticated dashboard chrome.

Manual checks:

- Status page exposes only public account status data.
- Private dashboard links or controls are absent from embed mode.
- Iframe headers allow intended embedding without allowing unsafe writes.
- Status page remains readable on mobile-width iframes.
- Any interactive status page widgets are focused Elm mounts, not a monolithic
  Elm app.

Done when:

- Status page settings determine display name, visibility, and included
  monitors.
- Public and embed routes are read-only.
- Authorization tests prevent private monitor details from leaking.

## Milestone 6: Analytics Summary

Goal: Customers can understand uptime, incidents, and latency trends.

Demo script:

1. Seed check runs across healthy and failing periods.
2. Open the analytics page.
3. Select a time window.
4. Review uptime percentage, latency percentile, incident count, and failure
   categories.
5. Compare a displayed metric against a known seeded calculation.

Manual checks:

- Empty analytics states are clear.
- Time windows use explicit start and end times.
- Calculations are stable across page reloads.
- Analytics can be reused by UI and MCP output.
- Any chart or filter interactivity is mounted as focused Elm components inside
  Rails-rendered pages.

Done when:

- Analytics query/service object returns structured summary data.
- Dashboard renders account-level and monitor-level analytics.
- Tests cover uptime, latency, and incident calculations.

## Milestone 7: Read-Only MCP Visibility

Goal: A customer's agent can read current outage context through MCP.

Demo script:

1. Create an MCP token for the demo account.
2. Connect a local MCP client with that token.
3. Call a tool or resource for current status.
4. Call a tool or resource for active outages.
5. Attempt an unsupported write operation and confirm it is rejected.

Manual checks:

- MCP responses are account-scoped.
- Tokens can be revoked.
- MCP schemas are stable and include timestamps.
- Tool names and descriptions are model-agnostic.
- MCP reads resolve customer data through the catalog database and the correct
  per-customer SQLite database.

Done when:

- MCP server exposes read-only current status, monitors, outages, and analytics.
- Token authentication and cross-account denial are tested.
- MCP usage is audited.

## Milestone 8: Notification Records and Provider Interfaces

Goal: Outages generate notification events through provider-neutral adapters.

Demo script:

1. Add a notification contact.
2. Trigger an outage.
3. Confirm an outage-open notification record is created.
4. Resolve the outage.
5. Confirm an outage-resolved notification record is created.

Manual checks:

- Notification payload previews are visible without sending external messages.
- Duplicate outage events do not create duplicate notifications.
- Provider adapter interfaces do not reference a specific vendor in core logic.

Done when:

- Notification records and delivery attempts are persisted.
- Outage transitions enqueue notification work.
- Tests cover event generation and deduplication.

## Milestone 9: Linux Native Deployment

Goal: The app can be deployed as supervised Linux services without Docker.

Demo script:

1. Build a release artifact on a Linux target or Linux-like environment.
2. Run database preparation for the catalog database and one customer database.
3. Start web, worker, scheduler, and MCP services through Linux service
   management.
4. Stop or crash one service and confirm it restarts automatically.
5. Switch the active release to a previous version and confirm services come
   back on the previous release.

Manual checks:

- No Docker container is required for the deliverable.
- Multiple app or worker instances can run on one large shared server.
- Internal load balancing can route to healthy local instances.
- Service failures are visible in logs and trigger restart or rollback behavior.
- Release directories and service definitions make rollback explicit.

Done when:

- Deployment docs describe Linux service units, environment files, release
  layout, frontend build artifacts, and rollback steps.
- Service definitions exist for web, worker, scheduler, and MCP as applicable.
- Health checks support internal load balancing.

# AGENTS.md

Guidance for coding agents working in this repository.

## Current Repository State

OutageWise is currently an early Rails application skeleton plus product
planning documentation. Treat the docs as the product direction, not as proof
that the capability already exists.

What exists now:

- Rails app using Rails `~> 8.1.3`.
- SQLite configured for the default Rails development and test databases.
- Production configuration includes separate SQLite databases for primary,
  cache, queue, and cable.
- Solid Cache, Solid Queue, Solid Cable, Propshaft, Importmap, Turbo, Stimulus,
  Jbuilder, Capybara, Selenium, Brakeman, Bundler Audit, and RuboCop Omakase
  are present in the Gemfile.
- Default Rails health route exists at `/up`.
- No product root route is enabled yet.
- No application domain models are implemented yet.
- `db/schema.rb` is empty at schema version `0`.
- `bin/dev` currently starts the Rails server directly.
- Product planning lives in `docs/`.

What is planned but not implemented yet:

- Account and user foundation.
- Catalog database plus per-customer SQLite database routing.
- HTTP monitors, check runs, outages, analytics, status pages, notifications,
  and MCP visibility.
- Vite, Elm, Tailwind CSS, and DaisyUI frontend pipeline.
- Public marketing website.
- Linux-native deployment service definitions.

## Product Direction

OutageWise is an HTTP outage detection service with customer-visible status
pages, analytics, and authenticated read-only MCP visibility for customer
agents.

Core product constraints from the roadmap:

- Keep the product AI-vendor-agnostic.
- Keep runtime providers, hosting providers, observability tools, notification
  providers, and MCP clients replaceable behind documented interfaces.
- Use Rails conventions first.
- Use SQLite, eventually with one catalog database plus per-customer SQLite
  databases.
- Use `http.rb` for HTTP monitor checks when HTTP checking is implemented.
- Use Rails-rendered pages as the main app structure.
- Use Elm only for focused interactive widgets, not as a monolithic SPA.
- Use Tailwind CSS and DaisyUI for the future design-system baseline.
- Make milestones manually demoable and testable before adding external
  providers or production infrastructure.
- The first deployable target is Linux-native services, not Docker as the
  required deliverable.

## Working Rules

- Read the relevant roadmap, milestone, and task sections before implementing a
  feature.
- Keep code changes scoped to the task.
- Do not introduce vendor-specific implementations where the roadmap calls for
  provider-neutral boundaries.
- Do not assume planned architecture exists. Check the current code first.
- Do not store customer-owned monitoring data in a shared place without an
  explicit account/customer database decision.
- Prefer Rails models, controllers, jobs, services, and query objects in
  conventional locations.
- Add migrations for schema changes. Do not hand-edit `db/schema.rb`.
- Add tests close to the behavior being changed.
- Keep public surfaces read-only unless the task explicitly requires writes.
- Keep public marketing pages, public status pages, and authenticated dashboard
  pages separated in routes, layouts, and navigation.
- Do not remove or rewrite unrelated work.

## Verification Commands

Use the narrowest command that proves the change. Useful commands in this repo:

```sh
bin/rails test
bin/rails test:system
bin/rubocop
bin/bundler-audit
bin/importmap audit
bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error
bin/ci
```

Notes:

- `bin/ci` runs setup, Ruby style, gem audit, importmap audit, Brakeman, Rails
  tests, and seed replant.
- System tests are present as an optional CI step and should be run for
  browser-visible flows when they exist.
- If Vite, Elm, Tailwind, or DaisyUI are added later, update this file with the
  frontend build and watch commands.

## Documentation Table Of Contents

### README

[README.md](README.md)

- Project summary.
- Links to the product planning docs.

### Product Roadmap

[docs/product-roadmap.md](docs/product-roadmap.md)

- Product Vision
- Product Principles
- Technical Direction
  - Application Runtime
  - Data Storage
  - HTTP Checking
  - Frontend
  - Local Development
  - Testing
  - Deployment and Operations
- Core Concepts
- Roadmap Phases
  - Phase 0: Product Foundation
  - Phase 1: Manual HTTP Monitoring
  - Phase 2: Outage Detection
  - Phase 3: Scheduled Checks
  - Phase 4: Customer Status Page
  - Phase 5: Analytics
  - Phase 6: Authenticated Read-Only MCP Server
  - Phase 7: Notifications and Escalation
  - Phase 8: Reliability, Security, and Scale
- Non-Goals for the First Release
- Release Slices
  - Local Alpha
  - Private Beta
  - Public Beta
- Vendor-Agnostic Architecture Guidelines

### Demoable Milestones

[docs/milestones.md](docs/milestones.md)

- Milestone 0: Local Product Skeleton
- Milestone 1: Monitor CRUD
- Milestone 2: Manual Check Runs
- Milestone 3: Outage State Machine
- Milestone 4: Scheduled Monitoring
- Milestone 5: Embeddable Status Page
- Milestone 6: Analytics Summary
- Milestone 7: Read-Only MCP Visibility
- Milestone 8: Notification Records and Provider Interfaces
- Milestone 9: Linux Native Deployment
- Milestone 10: Public Marketing Website

### Agent Task Breakdown

[docs/agent-task-breakdown.md](docs/agent-task-breakdown.md)

- Universal Task Instructions
- Preferred task shape
- Milestone 0 Tasks: Local Product Skeleton
  - Task 0.1: Add Product Routes and Placeholder Controllers
  - Task 0.2: Create Account and User Foundation
  - Task 0.3: Add Basic Product Layout
  - Task 0.4: Configure SQLite Catalog and Customer Databases
  - Task 0.5: Configure Vite, Elm, Tailwind, and DaisyUI
  - Task 0.6: Make `bin/dev` Frontend-Build-Aware
  - Task 0.7: Add Frontend File Watch Rebuilds
  - Task 0.8: Configure Capybara System Tests
- Milestone 1 Tasks: Monitor CRUD
  - Task 1.1: Add Monitor Model
  - Task 1.2: Build Monitor List and Detail Pages
  - Task 1.3: Add Monitor Create and Edit Forms
  - Task 1.4: Add Disable and Delete Behavior
- Milestone 2 Tasks: Manual Check Runs
  - Task 2.1: Add Check Run Model
  - Task 2.2: Implement HTTP Check Service
  - Task 2.3: Add Manual Run Check Action
  - Task 2.4: Render Recent Check History
- Milestone 3 Tasks: Outage State Machine
  - Task 3.1: Add Outage Model
  - Task 3.2: Add Outage Transition Service
  - Task 3.3: Integrate Outage Transitions with Manual Checks
  - Task 3.4: Show Current Status on Dashboard
- Milestone 4 Tasks: Scheduled Monitoring
  - Task 4.1: Add Scheduling Fields to Monitors
  - Task 4.2: Implement Due Monitor Query
  - Task 4.3: Add Check Job
  - Task 4.4: Add Scheduler Job
- Milestone 5 Tasks: Embeddable Status Page
  - Task 5.1: Add Status Page Settings
  - Task 5.2: Render Public Status Page
  - Task 5.3: Add Iframe Embed Mode
  - Task 5.4: Add Status Page Data Presenter
- Milestone 6 Tasks: Analytics Summary
  - Task 6.1: Define Analytics Summary Object
  - Task 6.2: Calculate Uptime Percentage
  - Task 6.3: Calculate Latency and Failure Breakdown
  - Task 6.4: Render Analytics Page
- Milestone 7 Tasks: Read-Only MCP Visibility
  - Task 7.1: Add MCP Token Model
  - Task 7.2: Add MCP Authentication Boundary
  - Task 7.3: Expose Current Status Through MCP
  - Task 7.4: Expose Outages and Analytics Through MCP
  - Task 7.5: Add MCP Usage Audit
- Milestone 8 Tasks: Notification Records and Provider Interfaces
  - Task 8.1: Add Notification Contact Model
  - Task 8.2: Add Notification Event and Delivery Models
  - Task 8.3: Add Provider-Neutral Notification Adapter
  - Task 8.4: Generate Notifications from Outage Transitions
- Milestone 9 Tasks: Linux Native Deployment
  - Task 9.1: Document Linux Release Layout
  - Task 9.2: Add Linux Service Definitions
  - Task 9.3: Add Health Check Endpoint for Internal Load Balancing
  - Task 9.4: Add Restart and Rollback Verification Script
- Milestone 10 Tasks: Public Marketing Website
  - Task 10.1: Add Public Marketing Routes and Controller
  - Task 10.2: Add a Public Marketing Layout and Navigation
  - Task 10.3: Build the Public Home Page
  - Task 10.4: Build Product and Pricing Pages
  - Task 10.5: Add Contact or Early-Access Capture Path
  - Task 10.6: Add SEO and Social Metadata for Public Pages
  - Task 10.7: Add Marketing Page Tests
  - Task 10.8: Document Local Marketing Site Review
- Cross-Cutting Tasks
  - Task X.1: Add Account Scoping Tests
  - Task X.2: Add Retention Policy Interface
  - Task X.3: Document Manual Demo Flow

## When Adding New Work

Before finishing a change, update documentation when the repo state changes in
a way future agents must know about. In particular, update this file when:

- The implemented stack differs from the planned stack.
- New setup, test, build, or run commands are introduced.
- A milestone moves from planned to partially or fully implemented.
- New docs are added or existing docs are reorganized.

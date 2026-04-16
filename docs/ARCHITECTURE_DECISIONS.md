# Architecture Decisions Record — Alhai Platform

> This document captures key architectural decisions, their rationale, and trade-offs.

---

## ADR-1: Flutter + Supabase

**Decision:** Use Flutter for all client apps and Supabase as the backend.

**Context:** Need to build 7+ apps (customer, driver, distributor, admin, cashier, super_admin, admin_lite) targeting Android, iOS, and Web with a small team.

**Rationale:**
- **Flutter:** Single codebase for Android + iOS + Web. Dart is strongly typed. Hot reload for fast development. Mature widget system for custom UI.
- **Supabase:** Open-source Firebase alternative. PostgreSQL (familiar, powerful). Built-in Auth, Realtime, Storage. Row Level Security. Can self-host if needed.
- **Alternative considered:** React Native + Firebase — rejected due to less consistent cross-platform behavior and Firebase vendor lock-in.
- **Alternative considered:** Native (Kotlin + Swift) — rejected due to team size constraints (would need 2x engineers).

**Trade-offs:**
- Flutter Web performance is acceptable but not optimal (large bundle size ~5 MB)
- Supabase free tier has limits — must upgrade for production
- Supabase Edge Functions use Deno (not Dart) — context switching

---

## ADR-2: Separate Apps (Not One Flutter Monolith)

**Decision:** Build separate Flutter apps per user type rather than one app with role switching.

**Architecture:**
```
customer_app/    — Customer ordering app (Android + iOS)
driver_app/      — Driver delivery app (Android + iOS)
distributor_portal/ — Distributor management (Web only)
admin/           — Store admin (Android + iOS)
cashier/         — POS cashier (Android + iOS)
super_admin/     — Super admin (Android + iOS)
admin_lite/      — Lightweight admin (Android + iOS)
```

**Rationale:**
- Each user type has distinct UI, permissions, and workflows
- Smaller app size per user (no unused features shipped)
- Independent release cycles — can update driver app without affecting customers
- App store optimization — dedicated listings per audience
- Security isolation — customer app cannot access admin APIs

**Trade-offs:**
- More apps to maintain (mitigated by shared packages)
- Potential code duplication (mitigated by `alhai_core` and `alhai_design_system`)

---

## ADR-3: Riverpod over Bloc

**Decision:** Use Riverpod for state management across all apps.

**Rationale:**
- **Compile-time safety:** Providers are type-safe and refactored with IDE support
- **No boilerplate:** Less code than Bloc (no Event/State classes for simple cases)
- **Dependency injection:** Built-in DI with `ref.watch`/`ref.read`
- **Testing:** Easy to override providers in tests
- **Future-proof:** Riverpod 2.x is stable with code generation support

**Alternative considered:** Bloc — rejected due to excessive boilerplate for this project size. Bloc is better for very large teams where strict event-driven architecture is beneficial.

**Alternative considered:** Provider — rejected as Riverpod is its evolution by the same author, with better type safety and testability.

---

## ADR-4: Shared Packages (alhai_core + alhai_design_system)

**Decision:** Extract shared logic into reusable packages within the monorepo.

**Package structure:**
```
packages/
├── alhai_core/           — Models, services, database, config
├── alhai_design_system/  — Shared UI components, themes, tokens
└── alhai_zatca/          — ZATCA e-invoicing logic
```

**Rationale:**
- **DRY:** Common models (User, Order, Product) defined once
- **Consistency:** All apps use same design tokens, colors, typography
- **Testability:** Core logic tested independently of any app
- **ZATCA isolation:** E-invoicing is complex enough to warrant its own package with dedicated tests

**Trade-offs:**
- Package changes require rebuilding dependent apps
- Versioning is implicit (path dependencies, not pub.dev)
- Breaking changes in `alhai_core` affect all apps

---

## ADR-5: ZATCA Phase 2 from Day One

**Decision:** Implement ZATCA Phase 2 (integration phase) e-invoicing from the start, not retroactively.

**Rationale:**
- ZATCA Phase 2 is **mandatory** for all businesses in Saudi Arabia
- Retroactively adding invoicing compliance is painful (schema changes, data migration)
- Invoice records must be retained for 7 years — better to start correctly
- QR code generation, XML signing, and API integration are complex — better to build and test early

**What this means:**
- Every transaction generates a ZATCA-compliant invoice
- Invoices support both B2C (simplified) and B2B (standard)
- Credit and debit notes are first-class citizens
- CSID onboarding flow is implemented
- Three environments supported: sandbox, simulation, production

---

## ADR-6: MFA for Super Admin Only

**Decision:** Require multi-factor authentication only for `super_admin` role, not all users.

**Rationale:**
- **Security proportionality:** Super admin has access to all distributor data, user management, and platform configuration. This role justifies the friction of MFA.
- **User experience:** Requiring MFA for customers or drivers would significantly increase friction and reduce adoption.
- **TOTP over SMS:** TOTP is more secure (no SIM swapping risk), free (no SMS costs), and works offline.

**Implementation:**
- Supabase Auth MFA API with TOTP
- 8 backup codes per user (hashed with SHA-256)
- Forced enrollment on first login for super_admin
- AAL2 required for admin operations

**Trade-offs:**
- Regular distributors don't have MFA (acceptable risk given lower privileges)
- TOTP requires an authenticator app (Google Authenticator, etc.)

---

## ADR-7: Certificate Pinning via Environment Variables

**Decision:** Store TLS certificate fingerprints in dart-define environment variables, not hardcoded.

**Rationale:**
- Certificates rotate — hardcoded pins require app updates on every rotation
- Environment variables allow rotation without code changes
- Backup pin supports seamless rotation (old + new pin active simultaneously)
- Debug mode disables pinning to allow proxy tools (Charles, mitmproxy)

**Implementation:**
- Primary pin: `SUPABASE_CERT_FINGERPRINT`
- Backup pin: `SUPABASE_CERT_FINGERPRINT_BACKUP`
- SHA-256 of DER-encoded certificate, base64
- Constant-time comparison to prevent timing attacks

**Trade-offs:**
- Still requires app rebuild to update pins (dart-define is compile-time)
- Could use a pin update API in the future for dynamic rotation

---

## ADR-8: Monorepo Structure

**Decision:** Use a single Git repository for all apps and packages.

**Rationale:**
- **Atomic changes:** A model change in `alhai_core` + UI update in `customer_app` can be one commit
- **Shared tooling:** One CI config, one linting config, one test runner
- **Discoverability:** All code in one place — easier for new team members
- **No version hell:** Path dependencies always use latest code

**Alternative considered:** Multi-repo with `pub.dev` or Git submodules — rejected due to complexity and version management overhead for a small team.

**Trade-offs:**
- Repository grows large over time
- CI runs may be slower (can be optimized with path-based triggers)
- All developers need access to all code

---

## ADR-9: Row Level Security (RLS) as Primary Access Control

**Decision:** Use Supabase RLS policies as the primary data access control mechanism, not application-level middleware.

**Rationale:**
- **Defense in depth:** Even if a client app is compromised, the database enforces access rules
- **Single source of truth:** Policies defined in SQL, not scattered across app code
- **Supabase native:** RLS is deeply integrated with Supabase Auth JWT claims
- **Auditable:** Policies are versioned in migration files

**Trade-offs:**
- Complex policies can be hard to debug
- Performance impact on complex queries (mitigated by proper indexing)
- Testing requires Supabase-specific test setup

---

## ADR-10: Arabic-First Design

**Decision:** Design all user-facing apps with Arabic as the primary language and RTL as the default layout direction.

**Rationale:**
- Target market is Saudi Arabia — Arabic is the primary user language
- RTL-first is harder to retrofit than LTR-first
- Flutter has good RTL support with `Directionality` widget
- All labels, error messages, and UI text are in Arabic first

**Trade-offs:**
- English translations are secondary and may lag behind
- Some third-party packages may not fully support RTL
- Development tools (DevTools, Sentry) show LTR — minor inconvenience

---

*Last updated: April 16, 2026*

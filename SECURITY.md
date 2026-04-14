# Security / الامان

Security overview for the Alhai Platform.

> For the full security audit report with RLS coverage matrix, see [docs/SECURITY_REPORT.md](docs/SECURITY_REPORT.md).

---

## 1. Threat Model Overview / نظرة عامة على نموذج التهديد

The Alhai platform is a multi-tenant POS system handling financial transactions, customer PII, and ZATCA-compliant invoices. The primary threat surface includes:

- **Cross-tenant data access:** One store reading/writing another store's data
- **Privilege escalation:** A cashier gaining admin or super_admin capabilities
- **Data tampering:** Modifying sales records, stock quantities, or audit logs
- **Offline device compromise:** Extracting data from a stolen POS device
- **API key exposure:** Leaking Supabase or third-party keys

### Trust Boundaries

| Boundary                  | Protection                                      |
|---------------------------|-------------------------------------------------|
| Client <-> Supabase       | HTTPS/TLS, JWT auth, RLS policies               |
| Local DB on device        | SQLCipher AES-256 encryption                     |
| Auth tokens               | flutter_secure_storage (Keychain/Keystore)       |
| Build secrets             | `--dart-define` flags, GitHub Actions Secrets     |
| Role changes              | RPC-only with trigger enforcement and audit log  |

---

## 2. Supabase RLS Strategy / استراتيجية امان الصفوف

Every table in the Supabase schema has Row Level Security (RLS) enabled. Policies use three helper functions defined with `SECURITY DEFINER` and pinned `search_path`:

```sql
is_super_admin()           -- true if current user role = 'super_admin'
is_store_member(store_id)  -- true if user is an active member of the store
is_store_admin(store_id)   -- true if user is owner/manager OR super_admin
```

### Policy Pattern

| Operation | Default Policy                              |
|-----------|---------------------------------------------|
| SELECT    | `USING (is_store_member(store_id))`         |
| INSERT    | `WITH CHECK (is_store_admin(store_id))`     |
| UPDATE    | `USING/WITH CHECK (is_store_admin(store_id))`|
| DELETE    | `USING (is_store_admin(store_id))`          |

### Append-Only Tables

The following tables have UPDATE and DELETE revoked entirely (append-only audit trails):
- `stock_adjustments`
- `activity_logs`
- `order_payments`
- `debt_payments`
- `role_audit_log` (all DML revoked; super_admin SELECT only)

### Immutability Triggers

- `prevent_direct_role_update` on `users`: blocks direct UPDATE on role column; forces use of `update_user_role()` RPC
- `immutable_order_items` on `order_items`: prevents changes after order is confirmed
- `store_id` immutability triggers on `products`, `store_members`, `debts`, `purchase_orders`

### Known RLS Gaps

26 tables created via `fix_compatibility.sql` currently have permissive "Allow authenticated full access" policies. These are tracked as P0 remediation items. See [docs/SECURITY_REPORT.md](docs/SECURITY_REPORT.md) section 6.1 for the full table list and remediation plan.

---

## 3. Key Management Policy / سياسة ادارة المفاتيح

| Secret                | Storage Location                       | Rotation Policy          |
|-----------------------|----------------------------------------|--------------------------|
| Supabase URL/Key      | `--dart-define` at build time          | Per-project              |
| Sentry DSN            | `--dart-define` at build time          | Per-project              |
| Android Keystore      | GitHub Actions Secrets (base64)        | Per-release cycle        |
| iOS Certificates      | Apple Developer portal                 | Annual renewal           |
| ZATCA Certificates    | flutter_secure_storage on device       | Per ZATCA renewal cycle  |
| OpenAI API Key        | Railway environment variables          | As needed                |
| Auth JWT tokens       | flutter_secure_storage (per device)    | Managed by Supabase Auth |
| Employee PINs         | Supabase `users` table                 | User-managed             |

**Build-time secrets** are never committed to source. They are injected via `--dart-define` flags in CI/CD and passed as GitHub Actions Secrets.

**On-device secrets** (auth tokens, ZATCA certificates) are stored using `flutter_secure_storage`, which uses Android Keystore and iOS Keychain.

---

## 4. Authentication Security / امان المصادقة

### Authentication Flow

- **Provider:** Supabase Auth (phone OTP primary, email secondary)
- **New user trigger:** `handle_new_user()` on `auth.users` INSERT creates a `public.users` record with default role `customer`
- **Role management:** Only via `update_user_role()` RPC, restricted to `super_admin`
- **Privilege escalation protection:** Super_admin roles cannot be changed by other super_admins

### Role Hierarchy

```
super_admin  -- Platform-level, manages all tenants
  +-- store_owner  -- Owns one or more stores
        +-- manager  -- Store manager, most admin rights
              +-- cashier  -- POS access, limited write
```

### Session Management

- JWT tokens managed by Supabase Auth SDK with automatic refresh
- POS shifts tracked via `shifts` table with opening/closing cash reconciliation
- Unique index prevents multiple open shifts per cashier
- `store_id` change prevention trigger blocks lateral movement

### Local Device Security

| Measure              | Implementation                                    |
|----------------------|---------------------------------------------------|
| Database encryption  | SQLCipher (AES-256) for all on-device data        |
| Token storage        | flutter_secure_storage (Keychain/Keystore)        |
| PIN protection       | 4-digit PIN for manager approval operations       |
| Code obfuscation     | `--obfuscate --split-debug-info` on release builds|
| Web security headers | X-Frame-Options: DENY, CSP meta tags              |

---

## 5. OWASP Top 10 Assessment Summary / ملخص تقييم OWASP

Assessment date: 2026-04-03. Based on Supabase backend, RLS policies, and authentication.

| OWASP Category                        | Risk Level   | Summary                                    |
|---------------------------------------|--------------|--------------------------------------------|
| A01 - Broken Access Control           | MEDIUM-HIGH  | Core tables properly secured; 26 tables have permissive RLS (remediation tracked) |
| A02 - Cryptographic Failures          | MEDIUM       | PINs stored as plaintext; ZATCA fields unencrypted at rest |
| A03 - Injection                       | LOW          | Parameterized queries throughout; search_path pinned on all SECURITY DEFINER functions |
| A04 - Insecure Design                 | MEDIUM       | Delivery confirmation has max 3 attempts; stock reservation uses FOR UPDATE locking |
| A05 - Security Misconfiguration       | MEDIUM       | RLS enabled on all tables but 26 have USING(true) policies |
| A06 - Vulnerable Components           | UNKNOWN      | No automated dependency scanning in place |
| A07 - Auth Failures                   | LOW-MEDIUM   | Phone OTP provides second factor; no account lockout at DB level |
| A08 - Data Integrity Failures         | LOW          | Append-only audit trails; store_id immutability triggers |
| A09 - Logging/Monitoring Failures     | MEDIUM       | activity_logs and role_audit_log exist; no centralized security event logging |
| A10 - SSRF                            | LOW          | No user-controlled URLs in server-side fetching |

---

## 6. Data Protection / حماية البيانات

### Encryption

| Layer          | Mechanism                                 |
|----------------|------------------------------------------|
| At rest (cloud)| Supabase managed disk encryption          |
| In transit     | HTTPS/TLS enforced by Supabase edge       |
| At rest (local)| SQLCipher AES-256                         |

### Storage Bucket Security

| Bucket               | Public | Upload Restriction          | Read Restriction |
|----------------------|--------|-----------------------------|------------------|
| `product-images`     | Yes    | Store member                | Public           |
| `store-logos`        | Yes    | Owner/admin only            | Public           |
| `receipts`           | No     | Store member                | Store member     |
| `backups`            | No     | Owner/admin                 | Owner/admin      |
| `invoice-attachments`| No     | Store member                | Store member     |
| `delivery-proofs`    | No     | Delivery role users         | Authenticated    |

---

## 7. Dependency Audit / تدقيق التبعيات

Recommended tooling for ongoing security:

| Tool                | Purpose                               | Frequency      |
|---------------------|---------------------------------------|----------------|
| `flutter pub audit` | Dart package vulnerability scan       | Every release  |
| `npm audit`         | Node.js E2E test dependency scan      | Every release  |
| Supabase Advisors   | PostgreSQL security advisors          | Monthly        |
| OWASP ZAP           | Dynamic application security testing  | Quarterly      |
| Snyk / Dependabot   | Automated dependency monitoring       | Continuous     |

### Recommended CI/CD Additions

1. **Pre-merge:** Run `flutter pub audit` and fail on high/critical CVEs
2. **Pre-deploy:** Run RLS test suite (`supabase/tests/rls_test.sql`) against staging
3. **Post-deploy:** Verify RLS is enabled on all tables via information_schema query
4. **Weekly:** Automated dependency update PRs via Dependabot or Renovate

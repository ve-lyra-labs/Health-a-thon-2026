# Security Notes

## CSRF risk — bearer-token auth (2026-07-19)

Investigated whether the app needs classic CSRF protection (anti-CSRF
tokens, `SameSite` cookies, etc.).

**Finding:** every login endpoint (`reg_and_sched/app/api/doctors.py`,
`ehr/app/api/routes/admin.py`, `inventory_management/app/api/v1/endpoints/auth.py`)
returns `access_token`/`refresh_token` as JSON body fields, not
`Set-Cookie` headers. The frontend attaches the access token via an
`Authorization: Bearer <token>` header on every request (see the axios
interceptors added in the `doctorStore`/`adminStore`/`pharmacistStore`
sessions). A grep across the whole repo for `cookie`, `Set-Cookie`,
`SameSite`, and `csrf` (case-insensitive, both `backend/` and
`frontend/src/`) found no endpoint that accepts or sets an auth cookie,
and no CSRF middleware/token anywhere.

Classic CSRF works by getting a victim's browser to automatically attach
*ambient* credentials (cookies) to a forged cross-site request. Since
this app never stores auth in a cookie — a malicious page cannot induce
the browser to attach the bearer token, because reading `Authorization`
headers from the requesting page's own JS is the only way that header
gets attached, and a cross-origin page cannot read another origin's
`localStorage`/token store. **Conclusion: CSRF risk is low today given
bearer-token-only auth.** If a cookie-based session or `withCredentials`
flow is ever introduced (e.g. for SSR or a same-site proxy), CSRF tokens
and `SameSite=Strict`/`Lax` cookies must be added at that point — this
conclusion does not automatically hold once cookies enter the picture.

**Re-verified 2026-07-23** after the Day 2 security pass (rate limiting,
persisted OTP store, `/refresh` endpoints — see below): the repo-wide
grep for `cookie`/`Set-Cookie`/`SameSite`/`csrf` still finds nothing, and
no route anywhere calls `response.set_cookie`. No CSRF middleware/tokens
were added — they would add complexity with no corresponding attack
surface for a bearer-only API, and per the reasoning above would be
inert (there's no ambient credential for a forged cross-site request to
carry). Two things enforce that this stays true rather than silently
drifting:
- Every CORS config in the backend (`ehr/app/main.py`,
  `inventory_management/app/main.py`) now sets `allow_credentials=False`
  — this doesn't add CSRF protection by itself, but it's a guardrail: if
  someone adds a cookie-based flow later without revisiting this file,
  browsers will refuse to send/receive that cookie cross-origin until
  `allow_credentials=True` is deliberately re-enabled, which is a natural
  trigger to come back and re-read this note.
- If a cookie-based session, SSR proxy, or `withCredentials` fetch is
  ever introduced: add `SameSite=Strict` (or `Lax`) on the cookie, add a
  double-submit or synchronizer CSRF token on state-changing requests,
  and re-run this same grep to confirm bearer-only auth is genuinely
  gone before trusting the "CSRF risk is low" conclusion again.

## CSRF defense-in-depth added (2026-08-01)

The conclusion above still holds — bearer-only auth, no cookies, so classic
CSRF is inert — but a second, independent layer was added anyway rather than
relying solely on that argument:
`reg_and_sched/app/utils/csrf_protection.py`'s `OriginCheckMiddleware` blocks
any state-changing request (non-GET/HEAD/OPTIONS) whose browser-set `Origin`
header doesn't match the app's own CORS allow-list. Requests with no `Origin`
header (server-to-server calls, curl, mobile clients) are left alone, since
CSRF is specifically a browser-driven attack and those callers were never
part of that threat model. Wired into both standalone apps —
`ehr/app/main.py` (covers ehr, reg_and_sched, diagtool, inventory's mounted
router — everything `include_router`'d into that one app) and
`inventory_management/app/main.py` — added *before* `CORSMiddleware` in each,
so CORS ends up outermost and still attaches its headers even to a blocked
response. Tests: `ehr/tests/test_csrf_protection.py`.

## Session idle timeout added (2026-08-01)

Before this change, a refresh token was valid for its full 7-day absolute
lifetime regardless of how long the user had actually been inactive — there
was no way to force re-authentication after a period of idleness short of
that 7-day cap. `reg_and_sched/app/utils/jwt_utils.py` now stamps every
refresh token with an `iat` claim, and
`reg_and_sched/app/utils/token_refresh.py`'s `refresh_access_token()` rejects
(and revokes) a refresh token if it's being redeemed more than
`IDLE_TIMEOUT_MINUTES` (30) after it was minted — independent of the 20-minute
access-token TTL and the 7-day absolute refresh-token expiry, both left
unchanged. Refresh tokens minted before this change carry no `iat` and are
treated as passing the check (so already-issued 7-day tokens aren't
retroactively broken); every token minted from now on always carries one.
Tests: `ehr/tests/test_token_refresh.py`, `ehr/tests/test_jwt_utils.py`.

## Access token expiry

`ACCESS_TOKEN_MINUTES = 20` in `reg_and_sched/app/utils/jwt_utils.py` —
already short-lived. Left as-is; no reason found to shorten or lengthen
it.

## Refresh token revocation on logout (added 2026-07-19)

Before this change there was **no logout endpoint at all** in the
backend — "logout" was purely client-side (clearing the Zustand store).
Refresh tokens were minted at login with a 7-day expiry and no way to
invalidate them early.

Added:
- A `jti` (unique token ID) claim on both access and refresh tokens
  (`reg_and_sched/app/utils/jwt_utils.py`).
- A shared `revoke_refresh_token()` / `is_refresh_token_revoked()` helper
  (`reg_and_sched/app/utils/token_revocation.py`), following the same
  "caller passes in its own DB session + model class" convention already
  used by `audit.py`/`rbac.py`.
- A `RevokedRefreshToken` table, keyed by `jti`, added to `ehr`'s DB
  (`ehr/app/db/models.py`) and re-declared narrowly in
  `inventory_management/app/db/audit_session.py` — mirroring exactly how
  `AuditLog` is already shared across modules. Auto-created via the
  existing `Base.metadata.create_all()` startup hook in `ehr/app/main.py`
  — no manual migration needed.
- A `POST /logout` endpoint on each of the three login surfaces
  (doctor, admin, pharmacist/inventory-admin) that takes
  `{"refresh_token": "..."}` and blacklists its `jti`. Idempotent and
  always returns success — an already-expired or malformed token is
  treated as a no-op, so logout never fails from the caller's
  perspective.

## Refresh endpoint (added 2026-07-23)

The gap above — no `/refresh` endpoint anywhere, so revoking a refresh
token had no observable effect and users were silently logged out every
20 minutes — is now closed. `reg_and_sched/app/utils/token_refresh.py`
adds `refresh_access_token()`, used by:
- `admin.router` `/refresh` (mounted at `/api/v1/admin`) — admin
- `doctors.router` `/refresh` (mounted at `/api/v1/doctors`) — doctor
- `scheduler_routes.router` `/patients/refresh` (mounted at `/api/v1`)
  — patient (a `/patients/logout` was also added on this router — there
  wasn't one before, so refresh-token revocation for patients had
  nothing to revoke through)
- `inventory_management`'s `auth.router` `/refresh` (mounted at
  `/api/v1/inventory/auth`) — pharmacist or inventory-admin, resolved by
  which table the token's subject actually belongs to (the two roles
  share one secret key/module)

Every refresh **rotates**: the presented refresh token is revoked via
the existing `is_refresh_token_revoked()`/`revoke_refresh_token()` pair
in the same call that mints the new access+refresh pair, so a stolen
refresh token is only ever redeemable once. Role is never trusted from
the old token — each call re-confirms the account still exists (or, for
the shared inventory_management case, re-resolves which table it
belongs to) before minting anything, so a deleted/deactivated account
can't keep refreshing indefinitely. All four endpoints are also rate
limited (`reg_and_sched/app/utils/rate_limit.py`) at 20 attempts / 5
minutes per IP.

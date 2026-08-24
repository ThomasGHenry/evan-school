# Bootstrap Checklist

One-time setup record for `ThomasGHenry/evan-school`.

`[x]` = done. `[ ]` = your next action. Each open item has explicit steps.

---

## 1. Clone and local setup

- [x] Repo created from `ThomasGHenry/tgh-template`
- [x] Namespace renamed `@template/*` → `@evan-school/*`
- [x] PRD committed as `PRD.md`
- [x] Lockfile regenerated (`pnpm install`)
- [x] `pnpm run typecheck` — exit 0
- [x] `pnpm run build` — exit 0
- [x] `pnpm run test` — 5 passed

**To run locally after cloning:**

```bash
fnm use 22          # Node 22 required
pnpm install
cp .env.example .env.local   # then fill in secrets (see §3 and §4 below)
```

---

## 2. Database (Neon) — done

- [x] Neon project `evan-school` provisioned (pg17, `aws-us-east-2`)
- [x] First migration applied: `20260823144522_init` (all 6 tables created)
- [x] `DATABASE_URL` set in Vercel for preview deployments (via Tofu)
- [x] `DATABASE_URL_PROD` set as GitHub Actions secret (via Tofu)

**Neon project details:**

| | |
|---|---|
| Project name | `evan-school` |
| Project ID | `long-hat-42093777` |
| Host | `ep-floral-cherry-axacd0tm.c-4.us-east-2.aws.neon.tech` |
| Database | `neondb` |
| Region | `aws-us-east-2` |
| Postgres | 17 |
| Console | https://console.neon.tech/app/projects/long-hat-42093777 |

**Get your `DATABASE_URL`:**

1. Go to the Neon console link above
2. Click **Connection string** (top of the dashboard)
3. Copy the `postgresql://...` string — this is your `DATABASE_URL`
4. Paste it into `.env.local` as `DATABASE_URL=postgresql://...`

**Running future migrations** (after schema changes):

```bash
DATABASE_URL="postgresql://..." pnpm run db:migrate
```

**Optional: create a personal dev branch in Neon** (isolates your local changes from the shared `main` branch):

1. Neon console → **Branches** → **Create branch**
2. Name it `dev/<your-name>`
3. Copy its connection string
4. Use that string as your local `DATABASE_URL` instead

---

## 3. Auth (Clerk) — needs your action

- [x] `@clerk/nextjs` wired into middleware, layout, and Zod env schema
- [ ] **Create Clerk application**
- [ ] **Add Clerk keys to `.env.local`**
- [ ] **Add Clerk keys to Vercel**
- [ ] **Create Clerk webhook**

### 3a. Create Clerk application

1. Go to https://dashboard.clerk.com
2. **Create application** → name it `evan-school`
3. Enable sign-in methods: **Email** (required), **Google OAuth** (optional, deferred to post-MVP per ADR 0100)
4. Click through to the dashboard

### 3b. Add keys to `.env.local`

On the Clerk dashboard, go to **API Keys**. Copy both keys:

```bash
# .env.local
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_...
CLERK_SECRET_KEY=sk_test_...
```

> The `pk_test_` key is safe to expose in the browser. The `sk_test_` key is server-only — never commit it.

### 3c. Add Clerk keys to Vercel

The build works without keys (conditional `ClerkProvider`) but sign-in will 500 at runtime without them.

Run these two commands (or set via Vercel dashboard under **Settings → Environment Variables**):

```bash
# Preview environment
vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY preview
vercel env add CLERK_SECRET_KEY preview

# Production environment
vercel env add NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY production
vercel env add CLERK_SECRET_KEY production
```

Or set all four via the Vercel dashboard at:
https://vercel.com/thomasghenry/evan-school/settings/environment-variables

### 3d. Create Clerk webhook (required for user sync to DB)

When a user signs up via Clerk, we need to create a `User` row in Neon. This happens via a webhook.

1. Clerk dashboard → **Webhooks** → **Add endpoint**
2. **Endpoint URL:** `https://<your-vercel-production-domain>/api/webhooks/clerk`
   - For preview testing use the Vercel preview URL
3. **Subscribe to events:** check `user.created`
4. Click **Create**
5. Copy the **Signing Secret** (`whsec_...`)
6. Add to `.env.local`:
   ```bash
   CLERK_WEBHOOK_SECRET=whsec_...
   ```
7. Add to Vercel env vars (preview + production):
   ```bash
   vercel env add CLERK_WEBHOOK_SECRET preview
   vercel env add CLERK_WEBHOOK_SECRET production
   ```

> Note: the `/api/webhooks/clerk` route handler does not exist yet — it's GitHub issue #7.
> You can create the Clerk webhook endpoint now so the secret is ready when the route is built.

---

## 4. Vercel — partially done

- [x] Vercel project `evan-school` provisioned and linked to `ThomasGHenry/evan-school`
- [x] Root directory set to `apps/web`
- [x] `DATABASE_URL` set for preview
- [x] `VERCEL_TOKEN` + `VERCEL_PROJECT_ID` set as GitHub secrets (CI can deploy)
- [ ] Add Clerk env vars (see §3c above)
- [ ] Set `DATABASE_URL` for **production** environment

**Vercel project details:**

| | |
|---|---|
| Project ID | `prj_P6mXGqFMgF5OLmFD6JnVytHiERlx` |
| Dashboard | https://vercel.com/thomasghenry/evan-school |
| Repo link | `ThomasGHenry/evan-school`, root `apps/web` |

**Set production `DATABASE_URL`** (use Neon `main` branch connection string):

```bash
vercel env add DATABASE_URL production
# paste the postgresql://... string when prompted
```

---

## 5. GitHub — done

- [x] Branch protection on `main` — requires `Commit Validation` status check to pass before merge
- [x] Environments: `production`, `preview`
- [x] Labels: standard governance set + 8 epic labels
- [x] Secrets: `VERCEL_TOKEN`, `DATABASE_URL_PROD`, `CF_R2_ACCESS_KEY_ID`, `CF_R2_SECRET_ACCESS_KEY`
- [x] Variable: `VERCEL_PROJECT_ID`
- [ ] **`RENOVATE_TOKEN`** — needed for Renovate dependency PRs

### 5a. Create RENOVATE_TOKEN

Renovate auto-creates PRs when dependencies have updates. It needs a PAT to push those PRs.

1. Go to https://github.com/settings/tokens?type=beta (fine-grained PATs)
2. **Generate new token**
   - Resource owner: `ThomasGHenry`
   - Repository access: **Only selected repositories** → `evan-school`
   - Permissions: **Contents** (read + write), **Pull requests** (read + write), **Metadata** (read)
3. Copy the token (`github_pat_...`)
4. Set as GitHub secret:
   ```bash
   env -u GH_TOKEN gh secret set RENOVATE_TOKEN \
     --repo ThomasGHenry/evan-school \
     --body "github_pat_..."
   ```

---

## 6. IaC state — done

- [x] Cloudflare R2 bucket `evan-school-tfstate` holds all Tofu state
- [x] `infra/github/` state: `evan-school-tfstate/github/terraform.tfstate`
- [x] `infra/platform/` state: `evan-school-tfstate/platform/terraform.tfstate`

**If you ever need to re-apply Tofu** (e.g. to change branch protection rules):

```bash
cd infra/github
export AWS_ACCESS_KEY_ID=<from Bitwarden: mde-r2-tofu-state username>
export AWS_SECRET_ACCESS_KEY=<from Bitwarden: mde-r2-tofu-state password>
GH_TOKEN_VAL=$(env -u GH_TOKEN gh auth token)
tofu init
tofu plan -var="github_token=$GH_TOKEN_VAL"
tofu apply -var="github_token=$GH_TOKEN_VAL"
```

---

## 7. End-to-end smoke test — pending

Run this after §3 (Clerk keys in Vercel) and §4 (production DATABASE_URL) are complete.

- [ ] Clerk keys added to Vercel (§3c)
- [ ] Production `DATABASE_URL` set in Vercel (§4)
- [ ] Push any trivial commit to `main`
  ```bash
  git commit --allow-empty -m "chore: smoke test pipeline"
  env -u GH_TOKEN git push
  ```
- [ ] On GitHub → **Actions**: `1-commit.yml` run appears and goes green
- [ ] `Commit Validation` status check shows ✅ on the commit
- [ ] Vercel dashboard shows a new production deployment triggered
- [ ] Visit the production URL — "Evan's Meditation School" heading renders
- [ ] Sign up via Clerk — redirects correctly, `User` row appears in Neon (check via Neon console SQL editor: `SELECT * FROM users;`)

---

## 8. First ticket

Once §7 is green, start with GitHub issue **#3 (Clerk application setup)** — it's already done after §3 above, so close it and move to:

- **#7** — Sync Clerk user to DB (webhook handler `/api/webhooks/clerk`)
- **#2** — Mailchimp subscribe form
- **#5** — Public landing page

---

## Summary: what's left

| Item | Blocks |
|---|---|
| Clerk app + keys in `.env.local` | local dev with auth |
| Clerk keys in Vercel | preview + production sign-in |
| Clerk webhook secret | issue #7 (user sync) |
| Production `DATABASE_URL` in Vercel | production deploys |
| `RENOVATE_TOKEN` GitHub secret | Renovate PRs (non-blocking) |
| Smoke test push | confidence that CI + Vercel pipeline works end-to-end |

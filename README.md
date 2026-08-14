# test

Static two-page demo: sign in with Supabase, then see everyone who has an account and who is currently logged in.

## Files

- `index.html` — login / sign up
- `users.html` — list of users, with online status
- `config.js` — your Supabase URL + anon key
- `supabase.sql` — the only SQL you need to run in Supabase
- `vercel.json` — static deploy config

## Setup

1. In Supabase → SQL Editor, paste and run `supabase.sql`.
2. In Supabase → Authentication → Providers → Email, turn **off** "Confirm email" so test accounts can sign in immediately.
3. Put your project URL and anon key in `config.js` (Project Settings → API).

## Run locally

```bash
python3 -m http.server 3000
```

Open http://localhost:3000

## Deploy to Vercel

```bash
npx vercel deploy --prod
```

No build step, no framework — Vercel serves it as static files. Add your Vercel URL to Supabase → Authentication → URL Configuration → Redirect URLs.

## How "logged in" is decided

Each open page writes `last_seen = now()` every 15 seconds. Anyone whose `last_seen` is within the last 2 minutes shows as **logged in**.

## Note

The anon key is meant to be public — Row Level Security in `supabase.sql` is what protects the data: signed-in users can read the list, but can only update their own row.

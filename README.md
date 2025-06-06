# Status Checker

A simple Flutter web app 👀 that monitors the availability of custom URLs.
Data is stored in Supabase and you can receive outage alerts through a Discord
webhook.

## How it works

1. The Supabase database stores monitored pages (`pages`) and hourly check logs
   (`pages_logs`).
2. The edge function `supabase/functions/status-checker.ts` is triggered by a
   Supabase cron job every five minutes (*/5 * * * *). The current minute is passed via the
   `minute` query parameter so the function can decide how often each page
   should be checked. Results are inserted into `pages_logs` and a Discord
   notification is sent for failing URLs.
3. The companion function `supabase/functions/update_daily_status.ts` runs once
   per day. It aggregates the logs from the previous day into
   `page_daily_status` for both UTC and Prague time zones. When a page was
   healthy the entire day, the logs for that day are deleted to keep the table
   small.
4. The Flutter app loads the daily status from `page_daily_status`. If there is
   no record for today yet, it falls back to the latest entries in `pages_logs`
   to determine the current status.

## User features

- Magic link login using Supabase Auth.
- Add, edit and delete your own URLs for monitoring.
- Overview of the last 30 days including today.
- Public pages visible even without an account.
- Switch between time zones (UTC / Prague) ⏰.
- Light and dark modes 🌙.
- Optional Discord webhook notifications 🔔.

## Local setup

1. Install Flutter 3.2 or newer.
2. Create a `.env` file with variables:
   ```
   EMAIL_REDIRECT_URL=<address to return to after clicking the magic link>
   SUPABASE_URL=<your Supabase project URL>
   SUPABASE_ANON_KEY=<anon key>
   ```
3. Run `make chrome` to pass the variables to Flutter and open the app in your
   browser.

## Build and deployment

- Use `netlify_build.sh` on Netlify. It downloads the Flutter SDK, runs
  `flutter build web` with the required `--dart-define` values and outputs to
  `build/web`.
- Redirects are configured via `netlify.toml`.

## Repository structure

- `lib/` – Flutter app source code.
- `supabase/functions/` – edge functions for checks and daily summaries.
- `makefile` – run local development while loading variables from `.env`.
- `netlify_build.sh` and `netlify.toml` – scripts and settings for Netlify
  deployment.

Created as part of the [Narrativva Labs project](https://labs.narrativva.com).

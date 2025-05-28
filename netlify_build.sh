#!/usr/bin/env bash
set -e

# (Optional) Install Flutter SDK if not present – většinou NENÍ třeba!
if ! command -v flutter &> /dev/null; then
  echo "🔄 Installing Flutter SDK (stable)…"
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git
  export PATH="$PATH:$(pwd)/flutter/bin"
fi

# Precache web artifacts
flutter precache --web

# Install dependencies
flutter pub get --no-precompile

# Generate localization (pokud používáš, jinak smaž)
flutter gen-l10n || true

# Build Flutter web app (všechny env proměnné se propisují přes --dart-define)
flutter build web \
  --dart-define=EMAIL_REDIRECT_URL=$EMAIL_REDIRECT_URL \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY

echo "✅ Flutter web build complete at build/web"

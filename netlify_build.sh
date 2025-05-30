#!/usr/bin/env bash
set -e

# Install Flutter SDK if not present (NEBO ji vždy přepiš, když složka existuje)
if ! command -v flutter &> /dev/null; then
  echo "🔄 Installing Flutter SDK (stable)…"
  # Smaž starou složku, pokud existuje
  rm -rf flutter
  git clone --depth 1 --branch stable https://github.com/flutter/flutter.git
  export PATH="$PATH:$(pwd)/flutter/bin"
else
  echo "✅ Flutter already installed"
fi

# Pokud běžíš build na Netlify, přidej flutter do PATH vždy (i když už je v systému)
export PATH="$PATH:$(pwd)/flutter/bin"

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
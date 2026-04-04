#!/bin/bash
# CarLens release build script
# Loads API keys from .env and passes them via --dart-define

set -e

if [ ! -f .env ]; then
  echo "Error: .env file not found. Copy .env.example and fill in your keys."
  exit 1
fi

# Load .env
export $(grep -v '^#' .env | xargs)

flutter build apk --release \
  --dart-define=GEMINI_API_KEY="$GEMINI_API_KEY" \
  --dart-define=GROQ_API_KEY="$GROQ_API_KEY" \
  --dart-define=TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN" \
  --dart-define=TELEGRAM_CHAT_ID="$TELEGRAM_CHAT_ID"

echo ""
echo "APK built: build/app/outputs/flutter-apk/app-release.apk"

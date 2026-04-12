# CarLens

App Flutter Android per identificazione auto d'epoca tramite AI. Scatto foto → AI riconosce marca/modello/anno → scheda tecnica completa con curiosità e valore di mercato.

## Stack

- **Flutter**: 3.41.5 (stable)
- **Dart**: 3.11.3
- **AI primario**: Gemini 3.1 Flash Lite Preview
- **AI fallback**: Gemini 2.5 Flash Lite → Gemini 2.0 Flash → Groq (Llama 4 Scout)
- **DB locale**: SQLite (sqflite)
- **OCR**: Google ML Kit Text Recognition (VIN)
- **Distribuzione**: APK diretto (beta tester), no Play Store
- **Versione**: 0.13.1+27

## Struttura

```
lib/
  main.dart                     # Entry point, tema, upgrade check
  models/
    car_scan.dart               # Modello CarScan (serializzazione DB)
  services/
    gemini_service.dart         # Integrazione AI (4 tier fallback)
    car_data_service.dart       # Carica/cerca car_models.json (singleton)
    database_service.dart       # SQLite wrapper (schema v4)
    notification_service.dart   # Notifiche giornaliere con curiosità
    telegram_service.dart       # Logging attività utente su Telegram
    url_scraper_service.dart    # Scraping marketplace (Subito, AutoScout24)
  screens/
    home_screen.dart            # Bottom nav (camera, galleria, URL)
    results_screen.dart         # Analisi principale (2557 righe, 2 livelli)
    garage_screen.dart          # Storico scansioni (1541 righe)
    settings_screen.dart        # Impostazioni app
    vin_helper_screen.dart      # Input VIN e decodifica
  utils/
    vin_decoder.dart            # Parser VIN (pre/post 1981, IT e US)
  widgets/                      # (vuoto)
test/                           # ~300 test, ~15 file
assets/
  data/car_models.json          # 400+ auto d'epoca con specifiche
  data/curiosities.json         # 50+ curiosità per notifiche
APK/                            # Archivio build rilasciate
build_apk.sh                    # Script build release (carica .env)
```

## Comandi

```bash
# Test (OBBLIGATORI prima di ogni release)
flutter test

# Analisi codice
flutter analyze

# Build APK release
./build_apk.sh

# Build manuale
flutter build apk --release \
  --dart-define=GEMINI_API_KEY="..." \
  --dart-define=GROQ_API_KEY="..." \
  --dart-define=TELEGRAM_BOT_TOKEN="..." \
  --dart-define=TELEGRAM_CHAT_ID="..."

# Run debug
flutter run
```

## Architettura

### Flusso AI (gemini_service.dart)
1. Immagini → base64 → prompt JSON-only
2. Fallback chain: Gemini 3.1 Flash Lite → 2.5 Flash Lite → 2.0 Flash → Groq Llama 4
3. Risposta: array 1-3 match con confidence (0-1), specifiche, curiosità, valore mercato
4. Parsing: rimozione fence markdown, supporto formato legacy oggetto singolo

### Livelli analisi
- **L1**: Scansione base (marca, modello, anno, confidence)
- **L2**: Analisi completa (motore, trasmissione, peso, dimensioni, numeri produzione, designer, valore mercato, timeline)
- DB/UI tratta come 2 livelli (L3 mergiato in L2 dalla schema v4)

### State management
- StatefulWidget + setState (no Provider/Riverpod/Bloc)
- Servizi singleton (GeminiService, CarDataService, DatabaseService, NotificationService)

### Database
- SQLite schema v4
- Migrazione v3→v4: merge L3 in L2
- Indici su created_at, brand

## Convenzioni

- **Lingua UI**: Italiano hardcoded (no i18n files attualmente)
- **Naming**: _camelCase privati, PascalCase classi, _ALL_CAPS costanti statiche
- **Colori**: Costanti statiche per screen (_bgColor, _textPrimary, _borderColor)
- **Screen pattern**: StatefulWidget → _ScreenNameState
- **Servizi**: Tutti singleton, tutti in services/
- **Test**: Unit test per modelli, servizi, utils. Nessun integration/widget test significativo

## Non modificare

- `.env` — API key Gemini, Groq, Telegram (mai committare)
- `APK/` — Archivio build (solo aggiungere, non eliminare)
- `pubspec.lock` — Auto-generato
- `build/` — Artefatti build
- `.dart_tool/` — Tooling Dart generato
- `android/app/src/main/AndroidManifest.xml` — Permessi platform-specific

## Note critiche

- **Build richiede .env** con GEMINI_API_KEY, GROQ_API_KEY, TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID
- **Signing**: Attualmente usa debug signing anche in release — da aggiornare per produzione
- **Fallback chain è critica**: Se Gemini primario fallisce, il fallback deve funzionare
- **car_models.json**: Caricato all'avvio, permette ricerca offline senza internet
- **VIN decoder**: Supporta pre-1981 (IT e US) e post-1981 (17 caratteri standard)
- **Scraping marketplace**: Rate-limited per evitare blocchi (Subito, AutoScout24)
- **Notifiche**: Curiosità giornaliere da curiosities.json via flutter_local_notifications
- **Update check**: Upgrader controlla appcast su GitHub Gist

<!-- GSD:project-start source:PROJECT.md -->
## Project

**CarLens**

CarLens is a Flutter Android app that identifies classic cars from photos using AI. Users snap a photo of a classic car at a rally, museum, or on the street, and the app returns the make, model, year, full technical specs, fun facts, and estimated market value. It's the Shazam for classic cars — zero competitors exist in this niche.

**Core Value:** A user can photograph any classic car and instantly get an accurate identification with rich technical details and curiosities.

### Constraints

- **Tech stack**: Flutter/Dart — established, not changing
- **AI provider**: Gemini primary with multi-tier fallback — critical reliability requirement
- **Platform**: Android only for now (iOS deferred)
- **Distribution**: APK beta → Play Store launch is the next major milestone
- **API keys**: Currently passed via --dart-define in build script, needs secure storage for production
- **Signing**: Currently using debug signing in release — must fix before Play Store
- **Budget**: Solo developer, no paid services beyond API keys
<!-- GSD:project-end -->

<!-- GSD:stack-start source:research/STACK.md -->
## Technology Stack

## Current Stack (Preserved)
| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.41.5 | UI framework |
| Dart | 3.11.3 | Language |
| sqflite | ^2.4.2 | Local SQLite storage |
| share_plus | ^10.1.4 | Native sharing |
| intl | ^0.20.2 | Date/number formatting |
| shared_preferences | ^2.5.5 | Simple key-value storage |
## Recommended Additions
### Internationalization (i18n)
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| slang | ^4.14.0 | Type-safe i18n with code generation | Compile-time safety catches missing translations. Zero-parsing at runtime (native Dart method calls). JSON/YAML source files. No string-key typos possible. |
| slang_flutter | ^4.14.0 | Flutter integration for slang | Provides BuildContext extensions, locale switching, device locale detection |
| slang_build_runner | ^4.14.0 | Code generation for slang (dev dep) | Generates Dart classes from translation JSON files |
| build_runner | ^2.4.0 | Dart code generation runner (dev dep) | Required by slang for `dart run build_runner build` |
### Secure API Key Storage
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| envied | ^1.3.4 | Compile-time env variable injection with obfuscation | Keys baked into binary at compile time with XOR obfuscation. Not extractable via simple string search of APK. Works with existing `--dart-define` workflow. |
| envied_generator | ^1.3.4 | Code generation for envied (dev dep) | Generates obfuscated Dart code from .env file |
### Firebase Analytics
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| firebase_core | ^4.6.0 | Firebase initialization | Required base dependency for all Firebase services |
| firebase_analytics | ^12.1.3 | Event tracking and user behavior analytics | Industry standard for mobile analytics. Free tier is generous. Integrates with Google Ads if monetization comes later. |
### Theming System
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| (Flutter built-in) | -- | ThemeData + ColorScheme + Material 3 | No external package needed. Flutter's built-in theming is comprehensive and the correct approach. |
- Enable `useMaterial3: true` in ThemeData (modern Material Design)
- Define `ColorScheme.fromSeed()` for light theme, `ColorScheme.fromSeed(brightness: Brightness.dark)` for dark
- Use `Theme.of(context).colorScheme.primary` etc. instead of hardcoded color constants
- Store theme preference in existing `shared_preferences` (already a dependency)
- Use `ThemeMode.system` as default (respects device setting)
### Branded Share Cards (Widget-to-Image)
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| (Flutter built-in) | -- | RepaintBoundary + dart:ui for widget capture | Built-in Flutter capability. Wrap share card widget in RepaintBoundary, capture to image, save to temp file, share via share_plus. |
### Achievement/Gamification System
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| (Custom on SQLite) | -- | Achievement tracking, badge unlocking | CarLens already has SQLite. Achievements are just a table with conditions. No package needed for this scale. |
- SQLite table: `achievements(id, name, description, icon, condition_type, condition_value, unlocked_at)`
- Condition types: `scan_count`, `brand_variety`, `decade_coverage`, `streak_days`, `vin_decoded`
- Check conditions after each scan, unlock and show celebration UI
- Store as JSON in SQLite or as a dedicated table (table preferred for querying)
### Play Store Deployment
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Android Gradle Plugin | 8.x+ | Build system | Required for targetSdk 35 compatibility |
| compileSdk | 35 | Android 15 compilation target | Google Play requirement as of Aug 2025 |
| targetSdk | 35 | Android 15 target API level | Mandatory for new app submissions in 2026 |
| minSdk | 23 | Minimum supported Android version | Covers 99%+ of active devices. Required by flutter_secure_storage if ever added. |
## Supporting Libraries (Already Present, Keep)
| Library | Version | Purpose | Status |
|---------|---------|---------|--------|
| camera | ^0.11.1 | Photo capture | Keep |
| image_picker | ^1.1.2 | Gallery import | Keep |
| http | ^1.2.2 | API calls | Keep |
| share_plus | ^10.1.4 | Native sharing + share cards | Keep |
| path_provider | ^2.1.5 | File system paths | Keep |
| sqflite | ^2.4.2 | Local database | Keep |
| google_mlkit_text_recognition | ^0.14.0 | VIN OCR | Keep |
| upgrader | ^12.5.0 | In-app update check | Keep (may replace with Play Store in-app updates later) |
| flutter_local_notifications | ^21.0.0 | Daily curiosity notifications | Keep |
| shared_preferences | ^2.5.5 | Simple settings storage | Keep (theme preference, locale preference) |
| intl | ^0.20.2 | Date/number formatting | Keep (complements slang) |
## Alternatives Considered
| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| i18n | slang | easy_localization 3.0.8 | No compile-time safety, string-key typos cause runtime errors |
| i18n | slang | flutter_localizations (official) | Too verbose for 2 locales, ARB format is painful for solo dev |
| API key security | envied | flutter_secure_storage 9.2.4 | Runtime storage for compile-time constants is wrong abstraction |
| API key security | envied | raw --dart-define | Keys trivially extractable from binary |
| Analytics | Firebase Analytics | Mixpanel | Unnecessary cost/complexity for pre-revenue app |
| Theming | Built-in ThemeData | flex_color_scheme | Extra dependency for what Flutter provides natively |
| Achievements | Custom SQLite | teqani_rewards | Adds unnecessary abstraction over existing SQLite |
| Share cards | RepaintBoundary | widget_screenshot_plus | 20 lines of built-in code vs. unnecessary dependency |
## New Dependencies Summary
# pubspec.yaml additions
## State Management Note
- **Theme switching** can use `ValueNotifier<ThemeMode>` at the MaterialApp level -- no Provider needed
- **Locale switching** is handled by slang's built-in `LocaleSettings` -- no Provider needed
- **Achievements** are triggered by service calls, not reactive state -- no Provider needed
## Sources
- [Flutter official i18n docs](https://docs.flutter.dev/ui/internationalization)
- [slang on pub.dev](https://pub.dev/packages/slang)
- [slang_flutter on pub.dev](https://pub.dev/packages/slang_flutter)
- [easy_localization on pub.dev](https://pub.dev/packages/easy_localization)
- [flutter_secure_storage on pub.dev](https://pub.dev/packages/flutter_secure_storage)
- [envied on pub.dev](https://pub.dev/packages/envied)
- [How to Store API Keys in Flutter (codewithandrea.com)](https://codewithandrea.com/articles/flutter-api-keys-dart-define-env-files/)
- [firebase_analytics on pub.dev](https://pub.dev/packages/firebase_analytics)
- [firebase_core on pub.dev](https://pub.dev/packages/firebase_core)
- [FlutterFire Analytics docs](https://firebase.flutter.dev/docs/analytics/overview/)
- [Flutter theming cookbook](https://docs.flutter.dev/cookbook/design/themes)
- [Flutter Play Store deployment guide](https://docs.flutter.dev/deployment/android)
- [Google Play target API level requirements](https://developer.android.com/google/play/requirements/target-sdk)
- [Play Store deployment 2026 checklist (dev.to)](https://dev.to/dharanidharan_d_tech/deploy-your-flutter-android-app-to-play-store-in-2026-step-by-step-guide-with-code-gotchas-n2k)
- [Flutter widget-to-image guide (freeCodeCamp)](https://www.freecodecamp.org/news/how-to-save-and-share-flutter-widgets-as-images-a-complete-production-ready-guide/)
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

Conventions not yet established. Will populate as patterns emerge during development.
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

Architecture not yet mapped. Follow existing patterns found in the codebase.
<!-- GSD:architecture-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd:quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd:debug` for investigation and bug fixing
- `/gsd:execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->

<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd:profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->

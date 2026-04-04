# CarLens Feature Roadmap & UX Strategy

**Version**: 1.0
**Date**: 2026-03-27
**Current App Version**: 0.12.1+25
**Platform**: Flutter (Android, direct APK distribution)
**AI Backend**: Gemini 2.0 Flash (primary) + Groq Llama 4 Scout (fallback)

---

## Current State Assessment

### What Exists Today (v0.12.1)
- Single-photo or multi-photo (up to 3) identification via Gemini AI
- URL scraping from marketplace listings (Subito.it, AutoScout24, etc.)
- Results screen with detailed specs, timeline, fun facts, market value range
- VIN decoder with OCR (ML Kit text recognition)
- Originality report generation (VIN vs. specs comparison)
- Digital Garage (local SQLite storage of all scans)
- Share functionality via share_plus
- Minimal, clean Italian UI (light theme only)

### What's Missing (Gap Analysis vs. Competitors)
- No real-time camera experience (current flow: take photo -> wait)
- No social/community features
- No gamification or engagement loops
- No offline capability
- No dark theme
- No push notifications
- No event/calendar integration
- No parts or maintenance data
- Two-tab navigation only (Home, Garage) -- no depth

---

## Architecture Principles

### Information Architecture: Five Pillars

```
CarLens
  |
  +-- IDENTIFY (Core scanning experience)
  |     Photo, Gallery, URL, AR Live Scan
  |
  +-- GARAGE (Personal collection)
  |     My Cars, Wish List, Stats Dashboard
  |
  +-- DISCOVER (Explore & learn)
  |     Car Encyclopedia, Market Trends, Nearby Events
  |
  +-- COMMUNITY (Social features)
  |     Feed, Leaderboards, Challenges
  |
  +-- PROFILE (Settings & achievements)
        Badges, Stats, Preferences, Theme
```

### Navigation Evolution

**Current** (2 tabs): Home | Garage

**Phase 1** (3 tabs): Scan | Garage | Profile

**Phase 2** (4 tabs): Scan | Garage | Discover | Profile

**Phase 3** (5 tabs): Scan | Garage | Discover | Community | Profile

---

## Phase 1: Foundation & Core Excellence (v1.0 - v1.2)
**Timeline**: 4-6 weeks
**Goal**: Make identification best-in-class, add dark theme, improve retention

### 1.1 Enhanced Identification Experience

#### Multi-Angle Scanning Flow
**Technical approach**: Leverage existing multi-image support (already handles up to 3 photos) but add guided UX.

```
User Flow:
1. Tap "Scan" -> Camera opens
2. Take first photo (3/4 front view)
3. Prompt overlay: "Now capture the rear for better accuracy"
4. Take second photo (rear 3/4)
5. Optional: "Capture any badges or interior details"
6. All images sent to Gemini in single request
7. Results screen with higher confidence score
```

**Implementation details**:
- New `ScanFlowScreen` with step indicator (1/3, 2/3, 3/3)
- Camera preview with semi-transparent overlay guide showing ideal car positioning
- Skip button on steps 2 and 3 for quick single-shot identification
- Combine all images in the existing `identifyCar(List<Uint8List>)` call
- Update prompt to describe what each image angle shows

#### Confidence Scoring & Alternative Matches
**Technical approach**: Modify the Gemini prompt to return top-3 matches.

```json
{
  "primary_match": { ... current CarIdentification fields ... },
  "alternatives": [
    {
      "brand": "Lancia",
      "model": "Fulvia Coupe",
      "year_estimate": "1969-1972",
      "confidence": 0.72,
      "why_different": "Headlight shape similar but roofline differs"
    },
    {
      "brand": "Fiat",
      "model": "124 Sport Coupe",
      "year_estimate": "1970-1973",
      "confidence": 0.45,
      "why_different": "Similar era but different grille treatment"
    }
  ]
}
```

**UX**: Results screen shows primary match prominently. Below the main card, a collapsible "Could also be..." section with alternative matches. Tapping an alternative regenerates the detail view for that car.

#### Detail Identification (Engine, Interior, Trim)
**Technical approach**: Add a "Deep Scan" button on the results screen.

```
User Flow:
1. After initial identification -> Results Screen
2. "Deep Scan" button appears
3. Opens camera with prompt: "Photograph the engine bay, interior, or badge details"
4. New Gemini call with context: "This is a [brand] [model] [year]. Identify the specific trim level, engine variant, and any modifications visible."
5. Results overlay on existing card with additional detail tags
```

**New data fields** for CarScan model:
- `trimLevel` (e.g., "GTV 2000", "SS", "Lusso")
- `engineVariant` (e.g., "twin-cam 1600", "V6 2.5L Dino")
- `modifications` (list of detected non-original elements)
- `conditionEstimate` (from visible rust, paint, chrome condition)

### 1.2 Dark Theme & Design System

**CSS Variables approach translated to Flutter**:

```dart
// New: lib/theme/app_theme.dart

class AppColors {
  // Light theme
  static const lightBg = Color(0xFFFAFAF8);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightTextPrimary = Color(0xFF1A1A1A);
  static const lightTextSecondary = Color(0xFF8C8C8C);
  static const lightBorder = Color(0xFFE8E8E6);

  // Dark theme
  static const darkBg = Color(0xFF0D0D0D);
  static const darkSurface = Color(0xFF1A1A1A);
  static const darkTextPrimary = Color(0xFFF5F5F3);
  static const darkTextSecondary = Color(0xFF8C8C8C);
  static const darkBorder = Color(0xFF2A2A28);
}
```

**Implementation**:
- Extract all hardcoded colors from screens into centralized theme
- Add `ThemeMode` support to `MaterialApp` (light/dark/system)
- Store preference in SharedPreferences
- Theme toggle in Profile/Settings screen
- Smooth transition animations on theme switch

### 1.3 Post-Identification Value Cards

Expand the results screen with tabbed sections below the main identification card:

```
[Identification Card - Hero Section]
    Brand / Model / Year / Confidence

[Tab Bar]
  Specs | History | Market | Issues

[Specs Tab]
  Engine, Power, Weight, Transmission
  (already exists, refine layout)

[History Tab]
  Production timeline (already exists)
  Designer info
  Fun fact
  Total produced (rarity indicator)

[Market Tab] -- NEW
  Current value range (already from Gemini)
  Trend indicator (rising/stable/falling)
  "Similar listings nearby" link (future)
  Recent auction results summary

[Issues Tab] -- NEW
  Common problems for this model/year
  Known rust points
  Parts availability rating (1-5)
  Restoration complexity rating (1-5)
```

**Technical approach for Issues tab**:
Add to the Gemini prompt:
```json
{
  "common_issues": [
    "Rust in rear wheel arches and floor pans",
    "Spica fuel injection system reliability",
    "Chrome bumper pitting in humid climates"
  ],
  "parts_availability": 4,
  "restoration_complexity": 3,
  "known_rust_points": ["sills", "rear arches", "boot floor"],
  "specialist_tips": "Check chassis numbers match on both sides of the firewall"
}
```

### 1.4 Garage Improvements

#### Stats Dashboard
Top of Garage screen, above the car list:

```
+-------------------------------------------+
|  MY GARAGE                                |
|                                           |
|  [12]          [8]           [1968]       |
|  Cars Spotted   Brands       Oldest       |
|                                           |
|  [0.89]        [Ferrari]    [3]           |
|  Avg Score      Rarest       This Month   |
+-------------------------------------------+
```

#### Filtering & Sorting
- Sort by: Date added, Brand, Year, Confidence, Rarity
- Filter by: Brand, Decade, Source (camera/URL)
- Search within garage

#### Wish List
New section in Garage: "Cars I Want to Find"
- User adds brand/model pairs manually
- When a scan matches a wish list item, celebratory notification

---

## Phase 2: Engagement & Discovery (v1.3 - v1.6)
**Timeline**: 6-8 weeks after Phase 1
**Goal**: Create daily engagement loops, add educational depth

### 2.1 Achievement System

#### Badge Categories

**Beginner Tier** (first 30 days):
- "First Lens" -- Identify your first car
- "Triple Shot" -- Use multi-angle scanning
- "Time Machine" -- Identify a car older than 1960
- "VIN Detective" -- Decode your first VIN
- "Link Scanner" -- Identify from a marketplace listing
- "Garage Starter" -- Save 5 cars to your garage

**Explorer Tier** (ongoing):
- "Brand Collector: [Brand]" -- Identify 10+ cars of one brand (one badge per brand)
- "Decade Master: [60s/70s/80s]" -- Identify 20+ cars from a specific decade
- "Century Club" -- 100 total identifications
- "Perfect Eye" -- Get 5 identifications with 95%+ confidence
- "World Tour" -- Identify cars from 10+ different countries of origin

**Rare Finds Tier**:
- "Unicorn Hunter" -- Identify a car with under 500 total produced
- "Barn Find" -- Identify a car in poor/unrestored condition
- "Concours Quality" -- Identify a car with 90%+ originality score
- "Million Dollar Eye" -- Identify a car worth over 1M EUR

**Social Tier** (Phase 3):
- "Show Off" -- Share your first identification
- "Community Star" -- Receive 50 likes on shared spots
- "Rally Master" -- Complete 5 weekly challenges

#### Rarity Scoring System

Every identified car gets a Rarity Score (1-10):

```
Rarity Score Calculation:
  Base = log10(total_produced) inverted to 1-10 scale
  Modifiers:
    +1 if pre-1960
    +1 if specific rare trim level
    +1 if limited/special edition
    -1 if mass-produced (100k+)
    +2 if fewer than 100 known survivors
```

Display: Star rating or gem icon on each garage card.

#### Technical Implementation

```dart
// New: lib/models/achievement.dart

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconAsset;
  final AchievementTier tier;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double progress; // 0.0 to 1.0
  final int targetCount;
  final int currentCount;
}

enum AchievementTier { beginner, explorer, rareFind, social }
```

New SQLite table:
```sql
CREATE TABLE achievements (
  id TEXT PRIMARY KEY,
  unlocked_at INTEGER,
  progress REAL DEFAULT 0.0,
  current_count INTEGER DEFAULT 0
);
```

Achievement check runs after every successful scan via `AchievementService.evaluate(CarScan scan)`.

### 2.2 Car Spotting Journal

Transform the Garage from a simple list into a location-aware journal.

**New fields on CarScan**:
- `latitude` / `longitude` (from device GPS at scan time)
- `locationName` (reverse geocoded: "Modena, Italy")
- `notes` (user-added personal notes)
- `tags` (user-defined: "car show", "street spot", "museum", etc.)

**Journal View Modes**:
1. **List** (current, enhanced with location/tags)
2. **Map** (all spots plotted on an embedded map)
3. **Timeline** (chronological scroll with month dividers)
4. **Stats** (aggregated dashboard)

**Technical**: Use `geolocator` package for GPS, `geocoding` for reverse lookup. Store coordinates in SQLite. Map view via `flutter_map` (OpenStreetMap, no API key needed).

### 2.3 Weekly Challenges

Server-free challenge system (challenges defined in bundled JSON, rotated by date):

```json
{
  "challenges": [
    {
      "id": "italian_week",
      "title": "Settimana Italiana",
      "description": "Identifica 5 auto italiane questa settimana",
      "target_count": 5,
      "filter": { "country_of_origin": "Italy" },
      "reward_badge": "italia_master",
      "duration_days": 7
    },
    {
      "id": "muscle_monday",
      "title": "Muscle Monday",
      "description": "Identifica 3 muscle car americane",
      "target_count": 3,
      "filter": { "body_type": "Muscle Car", "country_of_origin": "USA" },
      "reward_badge": "muscle_fan",
      "duration_days": 7
    }
  ]
}
```

**UX**: Banner at top of Scan screen showing current challenge. Progress bar. Completion triggers badge unlock animation.

### 2.4 Car Bingo Cards

For car shows and events -- a printable/digital bingo card:

```
+-----------+-----------+-----------+
| Red       | Pre-1960  | Italian   |
| Sports    | Classic   | Supercar  |
| Car       |           |           |
+-----------+-----------+-----------+
| American  |   FREE    | British   |
| Muscle    |  SPACE    | Roadster  |
+-----------+-----------+-----------+
| Convertible| German   | 4-Door   |
|           | Sports    | Classic   |
+-----------+-----------+-----------+
```

**Implementation**: Generate 3x3 or 4x4 grids from category pool. Each cell becomes "completed" when a scan matches its criteria. Share completed bingo card as image. Themed bingo cards for specific events (e.g., "Ferrari Bingo", "60s Bingo").

### 2.5 Discover Tab (Car Encyclopedia)

New bottom navigation tab: "Discover"

**Sections**:
1. **Car of the Day** -- Rotating featured car with full specs and history (from bundled data + Gemini enrichment)
2. **Brand Explorer** -- Browse by manufacturer, see all models in database
3. **Decade Browser** -- Explore cars by era with historical context
4. **Market Pulse** -- Curated summary of market trends (updated monthly via bundled JSON or remote config)

**Technical**: Expand `car_models.json` with richer data. "Car of the Day" selected deterministically from date hash so all users see the same car.

---

## Phase 3: Community & Social (v2.0 - v2.4)
**Timeline**: 8-12 weeks after Phase 2
**Goal**: Create network effects, user-generated content

### 3.1 Backend Infrastructure Required

Phase 3 requires a backend. Recommended stack:

```
Backend Architecture:
  Cloudflare Workers (consistent with btpoggi-worker)
  + Cloudflare D1 (SQLite at edge)
  + Cloudflare R2 (image storage)
  + Cloudflare KV (session tokens, rate limiting)

Authentication:
  Anonymous accounts with device ID (no email required initially)
  Optional Google Sign-In for cross-device sync

API Endpoints:
  POST /api/spots        -- Share a car spot
  GET  /api/feed         -- Community feed (paginated)
  POST /api/spots/:id/like
  GET  /api/leaderboard  -- Weekly/monthly/all-time
  GET  /api/challenges   -- Server-managed challenges
  GET  /api/user/:id/profile
  PUT  /api/user/me      -- Update display name, avatar
```

### 3.2 Community Feed

**Content**: User-shared car identifications with photo, brand/model, rarity score, location (city-level only for privacy).

**Feed Algorithm** (simple, no ML needed):
1. Recent spots from nearby users (geofenced, 100km radius)
2. High-rarity spots globally
3. Spots from users you follow
4. Challenge completions

**Moderation**: AI-based image validation (reject non-car images using Gemini). Report button. Simple admin dashboard.

### 3.3 Leaderboards

```
Leaderboard Categories:
  - Most Cars Spotted (weekly/monthly/all-time)
  - Rarest Finds (highest cumulative rarity score)
  - Brand Specialists (most cars of a single brand)
  - Challenge Champions (most challenges completed)
  - Streak Kings (longest daily scanning streak)
```

**Privacy**: Users choose a display name. No real names required. City-level location only.

### 3.4 Social Sharing with Branded Overlays

Enhance existing share_plus integration:

```
Share Card Layout:
+----------------------------------+
|  [Car Photo]                     |
|                                  |
|  CARLENS                         |
|  ________________________        |
|                                  |
|  1967 Alfa Romeo GTV 1750       |
|  Rarity: 7/10                   |
|  Confidence: 96%                |
|                                  |
|  Spotted in Modena, IT           |
|  March 27, 2026                  |
+----------------------------------+
```

**Technical**: Use `dart:ui` Canvas to render the share image with branded template overlay. Store as PNG in temp directory, share via share_plus.

---

## Phase 4: Utility & Monetization (v2.5 - v3.0)
**Timeline**: 12-16 weeks after Phase 3
**Goal**: Add practical utility, explore revenue

### 4.1 VIN Decoder Enhancement

Current VIN decoder uses local data + ML Kit OCR. Enhance with:

- **NHTSA API integration** (free, US vehicles): `https://vpic.nhtsa.dot.gov/api/`
- **EU type-approval database** for European vehicles
- **Automatic VIN photo scanning** with camera overlay guide showing where VIN digits should align
- **VIN history check** link-out to services like Carfax/AutoDNA (affiliate potential)

### 4.2 Maintenance Schedule Lookup

**Data source**: Bundled JSON per model with service intervals.

```json
{
  "brand": "Alfa Romeo",
  "model": "GTV",
  "years": "1967-1976",
  "maintenance_schedule": {
    "oil_change": { "interval_km": 5000, "notes": "Use 20W-50 mineral oil" },
    "valve_adjustment": { "interval_km": 10000, "notes": "0.42mm intake, 0.46mm exhaust" },
    "timing_chain": { "interval_km": 50000, "notes": "Duplex chain, tensioner check" },
    "brake_fluid": { "interval_months": 24, "notes": "DOT 4 only" }
  }
}
```

**UX**: Accessible from the results screen and from garage entries. User can set current mileage and get "upcoming service" alerts.

### 4.3 Parts Compatibility

**Approach**: AI-assisted, not a full database.

When viewing a car in the garage, "Find Parts" button triggers a Gemini query:
- "What parts from other models are compatible with a [year] [brand] [model]?"
- Returns cross-reference information (e.g., "The engine is shared with the [other model], brake calipers are the same as [other model]")
- Links out to parts suppliers (affiliate potential)

### 4.4 Event Calendar

**Data sources**:
- Curated list of major events (bundled, updated quarterly)
- User-submitted events (Phase 3 backend required)
- Integration with external APIs if available

**UX**: Calendar view in Discover tab. Filter by distance, type (show, auction, rally, museum). "Going" button for personal calendar. Reminder notifications.

### 4.5 Auction Alerts

**Prerequisite**: User has cars in Wish List.

**Implementation**:
- Background service checks marketplace listing APIs periodically
- When a match is found, local notification: "A 1967 Alfa Romeo GTV just listed on AutoScout24 for EUR 38,000"
- Link opens directly in the app's URL scraper flow

### 4.6 Offline Capabilities

#### Cached Car Database
**Technical approach**:
- Bundle a compressed SQLite database (~5-10MB) with the top 500 most common classic cars
- Include brand, model, years, key specs, distinguishing features, reference images (thumbnails)
- On-device TFLite model for basic make/model classification (no internet needed)
- When offline: use local model for rough identification, queue full Gemini analysis for when back online

#### Offline Queue
```dart
// New: lib/services/offline_queue_service.dart

class OfflineQueueService {
  // Store pending scans when offline
  Future<void> queueScan(String imagePath) async {
    // Save to SQLite queue table
    // When connectivity restored, process queue in order
    // Show badge on scan icon: "2 pending"
  }
}
```

**New SQLite table**:
```sql
CREATE TABLE scan_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  image_path TEXT NOT NULL,
  extra_image_paths TEXT,  -- JSON array
  queued_at INTEGER NOT NULL,
  status TEXT DEFAULT 'pending'  -- pending, processing, completed, failed
);
```

**UX**: When offline, user can still take photos. Toast message: "Photo saved. Will identify when online." Garage shows pending items with a clock icon.

---

## Monetization Strategy

### Free Tier (always)
- 10 scans per day (currently unlimited -- important for cost control)
- Full garage and history
- Basic achievements
- Share functionality
- Offline queue (but not offline identification)

### CarLens Pro (subscription, EUR 2.99/month or EUR 24.99/year)
- Unlimited scans
- Deep Scan (trim level, modifications, condition)
- Originality reports
- Full achievement system
- Offline identification (bundled TFLite model)
- Priority AI model (Gemini 2.5 Pro instead of Flash)
- Export garage to CSV/PDF
- Ad-free experience
- Early access to new features

### One-Time Purchases
- Themed bingo card packs (EUR 0.99 each)
- Premium share card templates (EUR 1.99 pack)

### Affiliate Revenue
- Links to marketplace listings when showing "similar for sale"
- Parts supplier referrals
- Auction house partnerships
- Insurance referrals (Hagerty, etc.)

---

## Technical Architecture Evolution

### Current Architecture
```
lib/
  main.dart
  models/
    car_scan.dart
  screens/
    home_screen.dart
    results_screen.dart
    garage_screen.dart
    vin_helper_screen.dart
  services/
    gemini_service.dart
    database_service.dart
    car_data_service.dart
    url_scraper_service.dart
    telegram_service.dart
  utils/
    vin_decoder.dart
```

### Target Architecture (Phase 2+)
```
lib/
  main.dart
  app.dart                          # MaterialApp with theme management
  theme/
    app_theme.dart                  # Light/dark theme definitions
    app_colors.dart                 # Color constants
    app_typography.dart             # Text style definitions
  models/
    car_scan.dart                   # Enhanced with location, tags, trim
    achievement.dart                # Achievement definitions
    challenge.dart                  # Weekly challenge model
    bingo_card.dart                 # Bingo card model
    user_profile.dart               # Local user profile
  screens/
    scan/
      scan_screen.dart              # Main scan tab
      scan_flow_screen.dart         # Multi-angle guided flow
      camera_overlay_screen.dart    # AR-lite camera overlay
    results/
      results_screen.dart           # Enhanced with tabs
      deep_scan_screen.dart         # Detailed analysis
      alternative_matches.dart      # "Could also be" section
    garage/
      garage_screen.dart            # Enhanced with views
      garage_map_view.dart          # Map of spotted cars
      garage_stats_view.dart        # Stats dashboard
      car_detail_screen.dart        # Single car deep view
      wish_list_screen.dart         # Cars I want to find
    discover/
      discover_screen.dart          # Discover tab
      car_of_the_day.dart           # Daily featured car
      brand_explorer_screen.dart    # Browse by brand
      event_calendar_screen.dart    # Car events
    profile/
      profile_screen.dart           # Settings & achievements
      achievements_screen.dart      # Full badge gallery
      settings_screen.dart          # Theme, notifications, etc.
    community/                      # Phase 3
      feed_screen.dart
      leaderboard_screen.dart
    vin/
      vin_helper_screen.dart        # Existing, enhanced
  services/
    gemini_service.dart             # Enhanced prompts
    database_service.dart           # More tables
    car_data_service.dart           # Richer data
    url_scraper_service.dart        # Existing
    telegram_service.dart           # Existing
    achievement_service.dart        # Badge evaluation
    challenge_service.dart          # Weekly challenges
    location_service.dart           # GPS + geocoding
    offline_queue_service.dart      # Offline scan queue
    share_card_service.dart         # Branded image generation
    theme_service.dart              # Theme persistence
    analytics_service.dart          # Usage tracking
  utils/
    vin_decoder.dart                # Existing
    rarity_calculator.dart          # Rarity score logic
    date_utils.dart                 # Challenge date math
  widgets/
    scan_button.dart                # Reusable scan action
    car_card.dart                   # Reusable car display card
    stat_tile.dart                  # Stats dashboard tile
    badge_widget.dart               # Achievement badge display
    rarity_indicator.dart           # Star/gem rarity display
    confidence_bar.dart             # Confidence visualization
    theme_toggle.dart               # Light/dark/system toggle
```

### State Management Evolution

**Current**: Direct setState, no state management library.

**Recommended for Phase 2+**: `provider` or `riverpod` for:
- Theme state (light/dark/system)
- Achievement state (unlocked badges, progress)
- Garage filters/sort state
- Challenge progress
- Online/offline state
- Scan queue state

### Database Schema Evolution

```sql
-- v4: Add location support
ALTER TABLE scans ADD COLUMN latitude REAL;
ALTER TABLE scans ADD COLUMN longitude REAL;
ALTER TABLE scans ADD COLUMN location_name TEXT;
ALTER TABLE scans ADD COLUMN notes TEXT;
ALTER TABLE scans ADD COLUMN tags TEXT;  -- JSON array
ALTER TABLE scans ADD COLUMN trim_level TEXT;
ALTER TABLE scans ADD COLUMN rarity_score INTEGER;

-- v5: Achievements
CREATE TABLE achievements (
  id TEXT PRIMARY KEY,
  unlocked_at INTEGER,
  progress REAL DEFAULT 0.0,
  current_count INTEGER DEFAULT 0
);

-- v6: Scan queue
CREATE TABLE scan_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  image_path TEXT NOT NULL,
  extra_image_paths TEXT,
  queued_at INTEGER NOT NULL,
  status TEXT DEFAULT 'pending'
);

-- v7: Wish list
CREATE TABLE wish_list (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  brand TEXT NOT NULL,
  model TEXT,
  notes TEXT,
  created_at INTEGER NOT NULL
);

-- v8: Challenges
CREATE TABLE challenge_progress (
  challenge_id TEXT PRIMARY KEY,
  started_at INTEGER NOT NULL,
  current_count INTEGER DEFAULT 0,
  completed_at INTEGER
);

-- v9: User profile
CREATE TABLE user_profile (
  key TEXT PRIMARY KEY,
  value TEXT
);
```

---

## User Journey Maps

### Journey 1: First-Time User (Day 1)

```
1. Opens app -> Clean CARLENS splash
2. Sees scan screen with camera button
3. Spots a classic Fiat 500 on the street
4. Takes photo -> Loading animation with car silhouette
5. Results: "Fiat 500 L (1968-1972)" with 94% confidence
6. Scrolls through specs, history, fun fact
7. "Save to Garage" -> First save
8. Achievement unlocked: "First Lens!" (subtle animation)
9. Checks Garage tab -> Sees their first car with stats
10. Comes back tomorrow to scan another car
```

**Retention hook**: Achievement unlock creates positive first impression. Stats counter ("1 car spotted") creates collection impulse.

### Journey 2: Car Show Visitor (Event Day)

```
1. Opens app at car show
2. Sees banner: "Car Show Mode: Start Bingo Challenge"
3. Taps to activate bingo card
4. Walks through show, scanning cars
5. Each scan auto-checks bingo card cells
6. Mid-show notification: "3 more to complete your card!"
7. Completes bingo -> Achievement + shareable completion image
8. Shares to WhatsApp group with car club friends
9. Has 15 new cars in garage from the event
10. Reviews collection at home, adds notes and tags
```

**Retention hook**: Event-specific engagement. Shareable moment. Rich post-event content to review.

### Journey 3: Marketplace Buyer (Purchase Research)

```
1. Sees a 1973 Alfa Romeo GTV on Subito.it
2. Copies listing URL
3. Opens CarLens -> Paste Link
4. Gets full identification + specs + market value range
5. Notices asking price is above market value
6. Checks "Common Issues" tab -> Learns about rust points
7. Saves to garage with "Considering purchase" tag
8. Later, decodes VIN from listing photos
9. Originality report shows non-matching engine
10. Decides to negotiate lower price based on findings
```

**Retention hook**: Practical utility creates habitual use during car shopping. VIN + originality features add unique value no competitor offers.

### Journey 4: Daily Enthusiast (Week 2+)

```
1. Opens app -> Sees "Weekly Challenge: German Engineering"
2. Challenge: Identify 5 German classics this week (2/5 done)
3. Walking to work, spots a Mercedes W123
4. Quick scan -> Identified, challenge progress 3/5
5. Checks Discover tab -> Today's car: Lancia Stratos
6. Reads history, adds to Wish List
7. Checks achievements -> Close to "Decade Master: 70s"
8. Motivated to find more 70s cars
9. End of week: Challenge completed -> New badge
10. Checks leaderboard position -> Top 50 this week
```

**Retention hook**: Daily content (Car of the Day). Weekly goal (challenges). Long-term progression (achievements + leaderboard).

---

## Key Performance Indicators

### Engagement Metrics
- **DAU/MAU ratio**: Target 25%+ (strong for utility apps)
- **Scans per session**: Target 2.5+ (currently likely ~1)
- **Session length**: Target 3+ minutes (currently likely <1 min)
- **Day 7 retention**: Target 30%+ (industry avg for tools: 15-20%)
- **Day 30 retention**: Target 20%+ (industry avg: 8-12%)

### Feature Adoption
- Multi-angle scan usage: Target 40% of scans
- VIN decode rate: Target 15% of saved cars
- Share rate: Target 10% of identifications
- Challenge participation: Target 30% of weekly actives
- Dark theme adoption: Target 35% of users

### Quality Metrics
- Identification accuracy (user-reported): Target 90%+
- Average confidence score: Target 0.85+
- Crash-free sessions: Target 99.5%+
- API response time (p95): Target <5 seconds

---

## Risk Assessment & Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Gemini API cost growth | High | High | Daily scan limits, efficient prompt design, TFLite fallback for common cars |
| Low Day-7 retention | High | Medium | Achievement system, push notifications, Car of the Day |
| AI hallucination on specs | Medium | Medium | Cross-reference with bundled car_models.json, let users report errors |
| Offline TFLite model accuracy | Medium | Medium | Limit offline to top 500 cars, clearly label as "preliminary" |
| Community moderation burden | Medium | Low | AI image validation, user reporting, start invite-only |
| Competitor copies features | Low | Medium | Speed of execution, community lock-in, unique originality reports |

---

## Priority Matrix

### Must Have (Phase 1)
- Multi-angle scanning flow
- Confidence scoring with alternatives
- Dark theme with system toggle
- Garage stats dashboard
- Common issues / problems tab on results

### Should Have (Phase 2)
- Achievement system (badges)
- Car spotting journal with location
- Weekly challenges
- Discover tab with Car of the Day
- Rarity scoring

### Could Have (Phase 3)
- Community feed
- Leaderboards
- Car bingo cards
- Branded share cards
- Event calendar

### Won't Have (Deferred)
- Real-time AR overlay (technically complex, battery drain, marginal UX benefit for identification use case -- reconsider when ARCore/ARKit Flutter plugins mature)
- Parts marketplace (too complex, better as link-outs)
- Full maintenance tracking (out of scope, many existing apps do this)
- Live auction bidding (legal/financial complexity)

---

## Implementation Order (Recommended)

```
Week 1-2:   Dark theme + design system extraction
Week 3-4:   Multi-angle scan flow + alternative matches
Week 5-6:   Results screen tabs (Issues, enhanced Market)
Week 7-8:   Garage stats + filtering + wish list
Week 9-10:  Achievement system foundation (10 initial badges)
Week 11-12: Car spotting journal (GPS + notes + tags)
Week 13-14: Weekly challenges + rarity scoring
Week 15-16: Discover tab + Car of the Day
Week 17-20: Branded share cards + bingo cards
Week 21-24: Community backend + feed (alpha)
Week 25-28: Leaderboards + social features
Week 29-32: Offline capabilities + TFLite model
```

---

**ArchitectUX Assessment**: CarLens has a strong identification core that already surpasses most competitors in depth (specs, timeline, fun facts, market value, VIN decoding, originality reports). The primary gap is engagement architecture -- there is no reason for users to return after their initial novelty scans. The achievement system and weekly challenges are the highest-impact additions for retention. The community features should be deferred until the single-player experience is proven sticky.

**Next Steps**: Begin with Phase 1.2 (dark theme extraction) as it touches every screen and establishes the design system foundation that all subsequent features build upon.

# Flutter SDK & Applications - AI Coding Agent Guide

## Project Overview

This workspace contains the **official Flutter SDK** repository and multiple Flutter applications:
- `flutter/` - Flutter SDK source (channels, tools, engine bindings)
- `my_app/` - Basic Flutter demo application
- `yeni_uygulama/` - Menstrual cycle tracker application (production example)

## Essential Architecture & Data Flow

### Flutter SDK Structure
- **bin/** - Command-line tools (flutter, dart executables)
- **packages/** - Core framework packages (flutter, flutter_test, flutter_tools, etc.)
- **engine/** - Native engine bindings and scripts
- **dev/** - Development tooling, tests, benchmarks
- **docs/** - Documentation and architecture guides

### Application Structure Pattern
Each Flutter app follows this standard layout:
```
lib/
  ├── main.dart          # App entry point & theme setup
  ├── screens/           # Page widgets (should stateful when needed)
  └── models/            # Data models & business logic

pubspec.yaml            # Dependencies, assets, versioning
```

## Critical Developer Workflows

### 1. Build & Run Commands
```powershell
# Flutter setup verification
flutter doctor

# Create new project
flutter create <app_name>

# Run app (interactive device selection)
flutter run

# Run on specific platform
flutter run -d windows          # Windows desktop
flutter run -d chrome           # Web browser
flutter run -d android          # Android emulator/device
flutter run -d ios              # iOS simulator

# Hot reload (quick iteration without state loss)
# Press 'r' in terminal during flutter run

# Hot restart (full app restart with state reset)
# Press 'R' in terminal during flutter run

# Build for distribution
flutter build windows           # .exe executable
flutter build web              # Static web assets
flutter build apk              # Android package
```

### 2. Dependency Management
```powershell
# Get dependencies
flutter pub get

# Add package
flutter pub add <package_name>

# Check for outdated packages
flutter pub outdated

# Update dependencies
flutter pub upgrade
```

### 3. Testing & Quality
```powershell
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Analysis & linting
flutter analyze
```

## Project-Specific Patterns & Conventions

### State Management
- **Simple apps**: Use `StatefulWidget` with `setState()` (as in `yeni_uygulama`)
- Persist app state via `SharedPreferences` - load in `initState()`, save after mutations
- Example pattern in [yeni_uygulama/lib/main.dart](yeni_uygulama/lib/main.dart#L65):
  ```dart
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // Load scalar values: getInt(), getString()
    // Load lists: getStringList() then parse if needed
    setState(() { /* update state */ });
  }
  
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // Save with setInt(), setString(), setStringList()
  }
  ```
- **Complex apps**: Consider Provider, Riverpod, or Bloc patterns

### Localization (L10n)
- Apps support multiple languages via ARB files in `lib/l10n/`
- Generate localizations: `flutter gen-l10n` (auto-generates `lib/gen_l10n/app_localizations.dart`)
- Access strings: `AppLocalizations.of(context)!.propertyName`
- Configuration in `l10n.yaml` specifies template language (en) and output class

#### ARB File Structure (Application Resource Bundle)
Template file: `lib/l10n/app_en.arb` (English as base)
```json
{
  "@@locale": "en",
  "appTitle": "Period Cycle Tracker",
  "calendar": "Calendar (predicted cycles)",
  "save": "Save",
  "mood": "Mood"
}
```

Translation file: `lib/l10n/app_tr.arb` (Turkish)
```json
{
  "@@locale": "tr",
  "appTitle": "Adet Takip",
  "calendar": "Takvim (tahmini döngüler)",
  "save": "Kaydet",
  "mood": "Ruh Hali"
}
```

#### l10n.yaml Configuration
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-dir: lib/gen_l10n
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

#### Usage in Code
```dart
// In main.dart MaterialApp:
localizationsDelegates: AppLocalizations.localizationsDelegates,
supportedLocales: AppLocalizations.supportedLocales,

// In widgets:
final l10n = AppLocalizations.of(context)!;
Text(l10n.appTitle);
Text('${l10n.save}');  // String interpolation
```

#### Supported Languages in yeni_uygulama
- `app_tr.arb` - Turkish (Türkçe)
- `app_en.arb` - English
- `app_de.arb` - German (Deutsch)
- `app_es.arb` - Spanish (Español)
- `app_fr.arb` - French (Français)

### UI Components (Material Design 3)
```dart
// Theme with custom color seed (see main.dart patterns)
colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),  // or Colors.deepPurple
useMaterial3: true,  // Enable Material Design 3

// Common widgets used
Scaffold, AppBar, FloatingActionButton, Card, ListView, Column/Row
TextField, ElevatedButton, showDatePicker(), showSnackBar()
```

### Date Handling Pattern
- Use `showDatePicker()` for user selection (with `initialDate`, `firstDate`, `lastDate`)
- Normalize dates: `DateTime(d.year, d.month, d.day)` to compare day-only
- Store in SharedPreferences: `d.millisecondsSinceEpoch` → deserialize via `DateTime.fromMillisecondsSinceEpoch()`
- Format for display: `DateFormat` from `intl` package with locale support

### Navigation Pattern
- Single-page apps: Use `Scaffold` with bottom/drawer navigation
- Multi-screen: Use explicit import of screen widgets, pass data via constructor parameters
- Multi-page: Use `Navigator` or `GoRouter` package

### Advanced UI Patterns

#### TableCalendar Customization (from yeni_uygulama)
Custom calendar with predicted dates and interactive selection:
```dart
TableCalendar(
  firstDay: DateTime.utc(2020, 1, 1),
  lastDay: DateTime.utc(2030, 12, 31),
  focusedDay: _selectedDate ?? DateTime.now(),
  selectedDayPredicate: (day) => _isSameDay(day, _selectedDate),
  calendarBuilders: CalendarBuilders(
    markerBuilder: (context, date, events) {
      final isPredicted = _predictedDatesSet.contains(_normalize(date));
      if (isPredicted) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.pink,
              shape: BoxShape.circle,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    },
  ),
  onDaySelected: (selectedDay, focusedDay) {
    setState(() { _selectedDate = selectedDay; });
    _savePreferences();
  },
  calendarStyle: CalendarStyle(
    todayDecoration: BoxDecoration(
      color: Colors.pink.shade200,
      shape: BoxShape.circle,
    ),
    selectedDecoration: BoxDecoration(
      color: Colors.pink,
      shape: BoxShape.circle,
    ),
  ),
)
```

#### Stack with Full-Screen Background
Use `Positioned.fill` for full-screen background images:
```dart
Stack(
  children: [
    Positioned.fill(
      child: Image.asset(
        'assets/login_bg.png',
        fit: BoxFit.cover,
      ),
    ),
    Center(
      child: Text('Content', style: TextStyle(color: Colors.white)),
    ),
  ],
)
```

#### Horizontal Scrollable Button Row
For mood/option selection with dynamic state:
```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: moods.map((mood) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() { _selectedMood = mood; });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedMood == mood 
            ? Colors.orange 
            : Colors.grey[300],
        ),
        child: Text(mood),
      ),
    )).toList(),
  ),
)
```

#### GestureDetector for Custom Tap Areas
```dart
GestureDetector(
  onTap: _selectDate,
  child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.pink),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(_selectedDate != null ? formatDate(_selectedDate!) : 'Select Date'),
  ),
)
```

#### Card-Based Layout in ListView
```dart
ListView(
  children: [
    Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [/* content */],
        ),
      ),
    ),
    const SizedBox(height: 12),  // Spacing between cards
    Card(/* next section */),
  ],
)
```

## Integration Points & Dependencies

### Core Dependencies (in pubspec.yaml)
```yaml
flutter:
  sdk: flutter

cupertino_icons: ^1.0.0      # iOS-style icons
# Add packages with: flutter pub add <name>
```

### Production App Dependencies (yeni_uygulama example)
```yaml
dependencies:
  flutter_localizations:       # Multi-language support
    sdk: flutter
  shared_preferences: ^2.2.0   # Local data persistence
  table_calendar: ^3.0.9       # Interactive calendar widget
  intl: ^0.20.0                # Date formatting & localization

dev_dependencies:
  flutter_launcher_icons: ^0.13.1  # Generate app icons
  flutter_lints: ^6.0.0            # Code quality rules

flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icon/app_icon.png"
  min_sdk_android: 21

flutter:
  uses-material-design: true
  assets:
    - assets/login_bg.png
    - assets/icon/app_icon.png
```

### Asset Management
- Place assets in `assets/` directory with subdirectories (e.g., `assets/icon/`)
- Always declare in `pubspec.yaml` under `flutter: assets:`
- Access via `Image.asset('assets/filename.png')`
- Use `flutter_launcher_icons` package to auto-generate platform-specific icons
- Run `flutter pub run flutter_launcher_icons` after configuring

### Platform-Specific Code
- **Android**: `android/app/build.gradle.kts` for SDK/API config
- **iOS**: `ios/Runner/` for native integration
- **Windows**: `windows/` for Win32 integration
- **Web**: `web/index.html` for web entry

### Android Configuration Details

#### build.gradle.kts Structure
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app_name"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true  // For older Android APIs
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.app_name"
        minSdk = flutter.minSdkVersion        // Typically 21+
        targetSdk = flutter.targetSdkVersion  // Latest recommended
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")  // Change for production
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

#### Key Android Settings
- **Java 17 Required**: Both `sourceCompatibility` and `targetCompatibility`
- **Desugaring**: Enables modern Java APIs on older Android versions
- **applicationId**: Must be unique (reverse domain notation)
- **minSdk 21**: Android 5.0+ (Lollipop) - common minimum
- **Signing**: Change `signingConfig` for production releases

## Building for Different Targets

### Prerequisites for Each Platform
- **Android**: Android SDK 36+, Java 21+ (winget install Oracle.JDK.21)
- **iOS**: macOS + Xcode (macOS only)
- **Web**: Chrome required (already installed)
- **Windows**: Visual Studio Build Tools (already present)

### Common Build Errors & Solutions
1. **"Android SDK 36 required"** → Run: `sdkmanager "platforms;android-36" "build-tools;36.0.0"`
2. **"Chrome not found"** → Install via: `winget install Google.Chrome`
3. **Pub dependencies issue** → Run: `flutter pub get` or `flutter pub upgrade`

## Hot Reload vs Hot Restart
- **Hot Reload** (r): Changes code without resetting state - fast iteration
- **Hot Restart** (R): Full app restart, resets all state - use after const/global changes

## Dart Language Specifics
- **Null safety** enforced - use `?` for nullable types, `!` to assert non-null
- **async/await** for async operations (not callbacks)
- **late** keyword for late initialization of TextEditingControllers and similar
- **extension** methods for adding functionality to existing classes
- DateTime operations: normalize dates to midnight with `DateTime(d.year, d.month, d.day)` for day-level comparisons
- Silent error handling: Use try/catch with empty catch blocks for non-critical SharedPreferences operations

## Common Patterns in This Codebase

### Error Handling Pattern
```dart
// Silently handle non-critical errors (SharedPreferences, date picker cancellation)
try {
  // operation that might fail
} catch (e) {
  // ignore errors silently - user will see validation or empty state instead
}

// For user-facing errors, show SnackBar
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(l10n.errorMessage)),
);
```

### TextEditingController Lifecycle
- Allocate in `initState()` with initial value
- Always call `.dispose()` in `dispose()` method
- Use `late` keyword for declaration to avoid null checks

### Mathematical Calculation Patterns

#### List Reduce for Statistics
```dart
// Calculate average from list
double _getAverageCycleLength() {
  if (_cycleDates.length < 2) return _cycleLength.toDouble();
  List<int> lengths = [];
  for (int i = 0; i < _cycleDates.length - 1; i++) {
    lengths.add(_cycleDates[i + 1].difference(_cycleDates[i]).inDays);
  }
  return lengths.isEmpty 
    ? _cycleLength.toDouble() 
    : lengths.reduce((a, b) => a + b) / lengths.length;
}

// Find min/max variation
int _getCycleVariation() {
  if (_cycleDates.length < 2) return 0;
  List<int> lengths = [];
  for (int i = 0; i < _cycleDates.length - 1; i++) {
    lengths.add(_cycleDates[i + 1].difference(_cycleDates[i]).inDays);
  }
  if (lengths.isEmpty) return 0;
  int maxLen = lengths.reduce((a, b) => a > b ? a : b);
  int minLen = lengths.reduce((a, b) => a < b ? a : b);
  return maxLen - minLen;
}
```

#### Date Difference Calculations
```dart
// Calculate days between dates
int daysBetween = date2.difference(date1).inDays;

// Add duration to date
DateTime nextCycle = startDate.add(Duration(days: cycleLength));

// Generate predicted dates set
Set<DateTime> get _predictedDatesSet {
  final Set<DateTime> s = {};
  if (_selectedDate == null) return s;
  var d = _normalize(_selectedDate!);
  for (int i = 0; i < 12; i++) {
    d = d.add(Duration(days: _cycleLength));
    s.add(d);
  }
  return s;
}
```

#### Map Operations for Key-Value Storage
```dart
// Store notes/mood by date key
final Map<String, String> _cycleNotes = {};  // dateStr -> notes
final Map<String, String> _cycleMood = {};   // dateStr -> mood

// Generate date key
final key = DateFormat('yyyy-MM-dd').format(_selectedDate!);
_cycleNotes[key] = noteText;

// Iterate and save to SharedPreferences
await prefs.setStringList('cycleNotesKeys', _cycleNotes.keys.toList());
for (var key in _cycleNotes.keys) {
  await prefs.setString('cycleNote_$key', _cycleNotes[key] ?? '');
}
```

## File Organization Rules

### DO:
- Keep widget files focused and small (<300 lines)
- Use descriptive names (e.g., `menstrual_cycle_tracker.dart` not `app.dart`)
- Separate business logic from UI (models in separate files)

### DON'T:
- Put all code in `main.dart`
- Mix stateless and complex stateful logic in one widget
- Hardcode values - use constants or config files

## Debugging Tips

### IDE Integration (VS Code)
- Set breakpoints by clicking line number
- Use Debug Console to inspect variables
- Flutter DevTools: `http://127.0.0.1:<port>/devtools/`

### Terminal Debugging
```powershell
# Verbose output
flutter run -v

# Profile mode (performance testing)
flutter run --profile

# Release mode (optimized, no debugging)
flutter run --release
```

## Common Workflow for New Features

1. **Create feature branch**: No formal Git workflow specified - add if needed
2. **Edit lib/main.dart or new feature file**
3. **Use hot reload** (press 'r') to test changes instantly
4. **Run `flutter analyze`** to check code quality
5. **Test on multiple devices**: `flutter run -d <device>`
6. **Build for release**: `flutter build <platform>`

## Quick Start for Contributors

```powershell
# Setup
flutter doctor           # Verify environment
flutter pub get          # Install dependencies

# Development iteration
flutter run -d windows   # Start with hot reload enabled
# Edit files, press 'r' to reload, repeat

# Before committing
flutter analyze          # Check for issues
flutter test             # Run tests
flutter build windows    # Test build process
```

## Key Resources
- Official docs: https://docs.flutter.dev/
- API reference: https://api.flutter.dev/
- Widget catalog: https://flutter.dev/docs/development/ui/widgets
- YouTube channel: https://www.youtube.com/c/flutterdev

---

**Last Updated**: 2026-02-06  
**Environment**: Flutter 3.38.9, Dart 3.10.8, Windows 11  
**Apps in Workspace**: my_app (demo), yeni_uygulama (menstrual cycle tracker - production)
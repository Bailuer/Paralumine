# Paralumine

**AI-powered photography assistant** — analyze any photo and get step-by-step guidance to recreate the look. Built with Flutter and Google Gemini.

---

## Features

- **Smart photo analysis** — Upload or capture a photo; the app analyzes lighting, composition, and style.
- **Camera settings suggestions** — Aperture, shutter speed, ISO, and white balance tailored to the shot.
- **Lighting breakdown** — Recognizes setups (e.g. Rembrandt, loop, high key) and suggests how to replicate them.
- **Composition & position** — Camera height, distance, and angle recommendations.
- **Pro mode** — Deeper analysis: color temperature, sharpness, and post-processing tips.
- **Offline-friendly** — Cached results when Gemini API is unavailable.

## Screenshots

_Add screenshots of the app here (e.g. home, analysis result, comparison view)._

---

## Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (SDK ^3.10.0)
- A [Gemini API key](https://makersuite.google.com/app/apikey) (free tier available)

## Getting Started

### 1. Clone and install

```bash
git clone https://github.com/Bailuer/paralumine.git
cd paralumine
flutter pub get
```

### 2. Configure Gemini API key

1. Get an API key from [Google AI Studio](https://makersuite.google.com/app/apikey).
2. Open `lib/config/api_config.dart` and replace the placeholder:

```dart
static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

**Do not commit your real API key.** Use the placeholder in the repo and set your key locally.

### 3. Run the app

```bash
flutter run
```

Supported platforms: **iOS**, **Android**, **macOS**, **Windows**, **Linux**, **Web**.

---

## Project structure

```
lib/
├── config/          # API and app config (e.g. api_config.dart)
├── models/           # Data models (e.g. photo analysis)
├── providers/        # State (e.g. analysis_provider)
├── screens/          # Main UI (home, analysis, comparison)
├── services/         # Gemini and analysis logic
└── widgets/          # Reusable UI components
```

## Tech stack

- **Flutter** — Cross-platform UI
- **Provider** — State management
- **Google Generative AI (Gemini)** — Image analysis
- **image_picker / camera** — Photo input

## Documentation

- [Gemini API setup & features](SETUP_GEMINI.md) — Detailed setup, capabilities, and troubleshooting.

## License

This project is not yet licensed. Add a LICENSE file and a line here (e.g. MIT, Apache 2.0) when you decide.

---

_Paralumine — Recreate the photos you love._

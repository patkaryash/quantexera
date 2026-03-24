# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Quantexera is a monorepo containing multiple applications for a hackathon project:

- **backend/** - Node.js Express API server
- **mobile_app/** - Flutter mobile application (boilerplate)
- **smart_civic/** - SmartCivic Flutter authentication UI

## Common Commands

### Backend (Node.js/Express)

```bash
cd quantexera/backend
npm install              # Install dependencies
npm run dev              # Start dev server with nodemon (hot reload)
npm start                # Start production server
```

Backend runs on Express 5 with PostgreSQL (pg), JWT auth (jsonwebtoken, bcryptjs), Socket.io for real-time, and dotenv for config.

### Flutter Apps (mobile_app, smart_civic)

```bash
cd quantexera/smart_civic  # or mobile_app
flutter pub get            # Install dependencies
flutter run                # Run on connected device/emulator
flutter analyze            # Static analysis
flutter test               # Run tests
flutter test test/widget_test.dart  # Run single test file
```

## Architecture

### smart_civic (SmartCivic App)

Authentication UI with indigo/blue civic-tech theme using Material 3.

```
lib/
├── main.dart              # App entry, theme config, MaterialApp
├── screens/
│   ├── login_screen.dart  # Login with email/password validation
│   └── signup_screen.dart # Signup with password confirmation
└── widgets/
    ├── custom_button.dart     # Reusable button with loading state
    └── custom_text_field.dart # Reusable form field with validation
```

Navigation uses `Navigator.push/pop` (no routing libraries). Form validation is built-in with `TextFormField` validators. State is managed via `setState` (no Provider/Bloc).

### backend

Express 5 API with:
- PostgreSQL database connection (pg)
- JWT-based authentication (jsonwebtoken + bcryptjs)
- Real-time communication (socket.io)
- CORS enabled

Environment config via `.env` file.

## Conventions

- Flutter: Material 3 with ColorScheme.fromSeed, 12px border radius on inputs/buttons
- Backend: CommonJS modules, nodemon for development
- Both Flutter apps use Dart SDK ^3.11.3

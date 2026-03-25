# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

SmartCivic is a Municipal Workforce Management System containing:

- **backend/** - Node.js Express API server with PostgreSQL
- **smart_civic/** - Flutter cross-platform mobile application

## Common Commands

### Backend (Node.js/Express)

```bash
cd quantexera/backend
npm install              # Install dependencies
npm run dev              # Start dev server with nodemon (hot reload)
npm start                # Start production server
```

Backend runs on **Express 4.21.2** with PostgreSQL (pg 8.13.1), JWT auth (jsonwebtoken), bcryptjs for password hashing, Socket.io for real-time, and dotenv for config.

### Flutter App (smart_civic)

```bash
cd quantexera/smart_civic
flutter pub get            # Install dependencies
flutter run                # Run on connected device/emulator
flutter analyze            # Static analysis
flutter test               # Run tests
flutter build apk          # Build Android APK
```

## Architecture

### Backend Structure

```
backend/
├── app.js                    # Express app setup, middleware, route mounting
├── server.js                 # HTTP server entry point, DB connection
└── src/
    ├── config/
    │   └── db.js             # PostgreSQL connection pool
    ├── controllers/
    │   ├── alertController.js
    │   ├── attendanceController.js
    │   ├── authController.js
    │   ├── locationController.js
    │   ├── taskController.js
    │   └── workerController.js
    ├── middleware/
    │   ├── authMiddleware.js    # JWT verification (verifyToken)
    │   └── roleMiddleware.js    # Role-based access (requireAdmin, requireWorker)
    ├── routes/
    │   ├── alertRoutes.js
    │   ├── attendanceRoutes.js
    │   ├── authRoutes.js
    │   ├── locationRoutes.js
    │   ├── taskRoutes.js
    │   └── workerRoutes.js
    ├── services/
    │   ├── alertService.js      # Automated alert creation
    │   └── geofenceService.js   # Point-in-polygon ray-casting algorithm
    └── utils/
        └── jwt.js               # Token generation (generateToken)
```

**Key patterns:**
- Controllers handle HTTP request/response
- Services contain business logic (geofencing, alert generation)
- Middleware for auth (JWT) and role-based access control
- PostgreSQL queries use raw SQL with pg connection pool

### Flutter App Structure

```
smart_civic/lib/
├── main.dart                    # App entry, theme config, MaterialApp
├── screens/
│   ├── login_screen.dart        # Login with role selector (Admin/Worker)
│   ├── signup_screen.dart       # Signup with password confirmation
│   ├── admin_dashboard.dart     # Admin dashboard with stats, alerts, workers table
│   ├── worker_dashboard.dart    # Worker dashboard with tasks and image upload
│   └── map_screen.dart          # Live worker tracking map with OpenStreetMap
└── widgets/
    ├── custom_button.dart       # Reusable button with loading state
    └── custom_text_field.dart   # Reusable form field with validation
```

**Key patterns:**
- Material 3 with ColorScheme.fromSeed (indigo primary)
- Navigation via `Navigator.push/pop`
- State management via `setState` (no Provider/Bloc)
- Form validation built-in with `TextFormField` validators
- Maps use `flutter_map` package with OpenStreetMap tiles

## API Endpoints

All endpoints under `/api/`:

| Route | Methods | Auth | Purpose |
|-------|---------|------|---------|
| `/auth/login` | POST | None | JWT login |
| `/workers` | GET | Admin | List all workers |
| `/workers/:id` | GET | Auth | Get worker details |
| `/workers/start-duty` | PUT | Worker | Start duty |
| `/workers/stop-duty` | PUT | Worker | Stop duty |
| `/tasks` | GET, POST | Auth/Admin | List/create tasks |
| `/tasks/:id/assign` | PUT | Admin | Assign task |
| `/tasks/:id/complete` | PUT | Auth | Complete task |
| `/locations` | GET, POST | Admin/Worker | Location tracking |
| `/locations/:workerId` | GET | Auth | Location history |
| `/attendance/check-in` | POST | Worker | Mark attendance |
| `/attendance` | GET | Admin | All attendance |
| `/alerts` | GET, POST | Admin | Alert management |

## Database

PostgreSQL with these tables (inferred from queries):

- **users**: id, name, email, password, role
- **workers**: id, user_id, phone, assigned_zone_id, duty_status
- **zones**: id, name, polygon (JSON array of {lat, lng})
- **tasks**: id, title, description, latitude, longitude, assigned_worker_id, status, created_at
- **locations**: id, worker_id, latitude, longitude, is_inside_zone, timestamp
- **attendance**: id, worker_id, date, check_in_time, status
- **alerts**: id, worker_id, type, message, created_at

## Environment Variables

Backend `.env` file:

```env
PORT=5000
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=municipal_workforce
JWT_SECRET=your_secret_key
```

## Conventions

- **Flutter**: Material 3, ColorScheme.fromSeed, 12px border radius on inputs/buttons
- **Backend**: CommonJS modules, nodemon for development, MVC pattern
- **Auth**: JWT with 1-day expiration, roles are "admin" or "worker"
- **Geofencing**: Point-in-polygon using ray-casting algorithm in geofenceService.js
- **SQL**: Raw queries with parameterized inputs ($1, $2, etc.)

## Known Limitations

1. Password comparison in authController currently uses plain-text (bcryptjs imported but not fully implemented)
2. Flutter app has some hardcoded mock data and tokens for development
3. Socket.io is imported but real-time features not yet implemented
4. No signup endpoint in backend (only login exists)

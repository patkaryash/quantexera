# SmartCivic - Municipal Workforce Management System

A comprehensive solution for managing municipal workers, tracking their locations, handling task assignments, and ensuring zone compliance through geofencing.

## Overview

SmartCivic is a full-stack application consisting of:
- **Backend**: Node.js Express API with PostgreSQL database
- **Mobile App**: Flutter cross-platform application for Android, iOS, Web, and Desktop

## Features

### Worker Management
- Role-based authentication (Admin/Worker)
- Worker duty status tracking (active/inactive)
- Zone assignment and compliance monitoring

### Location Tracking & Geofencing
- Real-time GPS location updates
- Point-in-polygon zone validation using ray-casting algorithm
- Automatic alerts when workers leave assigned zones
- Live map tracking with OpenStreetMap

### Task Management
- Create geo-tagged tasks with coordinates
- Assign tasks to workers
- Track task completion status (pending/assigned/completed)

### Attendance System
- Zone-validated check-in (must be inside assigned zone)
- Daily attendance tracking with violation detection
- Automated attendance violation alerts

### Alert System
- Manual alert creation by admins
- Auto-generated alerts for zone violations
- Auto-generated alerts for attendance violations

## Tech Stack

### Backend
| Component | Technology |
|-----------|------------|
| Runtime | Node.js |
| Framework | Express 4.21.2 |
| Database | PostgreSQL |
| Authentication | JWT (jsonwebtoken) |
| Password Hashing | bcryptjs |
| Real-time | Socket.io |

### Mobile App (Flutter)
| Component | Technology |
|-----------|------------|
| Framework | Flutter (Dart SDK ^3.11.3) |
| UI | Material 3 |
| Maps | flutter_map + OpenStreetMap |
| HTTP Client | http package |
| Camera | image_picker |

## Project Structure

```
quantexera/
├── backend/                     # Node.js Express API
│   ├── app.js                   # Express app setup & routes
│   ├── server.js                # HTTP server entry point
│   ├── package.json
│   └── src/
│       ├── config/db.js         # PostgreSQL connection
│       ├── controllers/         # Request handlers
│       ├── middleware/          # Auth & role middleware
│       ├── routes/              # API route definitions
│       ├── services/            # Business logic (geofence, alerts)
│       └── utils/               # JWT utilities
│
└── smart_civic/                 # Flutter mobile app
    ├── pubspec.yaml
    └── lib/
        ├── main.dart            # App entry point
        ├── screens/             # UI screens
        └── widgets/             # Reusable components
```

## Getting Started

### Prerequisites
- Node.js (v18+)
- PostgreSQL
- Flutter SDK (^3.11.3)

### Backend Setup

```bash
cd quantexera/backend
npm install
```

Create a `.env` file with:
```env
PORT=5000
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=municipal_workforce
JWT_SECRET=your_secret_key
```

Start the server:
```bash
npm run dev    # Development with hot reload
npm start      # Production
```

### Flutter App Setup

```bash
cd quantexera/smart_civic
flutter pub get
flutter run
```

Build for production:
```bash
flutter build apk       # Android
flutter build ios       # iOS
flutter build web       # Web
```

## API Endpoints

| Endpoint | Method | Access | Description |
|----------|--------|--------|-------------|
| **Authentication** ||||
| `/api/auth/login` | POST | Public | User login |
| **Workers** ||||
| `/api/workers` | GET | Admin | Get all workers |
| `/api/workers/:id` | GET | Auth | Get worker by ID |
| `/api/workers/start-duty` | PUT | Worker | Start duty |
| `/api/workers/stop-duty` | PUT | Worker | Stop duty |
| **Tasks** ||||
| `/api/tasks` | POST | Admin | Create task |
| `/api/tasks` | GET | Auth | Get all tasks |
| `/api/tasks/:id/assign` | PUT | Admin | Assign task |
| `/api/tasks/:id/complete` | PUT | Auth | Complete task |
| **Locations** ||||
| `/api/locations` | POST | Worker | Update location |
| `/api/locations` | GET | Admin | Get all locations |
| `/api/locations/:workerId` | GET | Auth | Get location history |
| **Attendance** ||||
| `/api/attendance/check-in` | POST | Worker | Mark attendance |
| `/api/attendance` | GET | Admin | Get all attendance |
| `/api/attendance/:workerId` | GET | Auth | Get worker attendance |
| **Alerts** ||||
| `/api/alerts` | POST | Admin | Create alert |
| `/api/alerts` | GET | Admin | Get all alerts |
| `/api/alerts/:workerId` | GET | Auth | Get worker alerts |

## Database Schema

### Tables
- **users** - User authentication (id, name, email, password, role)
- **workers** - Worker profiles (user_id, phone, assigned_zone_id, duty_status)
- **zones** - Geographic zones with polygon boundaries
- **tasks** - Geo-tagged tasks with assignment status
- **locations** - Worker location history with zone compliance
- **attendance** - Daily attendance records
- **alerts** - System and manual alerts

## License

This project was created for a hackathon.

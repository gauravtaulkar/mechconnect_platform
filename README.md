# MechConnect Platform

A full-stack platform that connects customers with two-wheeler mechanics for mechanic discovery, service booking, and booking management.

## 🚀 Tech Stack

### Backend

* Java 17
* Spring Boot
* Spring Security
* JWT Authentication
* REST APIs
* Maven
* Hibernate / JPA

### Frontend

* Flutter
* Dart
* Android / Windows support

### Database

* PostgreSQL
* Hibernate / JPA

### Deployment & DevOps

* Docker
* GitHub Actions
* GitHub Container Registry (GHCR)
* Render

## 📁 Project Structure

```text
mechconnect_platform/
│
├── mechconnect-backend/
│   ├── src/
│   ├── pom.xml
│   ├── Dockerfile
│   └── mvnw
│
├── mechconnect_app/
│   ├── lib/
│   │   ├── config/
│   │   ├── models/
│   │   ├── screens/
│   │   └── services/
│   ├── test/
│   └── pubspec.yaml
│
└── .github/
    └── workflows/
        └── ci-cd.yml
```

## ✨ Features

* User registration and login
* JWT-based authentication
* Mechanic profiles
* Mechanic availability
* Mechanic expertise
* Customer booking system
* Customer-specific "My Bookings"
* Booking status management
* REST API communication between Flutter and Spring Boot
* PostgreSQL database
* Secure authentication between frontend and backend

## 🔐 Authentication

MechConnect uses JWT authentication.

After login, the Flutter application stores the authentication token and sends it with authenticated API requests:

```text
Authorization: Bearer <JWT_TOKEN>
```

Customer bookings are associated with the authenticated user rather than requiring the customer to manually enter a phone number.

## 🌐 Backend API

The production backend is deployed on Render.

Health check:

```text
https://mechconnect-backend.onrender.com/actuator/health
```

The backend provides REST endpoints for:

* Authentication
* Mechanics
* Mechanic profiles
* Bookings
* Customer bookings
* Booking status management

## 📱 Flutter Application

The Flutter application communicates with the production backend through:

```text
https://mechconnect-backend.onrender.com
```

API configuration is maintained in:

```text
mechconnect_app/lib/config/app_config.dart
```

## 🐳 Docker

The Spring Boot backend is containerized using Docker.

The Docker image is published to GitHub Container Registry:

```text
ghcr.io/gauravtaulkar/mechconnect_platform:latest
```

## ⚙️ CI/CD

GitHub Actions is used for continuous integration and deployment.

The workflow:

1. Builds the Spring Boot backend
2. Runs automated tests
3. Builds the Docker image
4. Publishes the image to GHCR
5. Render deploys the updated backend

Workflow configuration:

```text
.github/workflows/ci-cd.yml
```

## 🛠️ Local Development

### Backend

```bash
cd mechconnect-backend
./mvnw spring-boot:run
```

On Windows:

```powershell
cd mechconnect-backend
.\mvnw.cmd spring-boot:run
```

### Flutter

```bash
cd mechconnect_app
flutter pub get
flutter run
```

### Run Flutter tests

```bash
flutter test
```

### Analyze Flutter code

```bash
flutter analyze
```

## 🧪 Testing

Backend tests:

```bash
./mvnw test
```

Flutter tests:

```bash
flutter test
```

## 📌 Current Architecture

```text
             ┌──────────────────┐
             │   Flutter App    │
             │   Dart / Flutter │
             └────────┬─────────┘
                      │
                      │ HTTPS / REST API
                      ▼
             ┌──────────────────┐
             │  Spring Boot API │
             │   JWT Security   │
             └────────┬─────────┘
                      │
                      │ JPA / Hibernate
                      ▼
             ┌──────────────────┐
             │   PostgreSQL     │
             └──────────────────┘

        GitHub Actions
              │
              ▼
       Docker → GHCR → Render
```

## 📄 License

This project is currently maintained as a personal development project.

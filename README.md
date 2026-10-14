# MechConnect Platform

A full-stack platform that connects customers with two-wheeler mechanics for mechanic discovery, service booking, and booking management.

## 🚀 Tech Stack

**Backend**
- Java 17
- Spring Boot
- Spring Security and JWT authentication
- REST APIs
- Spring Data JPA / Hibernate
- Maven

**Frontend**
- Flutter and Dart
- Android and Windows support

**Database**
- PostgreSQL for the application database
- H2 for automated integration tests

**Deployment and DevOps**
- Docker
- GitHub Actions
- GitHub Container Registry (GHCR)
- Render

## ✨ Features

- User registration and login
- JWT-based authentication
- Mechanic profiles, expertise, and availability
- Mechanic discovery
- Customer service booking
- Customer-specific booking history
- Booking status management
- Flutter-to-Spring Boot REST API communication
- Authenticated customer-booking association
- Automated backend tests and CI checks

## 🏗️ Architecture

```text
Flutter Application
        |
        | HTTPS / REST API
        v
Spring Boot Backend
        |
        | Spring Data JPA / Hibernate
        v
PostgreSQL Database
```

GitHub Actions builds and tests the backend. Successful builds on pushes to `main` can publish the backend container image to GHCR, with Render used for deployment.

## 🔐 Authentication and Security

MechConnect uses JWT authentication to secure API requests.

After login, the Flutter application stores the authentication token and includes it in authenticated requests:

```http
Authorization: Bearer <JWT_TOKEN>
```

Customer bookings are associated with the authenticated user rather than relying solely on a phone number supplied by the client.

The backend also restricts access to protected operations according to user roles.

## 🌐 Backend API

Production backend:

https://mechconnect-backend.onrender.com

Health check:

https://mechconnect-backend.onrender.com/actuator/health

The backend provides REST endpoints for:
- Authentication
- Mechanic discovery and profiles
- Booking creation and management
- Customer booking history
- Booking status updates

## 📱 Flutter Application

The Flutter application communicates with the backend through the production API URL.

API configuration:

`mechconnect_app/lib/config/app_config.dart`

## 📁 Project Structure

```text
mechconnect_platform/
├── mechconnect-backend/
│   ├── src/
│   ├── pom.xml
│   ├── Dockerfile
│   └── mvnw
├── mechconnect_app/
│   ├── lib/
│   │   ├── config/
│   │   ├── models/
│   │   ├── screens/
│   │   └── services/
│   ├── test/
│   └── pubspec.yaml
└── .github/
    └── workflows/
        └── ci-cd.yml
```

## 🛠️ Local Development

### Prerequisites

- Java 17
- Docker, if using the containerized database setup
- Flutter SDK and Dart
- Git

### Start the backend

From the repository root:

**Windows PowerShell**

```powershell
cd mechconnect-backend
.\mvnw.cmd spring-boot:run
```

**Linux / macOS**

```bash
cd mechconnect-backend
./mvnw spring-boot:run
```

Configure the required database and JWT environment variables according to the backend configuration before starting the application.

### Run the Flutter application

From the repository root:

```bash
cd mechconnect_app
flutter pub get
flutter run
```

Run Flutter tests:

```bash
flutter test
```

Analyze Flutter code:

```bash
flutter analyze
```

## 🧪 Backend Testing

The backend contains service-level unit tests and controller integration tests.

The integration tests use an in-memory H2 database in MySQL compatibility mode, so they do not require a running PostgreSQL or MySQL server.

Run the complete backend verification lifecycle from `mechconnect-backend`:

**Windows PowerShell**

```powershell
.\mvnw.cmd clean verify
```

**Linux / macOS**

```bash
./mvnw clean verify
```

This runs the automated tests and Maven verification lifecycle.

Additional test documentation is available in [`mechconnect-backend/TESTING.md`](mechconnect-backend/TESTING.md).

## 🐳 Docker and CI/CD

The Spring Boot backend is containerized using Docker.

The backend container image is published to GitHub Container Registry:

`ghcr.io/gauravtaulkar/mechconnect_platform:latest`

The GitHub Actions workflow at `.github/workflows/ci-cd.yml` builds and tests the backend for pushes and pull requests targeting `main`. Container publishing runs after a successful build on a push to `main`.

Render is used to deploy the backend.

## 🗺️ Project Status and Roadmap

The project currently includes authentication, mechanic discovery, booking management, a Flutter frontend, and automated backend testing.

Potential next improvements include:
- Redis caching for mechanic search results and available-slot lookups
- Kafka-based asynchronous booking events
- Expanded integration tests and performance measurements

These roadmap items are planned enhancements, not claims about currently implemented functionality.

## 📄 License

This project is maintained as a personal development project.
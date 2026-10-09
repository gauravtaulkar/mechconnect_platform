# Backend Testing

## Overview

MechConnect's Spring Boot backend uses JUnit 5 and Mockito for service-level unit testing.

The tests validate business logic while mocking repository dependencies. These unit tests do not require a running PostgreSQL or MySQL database.

## Prerequisites

- Java 17
- Maven, or the included Maven Wrapper
- Dependencies available from Maven repositories

## Run the tests

From the repository root:

```powershell
cd mechconnect-backend
.\mvnw.cmd clean verify
```

On Linux or macOS:

```bash
cd mechconnect-backend
./mvnw clean verify
```

To run tests without rebuilding the full verification lifecycle, use `test` instead of `clean verify`.

## Current test coverage

### AuthServiceTest

Tests registration, default user-role assignment, duplicate-email rejection, login success and failure cases, and user lookup.

### BookingServiceTest

Tests customer booking lookup, booking creation validation, unavailable mechanics, occupied time slots, pending status assignment, booking ownership checks, admin status updates, and mechanic booking lookup.

### MechanicServiceTest

Tests mechanic lookup, city search delegation, availability filtering, profile lookup, profile creation and updates, and deletion delegation.

## Continuous integration

The GitHub Actions workflow at `.github/workflows/ci-cd.yml` runs `mvn -B clean verify` in `mechconnect-backend` for pushes and pull requests targeting `main`.

Container publishing runs only after the build-and-test job succeeds on a push to `main`.

## Scope and limitations

The current suite consists of service-level unit tests with mocked dependencies. It does not yet establish end-to-end API behavior, database integration, HTTP authorization behavior, or measured code coverage.

A passing test suite confirms the tested scenarios only; it does not guarantee that every application behavior is correct.
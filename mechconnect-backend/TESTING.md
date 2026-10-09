# Backend Testing

## Overview

MechConnect's Spring Boot backend uses JUnit 5, Mockito, Spring Boot Test, MockMvc, and Spring Security Test.

The suite includes service-level unit tests and controller integration tests. Integration tests use an in-memory H2 database in MySQL compatibility mode, so they do not require a running MySQL or PostgreSQL server.

## Prerequisites

- Java 17
- Maven, or the included Maven Wrapper
- Dependencies available from Maven repositories

## Run the tests

From the backend repository directory:

```powershell
.\mvnw.cmd clean verify
```

On Linux or macOS:

```bash
./mvnw clean verify
```

To run tests without rebuilding the full verification lifecycle:

```powershell
.\mvnw.cmd test
```

## Unit test coverage

### AuthServiceTest

Tests registration, default user-role assignment, duplicate-email rejection, login success and failure cases, and user lookup.

### BookingServiceTest

Tests customer booking lookup, booking creation validation, unavailable mechanics, occupied time slots, pending status assignment, booking ownership checks, admin status updates, and mechanic booking lookup.

### MechanicServiceTest

Tests mechanic lookup, city search delegation, availability filtering, profile lookup, profile creation and updates, and deletion delegation.

## Controller integration test coverage

### AuthControllerIntegrationTest

Tests successful registration, rejection of self-assigned privileged roles, duplicate email rejection, successful login, incorrect password rejection, and invalid email handling.

### BookingControllerIntegrationTest

Tests authenticated booking creation, association of bookings with the logged-in customer, customer booking history, rejection of unauthenticated booking creation, and denial of customer access to the admin booking list.

## Test database configuration

The integration tests use `src/test/resources/application.properties` to configure an in-memory H2 database. The test profile uses schema creation and cleanup so the tests do not require the production database.

## Continuous integration

The GitHub Actions workflow at `.github/workflows/ci-cd.yml` runs `mvn -B clean verify` in `mechconnect-backend` for pushes and pull requests targeting `main`.

Container publishing runs only after the build-and-test job succeeds on a push to `main`.

## Scope and limitations

The integration tests exercise selected controller, security, and persistence scenarios. They do not replace testing against the production database, external services, or a deployed environment.

A passing test suite confirms the tested scenarios only; it does not guarantee that every application behavior is correct.
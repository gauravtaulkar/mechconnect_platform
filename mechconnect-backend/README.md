# MechConnect Backend

MechConnect's backend is a Java 17 Spring Boot REST API for mechanic discovery, user authentication, and vehicle service booking management.

## Technology Stack

- Java 17
- Spring Boot 3
- Spring Data JPA
- Spring Security and JWT
- MySQL and PostgreSQL drivers
- Maven
- Docker and GitHub Actions

## Testing

The backend uses JUnit 5 and Mockito for service-level unit tests.

Run the complete verification lifecycle from this directory:

```powershell
.\mvnw.cmd clean verify
```

See [TESTING.md](TESTING.md) for test coverage, prerequisites, and current limitations.

## Continuous Integration and Deployment

The repository's GitHub Actions workflow builds and tests the backend for pushes and pull requests targeting `main`. After a successful build on a push to `main`, the workflow publishes the backend container image to GitHub Container Registry.

See the root repository README and deployment documentation for project-wide setup and deployment details.
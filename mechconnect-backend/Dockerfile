# ---- Build stage ----
# Compiles the jar inside a container with Maven + JDK 17, so you don't need
# Maven installed on whatever machine actually builds the image (your PC,
# GitHub Actions, or Render's own builder all work the same way).
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Copy pom.xml first and download dependencies separately from the source
# copy below — Docker caches this layer, so re-builds after only changing
# Java files skip re-downloading every dependency from scratch.
COPY pom.xml .
RUN mvn -B dependency:go-offline

COPY src ./src
RUN mvn -B clean package -DskipTests

# ---- Run stage ----
# Final image only contains a JRE (not the full JDK+Maven build tooling),
# which keeps it small and reduces attack surface.
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

# Lets `docker ps` / hosting platforms know if the app is actually healthy,
# not just "the process is running" (see management.endpoints in
# application.properties).
HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
  CMD wget -qO- http://localhost:${PORT:-8080}/actuator/health | grep -q '"status":"UP"' || exit 1

ENTRYPOINT ["sh", "-c", "java -jar app.jar"]

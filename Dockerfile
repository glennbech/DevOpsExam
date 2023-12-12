FROM --platform=linux/arm64 maven:3.8.4-openjdk-11 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package

# Stage 2: Create a minimal JRE image
FROM --platform=linux/arm64 adoptopenjdk:11-jre-hotspot
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
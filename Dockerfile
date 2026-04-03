# Use a lightweight JRE base image for Java 21
FROM eclipse-temurin:21-jre-alpine

# Set working directory
WORKDIR /app

# Copy the generated JAR file into the container
COPY target/my-app-1.0-SNAPSHOT.jar app.jar

# Expose any port your app uses (this sample app might not be a web app, but just in case)
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "app.jar"]

# استخدم صورة JDK لبناء المشروع
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# استخدم JRE للتشغيل
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# شغّل السيرفر
ENTRYPOINT ["java", "-jar", "app.jar"]

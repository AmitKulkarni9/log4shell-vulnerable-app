FROM maven:3.6.3-jdk-11-slim AS build
RUN mkdir /home/maven
WORKDIR /home/maven
COPY pom.xml /home/maven
COPY src /home/maven/src
RUN mvn -B -f pom.xml clean package -DskipTests

FROM openjdk:8u181-jdk-alpine
RUN mkdir /app
COPY --from=build /home/maven/target/*.jar spring-boot-application.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","spring-boot-application.jar"]
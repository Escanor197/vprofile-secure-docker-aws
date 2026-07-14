# syntax=docker/dockerfile:1.7

FROM maven:3.9.6-eclipse-temurin-11 AS build

ARG APP_REPOSITORY=https://github.com/abdelrahmanonline4/sourcecodeseniorwr.git
ARG APP_BRANCH=Master

RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "${APP_BRANCH}" --single-branch \
    "${APP_REPOSITORY}" /src

WORKDIR /src

# Move runtime configuration out of the WAR and into a Compose secret.
RUN grep -q 'location="classpath:application.properties"' src/main/webapp/WEB-INF/appconfig-root.xml \
    && sed -i \
       's#location="classpath:application.properties"#location="file:/run/secrets/app_properties"#' \
       src/main/webapp/WEB-INF/appconfig-root.xml

# Add support for the dedicated RabbitMQ virtual host.
RUN grep -q 'password="${rabbitmq.password}"' src/main/webapp/WEB-INF/appconfig-rabbitmq.xml \
    && sed -i \
       's#password="${rabbitmq.password}"/>#password="${rabbitmq.password}" virtual-host="${rabbitmq.vhost}"/>#' \
       src/main/webapp/WEB-INF/appconfig-rabbitmq.xml

RUN mvn clean package -DskipTests

# Extract the WAR in the JDK build stage because the JRE runtime image
# intentionally does not include the jar utility.
RUN mkdir -p /opt/vprofile-root \
    && cd /opt/vprofile-root \
    && jar -xf /src/target/vprofile-v2.war

FROM tomcat:9.0.120-jre11-temurin

LABEL org.opencontainers.image.title="VProfile application" \
      org.opencontainers.image.description="Hardened Tomcat runtime for the VProfile Java application" \
      org.opencontainers.image.source="https://github.com/abdelrahmanonline4/sourcecodeseniorwr"

RUN groupadd --gid 10001 vprofile \
    && useradd --uid 10001 --gid 10001 --no-create-home --shell /usr/sbin/nologin vprofile \
    && rm -rf /usr/local/tomcat/webapps/* \
    && mkdir -p /usr/local/tomcat/webapps/ROOT \
                /usr/local/tomcat/temp \
                /usr/local/tomcat/work \
                /usr/local/tomcat/logs \
    && chown -R 10001:10001 /usr/local/tomcat

COPY --from=build --chown=10001:10001 \
    /opt/vprofile-root/ /usr/local/tomcat/webapps/ROOT/

RUN chmod -R go-w /usr/local/tomcat/webapps/ROOT

USER 10001:10001

EXPOSE 8080

CMD ["catalina.sh", "run"]

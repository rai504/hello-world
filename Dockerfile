FROM tomcat:8-jre8

LABEL maintainer="valaxytech@gmail.com"

# Add OpenTelemetry Java agent
ADD https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v2.7.0/opentelemetry-javaagent.jar /otel/opentelemetry-javaagent.jar

# Default OTel configuration (can be overridden by k8s env vars)
ENV CATALINA_OPTS="$CATALINA_OPTS -javaagent:/otel/opentelemetry-javaagent.jar"
ENV OTEL_SERVICE_NAME=webapp \
    OTEL_EXPORTER_OTLP_PROTOCOL=grpc \
    OTEL_EXPORTER_OTLP_ENDPOINT="http://otel-collector.observability:4317" \
    OTEL_TRACES_EXPORTER=otlp \
    OTEL_METRICS_EXPORTER=otlp \
    OTEL_LOGS_EXPORTER=otlp

# Deploy built WAR as ROOT app
COPY ./webapp/target/webapp.war /usr/local/tomcat/webapps/ROOT.war

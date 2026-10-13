FROM alpine:3.22

RUN apk add --no-cache ca-certificates curl tar

ARG AETHER_VERSION=2.3.0
ARG AETHER_ARCHIVE=aether-linux-x86_64-musl.tar.gz

WORKDIR /app

RUN curl -fsSL \
    "https://github.com/CluvexStudio/Aether/releases/download/v${AETHER_VERSION}/${AETHER_ARCHIVE}" \
    -o /tmp/aether.tar.gz \
    && tar -xzf /tmp/aether.tar.gz -C /app \
    && rm /tmp/aether.tar.gz \
    && chmod +x /app/aether \
    && test -x /app/aether

ENTRYPOINT ["/app/aether"]

# Use alpine as the base image
FROM alpine:latest

# Environment variables for package versions or configurations
ENV BUILD_PACKAGES="build-base openssl-dev ca-certificates wget curl git vim go czmq-dev" \
    PACKAGES="tor lyrebird webtunnel snowflake sudo bash haproxy privoxy procps" \
    PYTHON_PACKAGES="python3 py3-requests py3-pysocks py3-stem"

# Install build and runtime packages
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/main/" >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories && \
    echo "https://dl-cdn.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache $BUILD_PACKAGES $PACKAGES $PYTHON_PACKAGES && \
    update-ca-certificates

# Build and install Conjure Pluggable Transport
RUN git clone https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/conjure.git /tmp/conjure && \
    cd /tmp/conjure/client && \
    go build -o /usr/local/bin/conjure-client && \
    # Clean up the source code after build
    rm -rf /tmp/conjure

# Set up application directory
WORKDIR /usr/src/app

# Install multitor
ADD "https://api.github.com/repos/PacketCipher/multitor/commits?per_page=1" /usr/src/latest_commit
RUN git clone https://github.com/PacketCipher/multitor.git .
RUN chmod +x setup.sh && \
    ./setup.sh install && \
    # Create log folders required by multitor
    mkdir -p /var/log/multitor/privoxy/ && \
    # Modify HAProxy template to listen on all interfaces within the container
    # Ensure the path to templates/haproxy-template.cfg is correct relative to WORKDIR
    sed -i 's/127.0.0.1:16379/0.0.0.0:16379/g' templates/haproxy-template.cfg

# Copy the startup script
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Expose the default HAProxy port
EXPOSE 16379

# Set the entrypoint to the startup script
CMD ["/usr/local/bin/startup.sh"]
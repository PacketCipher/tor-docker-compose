# Use alpine as the base image
FROM alpine:latest

# Environment variables for package versions or configurations
ENV BUILD_PACKAGES="build-base openssl-dev ca-certificates wget git" \
    PACKAGES="tor sudo bash haproxy privoxy procps netcat"

# Install build and runtime packages
RUN apk update && \
    apk add --no-cache $BUILD_PACKAGES $PACKAGES && \
    update-ca-certificates

# Clean build packages to reduce image size
RUN apk del $BUILD_PACKAGES

# Set up application directory
WORKDIR /usr/src/app

# Install multitor
RUN git clone https://github.com/PacketCipher/multitor.git .
RUN ./setup.sh install && \
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

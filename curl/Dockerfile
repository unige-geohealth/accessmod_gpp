# Use the busybox image as the base
FROM alpine:latest

# Install curl
RUN apk --no-cache add curl jq

# Set the working directory
WORKDIR /app

# Copy the entrypoint script into the container
COPY ./entrypoint.sh /app/entrypoint.sh

# Make sure the script is executable
RUN chmod +x /app/entrypoint.sh

# Set the entrypoint to the script
ENTRYPOINT ["/app/entrypoint.sh"]

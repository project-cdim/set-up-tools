FROM golang:1.24-alpine3.22

# upgrading packages and installing curl
RUN apk update && \
    apk upgrade --available && \
    apk add --no-cache \
    curl

WORKDIR /gateway/tools
COPY tools/ .
RUN chmod +x initial_setup.sh
CMD ["./initial_setup.sh"]

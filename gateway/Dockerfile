FROM golang:1.23-alpine

# upgrading packages and installing git
RUN apk update && \
    apk upgrade --available && \
    apk add --no-cache \
    curl

WORKDIR /gateway/tools
COPY tools/ .
RUN chmod +x initial_setup.sh
CMD ["./initial_setup.sh"]

##FROM --platform=linux/amd64 debian:stable-slim
#FROM debian:stable-slim
#RUN apt-get update && apt-get install -y ca-certificates
#ADD notely /usr/bin/notely
#CMD ["notely"]


# syntax=docker/dockerfile:1
##########################
# 1. Build stage
##########################
FROM golang:1.22 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod and go.sum first for better build caching
COPY go.mod go.sum ./

# Download Go modules (dependencies)
RUN go mod download

# Copy the rest of the application source code
COPY . .

# Build the production binary (same as your script)
RUN ./scripts/buildprod.sh

##########################
# 2. Run stage
##########################
FROM debian:stable-slim

# Install minimal system dependencies
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy the compiled binary from the builder stage
COPY --from=builder /app/notely /usr/bin/notely

# Set the container start command
CMD ["notely"]
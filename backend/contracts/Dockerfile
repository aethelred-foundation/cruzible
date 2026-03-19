# Aethelred Cruzible Smart Contracts Dockerfile
# Multi-stage build for Rust contracts

FROM rust:1.85-alpine AS builder

RUN apk add --no-cache musl-dev

WORKDIR /app

COPY Cargo.toml Cargo.lock ./
COPY src/ ./src/

RUN cargo build --release

FROM alpine:3.20 AS production

RUN addgroup -g 1001 -S contracts && \
    adduser -S contracts -u 1001

WORKDIR /app

COPY --from=builder /app/target/release/cruzible-contracts ./

RUN chown -R contracts:contracts /app

USER contracts

CMD ["./cruzible-contracts"]

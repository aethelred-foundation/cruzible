# syntax=docker/dockerfile:1

FROM rust:1.85-bookworm AS builder

WORKDIR /workspace

RUN rustup target add wasm32-unknown-unknown

COPY Cargo.toml Cargo.lock ./
COPY contracts ./contracts

RUN cargo build --workspace --release --target wasm32-unknown-unknown --locked

RUN mkdir -p /artifacts/contracts \
    && cp target/wasm32-unknown-unknown/release/*.wasm /artifacts/contracts/ \
    && cd /artifacts/contracts \
    && sha256sum *.wasm > SHA256SUMS

FROM alpine:3.20 AS artifacts

RUN addgroup -g 1001 -S contracts \
    && adduser -S contracts -u 1001 -G contracts

WORKDIR /artifacts/contracts

COPY --from=builder --chown=contracts:contracts /artifacts/contracts/ ./

USER contracts

CMD ["cat", "SHA256SUMS"]

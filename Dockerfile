FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        coreutils \
        procps \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY app/app.sh /app/app.sh

RUN chmod +x /app/app.sh

ENTRYPOINT ["/app/app.sh"]

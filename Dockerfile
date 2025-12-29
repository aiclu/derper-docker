FROM golang:latest AS builder

ARG DERP_VERSION=latest
RUN go install tailscale.com/cmd/derper@${DERP_VERSION}

# 运行阶段
FROM debian:bookworm-slim
WORKDIR /app

# 安装依赖并清理
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        tzdata && \
    mkdir -p /app/certs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 环境变量
ENV DERP_DOMAIN=your-hostname.com \
    DERP_CERT_MODE=letsencrypt \
    DERP_CERT_DIR=/app/certs \
    DERP_ADDR=:443 \
    DERP_STUN=true \
    DERP_STUN_PORT=3478 \
    DERP_HTTP_PORT=80 \
    DERP_VERIFY_CLIENTS=false \
    DERP_VERIFY_CLIENT_URL="" \
    TZ=Asia/Shanghai

COPY --from=builder /go/bin/derper /app/derper

# 启动命令
ENTRYPOINT ["/app/derper"]
CMD ["--hostname=${DERP_DOMAIN}", \
     "--certmode=${DERP_CERT_MODE}", \
     "--certdir=${DERP_CERT_DIR}", \
     "--a=${DERP_ADDR}", \
     "--stun=${DERP_STUN}", \
     "--stun-port=${DERP_STUN_PORT}", \
     "--http-port=${DERP_HTTP_PORT}", \
     "--verify-clients=${DERP_VERIFY_CLIENTS}", \
     "--verify-client-url=${DERP_VERIFY_CLIENT_URL}"]


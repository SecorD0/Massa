FROM ubuntu:22.04

LABEL creator="SecorD >> 1package"
LABEL url="📦 All in https://t.me/OnePackage"

ENV TZ=UTC

WORKDIR root

COPY entrypoint.sh .

RUN apt update && \
    apt upgrade -y && \
    apt install wget jq git build-essential pkg-config libssl-dev -y; \
    apt clean; \
    chmod +x entrypoint.sh

EXPOSE 31244 31245

ENTRYPOINT ["./entrypoint.sh"]

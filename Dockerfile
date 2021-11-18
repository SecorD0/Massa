FROM ubuntu

LABEL creator="SecorD | Let's Node"
LABEL url="https://t.me/letskynode — node Community"

ARG DEBIAN_FRONTEND=noninteractive

ENV TZ=UTC

RUN apt update && \
    apt upgrade -y && \
    apt install wget unzip jq -y; \
    apt clean; \
    wget -qO massa.zip https://gitlab.com/massalabs/massa/-/jobs/artifacts/testnet/download?job=build-linux; \
    unzip massa.zip; \
    rm -rf massa.zip

EXPOSE 31244 31245

ENTRYPOINT ["/bin/sh", "-c", "cd /massa/massa-node/ && ./massa-node"]
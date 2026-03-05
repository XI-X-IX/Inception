FROM debian:bullseye

ARG CADVISOR_VERSION=0.47.2

RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# cAdvisor est un binaire unique qui lit les métriques des containers
# depuis les cgroups et l'API Docker
RUN curl -Lo /usr/local/bin/cadvisor \
        "https://github.com/google/cadvisor/releases/download/v${CADVISOR_VERSION}/cadvisor-v${CADVISOR_VERSION}-linux-amd64" && \
    chmod +x /usr/local/bin/cadvisor

EXPOSE 8080

# Les dossiers /sys, /var/lib/docker etc. sont montés depuis le host
# dans le docker-compose.yml (volumes en lecture seule)
CMD ["cadvisor", "-logtostderr"]
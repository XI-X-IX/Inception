FROM debian:bullseye

ARG PROMETHEUS_VERSION=2.45.0

RUN apt-get update && \
    apt-get install -y curl tar && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Télécharge l'archive Prometheus et extrait les deux binaires utiles :
# - prometheus : le serveur
# - promtool   : outil de debug/validation de config
RUN curl -Lo /tmp/prometheus.tar.gz \
        "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz" && \
    tar -xzf /tmp/prometheus.tar.gz -C /tmp/ && \
    mv /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus /usr/local/bin/ && \
    mv /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool   /usr/local/bin/ && \
    rm -rf /tmp/prometheus*

RUN mkdir -p /etc/prometheus /var/lib/prometheus

COPY conf/prometheus.yml /etc/prometheus/prometheus.yml

EXPOSE 9090

CMD ["prometheus", \
     "--config.file=/etc/prometheus/prometheus.yml", \
     "--storage.tsdb.path=/var/lib/prometheus"]
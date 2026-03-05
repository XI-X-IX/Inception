FROM debian:bullseye

ARG GRAFANA_VERSION=10.2.3

RUN apt-get update && \
    apt-get install -y curl tar && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -Lo /tmp/grafana.tar.gz \
        "https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz" && \
    tar -xzf /tmp/grafana.tar.gz -C /opt/ && \
    mv /opt/grafana-* /opt/grafana && \
    rm /tmp/grafana.tar.gz

# Bonne pratique : ne pas tourner en root
RUN useradd --no-create-home --shell /bin/false grafana && \
    mkdir -p /var/lib/grafana /var/log/grafana && \
    chown -R grafana:grafana /opt/grafana /var/lib/grafana /var/log/grafana

COPY conf/grafana.ini    /opt/grafana/conf/grafana.ini
COPY conf/datasource.yml /opt/grafana/conf/provisioning/datasources/datasource.yml

USER grafana

EXPOSE 3000

CMD ["/opt/grafana/bin/grafana", "server", \
     "--config=/opt/grafana/conf/grafana.ini", \
     "--homepath=/opt/grafana"]
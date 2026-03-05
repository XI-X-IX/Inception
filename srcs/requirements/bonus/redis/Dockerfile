FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y redis && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 6379

# --protected-mode no : accepte les connexions des autres containers du réseau
CMD ["redis-server", "--protected-mode", "no"]
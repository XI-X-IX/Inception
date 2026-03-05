FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y vsftpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY conf/start.sh    /start.sh
RUN chmod +x /start.sh

# Port 21 = commandes FTP
# Ports 21000-21010 = transferts de données (mode passif)
EXPOSE 21 21000-21010

CMD ["/start.sh"]
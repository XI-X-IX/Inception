FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY www/            /var/www/static/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    nginx \
    openssl && \
  	mkdir -p /etc/nginx/ssl /var/www/wordpress && \
  	chmod 755 /var/www/wordpress && \
  	chown -R www-data:www-data /var/www/wordpress && \
  	apt-get clean && \
  	rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf		/etc/nginx/nginx.conf
COPY conf/entrypoint.sh		/entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]

#!/bin/bash
set -e

FTP_PASSWORD=$(cat /run/secrets/ftp_password.txt)

# Crée l'utilisateur FTP s'il n'existe pas encore
# Son home = /var/www/wordpress (le volume WordPress)
if ! id "${FTP_USER}" &>/dev/null; then
    useradd -m -d /var/www/wordpress -s /bin/bash "${FTP_USER}"
    echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
    echo "[ftp] Utilisateur ${FTP_USER} créé ✓"
fi

# Lance vsftpd en PID 1
exec vsftpd /etc/vsftpd.conf
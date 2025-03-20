#!/bin/bash

# Установка пакетов
# https://dev.1c-bitrix.ru/learning/course/index.php?COURSE_ID=32&LESSON_ID=16784&LESSON_PATH=3903.4862.20866.30250.16782.16784
cat /etc/apt/sources.list > /etc/apt/sources.list.bkp

cat >> /etc/apt/sources.list << EOF
# Основной репозиторий
deb https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-main/ 1.7_x86-64 main contrib non-free
# Оперативные обновления основного репозитория
deb https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-update/ 1.7_x86-64 main contrib non-free
# Базовый репозиторий
deb https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-base/ 1.7_x86-64 main contrib non-free
# Расширенный репозиторий
deb https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-extended/ 1.7_x86-64 main contrib non-free
# Расширенный репозиторий (компонент astra-ce)
deb https://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-extended/ 1.7_x86-64 astra-ce
EOF

apt update -y && apt-get dist-upgrade -y
apt install mariadb-server mariadb-client php8.1 apache2 apache2-dev nginx wget curl unzip -y

wget https://nodejs.org/dist/v12.22.12/node-v12.22.12-linux-x64.tar.xz
tar -xvf node-v12.22.12-linux-x64.tar.xz -C /opt
ln -sf /opt/node-v12.22.12-linux-x64/bin/node /usr/local/bin/node
ln -sf /opt/node-v12.22.12-linux-x64/bin/npm /usr/local/bin/npm


# Конфигурация Nginx
# https://dev.1c-bitrix.ru/learning/course/index.php?COURSE_ID=32&LESSON_ID=5335&LESSON_PATH=3903.4862.20866.30250.16782.5335

wget https://dev.1c-bitrix.ru/docs/chm_files/astra.zip
unzip astra.zip
rsync -av astra/nginx/ /etc/nginx/

echo "127.0.0.1 push httpd" >> /etc/hosts

systemctl stop apache2
systemctl --now enable nginx


# Конфигурация PHP
# https://dev.1c-bitrix.ru/learning/course/index.php?COURSE_ID=32&LESSON_ID=3730&LESSON_PATH=3903.4862.20866.30250.16782.3730

cat astra/php.d/opcache.ini  >> /etc/php/8.1/apache2/php.ini
cat astra/php.d/zbx-bitrix.ini  >> /etc/php/8.1/apache2/php.ini

mkdir -v /var/log/php
chown www-data:www-data /var/log/php


# Конфигурация Apache
# https://dev.1c-bitrix.ru/learning/course/index.php?COURSE_ID=32&LESSON_ID=5407&LESSON_PATH=3903.4862.20866.30250.16782.5407

rsync -av astra/apache2/ /etc/apache2/
a2dismod --force autoindex
a2enmod rewrite
a2enmod php8.1
systemctl --now enable apache2


# Конфигурация MariaDB
# https://dev.1c-bitrix.ru/learning/course/index.php?COURSE_ID=32&LESSON_ID=16786&LESSON_PATH=3903.4862.20866.30250.16782.16786

rsync -av astra/mysql/ /etc/mysql/
systemctl --now enable mariadb
systemctl restart mariadb

mysql_root_password=$(date +%s | sha256sum | base64 | head -c 20)

mysql -sfu root <<EOS
-- set root password
UPDATE mysql.user SET Password=PASSWORD('$mysql_root_password') WHERE User='root';
-- delete anonymous users
DELETE FROM mysql.user WHERE User='';
-- delete remote root capabilities
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
-- drop database 'test'
DROP DATABASE IF EXISTS test;
-- also make sure there are lingering permissions to it
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
-- make changes immediately
FLUSH PRIVILEGES;
EOS

echo "mysql_root_password=$mysql_root_password" >> $PWD/.creds
echo "Generated Mysql root password: $mysql_root_password, it also will be saved to $PWD/.creds"


# Конфигурация redis
# https://dev.1c-bitrix.ru/learning/course/index.php?COURSE_ID=32&LESSON_ID=16788&LESSON_PATH=3903.4862.20866.30250.16782.16788
# Не нужен, пропущено

# apt install redis -y
# rsync -av astra/redis/redis.conf /etc/redis/redis.conf
# usermod -g www-data redis
# chown root:www-data /etc/redis/ /var/log/redis/
# [[ ! -d /etc/systemd/system/redis-server.service.d ]] && mkdir /etc/systemd/system/redis-server.service.d
# echo -e '[Service]\nGroup=www-data' > /etc/systemd/system/redis-server.service.d/custom.conf
# systemctl daemon-reload
# systemctl enable redis-server.service
# systemctl restart redis-server.service


# Конфигурация push-server
# https://dev.1c-bitrix.ru/learning/course/index.php?COURSE_ID=32&LESSON_ID=2381&LESSON_PATH=3903.4862.20866.30250.16782.2381
# Не нужен, пропущено


# Конфигурация сайта
# https://dev.1c-bitrix.ru/learning/course/index.php?COURSE_ID=32&LESSON_ID=6455&LESSON_PATH=3903.4862.20866.30250.16782.6455

mkdir /var/www/html/bx-site
wget -O /var/www/html/bx-site/bitrixsetup.php https://www.1c-bitrix.ru/download/scripts/bitrixsetup.php
chown www-data:www-data /var/www/html/bx-site -R
bitrix_user_password=$(date +%s | sha256sum | base64 | head -c 20)

mysql -sfu root <<EOS
create database portal;
CREATE USER 'bitrix'@'localhost' IDENTIFIED BY '$bitrix_user_password';
GRANT ALL PRIVILEGES ON portal.* TO 'bitrix'@'localhost';
EOS

echo "bitrix_user_password=$bitrix_user_password" >> $PWD/.creds
echo "Generated bitrix user password: $bitrix_user_password, it also will be saved to $PWD/.creds"
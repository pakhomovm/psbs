---
tags:
  - bitrix
  - битрикс
---

# Установка и настройка "1С-Битрикс: Управление сайтом" (Bitrix CMS)

**_Примечание_**: Данная инструкция написана для дистрибутива для Astra Linux 1.7

<br>

## Установка пакетов
_Оригинальная инструкция:_ [ссылка](https://dev.1c-bitrix.ru/learning/course/index.php?COURSE_ID=32&LESSON_ID=16784&LESSON_PATH=3903.4862.20866.30250.16782.16784)

### Сделайте резервную копию `sources.list`
```bash
cat /etc/apt/sources.list > /etc/apt/sources.list.bkp
```

### Подключите репозитории в файле `/etc/apt/sources.list`
```bash
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
```

### Обновитесь и установите все необходимые пакеты
```bash
apt update -y && apt-get dist-upgrade -y
apt install mariadb-server mariadb-client php8.1 apache2 apache2-dev nginx wget curl unzip -y
```

### Установите Node.js
```bash
wget https://nodejs.org/dist/v12.22.12/node-v12.22.12-linux-x64.tar.xz
tar -xvf node-v12.22.12-linux-x64.tar.xz -C /opt
ln -sf /opt/node-v12.22.12-linux-x64/bin/node /usr/local/bin/node
ln -sf /opt/node-v12.22.12-linux-x64/bin/npm /usr/local/bin/npm
```

#### Скачайте архив с конфигурационными файлами
Скачать архив с конфигурационными файлами можно по ссылками ниже:
* [Оригинальный архив](https://dev.1c-bitrix.ru/docs/chm_files/astra.zip)
* [Локальная копия](/_files/astra.zip)
```bash
wget https://dev.1c-bitrix.ru/docs/chm_files/astra.zip
unzip astra.zip
```



## Конфигурация Nginx
*Оригинальная инструкция: [ссылка](https://dev.1c-bitrix.ru/learning/course/index.php?COURSE_ID=32&LESSON_ID=5335&LESSON_PATH=3903.4862.20866.30250.16782.5335)*


### Перенесите конфигурационные файлы Nginx в каталог `/etc/nginx/`
```bash
rsync -av astra/nginx/ /etc/nginx/
```

Рабочий каталог для сайта - `/var/www/html/bx-site`. Пользователь для web окружения - `nginx`, группа `apache`.

Конфигурация nginx сервера и Bitrix CMS:
```
├── /etc/nginx
│        ├── nginx.conf                           # основной конфигурационный файл
│        ├── conf.d
│        │   ├── bitrix.conf                      # Bitrix: дефолтная конфигурация сайта
│        │   ├── bitrix_block.conf                # Bitrix: блокировки по умолчанию
│        │   ├── bitrix_general.conf              # Bitrix: отдача статики и прочее
│        │   ├── bx_temp.conf                     # Bitrix: конфигурация BX_TEMPORARY_FILES_DIRECTORY
│        │   ├── errors.conf                      # Bitrix:  обработка ошибок
│        │   ├── http-add_header.conf             # CORS заголовки
│        │   ├── im_subscrider.conf               # Bitrix:  проксирование запросов на push-server (получение)
│        │   ├── maps-composite_settings.conf     # параменные используемые для кеша
│        │   ├── maps.conf                        # дополнительные переменные
│        │   └── upstreams.conf                   # конфигурация для upstream серверов: apache && push-server
│        └── sites-available                      # подключаем сайты
│            ├── default.conf                     # сайт по умолчанию (настраиваем только 80 порт)
│            └── rtc.conf                         # проксирование запросов на push-server (публикация)
```


### Пропишите алиасы для сервисов

В сервисе используются имена для проксирования на определенные службы:
* httpd - проксирование запросов на apache,
* push - проксирование запросов на push-server. Чтобы заработала конфигурация, необходимо прописать их в локальных адресах. Если сервисы расположены на другом хосте, указываем здесь правильный адрес.
```bash
echo "127.0.0.1 push httpd" >> /etc/hosts
```

### Временно остановите Apache и запустите Nginx

Apache временно останавливается, т.к. его настройка и запуск следуюют далее
```bash
systemctl stop apache2
systemctl --now enable nginx
```



## Конфигурация PHP
*Оригинальная инструкция: [ссылка](https://dev.1c-bitrix.ru/learning/course/index.php?COURSE_ID=32&LESSON_ID=3730&LESSON_PATH=3903.4862.20866.30250.16782.3730)*

### Перенесите данные конфигурационных файлов PHP в `/etc/php/8.1/apache2/php.ini`
```bash
cat astra/php.d/opcache.ini  >> /etc/php/8.1/apache2/php.ini
cat astra/php.d/zbx-bitrix.ini  >> /etc/php/8.1/apache2/php.ini
```

### Создайте каталог для логов
```bash
mkdir -v /var/log/php
chown www-data:www-data /var/log/php
```



## Конфигурация Apache
*Оригинальная инструкция: [ссылка](https://dev.1c-bitrix.ru/learning/course/index.php?COURSE_ID=32&LESSON_ID=5407&LESSON_PATH=3903.4862.20866.30250.16782.5407)* 

### Перенесите конфигурационные файлы Apache в каталог `/etc/apache2/`
```bash
rsync -av astra/apache2/ /etc/apache2/
```

### Отключите листинг каталогов в Apache
```bash
a2dismod --force autoindex
```

### Включите модуль rewrite
```bash
a2enmod rewrite
```

### Включите php модуль
```bash
a2enmod php8.1
```

### Запустите сервис
```bash
systemctl --now enable apache2
```



## Конфигурация MariaDB
*Оригинальная инструкция: [ссылка](https://dev.1c-bitrix.ru/learning/course/index.php?COURSE_ID=32&LESSON_ID=16786&LESSON_PATH=3903.4862.20866.30250.16782.16786)* 

### Перенесите конфигурационные файлы MariaDB в каталог `/etc/mysql/`
```bash
rsync -av astra/mysql/ /etc/mysql/
```

### Запустите сервис
```bash
systemctl --now enable mariadb
systemctl restart mariadb
```

### Настройте сервис через mysql_secure_installation
```bash
mysql_secure_installation

...
Switch to unix_socket authentication [Y/n] n
 ... skipping.
Change the root password? [Y/n] y
New password:
Re-enter new password:
Password updated successfully!
Reloading privilege tables..
 ... Success!
Remove anonymous users? [Y/n] y
 ... Success!
Disallow root login remotely? [Y/n] y
 ... Success!
```

### Сгенерируйте пароль root-пользователя для MariaDB, задайте его, удалите анонимных пользователей и т.п.
```bash
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
```

### Сохраните пароль root-пользователя для MariaDB в `./.creds` для будущего использования
```bash 
echo "mysql_root_password=$mysql_root_password" >> $PWD/.creds
echo "Generated Mysql root password: $mysql_root_password, it also will be saved to $PWD/.creds"
```



## Конфигурация сайта
*Оригинальная инструкция: [ссылка](https://dev.1c-bitrix.ru/learning/course/index.php?COURSE_ID=32&LESSON_ID=6455&LESSON_PATH=3903.4862.20866.30250.16782.6455)* 

### Создайте рабочий каталог, скачайте и скопируйте в него `bitrixsetup.php`, выдайте права на каталог
```bash
mkdir /var/www/html/bx-site
wget -O /var/www/html/bx-site/bitrixsetup.php https://www.1c-bitrix.ru/download/scripts/bitrixsetup.php
chown www-data:www-data /var/www/html/bx-site -R
```

### Cгенерируйте пароль для сервисной учётной записи БД
```bash
bitrix_user_password=$(date +%s | sha256sum | base64 | head -c 20)
mysql -sfu root <<EOS
create database portal;
CREATE USER 'bitrix'@'localhost' IDENTIFIED BY '$bitrix_user_password';
GRANT ALL PRIVILEGES ON portal.* TO 'bitrix'@'localhost';
EOS
```

### Сохраните пароль сервисной учётной записи для MariaDB в `./.creds` для будущего использования
```bash
echo "bitrix_user_password=$bitrix_user_password" >> $PWD/.creds
echo "Generated bitrix user password: $bitrix_user_password, it also will be saved to $PWD/.creds"
```

### Пропишите имя БД и логин/пароль сервисной учётной записи в `/var/www/html/<каталог_сайта>/bitrix/.settings.php`
```
/var/www/html/psbins.ru/bitrix/.settings.php:
  'connetions' =>
  array (
    'value' =>
    array (
      'default' =>
      array (
        'className' => '\\Bitrix\\Main\\DB\\MysqliConnection',
        'host' => 'localhost',
        'database' => 'dbpsbins',                               # Имя БД
        'login' => 'lkpsbins',                                  # Логин сервисной УЗ
        'password' => '*******',                                # Пароль сервисной УЗ
        'options' => 2,
      ),
    ),
    'readonly' => true,
  ),
```
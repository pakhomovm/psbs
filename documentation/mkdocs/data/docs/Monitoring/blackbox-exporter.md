---
tags:
  - prometheus
  - exporter
---

# Blackbox Exporter
Blackbox Exporter - агент мониторинга, позволящий гибко проверять сетевую связность по различным протоколам (ICMP, TCP, HTTP и т.п.). Устанавливается на каждый сервер, с которого нужно проверять сетевую связность.

## Полезные Ссылки/документация
* [Github](https://github.com/prometheus/blackbox_exporter)
* [Пример конфига №1](https://github.com/prometheus/blackbox_exporter/blob/master/blackbox.yml)
* [Пример конфига №2](https://github.com/prometheus/blackbox_exporter/blob/master/example.yml)


## Установка Blackbox Exporter

### 1. Скачивание архива
```bash
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.27.0/blackbox_exporter-0.27.0.linux-amd64.tar.gz
```

### 2. Распаковка архива
```bash
tar -xvf blackbox_exporter-*.tar.gz
```

### 3. Перенос бинарного файла
```bash
cp blackbox_exporter-*/blackbox_exporter /usr/local/bin/
```

### 4. Создание директории для конфига
```bash
mkdir -p /etc/blackbox_exporter
cp config.yaml /etc/blackbox_exporter/config.yaml
```

### 5. Создание пользователя и выдача прав на бинарный файл и каталог с конфигом
```bash
useradd -rs /bin/false blackbox_exporter
chown -R blackbox_exporter:blackbox_exporter /etc/blackbox_exporter
chown blackbox_exporter:blackbox_exporter /usr/local/bin/blackbox_exporter
```

### 6. Создание файла службы
```bash
touch /etc/systemd/system/blackbox_exporter.service
vi /etc/systemd/system/blackbox_exporter.service 
```

### 7. Конфигурация файла службы
```bash
[Unit]
Description=Blackbox Exporter
After=network.target

[Service]
User=blackbox_exporter
Group=blackbox_exporter
Type=simple
ExecStart=/usr/local/bin/blackbox_exporter --config.file=/etc/blackbox_exporter/config.yaml --web.listen-address=:9115

[Install]
WantedBy=multi-user.target
```

### 8. Включение и запуск службы
```bash
systemctl daemon-reload && systemctl start blackbox_exporter && systemctl enable blackbox_exporter
```

### 9. Проверка
```bash
systemctl status blackbox_exporter
curl http://localhost:9115/probe?target=example.com&module=http_2xx
```
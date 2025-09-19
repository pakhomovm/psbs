---
tags:
  - prometheus
  - exporter
---

# BlackboxExporter

**_Полезные cсылки/документация_**:

* [Github](https://github.com/prometheus/blackbox_exporter)
* [Пример конфига №1](https://github.com/prometheus/blackbox_exporter/blob/master/blackbox.yml)
* [Пример конфига №2](https://github.com/prometheus/blackbox_exporter/blob/master/example.yml)



## Вводная
Blackbox Exporter - агент мониторинга, позволящий гибко проверять сетевую связность по различным протоколам (ICMP, TCP, HTTP и т.п.). Устанавливается на каждый сервер, с которого нужно проверять сетевую связность.



## Установка Blackbox Exporter
Все действия выполняются из под пользователя `root`.

### Скачайте архив
```bash
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.27.0/blackbox_exporter-0.27.0.linux-amd64.tar.gz
```

### Распакуйте архив
```bash
tar -xvf blackbox_exporter-*.tar.gz
```

### Скопируйте бинарный файл в /usr/local/bin/
```bash
cp blackbox_exporter-*/blackbox_exporter /usr/local/bin/
```

### Создате директорию для конфига
```bash
mkdir -p /etc/blackbox_exporter
cp config.yaml /etc/blackbox_exporter/config.yaml
```

### Скопируйте конфигурацию в файл конфига /etc/blackbox_exporter/config.yaml (пример)
```bash
modules:

  icmp:
    prober: icmp
    timeout: 10s
    icmp:
      preferred_ip_protocol: "ip4"

  http_2xx:
    prober: http
    timeout: 10s
    http:
      preferred_ip_protocol: "ip4"

  dns_smsc:
    prober: dns
    timeout: 10s
    dns:
      query_name: "smsc.ru"
      query_type: "A"
      transport_protocol: "udp"
      preferred_ip_protocol: "ip4" 
      valid_rcodes:
        - NOERROR

  dns_dadata:
    prober: dns
    timeout: 10s
    dns:
      query_name: "dadata.ru"
      query_type: "A"
      transport_protocol: "udp"
      preferred_ip_protocol: "ip4" 
      valid_rcodes:
        - NOERROR
```


### Создайте локального сервисного пользователя и выдать права на бинарный файл и каталог с конфигом
```bash
useradd -rs /bin/false blackbox_exporter
chown -R blackbox_exporter:blackbox_exporter /etc/blackbox_exporter
chown blackbox_exporter:blackbox_exporter /usr/local/bin/blackbox_exporter
```

### Создайте файла сервиса
```bash
touch /etc/systemd/system/blackbox_exporter.service
vi /etc/systemd/system/blackbox_exporter.service 
```

### Скопируйте содержимое в файл сервиса
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

### Активируйте и запустите сервис
```bash
systemctl daemon-reload && systemctl start blackbox_exporter && systemctl enable blackbox_exporter
```


## Проверка работы
Проверить работы экспортёра можно с помощью следующих шагов

1. Проверить статус сервиса
```bash
systemctl status blackbox_exporter.service
```
2. Проверить отдачу метрик
```bash
curl http://localhost:9115/probe?target=example.com&module=http_2xx
```



## Остановка
Для остановки выполните:
```bash
systemctl stop blackbox_exporter.service
```
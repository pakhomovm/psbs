---
tags:
  - prometheus
  - exporter
---

# NodeExporter

**_Полезные cсылки/документация_**:

* [Github](https://github.com/prometheus/node_exporter)


## Вводная
Node Exporter - агент мониторинга серверов, мониторит такие показатели операционной системы как нагрузка CPU, ОЗУ, дисковую подсистему, сеть, файловую подсистему и т.п. Устанавливается на каждый сервер, который нужно мониторить.



## Установка Node Exporter
Все действия выполняются из под пользователя `root`.


### Скачайте архив
```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz
```

### Распакуйте архив
```bash
tar -xvf node_exporter-*.tar.gz
```

### Скопируйте бинарный файл в /usr/local/bin/
```bash
cp node_exporter-*/node_exporter /usr/local/bin/
```

### Создайте локального сервисного пользователя и выдать права на бинарный файл 
```bash
useradd -rs /bin/false node_exporter
chown node_exporter:node_exporter /usr/local/bin/node_exporter
```

### Создайте файл сервиса
```bash
touch /etc/systemd/system/node_exporter.service
vi /etc/systemd/system/node_exporter.service 
```

### Скопируйте содержимое в файл сервиса
```bash
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter \
  --collector.filesystem.mount-points-exclude='^/(sys|proc|dev|run|var/lib/docker/.+|var/lib/kubelet/.+)($|/)' \
  --no-collector.wifi \
  --no-collector.hwmon \
  --collector.netdev.device-exclude='(lo|docker[0-9]|veth.*|br-.*)' \
  --collector.netstat.fields="^(.*_(InErrors|InErrs)|Ip_Forwarding|Ip(6|Ext)_(InOctets|OutOctets)|Icmp6?_(InMsgs|OutMsgs)|TcpExt_(Listen.*|Syncookies.*|TCPSynRetrans|TCPTimeouts)|Tcp_(ActiveOpens|InSegs|OutSegs|OutRsts|PassiveOpens|RetransSegs|CurrEstab)|Udp6?_(InDatagrams|OutDatagrams|NoPorts|RcvbufErrors|SndbufErrors))$"
[Install]
WantedBy=multi-user.target
```

### Активируйте и запустите сервис
```bash
systemctl daemon-reload && systemctl start node_exporter && systemctl enable node_exporter
```



## Проверка работы
Проверить работы экспортёра можно с помощью следующих шагов

1. Проверить статус сервиса
```bash
systemctl status node_exporter.service
```
2. Проверить отдачу метрик
```bash
curl http://localhost:9100/metrics
```



## Остановка
Для остановки выполните:
```bash
systemctl stop node_exporter.service
```
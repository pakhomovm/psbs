---
tags:
  - prometheus
  - exporter
---


# Node Exporter
Node Exporter - агент инфраструктурного мониторинга, т.е. показателей операционной системы (нагрузка/утилизация CPU, RAM, HDD, сети и прочие метрики). Устанавливается на каждый сервер, с которого нужно проверять сетевую связность.

## Полезные Ссылки/документация
* [Github](https://github.com/prometheus/node_exporter)


## Установка Node Exporter

### 1. Скачивание архива
```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz
```

### 2. Распаковка архива
```bash
tar -xvf node_exporter-*.tar.gz
```

### 3. Перенос бинарного файла
```bash
cp node_exporter-*/node_exporter /usr/local/bin/
```

### 4. Создание пользователя и выдача прав на бинарный файл и каталог с конфигом
```bash
useradd -rs /bin/false node_exporter
```

### 5. Создание файла службы
```bash
touch /etc/systemd/system/node_exporter.service
vi /etc/systemd/system/node_exporter.service 
```

### 6. Конфигурация файла службы
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

### 7. Включение и запуск службы
```bash
systemctl daemon-reload && systemctl start node_exporter && systemctl enable node_exporter
```

### 8. Проверка
```bash
systemctl status node_exporter
curl http://localhost:9100/metrics
```


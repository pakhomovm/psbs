# Установка Docker

## Вариант 1 (для Астра)
### Links
* https://micronode.ru/domestic/astra_linux/1.7/docker
* https://support.r7-office.ru/corporate-server2024/install-r7server/ustanovka-docker-na-primere-os-astra-orel-1-7-5/

### Опция 1: Простая установка из репозитория Астра
```bash
apt update
apt install -y docker.io 
```

### Опция 2: Установка актуальной версии на машине с доступом в сеть Интернет

#### Шаг 1: Обновите индекс пакетов и установите необходимые пакеты
```bash
apt update
apt install -y apt-transport-https ca-certificates curl gnupg gnupg2 software-properties-common lsb-release
```

#### Шаг 2: Добавьте официальный GPG ключ Docker
```bash
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

#### Шаг 3: Добавьте репозиторий Docker в систему
При установке на другой ОС обратите внимание на URL репозитория Docker. Возможно, потребуется вручную изменить URL репозитория на подходящий для Вашей ОС.
```bash
echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian buster stable" | sudo tee /etc/apt/sources.list.d/docker.list
```

#### Шаг 4: Установите Docker
```bash 
apt install docker-ce docker-ce-cli containerd.io
```

### Опция 3: Установка самой актуальной версии в изолированной среде (offline)
```bash
wget https://download.docker.com/linux/debian/dists/bullseye/pool/stable/amd64/docker-ce_20.10.23~3-0~debian-bullseye_amd64.deb
wget https://download.docker.com/linux/debian/dists/bullseye/pool/stable/amd64/docker-ce-cli_20.10.23~3-0~debian-bullseye_amd64.deb
wget https://download.docker.com/linux/debian/dists/bullseye/pool/stable/amd64/containerd.io_1.6.15-1_amd64.deb
dpkg -i docker-ce_20.10.23~3-0~debian-bullseye_amd64.deb docker-ce-cli_20.10.23~3-0~debian-bullseye_amd64.deb containerd.io_1.6.15-1_amd64.deb
```


### После установки
```bash
groupadd docker
usermod -aG docker $USER
newgrp docker  # Apply group changes without logging out
systemctl enable -now docker.service
systemctl start docker.service
systemctl enable containerd.service #??
```

### Проверка установки
```bash
systemctl enable docker.service
systemctl start docker.service
systemctl status docker.service
docker -v
```


# Установка docker compose / docker-compose

## Вариант 1: docker compose (v2, new, plugin)
```bash
apt install -y docker-compose-v2
```

## Вариант 2: docker-compose (v1, old, binary)
### Опция 1: Установка из репозитория (не последняя версия)
```bash
apt install -y docker-compose
```

### Опция 1: Установка с Github (последняя версия)
```bash
curl -SL https://github.com/docker/compose/releases/download/v2.30.3/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose version
```


# ==================================================================

# Установка Node Exporter

Node Exporter is a Prometheus exporter for hardware and OS metrics. Here's how to install it on a Linux server:

## Method 1: Downloading Precompiled Binary

### 1. Download Node Exporter
```bash
wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz
```

### 2. Extract the Archive
```bash
tar xvf node_exporter-*.linux-amd64.tar.gz
```

### 3. Move the Binary
```bash
mv node_exporter-*.linux-amd64/node_exporter /usr/local/bin/
```

### 4. Create a System User
```bash
useradd -rs /bin/false node_exporter
```

### 5. Create a Systemd Service File
```bash
touch /etc/systemd/system/node_exporter.service && vi /etc/systemd/system/node_exporter.service 
```

Add this content:
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

### 6. Start and Enable the Service
```bash
systemctl daemon-reload && systemctl start node_exporter && systemctl enable node_exporter
```

### 7. Check
```bash
curl http://localhost:9100/metrics
```


# ==================================================================


# Blackbox Exporter

### Links
* https://github.com/prometheus/blackbox_exporter
* https://github.com/prometheus/blackbox_exporter/blob/master/blackbox.yml
* https://github.com/prometheus/blackbox_exporter/blob/master/example.yml


# ==================================================================


# DNS Exporter

### Links
* https://www.youtube.com/watch?v=RbzVNJqt8-4
* https://github.com/tykling/dns_exporter


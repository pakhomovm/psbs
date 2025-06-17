


# Node Exporter

Node Exporter is a Prometheus exporter for hardware and OS metrics. Here's how to install it on a Linux server:

## Method 1: Downloading Precompiled Binary

### 1. Download Node Exporter
```bash
# For AMD64/x86_64 systems
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
```
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

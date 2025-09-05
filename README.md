# Docker

## Полезные Ссылки/документация
* https://micronode.ru/domestic/astra_linux/1.7/docker
* https://support.r7-office.ru/corporate-server2024/install-r7server/ustanovka-docker-na-primere-os-astra-orel-1-7-5/


## Установка. Вариант 1 : Простая установка из репозитория Астра
```bash
apt update
apt install -y docker.io 
```

## Установка. Вариант 2: Установка актуальной версии на машине с доступом в сеть Интернет

### 1. Обновление индексов пакетов и установка необходимых пакетов
```bash
apt update
apt install -y apt-transport-https ca-certificates curl gnupg gnupg2 software-properties-common lsb-release
```

### 2. Добавление официального GPG ключа Docker
```bash
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

### 3. Добавление репозитория Docker в систему
При установке на другой ОС обратите внимание на URL репозитория Docker. Возможно, потребуется вручную изменить URL репозитория на подходящий для Вашей ОС.
```bash
echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian buster stable" | sudo tee /etc/apt/sources.list.d/docker.list
```

### 4. Установка пакетов Docker
```bash 
apt install docker-ce docker-ce-cli containerd.io
```

### 5. Добавление текущего пользователя в группу docker
```bash
groupadd docker
usermod -aG docker $USER
newgrp docker  # Apply group changes without logging out
```

### 6. Включение и запуск службы
```bash
systemctl enable -now docker.service
systemctl start docker.service
systemctl enable containerd.service #??
```

### 7. Проверка
```bash
systemctl status docker.service
docker -v
```


<!--- ================================================================== -->


# Установка Docker compose / docker-compose

## (Предпочтительно) Установка docker compose (aka v2, new, plugin)
```bash
apt install -y docker-compose-v2
```

## (Альтернатива) Установка docker-compose (aka v1, old, binary)
### Вариант 1: Установка из репозитория (не последняя версия)
```bash
apt install -y docker-compose
```

### Вариант 2: Установка с Github (последняя версия)
```bash
curl -SL https://github.com/docker/compose/releases/download/v2.30.3/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose version
```


<!--- ================================================================== -->


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


<!--- ================================================================== -->


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


<!--- ================================================================== -->


# Windows Service Wrapper (WinSW)
WinSW - это т.н. wrapper, т.е. "обёртка" для процессов/исполняемых файлов. Эта утилита позволяет запускать исполняемые файлы, которые не могут работать в режиме службы операционной системы, в данном режиме - она запускается как служба, а целевой исполняемый файл запускается как подчинённый процесс.

## Полезные Ссылки/документация
* [Github](https://github.com/winsw/winsw)

## Установка 

### 1. Скачивание архива
Скачайте последнюю версию с [GitHub Releases](https://github.com/winsw/winsw/releases).

### Установка

1. Разместить *WinSW-x64.exe* в каталоге с бинарным файлом приложения (jar-файлом для Java приложения)
2. Переименовать *WinSW-x64.exe* в имя приложения (например, *myapp.exe*).
3. Написать конфигурационный файл *myapp.xml* (имя должно совпадать с именем *.exe*-файла) и разместить его в том же каталоге.
4. Выполнить команду [`myapp.exe install`] для создания службы.


### Пример конфигурационного файла

```xml
<service>
  <id>myapp</id>
  <name>My Application</name>
  <description>Custom service for My Application</description>
  <env name="DB_HOST" value="localhost" />
  <env name="DB_PORT" value="1521" />
  <env name="DB_NAME" value="OracleDB" />
  <env name="DB_USER" value="user" />
  <env name="DB_PASSWORD" value="password" />
  <executable>C:\Java\openjdk-17.0.2_windows-x64_bin\jdk-17.0.2\bin\java.exe</executable>
  <arguments>-jar "C:\MyApp\myapp-0.0.1.jar"</arguments>
  <logpath>C:\MyApp\logs</logpath>
  <log mode="roll-by-size">
    <sizeThreshold>10240</sizeThreshold>
    <keepFiles>8</keepFiles>
  </log>
</service>
```

## Использование

| Command     | Description                  |
| -------     | ---------------------------- |
| install     | Создание службы              |
| uninstall   | Удаление службы              |
| start       | Запуск службы                |
| stop        | Остановка службы             |
| restart     | Перезапуск службы            |
| status      | Проверка состояния службы    |
| refresh     | Обновление параметров службы |


---
tags:
  - docker
  - docker-compose
---

# Установка docker и docker-compose

**_Примечание_**: Полезные cсылки/документация

* [Установка Docker Astra Linux 1.7 Special Edition](https://micronode.ru/domestic/astra_linux/1.7/docker)
* [Установка Docker на примере ОС Астра Орел 1.7.5](https://support.r7-office.ru/corporate-server2024/install-r7server/ustanovka-docker-na-primere-os-astra-orel-1-7-5/)



## Установка docker

### Вариант 1 (по-умолчанию): Простая установка из репозитория Астра
```bash
apt update
apt install -y docker.io 
```

### Вариант 2: Установка актуальной версии на машине с доступом в сеть Интернет

#### Обновите индексы пакетов и установите необходимые пакеты
```bash
apt update
apt install -y apt-transport-https ca-certificates curl gnupg gnupg2 software-properties-common lsb-release
```

#### Добавьте GPG ключ Docker
```bash
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

#### Добавьте репозитории Docker в систему
При установке на другой ОС обратите внимание на URL репозитория Docker. Возможно, потребуется вручную изменить URL репозитория на подходящий для Вашей ОС.
```bash
echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian buster stable" |  tee /etc/apt/sources.list.d/docker.list
```

#### Установите пакеты Docker
```bash 
apt install docker-ce docker-ce-cli containerd.io
```

#### Добавьте текущего пользователя в группу docker (при необходимости)
```bash
groupadd docker
usermod -aG docker $USER
newgrp docker
```

#### Включите и запустите службы
```bash
systemctl enable -now docker.service
systemctl start docker.service
```

#### Проверье статус службы
```bash
systemctl status docker.service
docker -v
```



## Установка docker-compose

### Вариант 1 (предпочтительно)
Установка docker compose в виде плагина к docker (вызывается через `docker compose`) - это т.н. v2, более новая реализация docker-compose 
```bash
apt install -y docker-compose-v2
```

### Вариант 2 (альтернатива)
Установка docker compose в виде отдельного бинарного файла (вызывается через `docker-compose`) - это т.н. более старая, но рабочая реализация docker compose 
```bash
apt install -y docker-compose
```

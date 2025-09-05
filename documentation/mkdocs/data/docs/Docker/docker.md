---
tags:
  - docker
  - docker-compose
---

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

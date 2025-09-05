---
tags:
  - docker
---


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

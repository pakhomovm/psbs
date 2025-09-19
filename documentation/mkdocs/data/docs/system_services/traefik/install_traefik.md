---
tags:
  - traefik
---

# Реверс-прокси

**_Полезные cсылки/документация_**:

* [Сайт Traefik](https://traefik.io/traefik)
* [Сайт Traefik: документация](https://doc.traefik.io/traefik/)
* [Github-репозиторий Traefik](https://github.com/traefik/traefik)
* [Habr: Введение в Traefik 2.0](https://habr.com/ru/articles/508636/)


## Вводная
Реверс-прокси развёрнут в целях т.н. "публикации" нескольких веб-сервисов, работающих на одном сервере, под разными DNS-именами (URL'ами). В качестве ПО выбран **Traefik**.

**Traefik** - легковесный реверс-прокси, написанный на языке GoLang. Удобен для использования в средах контейнеризации (в данном случае в docker-compose), т.к. позволяет динамически (т.е. без правки конфигурационных файлов) обнаруживать публикуемые контейнеризованные сервисы за счёт лейблов следующего вида `docker-compose.yaml` файлах:

```yaml
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.<service_name>.rule=Host(`<app-dns-name.example.ru>`)"
      - "traefik.http.routers.<app_name>.entrypoints=<http>"
      - "traefik.http.services.<app_name>.loadbalancer.server.port=<port>"
```

где:

* `<service_name>` - имя приложения (под `services` в `docker-compose.yaml`);
* `<app-dns-name.example.ru>` - DNS-имя приложения по которому оно публикуется. Для каждого публикуемог приложение задаётся и заводится на DNS-сервере своё имя;
* `<http>` - имя entrypoint'а (логическая сущность Traefik, указывающая на порт, на котором публикуется приложение);
* `<port>` - порт на котором работает само приложения, т.е. на который будет перенаправлен трафик с порта entrypoint'а.


## Установка 

**_Примечания_**: 
* Перед установкой и запуском необходимо установить docker и docker-compose согласно [документации](/infra/install_docker/);
* В документации ниже примеры по запуску/остановке контейнеров указаны через команду `docker-compose` (см. [документацию](/infra/install_docker/#%D0%92%D0%B0%D1%80%D0%B8%D0%B0%D0%BD%D1%82_2_%D0%B0%D0%BB%D1%8C%D1%82%D0%B5%D1%80%D0%BD%D0%B0%D1%82%D0%B8%D0%B2%D0%B0), вариант 2).


### Создайте целевой каталог
```bash
mkdir /srv/traefik/
```

### Скопируйте конфигурационные файлы
Скопируйте в конфигурационные файлы на целевой сервер из репозитория или резервной копии. 

#### Структура каталогов и файлов
```
└── /srv/traefik                          # Рабочий каталог
         ├── data                         # Каталог для персистентных данных (например, конфигов)
         │   ├── dynamic.yml              # Файл динамической конфигурации 
         │   └── traefik.yml              # Файл статической конфигурации (основной)
         └── docker-compose.yaml          # Конфигурационный файл docker-compose
```


#### Файл **docker-compose.yaml**
??? example "Пример файла: `docker-compose.yaml`"
    ```yaml
    version: '3.5'

    services:
      traefik:
        image: traefik:v2.11
        container_name: traefik
        restart: unless-stopped
        ports:
          - 80:80
        volumes:
          - /etc/localtime:/etc/localtime:ro
          - /var/run/docker.sock:/var/run/docker.sock:ro
          - ./data/traefik.yml:/traefik.yml:ro
          - ./data/dynamic.yml:/dynamic.yml:ro
        labels:
          - "traefik.enable=true"
        networks:
          - traefik-net

    networks:
      traefik-net:
        external: true
    ```


#### Файл **traefik.yml**
??? example "Пример файла: `traefik.yml`"
    ```yaml
    api:
      insecure: true   # Dashboard will be published on 8080 (by default) and URL http://<Traefik IP>:8080/dashboard/
      dashboard: true

    entryPoints:
      http:
        address: ":80"
      https:
        address: ":443"

    metrics:
      prometheus:
        entryPoint: http

    providers:
      docker:
        endpoint: "unix:///var/run/docker.sock"
        exposedByDefault: false   # Discovers containers only with label="traefik.enable=true"
      file:
        filename: /dynamic.yml
        watch: true
    ```

Где:

* блок `api` - настройки публикации dashboard'а самого Traefik 
* блок `entryPoints` - символические имена портов, на которых далее будут публиковаться другие приложения (обычно `http` для порта 80 и `https` для порта 443)
* блок `metrics` - настройки публикации promethues-метрик (доступны по пути /metrics)
* блок `providers` - провайдеры конфигураций для публикации сервисов, где `docker` - это провайдер, который через сокет считывает свойства других контейнеров на данном хосте и в зависимости от их лейблов добавляет их себе в конфигурацию, а `file` - файл динамической конфигурации (при изменении настройки применяются на лету), используется для более тонкой настройки публикации странци dashboard'а и метрик




#### Файл **dynamic.yml**
??? example "Пример файла: `dynamic.yml`"
    ```yaml
    http:
    routers:
        dashboard:
        rule: "Host(`traefik.mydomain.ru`) && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))"
        service: api@internal
        entryPoints:
            - http
        prometheus:
        rule: "Host(`traefik.mydomain.ru`) && Path(`/metrics`)"
        service: prometheus@internal
        entryPoints:
            - http
    ```

Где:

* блок `http.routers` - список т.н. роутеров (маршрутов), связывающих публикуемый сервис (`service`), правила его публикации (`rules`) и entrypoint'ы (`entryPoints`)



### Создайте DNS-запись
Создайте на корпоративном DNS-сервере A или CNAME запись (например, `traefik.mydomain.ru`), указывающую на сервер с развёрнутым Traefik. Она нужна для того, чтобы при обращении по ней в качестве URL сработали правила `Host` из `dynamic.yml` и Traefik смаршрутизировал запрос на корректный сервис. 

Аналогичные записи и правила нужны будут для всех публикуемых сервисов.


### Создайте external сеть docker
Внешняя (external) сеть в docker нужна для того, чтобы в рамках неё контейнер Traefik смог получить доступ к портам контейнеров публикуемых сервисов
```bash
docker network create traefik-net
```



## Запуск
Для запуска перейдите в рабочий каталог с `docker-compose.yaml` и выполните:
```bash
cd /srv/traefik/
docker-compose up -d
```

??? warning "Если возникла ошибка при скачивании образа"
    При запуске служба docker попытается скачать docker-образ с [DockerHub](https://hub.docker.com/). Если с сервера нет доступа в Интернет и ранее приложение из данной версии образа не запускалось на сервере то можно вручную его скачать на другом компьютере/сервере, перенести на целевой сервер и импортировать. 
    
    Для этого нужно (на примере образа `alpine:3.22.1`):

    1. Проверить, что образа действительно нет на целевом сервере
    ```bash
    docker image ls
    ```
    Строчка следующего вида не должно быть
    ```
    REPOSITORY                         TAG       IMAGE ID       CREATED         SIZE
    .....
    alpine                             3.22.1    eafc1edb577d   7 weeks ago     3.6MB
    .....
    ```

    2. Скачать docker-образ на другом компьютере/сервере аналогичной архитектуры
    ```bash
    docker pull alpine:3.22.1
    ```

    3. Экспортировать docker-образ в tar-файл с сохранением тега
    ```bash
    docker save -o alpine_3.22.1.tar alpine:3.22.1
    ```

    4. Перенести tar-файл на целевой сервер во временный каталог и выполнить его импорт
    ```bash
    docker load -i ./alpine_3.22.1.tar 
    ```

    5. Проверить, что образ импортировался с сохранением тега:
    ```bash
    docker image ls
    ```
    Должна быть строчка вида:
    ```
    REPOSITORY                         TAG       IMAGE ID       CREATED         SIZE
    .....
    alpine                             3.22.1    eafc1edb577d   7 weeks ago     3.6MB
    .....
    ```



## Работа с Traefik

Traefik работает автономно и вся его конфигурация производится через файлы. Для контроля его конфигурации и состояния он выставляет два эндпоинта вида:

* `/dashboard/` - дашборд для просмотра сущностей (entrypoint'ов, router'ов, сервисов и т.п.) и их состояния (для текущего примера - [http://traefik.mydomain.ru/dashboard/](http://traefik.mydomain.ru/dashboard/));
* `/metrics/` - метрики в prometheus-формате (для текущего примера - [http://traefik.mydomain.ru/metrics/](http://traefik.mydomain.ru/metrics/)).



## Остановка
Для остановки перейдите в рабочий каталог с `docker-compose.yaml` и выполните:
```bash
cd /srv/traefik/
docker-compose down
```
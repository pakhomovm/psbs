---
tags:
  - prometheus
  - grafana
---

# Ядро системы мониторинга

**_Полезные cсылки/документация_**:

* [Сайт Prometheus: документация](https://prometheus.io/docs/introduction/overview/)
* [Сайт Grafana: документация](https://grafana.com/docs/grafana/latest/)


## Вводная
Система мониторинга развёрнута для отслеживания важных показателей (метрик) работы серверов и приложений с помощью дашбордов и алертов. Она состоит из популярной связки следующих сервисов:

* Ядра системы:
    * **Prometheus** - система сбора метрик (с экспортёров) и их хранения. Работает по pull-модели, т.е. сама собирает данные с экспортёров или встроенных в некоторое ПО "коробочных" эндпоинтов с метриками;
    * **Grafana** - система визуализации метрик, использует Prometheus в качестве базы данных, позволяет создавать дашборды с разного рода графиками/диаграммами, а так же гибко настраивать и рассылать алерты (по почте, в мессенджеры и т.п.).
* Агентов мониторинга (экспортёров): 
    * **[NodeExporter](/system_services/monitoring/node-exporter/)** - агент мониторинга серверов, мониторит такие показатели операционной системы как нагрузка CPU, ОЗУ, дисковую подсистему, сеть, файловую подсистему и т.п.;
    * **[BlackboxExporter](/system_services/monitoring/blackbox-exporter/)** - агент мониторинга сетевой доступности, может проверять её по протоколам ICMP, TCP, HTTP, SMTP, SSH и проч.;



## Установка 

**_Примечания_**: 

* Перед установкой и запуском необходимо установить docker и docker-compose согласно [документации](/infra/install_docker/);
* В документации ниже примеры по запуску/остановке контейнеров указаны через команду `docker-compose` (см. [документацию](/infra/install_docker/#%D0%92%D0%B0%D1%80%D0%B8%D0%B0%D0%BD%D1%82_2_%D0%B0%D0%BB%D1%8C%D1%82%D0%B5%D1%80%D0%BD%D0%B0%D1%82%D0%B8%D0%B2%D0%B0), вариант 2).
* Prometheus и Grafana связаны друг с другом, поэтому у них единый `docker-compose.yaml` и они соответственно устанавиливаются, запускаются и останавливаются вместе. Функционирование одного без другого не имеет смысла;
* Структура каталогов и соответствующие опции `volumes` в `docker-compose.yaml` созданы в соответствии с принципами, описанными [тут](http://mkdocs.home.local/system_services/overview/#%D0%9F%D0%BE%D0%B4%D1%85%D0%BE%D0%B4%D1%8B_%D0%BA_%D0%BF%D1%80%D0%BE%D0%B5%D0%BA%D1%82%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D1%8E%D1%80%D0%B0%D0%B7%D0%B2%D1%91%D1%80%D1%82%D1%8B%D0%B2%D0%B0%D0%BD%D0%B8%D1%8E).


### Создайте целевой каталог
```bash
mkdir /srv/monitoring/
```

### Скопируйте конфигурационные файлы
Скопируйте в конфигурационные файлы на целевой сервер из репозитория или резервной копии. 

#### Структура каталогов и файлов
```
└── /srv/monitoring                                   # Рабочий каталог
        ├── docker-compose.yaml                       # Конфигурационный файл docker-compose
        ├── grafana
        │   ├── lib                                   # Каталог для персистентных данных (внутренней БД)
        │   ├── plugins                               # Каталог для персистентных данных (плагинов)
        │   │   └── ...
        │   └── provisioning                          # Каталог для персистентных данных (provisioned конфигов)
        │       ├── alerting
        │       │   ├── alert_resources.yaml
        │       │   └── alert_rules.yaml
        │       ├── dashboards
        │       │   ├── dashboard.yaml
        │       │   └── definitions
        │       │       └── Dashboard_folder
        │       │           ├── dasboard_01.json 
        │       │           ├── ...
        │       │           └── dashboard_NN.json
        │       ├── datasources
        │       │   └── datasources.yml
        │       └── plugins
        │           └── plugins.yaml
        └── prometheus
            ├── data                                  # Каталог для персистентных данных (внутренней БД)
            └── prometheus.yml                        # Конфигурационный файл
```
где:

* `/grafana/lib/` - каталог внутренней БД Grafana, которая создаётся при её запуске и в которой хранятся все конфигурации, кроме provisioned (т.е. статичных, заданных в соответствующих файлах). Это могут быть, например, дашборды, правила алертинга и т.п., созданные в самом интерфейсе Grafana.
* `/grafana/plugins/` - каталог для плагинов. В этот каталог нужно **распаковать** содержимое архива с плагином, т.е. в нём должна быть папка с именем плагина (например, для популярного плагина для интеграции с Zabbix - папка с именем `alexanderzobnin-zabbix-app`), в которой уже содержатся файлы кода плагина.
* `/grafana/provisioning/` - основной каталог для provisioned файлов конфигураций, который может включать в себя:
    * `./alerting/alert_resources.yaml` - настройки алертинга (группы и политики рассылки, метод отправки и т.п.);
    * `./alerting/alert_rules.yaml` - правила алертинга;
    * `./dashboards/dashboard.yaml` - настройки provisioned дашбордов;
    * `./dashboards/definitions/` - каталог для provisioned дашбордов и их папок (в примере выше - `dasboard_01.json` и `Dashboard_folder`);
    * `./datasources/datasources.yml` - настройки datasource'ов (источников данных), как, например, Prometheus;
    * `./plugins/plugins.yaml` - настройки provisioned плагинов;
* `/prometheus/data/` - каталог time-series БД Prometheus, которая создаётся при её запуске и в которой хранятся собранные метрики;
* `/prometheus/prometheus.yml` - конфигурационный файл Prometheus.


#### Файл **docker-compose.yaml**
??? example "Пример файла: `docker-compose.yaml`"
    ```yaml
    version: '3.5'

    services:
      prometheus:
        image: prom/prometheus:v2.53.4
        container_name: prometheus
        restart: unless-stopped
        volumes:
          - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
          - ./prometheus/data:/prometheus
        ports:
          - 9090:9090
        command:
          - '--config.file=/etc/prometheus/prometheus.yml'
          - '--storage.tsdb.path=/prometheus'
          - '--storage.tsdb.retention.time=31d'
        labels:
          - "traefik.enable=true"
          - "traefik.http.routers.prometheus.rule=Host(`prometheus.mydomain.ru`)"
          - "traefik.http.routers.prometheus.entrypoints=http"
          - "traefik.http.services.prometheus.loadbalancer.server.port=9090"
        networks:
          - traefik-net

      grafana:
        image: grafana/grafana:12.0.2
        container_name: grafana
        restart: unless-stopped
        depends_on:
          - prometheus
        volumes:
          - ./grafana/lib:/var/lib/grafana
          - ./grafana/provisioning:/etc/grafana/provisioning
          - ./grafana/plugins:/var/lib/grafana/plugins
        environment:
          - GF_PATHS_PROVISIONING=/etc/grafana/provisioning
        ports:
          - 3000:3000
        labels:
          - "traefik.enable=true"
          - "traefik.http.routers.grafana.rule=Host(`grafana.mydomain.ru`)"
          - "traefik.http.routers.grafana.entrypoints=http"
          - "traefik.http.services.grafana.loadbalancer.server.port=3000"
        networks:
          - traefik-net

    networks:
      traefik-net:
        external: true
    ```


### Создайте DNS-запись
Создайте на корпоративном DNS-сервере A или CNAME записи (например, `prometheus.mydomain.ru` и `grafana.mydomain.ru`), указывающую на сервер с развёрнутыми Prometheus и Grafana. Они нужны для того, чтобы при обращении по ним в качестве URL сработали правила `Host` реверс-прокси [Traefik](/system_services/traefik/install_traefik/), заданные в блоках `services.prometheus.labels` и `services.grafana.labels` файла `docker-compose.yaml`, и Traefik смаршрутизировал запрос на корректные сервисы.


## Запуск
Для запуска перейдите в рабочий каталог с `docker-compose.yaml` и выполните:
```bash
cd /srv/monitoring/
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



## Работа с Prometheus

Prometheus работает автономно и вся его конфигурация производится через файл `prometheus.yml`. Для контроля его конфигурации и состояния он выставляет два эндпоинта вида:

* `/` - веб-интерфейс Prometheus, в котором доступны для просмотра несколько разделов. Более подробнее о них ниже;
* `/metrics/` - метрики в prometheus-формате (для текущего примера - [http://prometheus.mydomain.ru/metrics/](http://prometheus.mydomain.ru/metrics/)), которые Prometheus сам с себя же и снимает.

### Prometheus: веб-интерфейс

В веб-интерфейсе Prometheus недоступны функции какой-либо переконфигурации. В нём можно только посмотреть состояние работы самого Prometheus, его scrape job (задания, которые периодически забирают метрики с экспортёров) и получить данные по метрикам.

####  Меню Graph
Данный раздел веб-интерфейса служит для просмотра "сырых" данных по метрикам. В поле ввода вводится метрика (есть функции автозаполнения) или более сложное выражение на языке PromQL (язык написания запросов в Prometheus).

Если есть метрики, попадающие под заданное выражение, то окне ниже получим соответствующие временные ряды (это метрика + все вариации лейблов):

* вкладка `Table` - последние значения (т.н. Instant значения);
* вкладка `Graph` - в виде графика.

Этим разделом удобно пользоваться для проектирования выражений для дашбордов или алертов в Grafana.


####  Меню Status
Данный раздел служит для просмотра текущей конфигурации. Самые полезные подразделы:

* `Targets` - список scrape job и статус по ним. Есть фильтрация и поиск;
* `Configuration` - итоговая конфигурация Prometheus. Состоит из содержимого `prometheus.yml` и дефолтных параметров;
* `TSDB Status` - статистика по БД Prometheus (TSDB): количество временных рядов (series), ТОП метрик в разных разрезах; 
* `Runtime & Build Information` - информация о Prometheus: дата запуска, длительность хранения данных в БД (Storage retention), версия и т.п.



## Работа с Grafana
В отличие от Prometheus, в веб-интерфейсе Grafana можно полностью управлять её конфигурацией. 
Исключения составляют только те параметры/сущности, которые определены:

* в переменных окружения (блок `environment` в `docker-compose.yaml`);
* в provisioned конфигах (политики и правила алертинга, дашборды, источники данных и плагины).

Эти параметры/сущности нельзя изменить или удалить. 
Однако, согласно лучшим практикам, все параметры/сущности Grafana рекомендуется конфигурировать через код и хранить в репозитории, а через веб-интерфейс вносить только временные/тестовые правки - такой подход снижает риск потери важных конфигураций.


### Grafana: веб-интерфейс
Ниже описаны самые полезные подразделы.


#### Меню Bookmarks
Раздел с избранными разделами и подразделами меню. Чтобы добавить сюда один из них, нужно нажать иконку закладки напротив имени раздела в меню.


#### Меню Starred
Раздел с избранными дашбордами. Чтобы добавить сюда один из них, нужно открыть дашборд и нажать иконку звёздочки в правом верхнем углу.


#### Меню Dashboards
Раздел с дашбордами. Позволяет их:

* организовывать в папки;
* искать по имени и тегам, сортировать;
* создавать, импортировать, удалять.


#### Меню Explore
Раздел, аналогичный разделу Graph в Prometheus - позволяет писать выражения на PromQL и полуать сырые данные в виде метрик/временных рядов. Полезен при создании новых дашбордов или диагностики их работы.


#### Меню Alerting
Раздел, посвящённый алертам:

* **Alert rules** - правила алертинга. Provisioned правила имеют соответствующий тег;
* **Contact points** - группы рассылок.  Provisioned группы рассылки имеют соответствующий тег;
* **Notification policies** - политики.  Provisioned политики имеют соответствующий тег;
* **Silences** - временное отключение алертинга с помощью фильтров. Полезно, например, во время плановых работ;
* **Active Notifications** - активные алерты;


#### Меню Connections
В этом разделе настраиватьются источники данных (Datasources)



## Остановка
Для остановки перейдите в рабочий каталог с `docker-compose.yaml` и выполните:
```bash
cd /srv/monitoring/
docker-compose down
```
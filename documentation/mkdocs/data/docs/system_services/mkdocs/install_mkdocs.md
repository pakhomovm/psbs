---
tags:
  - mkdocs
---

# Система хранения документации

**_Полезные cсылки/документация_**:

* [Сайт MkDocs](https://www.mkdocs.org/)
* [Сайт Material for MkDocs](https://squidfunk.github.io/mkdocs-material/)
* [Сайт Material for MkDocs: документация](https://squidfunk.github.io/mkdocs-material/getting-started/)
* [Github-репозиторий Material for MkDocs](https://github.com/squidfunk/mkdocs-material)
* [Habr: Пошаговая инструкция как использовать MkDocs для создания сайта с документацией продукта](https://habr.com/ru/companies/rostelecom/articles/570098/)


## Вводная
Система хранения документации развёрнута для хранения в одном месте всей эксплуатационной документации. В качестве ПО выбрана платформа **MkDocs** и её тема **Material for MkDocs**.

**Material for MkDocs** - удобная, легковесная, простая в использовании платформа для хранения документации в формате Markdown, обладающая широким функционалом по кастомизации внешнего вида и форматирования.


## Установка 

**_Примечания_**: 

* Перед установкой и запуском необходимо установить docker и docker-compose согласно [документации](/infra/install_docker/);
* В документации ниже примеры по запуску/остановке контейнеров указаны через команду `docker-compose` (см. [документацию](/infra/install_docker/#%D0%92%D0%B0%D1%80%D0%B8%D0%B0%D0%BD%D1%82_2_%D0%B0%D0%BB%D1%8C%D1%82%D0%B5%D1%80%D0%BD%D0%B0%D1%82%D0%B8%D0%B2%D0%B0), вариант 2).


### Создайте целевой каталог
```bash
mkdir /srv/mkdocs/
```

### Скопируйте конфигурационные файлы
Скопируйте в конфигурационные файлы на целевой сервер из репозитория или резервной копии. 

#### Структура каталогов и файлов
```
└── /srv/mkdocs                           # Рабочий каталог
         ├── data                         # Каталог для персистентных данных (например, конфигов)
         │   ├── docs                     # Каталог для документов (md-файлов) и пр.
         │   │   └── index.md             # Файл заглавной страницы документации
         │   └── mkdocs.yml               # Файл конфигурации
         └── docker-compose.yaml          # Конфигурационный файл docker-compose
```


#### Файл **docker-compose.yaml**
??? example "Пример файла: `docker-compose.yaml`"
    ```yaml
    version: '3.5'

    services:
      mkdocs:
        image: squidfunk/mkdocs-material:9.6
        container_name: mkdocs
        restart: unless-stopped
        ports:
          - 8000:8000
        volumes:
          - ./data:/docs
        labels:
          - "traefik.enable=true"
          - "traefik.http.routers.mkdocs.rule=Host(`mkdocs.mydomain.ru`)"
          - "traefik.http.routers.mkdocs.entrypoints=http"
          - "traefik.http.services.mkdocs.loadbalancer.server.port=8000"
        networks:
          - traefik-net

    networks:
      traefik-net:
        external: true
    ```


### Файл **mkdocs.yml**
??? example "Пример файла: `mkdocs.yml`"
    ```yaml
    site_name: Библиотека технической документации
    copyright: © 2025, ООО «ПСБ Страхование»

    theme:
    name: material
    language: ru
    logo: _img/logo.png
    favicon: _img/logo_small.png
    font:
        text: Inter
        code: Source Code Pro
    features:
        - content.code.copy
        - navigation.path
        - navigation.top
        - navigation.indexes
        - search.highlight

    palette:
        # Palette toggle for light mode
        - scheme: default
        toggle:
            icon: material/brightness-7
            name: Switch to dark mode
        # Palette toggle for dark mode
        - scheme: slate
        toggle:
            icon: material/brightness-4
            name: Switch to light mode

    extra_css:
    - _stylesheets/extra.css

    plugins:
    - search
    - tags

    markdown_extensions:
    - attr_list
    - md_in_html
    - admonition            # For simple admonitions
    - pymdownx.details      # For collapsible admonitions
    - pymdownx.caret
    - pymdownx.mark
    - pymdownx.tilde

    nav:
    - Главная: index.md
    ```

Где:

* блоки `features`, `plugins` - активация разного рода функционала (см [документацию](https://squidfunk.github.io/mkdocs-material/setup/));
* блок `extra_css` - подключение файла CSS (в нём можно переопределить стили по-умолчанию);
* блок `markdown_extensions` - активация расширений языка Markdown;
* блок `nav` - описание структуры библиотеки документации.


### Создайте DNS-запись
Создайте на корпоративном DNS-сервере A или CNAME запись (например, `mkdocs.mydomain.ru`), указывающую на сервер с развёрнутым MkDocs. Она нужна для того, чтобы при обращении по ней в качестве URL сработали правила `Host` реверс-прокси [Traefik](/system_services/traefik/install_traefik/), заданные в блоке `services.mkdocs.labels` файла `docker-compose.yaml`, и Traefik смаршрутизировал запрос на корректный сервис. 



## Запуск
Для запуска перейдите в рабочий каталог с `docker-compose.yaml` и выполните:
```bash
cd /srv/mkdocs/
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



## Работа с MkDocs

MkDocs работает автономно и вся его конфигурация производится через файлы. Он выставляет единственный эндпоинта вида:

* `/` - корневая (главная) страница библиотеки документации, соответствующая файлу `/data/docs/index.md` (для текущего примера - [http://mkdocs.mydomain.ru/](http://mkdocs.mydomain.ru/));

### Внесение изменений в конфигурацию
Чтобы внести изменения в конфигурацию **MkDocs** необходимо отредактировать и сохранить файл `mkdocs.yml`. Сервис сам перечитает его в течении нескольких секунд


### Внесение изменений в библиотеку документации
Чтобы внести изменения в библиотеку документации необходимо:

1.  Создать/скопировать в каталог `/data/docs/` новые md-файлы и/или каталоги с ними
Например, добавим два каталога `section_01` и `section_02` и по два файла в них, где `index.md` - это корневые файлы разделов (папок)
```
├── /srv/mkdocs
         └── data
             └── docs
                 ├── index.md
                 ├── section_01
                 │   ├── index.md
                 │   └── section01_page01.md
                 └── section_01
                     ├── section02_page01.md
                     └── section02_page02.md

```
2. Отредактировать соответственно блок `nav` в файле `mkdocs.yml`.
Пример, соответствующий добавленным выше файлам
```
nav:
  - Главная: index.md
  - Раздел 1:
    - section_01/index.md
    - Страница 1: section_01/section01_page01.md
  - Раздел 2:
    - Страница 1: section_02/section02_page01.md
    - Страница 2: section_02/section02_page02.md
```


## Остановка
Для остановки перейдите в рабочий каталог с `docker-compose.yaml` и выполните:
```bash
cd /srv/mkdocs/
docker-compose down
```
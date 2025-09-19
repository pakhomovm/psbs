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
  <id>ConnectorITDMS</id>
  <name>Connector IT DMS</name>
  <description>Custom service for Connector IT DMS</description>
  <env name="DB_HOST" value="localhost" />
  <env name="DB_PORT" value="1521" />
  <env name="DB_NAME" value="Orcl" />
  <env name="DB_USER" value="user" />
  <env name="DB_PASSWORD" value="password" />
  <executable>C:\Java\openjdk-17.0.2_windows-x64_bin\jdk-17.0.2\bin\java.exe</executable>
  <arguments>-jar "C:\ConnectorITDMS\ConnectorITDMS-0.0.1.jar"</arguments>
  <logpath>C:\ConnectorITDMS\logs</logpath>
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


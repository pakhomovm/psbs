---
tags:
  - mobileapp
  - iOS
  - Android
---

# ПСБ_С.Территория здоровья

**_Примечание_**: Настройка среды (документация) - [**React Native**](https://reactnative.dev/docs/set-up-your-environment)


## Требования

Необходимо убедиться, что установлены:

- [**Node.js**](https://nodejs.org/en/download/)
- Пакетный мереджер [**yarn**](https://classic.yarnpkg.com/lang/en/docs/install/)


## Установка окружения на macOS (iOS и Android общее)
### Установка Watchman
```bash
  brew install watchman
```


## Установка окружения на macOS (только для iOS)

### Необходимо установить и настроить Xcode на macOS по [**документации**](https://reactnative.dev/docs/set-up-your-environment?os=macos&platform=ios).

??? note "Краткая инструкция (см. документацию по ссылке выше ↑)"
    #### Установка Xcode
    1. Скачайте и установите [**Xcode**](https://itunes.apple.com/us/app/xcode/id497799835?mt=12).
    2. Убедитесь, что установлена последняя версия.
    3. Xcode автоматически установит:
    - Инструменты сборки
    - iOS Simulator

    #### Xcode Command Line Tools.
    1. Откройте **Xcode**
    2. Перейдите в меню: **Xcode** → **Settings…** (или **Preferences...**) → **Locations**
    3. В поле **Command Line Tools** выберите последнюю доступную версию.

    #### Установка iOS Simulator
    1. В Xcode откройте: **Settings…** → **Platforms** (или **Components**)
    2. В **Devices** установите **iOS Simulator** последней доступной версии или нажмите + и выберите нужную версию iOS.
  

### Установка CocoaPods по [**документации**](https://cocoapods.org/)
```bash
  sudo gem install cocoapods
```

### Включить corepack
```bash
  corepack enable
```


## Установка окружения на macOS (только для Android)

### Установка JDK
```bash
  brew install --cask zulu@17
```

> После установки необходимо укзать путь к JDK в `~/.zshrc` (или `~/.bash_profile`):
```bash
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
```

Применить изменения:
```bash
source ~/.zshrc
```
> На M1/M2 используется `/opt/homebrew/`, на Intel — `/usr/local/`.

### Необходимо установить и настроить Android Studio на macOS по [**документации**](https://reactnative.dev/docs/set-up-your-environment?os=macos&platform=android).


??? note "Краткая инструкция (см. документацию по ссылке выше ↑)"
    #### Установка Android Studio
    1. Скачайте и установите [**Android Studio**](https://developer.android.com/studio).
    2. При установке отметьте галочками:
    - Android SDK
    - Android SDK Platform
    - Android Virtual Device

    #### Установка Android SDK
    1. В Android Studio открой SDK Manager → SDK Platforms.
    2. Включи Show Package Details.
    3. Установить:
    - Android 15 (VanillaIceCream) → Android SDK Platform 35 (или выше если доступно).
    - Системный образ:
      - Google APIs ARM 64 v8a System Image (для Apple Silicon)
      - или Google APIs Intel x86 Atom_64 System Image (для Intel Mac).
    4. Перейди в SDK Tools и включи:
    - Android SDK Build-Tools 35.0.0. (соответствующая версия).

    #### Переменные окружения.
    Добавь в `~/.zshrc` (или `~/.zprofile`):
    ```
    export ANDROID_HOME=$HOME/Library/Android/sdk
    export PATH=$PATH:$ANDROID_HOME/emulator
    export PATH=$PATH:$ANDROID_HOME/platform-tools
    ```

    Применить изменения:
    ```
    source ~/.zshrc
    ```


## Установка окружения на Windows (Android)

### Установите **JDK 17** через Chocolatey (коммандная строка от имени администратора):
```bash
  choco install -y nodejs-lts microsoft-openjdk17
```

### Необходимо установить и настроить Android Studio на Windows по [**документации**](https://reactnative.dev/docs/set-up-your-environment?os=windows&platform=android).

??? note "Краткая инструкция (см. документацию по ссылке выше ↑)"
    #### Установка Android Studio
    1. Скачайте и установите [**Android Studio**](https://developer.android.com/studio).
    2. При установке отметьте галочками:
    - Android SDK
    - Android SDK Platform
    - Android Virtual Device
    - (Если нет Hyper-V → Intel HAXM)
    3. После установки откройте Android Studio → More Actions → SDK Manager:
    - Вкладка SDK Platforms:
      - Android 15 (VanillaIceCream) → Android SDK Platform 35
      - Системный образ Intel x86_64
    - Вкладка SDK Tools:
      - Android SDK Build-Tools 35.0.0

    #### Переменные окружения
    1. Откройте:
    - Панель управления → Учётные записи пользователей → Изменение переменных среды
    - Добавьте переменную:
    ```
    ANDROID_HOME = %LOCALAPPDATA%\Android\Sdk
    ```
    - В Path добавьте:
    ```
    %LOCALAPPDATA%\Android\Sdk\platform-tools
    ```


## Запуск проекта

1. Установите зависимости:
```bash
yarn install
```
> Дополнительно только для iOS (на macOS):
> ```bash
> cd ios && pod install && cd ..
> ```
2. Запустите приложение (Metro):
```bash
yarn start
```

### Запуск на Android
Откройте симулятор Android и в новом окне терминала выполните команду:
```bash
yarn android
```

### Запуск на iOS
Откройте симулятор iOS и в новом окне терминала выполните команду:
```bash
yarn ios
```


## Сборка приложения для Android
1. Перейдите в папку `android`:
```bash
cd android
```
2. Выполните очистку от предыдущих сборок:
```bash
./gradlew clean
```

### Сборка **APK-файла** для установки на устройстве без RuStore / Google Play:
3. Выполните команду:
```bash
./gradlew assembleRelease
```
> Файл появиться в папке `android/app/build/outputs/apk/`  
> Найдите APK-файл `app-arm64-v8a-release.apk` (или `app-armeabi-v7a-release.apk` для старых устройств).

### Сборка **AAB-файла** для публикации в RuStore / Google Play:
3. Выполните команду:
```bash
./gradlew bundleRelease
```
> Файл появится в папке `android/app/build/outputs/bundle/release/app-release.aab`  
> Этот файл автоматически подписывается загрузочным ключом **upload** из хранилища ключей `psbs.keystore`.  
> Для этого необходимо поместить хранилище ключей `psbs.keystore` в папку `android/app/` (если его там нет).  
> 🔑 Хранилище ключей, все ключи и пароли к ним находятся у заказчика.

### Конфигурация приложения:
??? example "Пример настройки файла: `android/app/build.gradle`"
    ```
    defaultConfig {
        applicationId "ru.psbins.dms"
        minSdkVersion rootProject.ext.minSdkVersion
        targetSdkVersion rootProject.ext.targetSdkVersion
        versionCode VERSION_CODE.toInteger()
        versionName VERSION_NAME
    }
    signingConfigs {
        debug {
            storeFile file('debug.keystore')
            storePassword 'android'
            keyAlias 'androiddebugkey'
            keyPassword 'android'
        }
        release {
            if (project.hasProperty('MYAPP_UPLOAD_STORE_FILE')) {
                storeFile file(MYAPP_UPLOAD_STORE_FILE)
                storePassword MYAPP_UPLOAD_STORE_PASSWORD
                keyAlias MYAPP_UPLOAD_KEY_ALIAS
                keyPassword MYAPP_UPLOAD_KEY_PASSWORD
            }
        }
    }
    buildTypes {
        debug {
            signingConfig signingConfigs.debug
        }
        release {
            // Caution! In production, you need to generate your own keystore file.
            // see https://reactnative.dev/docs/signed-apk-android.
            signingConfig signingConfigs.release
            minifyEnabled enableProguardInReleaseBuilds
            proguardFiles getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro"
        }
    }
    ```


### Версия приложения:
??? example "Пример переменных для поднятия версии приложения в файле: `android/gradle.properties`"
    ```
    VERSION_CODE=2 // ← версия для RuStore / Google Play (увеличиваем при каждой сборке для RuStore / Google Play)
    VERSION_NAME=1.0.5 // ← версия для пользователей (показывается пользователям в приложении)
    ```

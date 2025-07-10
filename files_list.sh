#!/bin/bash

REPO_PATH="."
REPO_URL="https://raw.githubusercontent.com/pakhomovm/psbs/refs/heads/master/monitoring"
OUTPUT_FILE="files_download.sh"
THIS_FILE="$(basename "$0")"

# Очищаем предыдущий файл (если есть)
> "$OUTPUT_FILE"

# Функция для обработки файлов
process_file() {
    local file="$1"
    # Получаем относительный путь от корня репозитория
    local relative_path="${file#$REPO_PATH/}"
    # Формируем URL 
    local url="$REPO_URL/$relative_path"
    # Записываем команду wget в файл
    echo "wget '$url'" >> "$OUTPUT_FILE"
}

# Рекурсивно обходим все файлы в репозитории (исключая .git)
find "$REPO_PATH" -type f ! -path "*/.git/*" ! -name ".gitignore" ! -name "$OUTPUT_FILE" ! -name "$THIS_FILE" | while read -r file; do
    process_file "$file"
done


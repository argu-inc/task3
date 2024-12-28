#!/bin/env bash

# Функция для вывода справки
show_help() {
    echo "Использование: topsize [--help] [-h] [-N] [-s minsize] [--] [dir...]"
    echo
    echo "Опции:"
    echo "  --help       Показать эту справку и выйти"
    echo "  -N           Количество файлов для вывода (например, -10)"
    echo "  -s minsize   Минимальный размер файла (например, -s 100k)"
    echo "  -h           Вывод размера в человекочитаемом формате"
    echo "  dir...       Каталог(и) для поиска, если не заданы - текущий каталог"
    echo "  --           Разделение опций и каталога"
}

# Инициализация переменных
N=""
minsize="1c"  # Минимальный размер файла по умолчанию (1 байт)
human_readable=false
directories=()

# Парсинг аргументов командной строки
while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            show_help
            exit 0
            ;;
        -N)
            N="$2"  # Сохраняем количество файлов для вывода
            shift 2
            ;;
        -s)
            minsize="$2"  # Сохраняем минимальный размер файла
            shift 2
            ;;
        -h)
            human_readable=true  # Устанавливаем флаг для человекочитаемого формата
            shift
            ;;
        --)
            shift
            break
            ;;
        -*)
            echo "Неизвестная опция: $1"
            show_help
            exit 1
            ;;
        *)
            directories+=("$1")  # Добавляем директорию в массив
            shift
            ;;
    esac
done

# Если директории не указаны, используем текущую директорию
if [ ${#directories[@]} -eq 0 ]; then
    directories=(".")
fi

# Формируем команду find
find_cmd=(find "${directories[@]}" -type f -size +"$minsize" -print0)

# Выполняем команду find и обрабатываем результаты
if $human_readable; then
    "${find_cmd[@]}" | xargs -0 ls -lh | sort -rh -k5 | head -n ${N:-0} | awk '{print $5, $9}'
else
    "${find_cmd[@]}" | xargs -0 ls -l | sort -rn -k5 | head -n ${N:-0} | awk '{print $5, $9}'
fi

                                 _             _____         ___                    
                                | |           | ___ \       /   |                   
                                | |__  _   _  | |_/ / __ _ / /| | __ _ _ __   __ _  
                                | '_ \| | | | | ___ \/ _` / /_| |/ _` | '_ \ / _` | 
                                | |_)1 | |_| | | |_/ / (_| \___  | (_| | | | | (_| | 
                                |_.__/ \__, | \____/ \__,_|   |_/\__,_|_| |_|\__,_| 
                                        __/ |                                       
                                       |___/                                
Утилита оптимизации _winbuff.py
Функционал:
        Утилита подготавливает систему, выполняя следующие действия:

        1 Инициализация окружения:
        Устанавливает оформление консоли (цвет, заголовок, очистка экрана).
        Создает необходимые рабочие директории (C:\Windows\_soft, логов, временные файлы, административные файлы).

        2 Установка и проверка 7-Zip:
        Проверяет архитектуру системы (32/64-bit) и наличие установленной версии 7-Zip.
        Если версия отсутствует или не совпадает с указанной, скачивает и устанавливает 7-Zip.

        3 Загрузка и распаковка данных:
        Скачивает архив с FTP-сервера с использованием учетных данных.
        Распаковывает архив в указанный временный каталог.

        4 Копирование файлов:
        Копирует сценарии и административные файлы в соответствующие каталоги с использованием robocopy.

        5 Настройка автозапуска:
        Проверяет наличие задачи в планировщике Windows.
        Создает задачу автозапуска, если она отсутствует.

        6 Обновление реестра:
        Удаляет/добавляет ключи реестра для настройки ассоциации файлов .ps1 и запуска PowerShell.

        7 Запуск следующего сценария:
        Запускает PowerShell-скрипт loging.ps1 из временного каталога.

        8 Обработка ошибок:
        Все ключевые операции защищены обработкой исключений с выводом ошибок.

        9 Логирование:
        Записывает успешное выполнение шагов и ошибки в логи.
        Примечание
        Скрипт требует прав администратора для выполнения некоторых операций (например, изменения реестра, установки 7-Zip).


        Лицензия
        Этот проект лицензирован по лицензии MIT - смотрите файл LICENSE.md для получения подробной информации.

#!/bin/bash

# Проверка на Debian
if ! grep -q "debian" /etc/os-release; then
    echo "Этот скрипт предназначен только для Debian"
    exit 1
fi

# Проверка root прав
if [[ $EUID -ne 0 ]]; then
    echo "Этот скрипт должен быть запущен с правами root"
    exit 1
fi

# Выбор этапа выполнения
echo "Выберите этап установки:"
echo "1 - Первичная настрока"
echo "2 - Zabbix"
echo "3 - Настройка автообновления"
read -p "Введите номер этапа: " stage

if [[ "$stage" == "1" ]]; then
    # Установка необходимых пакетов
    echo "Устанавливаем необходимые пакеты..."
    sed -i '/^deb cdrom:/d' /etc/apt/sources.list
    apt-get update && apt-get upgrade -y
    apt update && apt dist-upgrade -y
    apt-get autoremove -y && apt-get clean -y
    apt-get install -y sudo curl wget lnav htop mc whois gnupg2 ncdu console-cyrillic

    # История команд с временем
    echo "Настройка формата истории команд с временем..."
    echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> ~/.bash_profile
    echo 'export HISTSIZE=10000' >> ~/.bashrc
    echo 'export HISTFILESIZE=10000' >> ~/.bashrc
    echo 'export HISTCONTROL=ignoreboth:erasedups' >> ~/.bashrc
    source ~/.bashrc
    source ~/.bash_profile
    echo > ~/.bash_history

    # Увеличение скорости TCP
    echo "Настройка ускорения TCP..."
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    sysctl -p || { echo "Ошибка при применении sysctl"; exit 1; }

    # Отключение IPv6
    echo "Отключаем IPv6..."
    echo "net.ipv6.conf.all.disable_ipv6 = 1" > /etc/sysctl.d/disable-ipv6.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.d/disable-ipv6.conf
    sysctl --system

    # Настройка sudo без пароля для пользователя tech
    echo "Настраиваем sudo для пользователя tech без пароля..."
    echo "tech    ALL=(ALL)    NOPASSWD:ALL" >> /etc/sudoers

    echo "Этап 1 завершен!"
    exit 0
fi

if [[ "$stage" == "2" ]]; then
    # Пауза перед установкой Zabbix
    echo "Перед установкой Zabbix нажмите любую клавишу для продолжения..."
    read -n 1 -s

    # Переменные для установки Zabbix
    ZABBIX_VERSION="7.0"
    DEBIAN_VERSION=$(lsb_release -sc)
    ZABBIX_SERVER="192.168.103.251"
    HOSTNAME=$(hostname)

    # Добавление репозитория Zabbix
    echo "Добавляем репозиторий Zabbix $ZABBIX_VERSION для Debian $DEBIAN_VERSION"
    wget -q https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_latest+debian12_all.deb || { echo "Ошибка при загрузке репозитория Zabbix"; exit 1; }

    # Установка пакета репозитория
    dpkg -i zabbix-release_latest+debian12_all.deb || { echo "Ошибка при установке репозитория Zabbix"; exit 1; }
    apt update || { echo "Ошибка при обновлении списка пакетов"; exit 1; }

    # Установка Zabbix агента
    echo "Устанавливаем Zabbix агент"
    apt install -y zabbix-agent2 || { echo "Ошибка при установке Zabbix агента"; exit 1; }

    # Настройка Zabbix агента
    echo "Настраиваем Zabbix агент"
    sed -i "s/^Server=127.0.0.1/Server=${ZABBIX_SERVER}/" /etc/zabbix/zabbix_agentd.conf
    sed -i "s/^ServerActive=127.0.0.1/ServerActive=${ZABBIX_SERVER}/" /etc/zabbix/zabbix_agentd.conf
    sed -i "s/^Hostname=Zabbix server/Hostname=${HOSTNAME}/" /etc/zabbix/zabbix_agentd.conf

    # Перезапуск и включение агента
    echo "Перезапускаем Zabbix агент"
    systemctl restart zabbix-agent || { echo "Ошибка при перезапуске Zabbix агента"; exit 1; }
    systemctl enable zabbix-agent || { echo "Ошибка при включении Zabbix агента"; exit 1; }

    # Проверка статуса агента
    systemctl status zabbix-agent || { echo "Ошибка при проверке статуса Zabbix агента"; exit 1; }

    echo "Zabbix агент установлен и настроен!"
    exit 0
fi

if [[ "$stage" == "3" ]]; then
    echo "Настраиваем автоматическое обновление..."
    apt update
    apt install unattended-upgrades -y
    dpkg-reconfigure -f noninteractive unattended-upgrades
    echo 'APT::Periodic::Update-Package-Lists "1";' > /etc/apt/apt.conf.d/20auto-upgrades
    echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.d/20auto-upgrades
    echo 'Unattended-Upgrade::Remove-Unused-kernel-Packages "true";' >> /etc/apt/apt.conf.d/50unattended-upgrades
    echo 'Unattended-Upgrade::Remove-Unused-Dependencies "true";' >> /etc/apt/apt.conf.d/50unattended-upgrades
    echo 'Unattended-Upgrade::Automatic-Reboot "true";' >> /etc/apt/apt.conf.d/50unattended-upgrades
    echo 'Unattended-Upgrade::Automatic-Reboot-Time "04:00";' >> /etc/apt/apt.conf.d/50unattended-upgrades
    echo "Автоматическое обновление настроено."
    exit 0
fi

echo "Некорректный выбор. Запустите скрипт снова и введите 1, 2 или 3."

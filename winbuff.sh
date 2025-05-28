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

while true; do
    echo ""
    echo "Выберите этап установки:"
    echo "1 - Первичная настройка"
    echo "2 - Установка обновлений"
    echo "3 - Установка Zabbix"
    echo "4 - Настройка автообновления"
    echo "0 - Выход"
    read -p "Введите номер этапа: " stage

    if [[ "$stage" == "1" ]]; then
        echo "Устанавливаем необходимые пакеты..."
        sed -i '/^deb cdrom:/d' /etc/apt/sources.list
        apt-get update && apt-get upgrade -y
        apt update && apt dist-upgrade -y
        apt-get autoremove -y && apt-get clean -y
        apt-get install -y sudo curl socat git wget lnav htop mc whois gnupg2 ncdu console-cyrillic
        echo "Настройка формата истории команд с временем..."
        echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> ~/.bash_profile
        echo 'export HISTSIZE=10000' >> ~/.bashrc
        echo 'export HISTFILESIZE=10000' >> ~/.bashrc
        echo 'export HISTCONTROL=ignoreboth:erasedups' >> ~/.bashrc
        source ~/.bashrc
        source ~/.bash_profile
        echo "Настройка ускорения TCP..."
        echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
        echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
        sysctl -p || { echo "Ошибка при применении sysctl"; continue; }
        echo "Отключаем IPv6..."
        echo "net.ipv6.conf.all.disable_ipv6 = 1" > /etc/sysctl.d/disable-ipv6.conf
        echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.d/disable-ipv6.conf
        sysctl --system
        echo "Настраиваем sudo для пользователя tech без пароля..."
        echo "tech    ALL=(ALL)    NOPASSWD:ALL" >> /etc/sudoers
        echo "Этап 1 завершен!"

    elif [[ "$stage" == "2" ]]; then
        echo "Установка обновлений..."
        apt-get update && apt-get upgrade -y
        apt update && apt dist-upgrade -y
        apt-get autoremove  -y && apt-get clean -y
        echo "Этап 2 завершен!"

    elif [[ "$stage" == "3" ]]; then
        echo "Перед установкой Zabbix нажмите любую клавишу для продолжения..."
        read -n 1 -s
        ZABBIX_VERSION="7.0"
        DEBIAN_VERSION=$(lsb_release -sc)
        ZABBIX_SERVER="192.168.103.251"
        HOSTNAME=$(hostname)
        echo "Добавляем репозиторий Zabbix $ZABBIX_VERSION для Debian $DEBIAN_VERSION"
        wget -q https://repo.zabbix.com/zabbix/7.0/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.0+debian12_all.deb|| { echo "Ошибка при загрузке репозитория Zabbix"; continue; }
        dpkg -i zabbix-release_latest_7.0+debian12_all.deb || { echo "Ошибка при установке репозитория Zabbix"; continue; }
        apt update || { echo "Ошибка при обновлении списка пакетов"; continue; }
        echo "Устанавливаем Zabbix агент"
        apt install -y zabbix-agent || { echo "Ошибка при установке Zabbix агента"; continue; }
        echo "Настраиваем Zabbix агент"
        sed -i "s/^Server=127.0.0.1/Server=${ZABBIX_SERVER}/" /etc/zabbix/zabbix_agentd.conf
        sed -i "s/^ServerActive=127.0.0.1/ServerActive=${ZABBIX_SERVER}/" /etc/zabbix/zabbix_agentd.conf
        sed -i "s/^Hostname=Zabbix server/Hostname=${HOSTNAME}/" /etc/zabbix/zabbix_agentd.conf
        echo "Перезапускаем Zabbix агент"
        systemctl restart zabbix-agent || { echo "Ошибка при перезапуске Zabbix агента"; continue; }
        systemctl enable zabbix-agent || { echo "Ошибка при включении Zabbix агента"; continue; }
        systemctl status zabbix-agent || { echo "Ошибка при проверке статуса Zabbix агента"; continue; }
        echo "Zabbix агент установлен и настроен!"
        read -n 1 -s

    elif [[ "$stage" == "4" ]]; then
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

    elif [[ "$stage" == "0" ]]; then
        echo "Выход из скрипта."
        exit 0
    else
        echo "Некорректный выбор. Введите 1, 2, 3, 4 или 0 для выхода."
    fi
done

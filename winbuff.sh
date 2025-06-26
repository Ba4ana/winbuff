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

    case "$stage" in
        1)
            echo "Устанавливаем необходимые пакеты..."
            sed -i '/^deb cdrom:/d' /etc/apt/sources.list
            apt-get update && apt-get upgrade -y
            apt update && apt dist-upgrade -y
            apt-get autoremove -y && apt-get clean -y
            apt-get install -y sudo curl socat git wget lnav htop mc whois gnupg2 ncdu console-cyrillic

            echo "Настройка формата истории команд с временем..."
            grep -qx 'export HISTTIMEFORMAT="%d/%m/%y %T "' ~/.bash_profile || echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> ~/.bash_profile
            grep -qx 'export HISTSIZE=10000' ~/.bashrc || echo 'export HISTSIZE=10000' >> ~/.bashrc
            grep -qx 'export HISTFILESIZE=10000' ~/.bashrc || echo 'export HISTFILESIZE=10000' >> ~/.bashrc
            grep -qx 'export HISTCONTROL=ignoreboth:erasedups' ~/.bashrc || echo 'export HISTCONTROL=ignoreboth:erasedups' >> ~/.bashrc
            source ~/.bashrc
            source ~/.bash_profile

            echo "Настройка ускорения TCP..."
            grep -qx 'net.core.default_qdisc=fq' /etc/sysctl.conf || echo 'net.core.default_qdisc=fq' >> /etc/sysctl.conf
            grep -qx 'net.ipv4.tcp_congestion_control=bbr' /etc/sysctl.conf || echo 'net.ipv4.tcp_congestion_control=bbr' >> /etc/sysctl.conf
            sysctl -p || { echo "Ошибка при применении sysctl"; continue; }

            echo "Отключаем IPv6..."
            echo "net.ipv6.conf.all.disable_ipv6 = 1" > /etc/sysctl.d/disable-ipv6.conf
            echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.d/disable-ipv6.conf
            sysctl --system

            echo "Настраиваем sudo для пользователя tech без пароля..."
            if grep -q '^tech\s\+ALL=(ALL)\s\+NOPASSWD:ALL' /etc/sudoers; then
                echo "Пользователь tech уже имеет права sudo без пароля"
                sleep 5
            else
                echo "tech    ALL=(ALL)    NOPASSWD:ALL" >> /etc/sudoers
                echo "Добавлена строка в /etc/sudoers"

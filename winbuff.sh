#!/bin/bash

# Проверка на Debian
if ! grep -qi "debian" /etc/os-release; then
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
    echo "3 - Настройка автообновления"
    echo "4 - Удаление автообновления"
    echo "5 - Установка Zabbix"
    echo "6 - Настройка интерфейса eth0"
    echo "9 - Разрешить подключение root через sftp"
    echo "10 - Стереть историяю команд"
    echo "0 - Выход"
    read -p "Введите номер этапа: " stage

######################
#          I         #
######################

    if [[ "$stage" == "1" ]]; then
        echo "Устанавливаем необходимые пакеты..."
        sed -i '/^deb cdrom:/d' /etc/apt/sources.list
        apt-get update && apt update
        apt-get autoremove -y && apt-get clean -y
        apt-get install -y sudo curl socat git wget lnav htop mc whois gnupg2 ncdu console-cyrillic

        echo "Настройка формата истории команд и окружения..."

        [ -f ~/.bash_profile ] || touch ~/.bash_profile
        [ -f ~/.bashrc ] || touch ~/.bashrc

        sed -i '/^export HISTSIZE=/d' ~/.bashrc
        sed -i '/^export HISTFILESIZE=/d' ~/.bashrc
        sed -i '/^export HISTCONTROL=/d' ~/.bashrc

        grep -qx 'export HISTTIMEFORMAT="%d/%m/%y %T "' ~/.bash_profile || echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> ~/.bash_profile
        grep -qx 'export HISTSIZE=1999' ~/.bash_profile || echo 'export HISTSIZE=1999' >> ~/.bash_profile
        grep -qx 'export HISTFILESIZE=1999' ~/.bash_profile || echo 'export HISTFILESIZE=1999' >> ~/.bash_profile
        grep -qx 'export HISTCONTROL=ignoreboth:erasedups' ~/.bash_profile || echo 'export HISTCONTROL=ignoreboth:erasedups' >> ~/.bash_profile
        grep -Fxq "export HISTIGNORE='shutdown:reboot:history*:exit:ls:mc:htop:apt*'" ~/.bash_profile || echo "export HISTIGNORE='shutdown:reboot:history*:exit:ls:mc:htop:apt*'" >> ~/.bash_profile
        grep -qx "PROMPT_COMMAND='history -a'" ~/.bash_profile || echo "PROMPT_COMMAND='history -a'" >> ~/.bash_profile

        if [ -d /home/tech ]; then
            [ -f /home/tech/.bash_profile ] || touch /home/tech/.bash_profile
            [ -f /home/tech/.bashrc ] || touch /home/tech/.bashrc

            sed -i '/^export HISTSIZE=/d' /home/tech/.bashrc 2>/dev/null
            sed -i '/^export HISTFILESIZE=/d' /home/tech/.bashrc 2>/dev/null
            sed -i '/^export HISTCONTROL=/d' /home/tech/.bashrc 2>/dev/null

            grep -qx 'export HISTTIMEFORMAT="%d/%m/%y %T "' /home/tech/.bash_profile || echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> /home/tech/.bash_profile
            grep -qx 'export HISTSIZE=1999' /home/tech/.bash_profile || echo 'export HISTSIZE=1999' >> /home/tech/.bash_profile
            grep -qx 'export HISTFILESIZE=1999' /home/tech/.bash_profile || echo 'export HISTFILESIZE=1999' >> /home/tech/.bash_profile
            grep -qx 'export HISTCONTROL=ignoreboth:erasedups' /home/tech/.bash_profile || echo 'export HISTCONTROL=ignoreboth:erasedups' >> /home/tech/.bash_profile
            grep -Fxq "export HISTIGNORE='shutdown:reboot:history*:exit:ls:mc:htop:apt*'" /home/tech/.bash_profile || echo "export HISTIGNORE='shutdown:reboot:history*:exit:ls:mc:htop:apt*'" >> /home/tech/.bash_profile
            grep -qx "PROMPT_COMMAND='history -a'" /home/tech/.bash_profile || echo "PROMPT_COMMAND='history -a'" >> /home/tech/.bash_profile
            chown tech:tech /home/tech/.bash_profile
        fi

        source ~/.bashrc
        source ~/.bash_profile

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
        fi
        echo "Этап 1 завершен!"

######################
#         II         #
######################

    elif [[ "$stage" == "2" ]]; then
        echo "Установка обновлений..."
        apt-get update && apt-get upgrade -y
        apt update && apt dist-upgrade -y
        apt-get autoremove  -y && apt-get clean -y
        echo "Этап 2 завершен!"

######################
#         III        #
######################

    elif [[ "$stage" == "3" ]]; then
        echo "Настраиваем автоматическое обновление..."
        # Удаляет старые ядра, которые больше не используются
        # Удаляет пакеты, которые больше не нужны
        # После обновления пакетов, требующих перезагрузки, система автоматически перезагружается.
        # Автомтаическая перезагрузка в 04:00
        apt update
        apt install unattended-upgrades -y
        dpkg-reconfigure -f noninteractive unattended-upgrades
        #echo 'APT::Periodic::Update-Package-Lists "1";' > /etc/apt/apt.conf.d/20auto-upgrades
        #echo 'APT::Periodic::Unattended-Upgrade "1";' >> /etc/apt/apt.conf.d/20auto-upgrades

        UPG_FILE="/etc/apt/apt.conf.d/50unattended-upgrades"

        declare -A settings
        settings["Unattended-Upgrade::Remove-Unused-kernel-Packages"]="true"
        settings["Unattended-Upgrade::Remove-Unused-Dependencies"]="true"
        settings["Unattended-Upgrade::Automatic-Reboot"]="true"
        settings["Unattended-Upgrade::Automatic-Reboot-Time"]="\"04:00\""

        for key in "${!settings[@]}"; do
            value="${settings[$key]}"
            if grep -q "$key \"$value\";" "$UPG_FILE"; then
                echo "Уже настроено: $key $value"
                sleep 5
            else
                echo "$key \"$value\";" >> "$UPG_FILE"
                echo "Добавлено: $key $value"
            fi
        done
        echo "Автоматическое обновление настроено."

######################
#         IV         #
######################

    elif [[ "$stage" == "4" ]]; then
        echo "Удаляем автоматическое обновление..."

        # Отключаем пакет unattended-upgrades
        systemctl stop unattended-upgrades.service
        systemctl disable unattended-upgrades.service
        systemctl disable apt-daily.timer
        systemctl disable apt-daily-upgrade.timer

        # Удаляем пакет и его конфигурацию
        apt purge -y unattended-upgrades
        apt autoremove -y
        apt clean -y

        # Удаляем созданные ранее файлы и настройки
        rm -f /etc/apt/apt.conf.d/20auto-upgrades
        rm -f /etc/apt/apt.conf.d/50unattended-upgrades

        echo "Автоматическое обновление успешно удалено."
        sleep 10

######################
#          V         #
######################

    elif [[ "$stage" == "5" ]]; then
        echo "Перед установкой Zabbix нажмите любую клавишу для продолжения..."
        read -n 1 -s
        ZABBIX_VERSION="7.0"
        ZABBIX_SERVER="192.168.103.251"
        HOSTNAME=$(hostname)
        DEBIAN_VERSION_ID=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
        DEBIAN_CODENAME=$(grep '^VERSION_CODENAME=' /etc/os-release | cut -d= -f2)

        if [[ "$DEBIAN_VERSION_ID" == "12" ]]; then
            ZABBIX_PKG="zabbix-release_latest_${ZABBIX_VERSION}+debian12_all.deb"
        elif [[ "$DEBIAN_VERSION_ID" == "13" ]]; then
            ZABBIX_PKG="zabbix-release_latest_${ZABBIX_VERSION}+debian13_all.deb"
        else
            echo "Неизвестная версия Debian ($DEBIAN_VERSION_ID, codename: $DEBIAN_CODENAME)"
            echo "Поддерживаются только Debian 12 и 13."
            echo "Скрипт приостановлен на 15 секунд..."
            sleep 15
            continue
        fi

        ZABBIX_URL="https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/debian/pool/main/z/zabbix-release/${ZABBIX_PKG}"
        echo "Добавляем репозиторий Zabbix ${ZABBIX_VERSION} для Debian ${DEBIAN_CODENAME}"
        wget -q "$ZABBIX_URL" || { echo "Ошибка при загрузке репозитория Zabbix"; continue; }
        dpkg -i "$ZABBIX_PKG" || { echo "Ошибка при установке репозитория Zabbix"; continue; }

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

######################
#         VI         #
######################

    elif [[ "$stage" == "6" ]]; then
        echo "Настройка наименования сетевого интерфейса как eth0..."

        if grep -q 'net.ifnames=0' /etc/default/grub; then
            echo "Параметр net.ifnames=0 уже установлен в GRUB"
        else
            sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/net.ifnames=0"/' /etc/default/grub
            echo "Добавлен параметр net.ifnames=0 в GRUB"
            grub-mkconfig -o /boot/grub/grub.cfg || { echo "Ошибка при обновлении конфигурации GRUB"; continue; }
        fi

        if grep -q '^iface eth0 inet dhcp' /etc/network/interfaces; then
            echo "Интерфейс eth0 уже настроен"
        else
            cat << EOF >> /etc/network/interfaces

# The primary network interface
allow-hotplug eth0
iface eth0 inet dhcp
EOF
            echo "Добавлена настройка интерфейса eth0 в /etc/network/interfaces"
        fi

        systemctl restart networking || { echo "Ошибка при перезапуске networking"; continue; }

        echo "Настройка интерфейса eth0 завершена. Требуется перезагрузка системы для применения изменений."
        read -n 1 -s -p "Нажмите любую клавишу для продолжения..."

######################
#         VII        #
######################


######################
#         VIII       #
######################


######################
#         IX         #
######################

    elif [[ "$stage" == "9" ]]; then
        # Разрешить sftp по root
        sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config 
        systemctl restart ssh
        systemctl restart sshd

######################
#         X          #
######################

    elif [[ "$stage" == "10" ]]; then
        # Стереть всю историю
        echo>~/.bash_history
        clear

######################
#          N         #
######################

    elif [[ "$stage" == "0" ]]; then
        echo "Выход из скрипта."
        exit 0

######################
#        E N D       #
######################
    else
        echo "Некорректный выбор. Введите цыфру или 0 для выхода."
    fi
done
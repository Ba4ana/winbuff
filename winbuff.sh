#!/bin/bash

### Цвета
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

### Проверка root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}Скрипт должен быть запущен от root${RESET}"
    exit 1
fi

### Меню
while true; do
    ### Информация о системе при запуске
    DISTRO=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
    HOST=$(hostname)
    IP=$(hostname -I | awk '{print $1}')
    LOAD=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ //')
    MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{printf "%.0f\n", $2/1024}')
    MEM_FREE=$(grep MemAvailable /proc/meminfo | awk '{printf "%.0f\n", $2/1024}')
    MEM_USED=$((MEM_TOTAL - MEM_FREE))
    MEM_PERC=$(( MEM_USED * 100 / MEM_TOTAL ))

    echo -e "${BLUE}============================================================${RESET}"
    echo -e "${GREEN}   SYSTEM INFORMATION${RESET}"
    echo -e "${BLUE}============================================================${RESET}"
    echo -e "${YELLOW}Distro:           ${RESET}${DISTRO}"
    echo -e "${YELLOW}Hostname:         ${RESET}${HOST}"
    echo -e "${YELLOW}IP:               ${RESET}${IP}"
    echo -e "${YELLOW}Load average:     ${RESET}${LOAD}"
    echo -e "${YELLOW}RAM:              ${RESET}${MEM_USED}MB / ${MEM_TOTAL}MB (${MEM_PERC}%)"
    echo -e "${BLUE}============================================================${RESET}"
    echo ""
    echo -e "${GREEN}Выберите этап:${RESET}"
    echo -e "${YELLOW}1${RESET}  - Первичная настройка"
    echo -e "${YELLOW}2${RESET}  - Установка обновлений"
    echo -e "${YELLOW}3${RESET}  - Настройка автообновления"
    echo -e "${YELLOW}4${RESET}  - Удаление автообновления"
    echo -e "${YELLOW}5${RESET}  - Установка Zabbix"
    echo -e "${YELLOW}6${RESET}  - Настройка eth0"
    echo -e "${YELLOW}7${RESET}  - Обновление Debian 12 -> 13 (автоматически)"
    echo -e "${YELLOW}8${RESET}  - Создать пользователя tech"
    echo -e "${YELLOW}9${RESET}  - SFTP root"
    echo -e "${YELLOW}10${RESET} - Очистить историю"
    echo -e "${YELLOW}0${RESET}  - Выход"
    read -p "Введите номер: " stage

###################### 1 ######################
if [[ "$stage" == "1" ]]; then
    echo -e "${BLUE}Устанавливаем пакеты...${RESET}"
    sed -i '/^deb cdrom:/d' /etc/apt/sources.list
    apt update && apt-get update
    apt-get autoremove -y && apt-get clean -y
    apt-get install -y sudo curl socat git wget lnav btop mc whois gnupg2 ncdu console-cyrillic

    echo -e "${BLUE}Настройка истории...${RESET}"
    for USER_HOME in /root /home/tech; do
        if [ -d "$USER_HOME" ]; then
            touch $USER_HOME/.bash_profile
            touch $USER_HOME/.bashrc
            sed -i '/^export HIST/d' $USER_HOME/.bash_profile
            grep -qx 'export HISTTIMEFORMAT="%d/%m/%y %T "' $USER_HOME/.bash_profile || echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> $USER_HOME/.bash_profile
            grep -qx 'export HISTSIZE=1999' $USER_HOME/.bash_profile || echo 'export HISTSIZE=1999' >> $USER_HOME/.bash_profile
            grep -qx 'export HISTFILESIZE=1999' $USER_HOME/.bash_profile || echo 'export HISTFILESIZE=1999' >> $USER_HOME/.bash_profile
            grep -qx 'export HISTCONTROL=ignoreboth:erasedups' $USER_HOME/.bash_profile || echo 'export HISTCONTROL=ignoreboth:erasedups' >> $USER_HOME/.bash_profile
            grep -Fxq "export HISTIGNORE='shutdown:reboot:history*:exit:ls:mc:htop:btop:apt*'" $USER_HOME/.bash_profile || echo "export HISTIGNORE='shutdown:reboot:history*:exit:ls:mc:htop:apt*'" >> $USER_HOME/.bash_profile
            grep -qx "PROMPT_COMMAND='history -a'" $USER_HOME/.bash_profile || echo "PROMPT_COMMAND='history -a'" >> $USER_HOME/.bash_profile
        fi
    done

    echo -e "${BLUE}Отключаем IPv6...${RESET}"
    cat > /etc/sysctl.d/disable-ipv6.conf <<EOF
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
    sysctl --system

    echo -e "${BLUE}Настройка sudo для tech...${RESET}"
    if id tech &>/dev/null; then
        if ! grep -q '^tech\s\+ALL=' /etc/sudoers ; then
            echo "tech    ALL=(ALL)    NOPASSWD:ALL" >> /etc/sudoers
        fi
    fi

    echo -e "${GREEN}Этап 1 завершен!${RESET}"

###################### 2 ######################
elif [[ "$stage" == "2" ]]; then
    echo -e "${BLUE}Обновляем систему...${RESET}"
    apt update && apt upgrade -y && apt dist-upgrade -y
    apt autoremove -y && apt clean -y
    echo -e "${GREEN}Этап 2 завершен${RESET}"

###################### 3 ######################
elif [[ "$stage" == "3" ]]; then
    echo -e "${BLUE}Настраиваем автообновление...${RESET}"
    apt update
    apt install unattended-upgrades -y
    dpkg-reconfigure -f noninteractive unattended-upgrades

    CONF="/etc/apt/apt.conf.d/50unattended-upgrades"
    declare -A cfg=(
        ["Unattended-Upgrade::Remove-Unused-kernel-Packages"]="true"
        ["Unattended-Upgrade::Remove-Unused-Dependencies"]="true"
        ["Unattended-Upgrade::Automatic-Reboot"]="true"
        ["Unattended-Upgrade::Automatic-Reboot-Time"]="\"04:00\""
    )
    for key in "${!cfg[@]}"; do
        if ! grep -q "$key" "$CONF"; then
            echo "$key \"${cfg[$key]}\";" >> "$CONF"
        fi
    done
    echo -e "${GREEN}Автообновление включено${RESET}"

###################### 4 ######################
elif [[ "$stage" == "4" ]]; then
    echo -e "${BLUE}Удаляем автообновление...${RESET}"
    systemctl stop unattended-upgrades.service
    systemctl disable unattended-upgrades.service
    systemctl disable apt-daily.timer apt-daily-upgrade.timer
    apt purge -y unattended-upgrades
    apt autoremove -y
    rm -f /etc/apt/apt.conf.d/20auto-upgrades
    rm -f /etc/apt/apt.conf.d/50unattended-upgrades
    echo -e "${GREEN}Автообновление удалено${RESET}"

###################### 5 ######################
elif [[ "$stage" == "5" ]]; then
    echo -e "${BLUE}Устанавливаем Zabbix...${RESET}"
    ZVER="7.0"
    SERVER="192.168.103.251"
    HOST=$(hostname)
    VER=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    if [[ "$VER" != "12" && "$VER" != "13" ]]; then
        echo -e "${RED}Поддерживается только Debian 12/13${RESET}"
        sleep 5
        continue
    fi
    PKG="zabbix-release_latest_${ZVER}+debian${VER}_all.deb"
    URL="https://repo.zabbix.com/zabbix/${ZVER}/debian/pool/main/z/zabbix-release/${PKG}"
    wget -q "$URL" && dpkg -i "$PKG"
    apt update
    apt install -y zabbix-agent
    sed -i "s/^Server=.*/Server=${SERVER}/" /etc/zabbix/zabbix_agentd.conf
    sed -i "s/^ServerActive=.*/ServerActive=${SERVER}/" /etc/zabbix/zabbix_agentd.conf
    sed -i "s/^Hostname=.*/Hostname=${HOST}/" /etc/zabbix/zabbix_agentd.conf
    systemctl restart zabbix-agent
    systemctl enable zabbix-agent
    echo -e "${GREEN}Zabbix установлен${RESET}"

###################### 6 ######################
elif [[ "$stage" == "6" ]]; then
    echo -e "${BLUE}Настройка eth0...${RESET}"

    if ! grep -q 'net.ifnames=0' /etc/default/grub; then
        sed -i '/GRUB_CMDLINE_LINUX=/ s/"$/ net.ifnames=0"/' /etc/default/grub
        grub-mkconfig -o /boot/grub/grub.cfg
    fi

    if ! grep -q '^iface eth0 inet dhcp' /etc/network/interfaces; then
        cat <<EOF >> /etc/network/interfaces

allow-hotplug eth0
iface eth0 inet dhcp
EOF
    fi

    systemctl restart networking
    echo -e "${GREEN}Готово. Требуется перезагрузка.${RESET}"

###################### 7 ######################
elif [[ "$stage" == "7" ]]; then
    VER=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    if [[ "$VER" != "12" ]]; then
        echo -e "${RED}Этот этап предназначен только для Debian 12. Текущая версия: ${VER}${RESET}"
        sleep 5
        continue
    fi

    echo -e "${BLUE}Подготовка: обновляем Debian 12 до актуального состояния...${RESET}"
    export DEBIAN_FRONTEND=noninteractive
    apt update
    apt -y upgrade
    apt -y full-upgrade
    apt -y autoremove
    apt -y clean

    echo -e "${BLUE}Отключаем сторонние репозитории (если есть) и готовим sources.list...${RESET}"
    mkdir -p /root/upgrade-backup
    cp -a /etc/apt/sources.list /root/upgrade-backup/sources.list.$(date +%F_%H%M%S)

    if [ -d /etc/apt/sources.list.d ]; then
        tar -czf /root/upgrade-backup/sources.list.d.$(date +%F_%H%M%S).tgz /etc/apt/sources.list.d 2>/dev/null || true
    fi

    if [ -d /etc/apt/sources.list.d ]; then
        find /etc/apt/sources.list.d -maxdepth 1 -type f -name "*.list" -exec mv -f {} {}.disabled \; 2>/dev/null || true
    fi

    sed -i 's/bookworm/trixie/g' /etc/apt/sources.list
    sed -i 's/Bookworm/Trixie/g' /etc/apt/sources.list
    sed -i '/^deb cdrom:/d' /etc/apt/sources.list

    echo -e "${BLUE}Обновляем списки пакетов для Debian 13 (trixie)...${RESET}"
    apt update

    echo -e "${BLUE}Выполняем dist-upgrade (full-upgrade) до Debian 13...${RESET}"
    apt -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" full-upgrade

    echo -e "${BLUE}Чистим систему...${RESET}"
    apt -y autoremove
    apt -y clean

    NEWVER=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    echo -e "${GREEN}Обновление завершено. Текущая версия Debian: ${NEWVER}${RESET}"
    echo -e "${YELLOW}Рекомендуется перезагрузка.${RESET}"

###################### 8 ######################
elif [[ "$stage" == "8" ]]; then
    echo -e "${BLUE}Создание пользователя tech...${RESET}"

    if id tech &>/dev/null; then
        echo -e "${YELLOW}Пользователь tech уже существует${RESET}"
    else
        useradd -m -s /bin/bash tech
        echo -e "${GREEN}Пользователь tech создан${RESET}"
    fi

    echo -e "${BLUE}Задайте пароль для tech:${RESET}"
    passwd tech

    if ! id tech &>/dev/null; then
        echo -e "${RED}Ошибка создания пользователя${RESET}"
        continue
    fi

    usermod -aG sudo tech

    if ! grep -q '^tech\s\+ALL=' /etc/sudoers ; then
        echo "tech    ALL=(ALL)    NOPASSWD:ALL" >> /etc/sudoers
    fi

    echo -e "${GREEN}Пользователь tech готов и добавлен в sudo${RESET}"

###################### 9 ######################
elif [[ "$stage" == "9" ]]; then
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    systemctl restart sshd
    echo -e "${GREEN}SFTP root разрешён${RESET}"

###################### 10 ######################
elif [[ "$stage" == "10" ]]; then
    echo > ~/.bash_history
    history -c
    clear
    echo -e "${GREEN}История очищена${RESET}"

###################### EXIT ######################
elif [[ "$stage" == "0" ]]; then
    echo -e "${GREEN}Выход...${RESET}"
    exit 0

else
    echo -e "${RED}Некорректный ввод${RESET}"
fi

done

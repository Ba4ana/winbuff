#!/bin/bash

# Проверка только на Debian
OS_ID=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
if [[ "$OS_ID" != "debian" ]]; then
    echo "Этот скрипт предназначен только для Debian"
    exit 1
fi

# Проверка root прав
if [[ $EUID -ne 0 ]]; then
    echo "Этот скрипт должен быть запущен с правами root"
    exit 1
fi

# Функция отображения системной информации
system_info() {
    DISTRO=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
    HOST=$(hostname)
    IP=$(hostname -I | awk '{print $1}')
    LOAD=$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ //')
    MEM=$(free -h | awk '/Mem:/ {print $3 "/" $2}')

    echo ""
    echo "========== СИСТЕМНАЯ ИНФОРМАЦИЯ =========="
    echo "Дистрибутив  : $DISTRO"
    echo "Hostname     : $HOST"
    echo "IP адрес     : $IP"
    echo "Load Average : $LOAD"
    echo "RAM usage    : $MEM"
    echo "=========================================="
    echo ""
}

# Основной цикл
while true; do
    system_info

    echo "Выберите этап установки:"
    echo "1 - Первичная настройка"
    echo "2 - Установка обновлений"
    echo "3 - Настройка автообновления"
    echo "4 - Удаление автообновления"
    echo "5 - Установка Zabbix"
    echo "6 - Настройка интерфейса eth0"
    echo "9 - Разрешить подключение root через sftp"
    echo "10 - Стереть историю команд"
    echo "0 - Выход"
    read -p "Введите номер этапа: " stage

########################################
### I — ПЕРВИЧНАЯ НАСТРОЙКА
########################################
if [[ "$stage" == "1" ]]; then
    echo "Устанавливаем необходимые пакеты..."
    sed -i '/^deb cdrom:/d' /etc/apt/sources.list
    apt update && apt-get update
    apt-get autoremove -y && apt-get clean -y
    apt install -y sudo curl socat git wget lnav htop mc whois gnupg2 ncdu console-cyrillic

    echo "Настройка истории команд..."
    for user in root tech; do
        HOME_DIR=$(eval echo ~$user)
        [ -d "$HOME_DIR" ] || continue
        [ -f "$HOME_DIR/.bash_profile" ] || touch "$HOME_DIR/.bash_profile"

        {
            echo 'export HISTTIMEFORMAT="%d/%m/%y %T "'
            echo 'export HISTSIZE=1999'
            echo 'export HISTFILESIZE=1999'
            echo 'export HISTCONTROL=ignoreboth:erasedups'
            echo "export HISTIGNORE='shutdown:reboot:history*:exit:ls:mc:htop:apt*'"
            echo "PROMPT_COMMAND='history -a'"
        } >> "$HOME_DIR/.bash_profile"

        chown "$user":"$user" "$HOME_DIR/.bash_profile" 2>/dev/null
    done

    echo "Отключаем IPv6..."
    echo "net.ipv6.conf.all.disable_ipv6 = 1" > /etc/sysctl.d/disable-ipv6.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.d/disable-ipv6.conf
    sysctl --system

    echo "Настраиваем sudo без пароля для tech..."
    if ! grep -q '^tech\s\+ALL=(ALL)\s\+NOPASSWD:ALL' /etc/sudoers; then
        echo "tech    ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    fi

    echo "Этап 1 завершен!"

########################################
### II — ОБНОВЛЕНИЕ СИСТЕМЫ
########################################
elif [[ "$stage" == "2" ]]; then
    echo "Установка обновлений..."
    apt update && apt-get update
    apt upgrade -y
    apt dist-upgrade -y
    apt autoremove -y && apt clean -y
    echo "Этап 2 завершен!"

########################################
### III — НАСТРОЙКА АВТООБНОВЛЕНИЯ
########################################
elif [[ "$stage" == "3" ]]; then
    echo "Настраиваем автообновление..."

    apt update
    apt install -y unattended-upgrades
    dpkg-reconfigure -f noninteractive unattended-upgrades

    UPG="/etc/apt/apt.conf.d/50unattended-upgrades"

    echo 'Unattended-Upgrade::Remove-Unused-kernel-Packages "true";' >> $UPG
    echo 'Unattended-Upgrade::Remove-Unused-Dependencies "true";' >> $UPG
    echo 'Unattended-Upgrade::Automatic-Reboot "true";' >> $UPG
    echo 'Unattended-Upgrade::Automatic-Reboot-Time "04:00";' >> $UPG

    echo "Автоматическое обновление настроено."

########################################
### IV — УДАЛЕНИЕ АВТООБНОВЛЕНИЯ
########################################
elif [[ "$stage" == "4" ]]; then
    echo "Удаляем автоматическое обновление..."

    systemctl stop unattended-upgrades.service
    systemctl disable unattended-upgrades.service
    systemctl disable apt-daily.timer
    systemctl disable apt-daily-upgrade.timer

    apt purge -y unattended-upgrades
    apt autoremove -y
    apt clean -y

    rm -f /etc/apt/apt.conf.d/20auto-upgrades
    rm -f /etc/apt/apt.conf.d/50unattended-upgrades

    echo "Удалено успешно."

########################################
### V — УСТАНОВКА ZABBIX
########################################
elif [[ "$stage" == "5" ]]; then
    echo "Установка Zabbix..."
    read -n 1 -s

    ZABBIX_VERSION="7.0"
    ZABBIX_SERVER="192.168.103.251"
    HOSTNAME=$(hostname)
    VER=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

    if [[ "$VER" == "12" ]]; then
        PKG="zabbix-release_latest_${ZABBIX_VERSION}+debian12_all.deb"
    elif [[ "$VER" == "13" ]]; then
        PKG="zabbix-release_latest_${ZABBIX_VERSION}+debian13_all.deb"
    else
        echo "Поддерживаются только Debian 12 и 13."
        sleep 10
        continue
    fi

    URL="https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/debian/pool/main/z/zabbix-release/${PKG}"

    wget -q "$URL" || { echo "Ошибка загрузки"; continue; }
    dpkg -i "$PKG" || { echo "Ошибка установки"; continue; }

    apt update
    apt install -y zabbix-agent

    sed -i "s/^Server=.*/Server=$ZABBIX_SERVER/" /etc/zabbix/zabbix_agentd.conf
    sed -i "s/^ServerActive=.*/ServerActive=$ZABBIX_SERVER/" /etc/zabbix/zabbix_agentd.conf
    sed -i "s/^Hostname=.*/Hostname=$HOSTNAME/" /etc/zabbix/zabbix_agentd.conf

    systemctl restart zabbix-agent
    systemctl enable zabbix-agent

    echo "Zabbix установлен."

########################################
### VI — eth0
########################################
elif [[ "$stage" == "6" ]]; then
    echo "Настройка eth0..."

    if ! grep -q 'net.ifnames=0' /etc/default/grub; then
        sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="net.ifnames=0 /' /etc/default/grub
        grub-mkconfig -o /boot/grub/grub.cfg
    fi

    if ! grep -q '^iface eth0 inet dhcp' /etc/network/interfaces; then
        cat << EOF >> /etc/network/interfaces

allow-hotplug eth0
iface eth0 inet dhcp
EOF
    fi

    systemctl restart networking
    echo "Требуется перезагрузка."

########################################
### IX — SFTP ROOT
########################################
elif [[ "$stage" == "9" ]]; then
    sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    systemctl restart sshd
    echo "Root SFTP разрешён."

########################################
### X — ОЧИСТКА ИСТОРИИ
########################################
elif [[ "$stage" == "10" ]]; then
    echo > ~/.bash_history
    history -c
    clear
    echo "История очищена."

########################################
# ВЫХОД
########################################
elif [[ "$stage" == "0" ]]; then
    exit 0

else
    echo "Некорректный ввод."
fi

done

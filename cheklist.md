1. �������� �������:
   - ���������, ��� ������� �������� Debian, ����� ����� �� �������.
   - ���������, ��� ������ ������� � ������� root, ����� ����� �� �������.

2. ��������� ����������� �������:
   - �������� ������ ������� (`apt-get update`).
   - ���������� ���������� (`apt-get upgrade -y`).
   - ��������� �������������� ���������� (`apt dist-upgrade -y`).
   - �������� �������� ������ (`apt-get autoremove -y`).
   - �������� ��� (`apt-get clean -y`).
   - ���������� ������ (`sudo, curl, wget, lnav, htop, mc, whois, gnupg2, ncdu`).

3. ��������� ������� ������:
   - �������� � `~/.bash_profile` ������ ������ ������� � ������� ������.
   - ���������� ������ ������� � `~/.bashrc` (`HISTSIZE=10000`, `HISTFILESIZE=10000`).
   - ������ ������������ ������ � ������� (`HISTCONTROL=ignoreboth:erasedups`).
   - ��������� ��������� (`source ~/.bashrc` � `source ~/.bash_profile`).
   - �������� ������� ������ (`echo>~/.bash_history`).

4. ����������� TCP:
   - �������� ����������� `fq` ��� �������� �������.
   - �������� �������� �������� ���������� BBR.
   - ��������� ��������� (`sysctl -p`).

5. ��������� ����� Midnight Commander:
   - ���������� ����� `console-cyrillic`.
   - ������������������� ������ (`dpkg-reconfigure locales`).

6. ���������� IPv6:
   - ������� ���� `/etc/sysctl.d/disable-ipv6.conf` � ����������� ���������� IPv6.
   - ��������� ��������� (`sysctl --system`).

7. �������� ����� ���������� Zabbix:
   - ������� ��������� � ������� ������� ������� �������������.

8. ��������� ���������� ��� ��������� Zabbix:
   - ���������� ���������� `ZABBIX_VERSION=7.0`.
   - ���������� ������ Debian (`lsb_release -sc`).
   - ������ IP-����� ������� Zabbix.
   - �������� ��� ����� (`hostname`).

9. ��������� ����������� Zabbix:
   - ������� ����������� Zabbix.
   - ���������� ��������� �����.
   - �������� ������ �������.

10. ��������� Zabbix-������:
    - ���������� `zabbix-agent2`.

11. ��������� Zabbix-������:
    - �������� `Server`, `ServerActive`, `Hostname` � `/etc/zabbix/zabbix_agentd.conf`.

12. ���������� Zabbix-�������:
    - ������������� `zabbix-agent`.
    - �������� ��� � ����������.
    - ��������� ��� ������.

13. ��������� ��������� � �������� �������������:
    - ������� ��������� �� �������� ���������.
    - ������� ������� ������� �������������.


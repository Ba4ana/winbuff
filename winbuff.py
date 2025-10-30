# -*- coding: cp1251 -*-
import time
import os
import subprocess
import shutil
import zipfile
import requests
import winreg
import logging
import platform
from pathlib import Path
from ftplib import FTP
import socket

def has_internet(timeout=3):
    """Ïðîñòåéøàÿ ïðîâåðêà èíòåðíåò-ñîåäèíåíèÿ: ïðîáóåì óñòàíîâèòü TCP-ñîåäèíåíèå ñ ïóáëè÷íûì DNS."""
    try:
        socket.create_connection(("8.8.8.8", 53), timeout=timeout)
        return True
    except Exception:
        return False


def warn_and_pause(msg, seconds=10):
    if msg:
        print(msg)
    try:
        time.sleep(seconds)
    except KeyboardInterrupt:
        pass


def main():
    ver = "0053"
    name = "_winbuff"
    main = os.path.join(r"C:\Windows", name)
    logs = os.path.join(main, "log")
    temp = os.path.join(main, "temp")
    adms = r"C:\Admins\add"
    for path in [main, logs, temp, adms]:
        Path(path).mkdir(parents=True, exist_ok=True)

    steps = [
        (setup_console, ()),
        (print_info, (ver, name)),
        (setup_7zip, (adms,)),
        (download_and_extract, (name, temp)),
        (copy_files, (temp, main, adms, name)),
        (setup_autostart, (name, temp)),
        (update_registry, ()),
        (update_execution_policy, ()),
        (run_next_script, (temp, name)),
    ]

    for func, args in steps:
        try:
            func(*args)
        except KeyboardInterrupt:
            print("Ïðåðâàíî ïîëüçîâàòåëåì.")
            break
        except Exception as e:
            print(f"Ïðîèçîøëà îøèáêà ïðè âûïîëíåíèè {func.__name__}: {e}")
            warn_and_pause("Ïðîèçîøëà îøèáêà, ïðîäîëæàþ ÷åðåç 10 ñåêóíä...", 10)

def setup_console():
    os.system('color 0a')
    os.system('title Ïîäãîòîâêà ñèñòåìû')
    os.system('cls')

def print_info(ver, name):
    print("=" * 64)
    print (f"[                ß óòèëèòà îïòèìèçàöèè ñèñòåìû v.{ver}          ]")
    print ("[          Íóæíà äëÿ òîãî ÷òîáû óñêîðèòü è îáåçîïàñèòü         ]")
    print ("[                   ðàáîòó âàøåãî çâåðüêà                      ]")
    print ("[                                                              ]")
    print ("[            Ïîñòîÿííî  ñîâåðøåíñòâóþñü è ïîçíàþ íîâîå         ]")
    print ("[      Ïåðåä òåì êàê ðàáîòàòü ÿ ñîçäàþ òî÷êó âîññòàíîâëåíèÿ    ]")
    print ("[              ïîýòîìó âñå äåéñòâèÿ ìîæíî îòìåíèòü             ]")
    print ("[                                                              ]")
    print ("[               Èíôîðìàöèþ îá ìíå ìîæíî óçíàòü                 ]")
    print ("[             ó âàøåãî ñèñòåìíîãî àäìèíèñòðàòîðà               ]")
    print ("[                                                              ]")
    print ("[        ×òîáû ÿ ïðåêðàòèëà ðàáîòó  çàêðîéòå îêíî èëè          ]")
    print ("[    Íàæìèòå êíîïêó [ Õ ] â ïðàâîì âåðõíåì óãëó ýòîãî îêíà     ]")
    print ("[                        Ïðîäîëæèì?                            ]")
    print("=" * 64)

def setup_7zip(adms):
    seven_zip_display_version = "25.01"
    seven_zip_download_version = "2501"

    arch = platform.machine()
    if arch.endswith('64'):
        os_architecture = "64-bit"
    else:
        os_architecture = "32-bit"

    seven_zip_installer = f"7z{seven_zip_download_version}-x64.exe" if "64" in os_architecture else f"7z{seven_zip_download_version}.exe"
    seven_zip_install_path = os.path.join(adms, "components", "7zip", seven_zip_installer)
    seven_zip_exe_path = r"C:\Program Files\7-Zip\7z.exe"

    def get_installed_7zip_version():
        if os.path.exists(seven_zip_exe_path):
            try:
                output = subprocess.check_output([seven_zip_exe_path], universal_newlines=True)
                version_line = [line for line in output.splitlines() if "7-Zip" in line]
                if version_line:
                    version = version_line[0].replace("7-Zip", "").strip().split()[0]
                    return version
            except subprocess.CalledProcessError:
                return None
        return None

    if os.path.exists(seven_zip_exe_path):
        installed_version = get_installed_7zip_version()
        if installed_version:
            installed_version = installed_version.strip()
            print(f"Óñòàíîâëåííàÿ âåðñèÿ 7-Zip: {installed_version}")
        else:
            print("Íå óäàëîñü îïðåäåëèòü âåðñèþ óñòàíîâëåííîãî 7-Zip.")

        if installed_version == seven_zip_display_version.strip():
            print(f"7-Zip âåðñèè {seven_zip_display_version} óæå óñòàíîâëåí.")
            return
    else:
        print("7-Zip íå óñòàíîâëåí. Íà÷èíàåì óñòàíîâêó.")

    if not os.path.exists(seven_zip_install_path):
        print("Çàãðóçêà 7-Zip...")
        os.makedirs(os.path.dirname(seven_zip_install_path), exist_ok=True)
        download_link = f"https://www.7-zip.org/a/{seven_zip_installer}"
        if not has_internet():
            warn_and_pause("Íåò èíòåðíåò-ñîåäèíåíèÿ, ïðîïóñêàþ çàãðóçêó 7-Zip.", 10)
        else:
            try:
                response = requests.get(download_link, timeout=15)
                if response.status_code == 200:
                    with open(seven_zip_install_path, 'wb') as f:
                        f.write(response.content)
                    print("7-Zip óñïåøíî çàãðóæåí.")
                else:
                    print(f"Íå óäàëîñü çàãðóçèòü 7-Zip, êîä: {response.status_code}")
                    warn_and_pause("Ïðîáëåìà ïðè çàãðóçêå 7-Zip, ïðîäîëæàþ âûïîëíåíèå...", 10)
            except Exception as e:
                print(f"Îøèáêà ïðè çàãðóçêå 7-Zip: {e}")
                warn_and_pause("Îøèáêà ñåòè ïðè çàãðóçêå 7-Zip, ïðîäîëæàþ âûïîëíåíèå...", 10)
    else:
        print("Óñòàíîâî÷íûé ôàéë 7-Zip óæå çàãðóæåí.")

    print("Óñòàíîâêà 7-Zip...")
    subprocess.run([seven_zip_install_path, '/S'])
    print("7-Zip óñòàíîâëåí.")

def download_and_extract(name, temp):
    ftp_url = "winbuff.evrasia.spb.ru"
    ftp_path = f"/{name}.zip"
    local_path = os.path.join(temp, f"{name}.zip")
    user = "u1206988_upd_win"
    password = "0912832130Ws@"
    # Ïîïûòêà çàãðóçêè àðõèâà ÷åðåç FTP, íî ïðè îòñóòñòâèè ñåòè èëè îøèáêå — ëîãèðóåì è ïðîäîëæàåì
    if has_internet():
        try:
            ftp = FTP(ftp_url)
            # if user not provided, attempt anonymous login
            if not user:
                ftp.login()
            else:
                ftp.login(user, password)
            with open(local_path, 'wb') as f:
                ftp.retrbinary(f"RETR {ftp_path}", f.write)
            ftp.quit()
            print(f"Ôàéë {name}.zip óñïåøíî çàãðóæåí.")
        except Exception as e:
            print(f"Îøèáêà ïðè çàãðóçêå ôàéëà: {e}")
            warn_and_pause("Îøèáêà ïðè çàãðóçêå àðõèâà, ïðîäîëæàþ âûïîëíåíèå...", 10)
    else:
        warn_and_pause("Íåò èíòåðíåò-ñîåäèíåíèÿ, ïðîïóñêàþ çàãðóçêó àðõèâà.", 10)

    # Åñëè ôàéë äîñòóïåí — ðàñïàêîâûâàåì, èíà÷å ïðîäîëæàåì ðàáîòó áåç èñêëþ÷åíèÿ
    if os.path.exists(local_path):
        try:
            with zipfile.ZipFile(local_path, 'r') as zip_ref:
                zip_ref.extractall(temp)
        except Exception as e:
            print(f"Îøèáêà ïðè ðàñïàêîâêå àðõèâà: {e}")
            warn_and_pause("Îøèáêà ðàñïàêîâêè àðõèâà, ïðîäîëæàþ âûïîëíåíèå...", 10)
    else:
        print(f"Ôàéë {local_path} íå íàéäåí — ïðîïóñêàþ ðàñïàêîâêó.")
        warn_and_pause("Ôàéë àðõèâà îòñóòñòâóåò, ïðîäîëæàþ âûïîëíåíèå...", 10)

def copy_files(temp, main, adms, name):
    ps1_src = os.path.join(temp, f"{name}.ps1")
    try:
        if os.path.exists(ps1_src):
            shutil.copy(ps1_src, main)
        else:
            print(f"Ôàéë {ps1_src} íå íàéäåí, ïðîïóñêàþ êîïèðîâàíèå .ps1")
            warn_and_pause("Ôàéë .ps1 îòñóòñòâóåò, ïðîäîëæàþ âûïîëíåíèå...", 10)
    except Exception as e:
        print(f"Îøèáêà ïðè êîïèðîâàíèè .ps1: {e}")
        warn_and_pause("Îøèáêà ïðè êîïèðîâàíèè .ps1, ïðîäîëæàþ âûïîëíåíèå...", 10)

    result = subprocess.run(["robocopy", os.path.join(temp, "add"), adms, "/MIR", "/Z", "/XO", "/R:0", "/W:5"], check=False)
    if result.returncode > 3:
        raise subprocess.CalledProcessError(result.returncode, result.args, output=result.stdout, stderr=result.stderr)

def setup_autostart(name, temp):
    task_xml_path = os.path.join(temp, f"{name}.xml")
    try:
        result = subprocess.run(["schtasks", "/Query", "/TN", name], capture_output=True, text=True, encoding='cp866')
        if result.returncode != 0:
            print(f"Ñîçäàíèå çàäà÷è ïëàíèðîâùèêà äëÿ {name}...")
            subprocess.run(["schtasks", "/Create", "/TN", name, "/XML", task_xml_path, "/F"], capture_output=True, text=True, encoding='cp866')
            print("Çàäà÷à óñïåøíî ñîçäàíà.")
        else:
            print("Çàäà÷à óæå ñóùåñòâóåò, ïåðåñîçäàíèå íå òðåáóåòñÿ.")
    except subprocess.CalledProcessError as e:
        raise Exception(f"Îøèáêà ïðè íàñòðîéêå àâòîçàïóñêà: {e}")
    except UnicodeDecodeError as e:
        print("Îøèáêà äåêîäèðîâàíèÿ ñèìâîëîâ. Âîçìîæíî, íåîáõîäèìî èçìåíèòü êîäèðîâêó.")

def update_registry():
    try:
        subprocess.run(['reg', 'delete', 'HKCR\\Microsoft.PowerShellScript.1\\Shell\\0', '/f'], capture_output=True, text=True)
        subprocess.run(['reg', 'add', 'HKCR\\SystemFileAssociations\\.ps1\\Shell\\runas', '/v', 'HasLUAShield', '/t', 'REG_SZ', '/f'], capture_output=True, text=True)
        subprocess.run(['reg', 'add', 'HKCR\\SystemFileAssociations\\.ps1\\Shell\\runas\\command', '/ve', '/t', 'REG_SZ', '/d', 'c:\\windows\\system32\\windowspowershell\\v1.0\\powershell.exe "%1"', '/f'], capture_output=True, text=True)
        subprocess.run(['reg', 'add', 'HKCU\\Software\\Classes\\Applications\\powershell.exe\\shell\\open\\command', '/ve', '/t', 'REG_SZ', '/d', 'c:\\windows\\system32\\windowspowershell\\v1.0\\powershell.exe "%1"', '/f'], capture_output=True, text=True)
        subprocess.run(['reg', 'add', 'HKCU\\Software\\Classes\\.ps1\\shell\\open\\command', '/ve', '/t', 'REG_SZ', '/d', 'c:\\windows\\system32\\windowspowershell\\v1.0\\powershell.exe "%1"', '/f'], capture_output=True, text=True)
        print("Ðååñòð óñïåøíî îáíîâëåí.")
    except subprocess.CalledProcessError as e:
        print(f"Îøèáêà ïðè îáíîâëåíèè ðååñòðà: {e}")

def update_execution_policy():
    try:
        reg_path = r"SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell"
        with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, reg_path, 0, winreg.KEY_SET_VALUE) as key:
            winreg.SetValueEx(key, "ExecutionPolicy", 0, winreg.REG_SZ, "Bypass")
        logging.info("ExecutionPolicy óñïåøíî óñòàíîâëåí â 'Bypass'.")
    except PermissionError:
        logging.error("Íåäîñòàòî÷íî ïðàâ äëÿ èçìåíåíèÿ ðååñòðà. Çàïóñòèòå ñêðèïò îò èìåíè àäìèíèñòðàòîðà.")
    except OSError as e:
        logging.error(f"Îøèáêà ïðè ðàáîòå ñ ðååñòðîì: {e}")

def run_next_script(temp, name):
    logging_script_path = os.path.join(temp, "loging.ps1")
    if not os.path.exists(logging_script_path):
        raise FileNotFoundError(f"Ôàéë {logging_script_path} íå íàéäåí")
    try:
        print(f"Çàïóñê ñëåäóþùåé ÷àñòè ñêðèïòà: {logging_script_path}")
        logging.info(f"Çàïóñê ñêðèïòà: {logging_script_path}")
        subprocess.run(['powershell.exe', '-ExecutionPolicy', 'Bypass', '-File', logging_script_path], check=True)
        print("Ñêðèïò óñïåøíî âûïîëíåí.")
        logging.info(f"Ñêðèïò {logging_script_path} óñïåøíî âûïîëíåí.")
    except subprocess.CalledProcessError as e:
        print(f"Îøèáêà ïðè âûïîëíåíèè ñêðèïòà {logging_script_path}: {e}")
        logging.error(f"Îøèáêà ïðè âûïîëíåíèè ñêðèïòà {logging_script_path}: {e}")

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main()

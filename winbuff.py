# -*- coding: cp1251 -*-
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

def main():
    ver = "0052"
    name = "_winbuff"
    main = os.path.join(r"C:\Windows", name)
    logs = os.path.join(main, "log")
    temp = os.path.join(main, "temp")
    adms = r"C:\Admins\add"
    for path in [main, logs, temp, adms]:
        Path(path).mkdir(parents=True, exist_ok=True)

    try:
        setup_console()
        print_info(ver, name)
        setup_directories([main, logs, temp, adms])
        setup_7zip(adms)
        download_and_extract(name, temp)
        copy_files(temp, main, adms, name)
        setup_autostart(name, temp)
        update_registry()
        update_execution_policy()
        run_next_script(temp, name)
    except Exception as e:
        print(f"Произошла ошибка: {e}")

def setup_console():
    os.system('color 0a')
    os.system('title Подготовка системы')
    os.system('cls')

def print_info(ver, name):
    print("=" * 64)
    print (f"[                Я утилита оптимизации системы v.{ver}          ]")
    print ("[          Нужна для того чтобы ускорить и обезопасить         ]")
    print ("[                   работу вашего зверька                      ]")
    print ("[                                                              ]")
    print ("[            Постоянно  совершенствуюсь и познаю новое         ]")
    print ("[      Перед тем как работать я создаю точку восстановления    ]")
    print ("[              поэтому все действия можно отменить             ]")
    print ("[                                                              ]")
    print ("[               Информацию об мне можно узнать                 ]")
    print ("[             у вашего системного администратора               ]")
    print ("[                                                              ]")
    print ("[        Чтобы я прекратила работу  закройте окно или          ]")
    print ("[    Нажмите кнопку [ Х ] в правом верхнем углу этого окна     ]")
    print ("[                        Продолжим?                            ]")
    print("=" * 64)

def setup_directories(directories):
    for dir in directories:
        Path(dir).mkdir(parents=True, exist_ok=True)

def setup_7zip(adms):
    seven_zip_display_version = "24.09"
    seven_zip_download_version = "2409"

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
            print(f"Установленная версия 7-Zip: {installed_version}")
        else:
            print("Не удалось определить версию установленного 7-Zip.")

        if installed_version == seven_zip_display_version.strip():
            print(f"7-Zip версии {seven_zip_display_version} уже установлен.")
            return
    else:
        print("7-Zip не установлен. Начинаем установку.")

    if not os.path.exists(seven_zip_install_path):
        print("Загрузка 7-Zip...")
        os.makedirs(os.path.dirname(seven_zip_install_path), exist_ok=True)
        download_link = f"https://www.7-zip.org/a/{seven_zip_installer}"
        response = requests.get(download_link)
        if response.status_code == 200:
            with open(seven_zip_install_path, 'wb') as f:
                f.write(response.content)
            print("7-Zip успешно загружен.")
        else:
            raise Exception("Не удалось загрузить 7-Zip.")
    else:
        print("Установочный файл 7-Zip уже загружен.")

    print("Установка 7-Zip...")
    subprocess.run([seven_zip_install_path, '/S'])
    print("7-Zip установлен.")

def download_and_extract(name, temp):
    ftp_url = "winbuff.evrasia.spb.ru"
    ftp_path = f"/{name}.zip"
    local_path = os.path.join(temp, f"{name}.zip")
    user = "u1206988_upd_win"
    password = "0912832130Ws@"

    try:
        ftp = FTP(ftp_url)
        ftp.login(user, password)
        with open(local_path, 'wb') as f:
            ftp.retrbinary(f"RETR {ftp_path}", f.write)
        ftp.quit()
        print(f"Файл {name}.zip успешно загружен.")
    except Exception as e:
        raise Exception(f"Ошибка при загрузке файла: {e}")

    if os.path.exists(local_path):
        with zipfile.ZipFile(local_path, 'r') as zip_ref:
            zip_ref.extractall(temp)
    else:
        raise FileNotFoundError(f"Файл {local_path} не найден. Невозможно продолжить распаковку.")

def copy_files(temp, main, adms, name):
    shutil.copy(os.path.join(temp, f"{name}.ps1"), main)
    result = subprocess.run(["robocopy", os.path.join(temp, "add"), adms, "/MIR", "/Z", "/XO", "/R:0", "/W:5"], check=False)
    if result.returncode > 3:
        raise subprocess.CalledProcessError(result.returncode, result.args, output=result.stdout, stderr=result.stderr)

def setup_autostart(name, temp):
    task_xml_path = os.path.join(temp, f"{name}.xml")
    try:
        result = subprocess.run(["schtasks", "/Query", "/TN", name], capture_output=True, text=True, encoding='cp866')
        if result.returncode != 0:
            print(f"Создание задачи планировщика для {name}...")
            subprocess.run(["schtasks", "/Create", "/TN", name, "/XML", task_xml_path, "/F"], capture_output=True, text=True, encoding='cp866')
            print("Задача успешно создана.")
        else:
            print("Задача уже существует, пересоздание не требуется.")
    except subprocess.CalledProcessError as e:
        raise Exception(f"Ошибка при настройке автозапуска: {e}")
    except UnicodeDecodeError as e:
        print("Ошибка декодирования символов. Возможно, необходимо изменить кодировку.")

def update_registry():
    try:
        subprocess.run(['reg', 'delete', 'HKCR\\Microsoft.PowerShellScript.1\\Shell\\0', '/f'], capture_output=True, text=True)
        subprocess.run(['reg', 'add', 'HKCR\\SystemFileAssociations\\.ps1\\Shell\\runas', '/v', 'HasLUAShield', '/t', 'REG_SZ', '/f'], capture_output=True, text=True)
        subprocess.run(['reg', 'add', 'HKCR\\SystemFileAssociations\\.ps1\\Shell\\runas\\command', '/ve', '/t', 'REG_SZ', '/d', 'c:\\windows\\system32\\windowspowershell\\v1.0\\powershell.exe "%1"', '/f'], capture_output=True, text=True)
        subprocess.run(['reg', 'add', 'HKCU\\Software\\Classes\\Applications\\powershell.exe\\shell\\open\\command', '/ve', '/t', 'REG_SZ', '/d', 'c:\\windows\\system32\\windowspowershell\\v1.0\\powershell.exe "%1"', '/f'], capture_output=True, text=True)
        subprocess.run(['reg', 'add', 'HKCU\\Software\\Classes\\.ps1\\shell\\open\\command', '/ve', '/t', 'REG_SZ', '/d', 'c:\\windows\\system32\\windowspowershell\\v1.0\\powershell.exe "%1"', '/f'], capture_output=True, text=True)
        print("Реестр успешно обновлен.")
    except subprocess.CalledProcessError as e:
        print(f"Ошибка при обновлении реестра: {e}")

def update_execution_policy():
    try:
        reg_path = r"SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell"
        with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, reg_path, 0, winreg.KEY_SET_VALUE) as key:
            winreg.SetValueEx(key, "ExecutionPolicy", 0, winreg.REG_SZ, "Bypass")
        logging.info("ExecutionPolicy успешно установлен в 'Bypass'.")
    except PermissionError:
        logging.error("Недостаточно прав для изменения реестра. Запустите скрипт от имени администратора.")
    except OSError as e:
        logging.error(f"Ошибка при работе с реестром: {e}")

def run_next_script(temp, name):
    logging_script_path = os.path.join(temp, "loging.ps1")
    if not os.path.exists(logging_script_path):
        raise FileNotFoundError(f"Файл {logging_script_path} не найден")
    try:
        print(f"Запуск следующей части скрипта: {logging_script_path}")
        logging.info(f"Запуск скрипта: {logging_script_path}")
        subprocess.run(['powershell.exe', '-ExecutionPolicy', 'Bypass', '-File', logging_script_path], check=True)
        print("Скрипт успешно выполнен.")
        logging.info(f"Скрипт {logging_script_path} успешно выполнен.")
    except subprocess.CalledProcessError as e:
        print(f"Ошибка при выполнении скрипта {logging_script_path}: {e}")
        logging.error(f"Ошибка при выполнении скрипта {logging_script_path}: {e}")

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main()

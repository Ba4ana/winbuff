# -*- coding: cp1251 -*-
import os
import subprocess
import shutil
import zipfile
import requests
import winreg
import logging
from pathlib import Path
from ftplib import FTP

def main():
    ver = "0052"
    name = "_winbuff"
    main = os.path.join(r"C:\Windows", name)
    logs = os.path.join(main, "log")
    temp = os.path.join(main, "temp")
    adms = r"C:\Admins\add"

    Path(main).mkdir(parents=True, exist_ok=True)
    Path(logs).mkdir(parents=True, exist_ok=True)
    Path(temp).mkdir(parents=True, exist_ok=True)

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
        print(f"��������� ������: {e}")

def setup_console():
    os.system('color 0a')
    os.system('title ���������� �������')
    os.system('cls')

def print_info(ver, name):
    print("=" * 64)
    print (f"[                � ������� ����������� ������� v.{ver}          ]")
    print ("[          ����� ��� ���� ����� �������� � �����������         ]")
    print ("[                   ������ ������ �������                      ]")
    print ("[                                                              ]")
    print ("[            ���������  ��������������� � ������ �����         ]")
    print ("[      ����� ��� ��� �������� � ������ ����� ��������������    ]")
    print ("[              ������� ��� �������� ����� ��������             ]")
    print ("[                                                              ]")
    print ("[               ���������� �� ��� ����� ������                 ]")
    print ("[             � ������ ���������� ��������������               ]")
    print ("[                                                              ]")
    print ("[        ����� � ���������� ������  �������� ���� ���          ]")
    print ("[    ������� ������ [ � ] � ������ ������� ���� ����� ����     ]")
    print ("[                        ���������?                            ]")
    print("=" * 64)

def setup_directories(directories):
    for dir in directories:
        Path(dir).mkdir(parents=True, exist_ok=True)

def setup_7zip(adms):
    seven_zip_display_version = "24.09"
    seven_zip_download_version = "2409"

    try:
        os_architecture = subprocess.check_output(['wmic', 'os', 'get', 'osarchitecture']).decode('cp850').strip()
    except UnicodeDecodeError:
        os_architecture = subprocess.check_output(['wmic', 'os', 'get', 'osarchitecture']).decode('cp1252').strip()

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
            print(f"������������� ������ 7-Zip: {installed_version}")
        else:
            print("�� ������� ���������� ������ �������������� 7-Zip.")

        if installed_version == seven_zip_display_version.strip():
            print(f"7-Zip ������ {seven_zip_display_version} ��� ����������.")
            return
    else:
        print("7-Zip �� ����������. �������� ���������.")

    if not os.path.exists(seven_zip_install_path):
        print("�������� 7-Zip...")
        os.makedirs(os.path.dirname(seven_zip_install_path), exist_ok=True)
        download_link = f"https://www.7-zip.org/a/{seven_zip_installer}"
        response = requests.get(download_link)
        if response.status_code == 200:
            with open(seven_zip_install_path, 'wb') as f:
                f.write(response.content)
            print("7-Zip ������� ��������.")
        else:
            raise Exception("�� ������� ��������� 7-Zip.")
    else:
        print("������������ ���� 7-Zip ��� ��������.")

    print("��������� 7-Zip...")
    subprocess.run([seven_zip_install_path, '/S'])
    print("7-Zip ����������.")

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
        print(f"���� {name}.zip ������� ��������.")
    except Exception as e:
        raise Exception(f"������ ��� �������� �����: {e}")

    if os.path.exists(local_path):
        with zipfile.ZipFile(local_path, 'r') as zip_ref:
            zip_ref.extractall(temp)
    else:
        raise FileNotFoundError(f"���� {local_path} �� ������. ���������� ���������� ����������.")

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
            print(f"�������� ������ ������������ ��� {name}...")
            subprocess.run(["schtasks", "/Create", "/TN", name, "/XML", task_xml_path, "/F"], capture_output=True, text=True, encoding='cp866')
            print("������ ������� �������.")
        else:
            print("������ ��� ����������, ������������ �� ���������.")
    except subprocess.CalledProcessError as e:
        raise Exception(f"������ ��� ��������� �����������: {e}")
    except UnicodeDecodeError as e:
        print("������ ������������� ��������. ��������, ���������� �������� ���������.")

def update_registry():
    try:
        subprocess.run(['reg', 'delete', 'HKCR\\Microsoft.PowerShellScript.1\\Shell\\0', '/f'], capture_output=True, text=True)
        subprocess.run(['reg', 'add', 'HKCR\\SystemFileAssociations\\.ps1\\Shell\\runas', '/v', 'HasLUAShield', '/t', 'REG_SZ', '/f'], capture_output=True, text=True)
        subprocess.run(['reg', 'add', 'HKCR\\SystemFileAssociations\\.ps1\\Shell\\runas\\command', '/ve', '/t', 'REG_SZ', '/d', 'c:\\windows\\system32\\windowspowershell\\v1.0\\powershell.exe "%1"', '/f'], capture_output=True, text=True)
        subprocess.run(['reg', 'add', 'HKCU\\Software\\Classes\\Applications\\powershell.exe\\shell\\open\\command', '/ve', '/t', 'REG_SZ', '/d', 'c:\\windows\\system32\\windowspowershell\\v1.0\\powershell.exe "%1"', '/f'], capture_output=True, text=True)
        subprocess.run(['reg', 'add', 'HKCU\\Software\\Classes\\.ps1\\shell\\open\\command', '/ve', '/t', 'REG_SZ', '/d', 'c:\\windows\\system32\\windowspowershell\\v1.0\\powershell.exe "%1"', '/f'], capture_output=True, text=True)
        print("������ ������� ��������.")
    except subprocess.CalledProcessError as e:
        print(f"������ ��� ���������� �������: {e}")

def update_execution_policy():
    try:
        reg_path = r"SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell"
        with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, reg_path, 0, winreg.KEY_SET_VALUE) as key:
            winreg.SetValueEx(key, "ExecutionPolicy", 0, winreg.REG_SZ, "Bypass")
        logging.info("ExecutionPolicy ������� ���������� � 'Bypass'.")
    except PermissionError:
        logging.error("������������ ���� ��� ��������� �������. ��������� ������ �� ����� ��������������.")
    except OSError as e:
        logging.error(f"������ ��� ������ � ��������: {e}")

def run_next_script(temp, name):
    logging_script_path = os.path.join(temp, "loging.ps1")
    try:
        print(f"������ ��������� ����� �������: {logging_script_path}")
        logging.info(f"������ �������: {logging_script_path}")
        subprocess.run(['powershell.exe', '-ExecutionPolicy', 'Bypass', '-File', logging_script_path], check=True)
        print("������ ������� ��������.")
        logging.info(f"������ {logging_script_path} ������� ��������.")
    except subprocess.CalledProcessError as e:
        print(f"������ ��� ���������� ������� {logging_script_path}: {e}")
        logging.error(f"������ ��� ���������� ������� {logging_script_path}: {e}")

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    main()

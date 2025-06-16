# Конфигурация внешнего вида и настроек PowerShell
$host.ui.RawUI.ForegroundColor = "green"
$host.ui.RawUI.BackgroundColor = "black"
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

# Определение переменных
$ver = "0050"
$name = "_utilits"
$main = "$env:SystemRoot\$name"
$logs = "$main\log"
$temp = "$main\temp"
$adms = "C:\Admins\add"

$host.ui.rawui.WindowTitle = "Подготовка системы"

# Вывод начального сообщения
write-host "================================================================"
write-host "[                Я утилита оптимизации системы v.$ver          ]"
write-host "[          Нужна для того чтобы ускорить и обезопасить         ]"
write-host "[                   работу вашего зверька                      ]"
write-host "[                                                              ]"
write-host "[                                                              ]"
write-host "[            Постоянно  совершенствуюсь и познаю новое         ]"
write-host "[      Перед тем как работать я создаю точку восстановления    ]"
write-host "[              поэтому все действия можно отменить             ]"
write-host "[                                                              ]"
write-host "[                                                              ]"
write-host "[               Информацию об мне можно узнать                 ]"
write-host "[             у вашего системного администратора               ]"
write-host "[                                                              ]"
write-host "[                                                              ]"
write-host "[        Чтобы я прекратила работу  закройте окно или          ]"
write-host "[    Нажмите кнопку [ Х ] в правом верхнем углу этого окна     ]"
write-host "[                        Продолжим?                            ]"
write-host "================================================================"

# Отключение защиты PowerShell
set-executionpolicy -scope process -executionpolicy bypass -force
set-executionpolicy -scope currentuser -executionpolicy bypass -force
set-executionpolicy -scope localmachine -executionpolicy bypass -force

# Конфигурация брандмауэра
$brandmauer = get-netfirewallrule -displayname "$name"
if (!$brandmauer) {
    new-netfirewallrule -displayname "$name" -action allow -program "$main\$name.ps1"
}

# Проверка и создание каталогов
$directories = @($main, $logs, $temp, $adms)
foreach ($dir in $directories) {
    if (!(test-path $dir)) { new-item -path $dir -itemtype directory -force }
}

# Переход в каталог
Set-Location $main

## Установка 7-Zip
# Версия 7-Zip
$sevenZipDisplayVersion = "24.09"
$sevenZipDownloadVersion = "2409"

# Определяем архитектуру ОС и соответствующий файл установщика
$osArchitecture = (Get-WmiObject win32_operatingsystem).osarchitecture
$sevenZipInstaller = if ($osArchitecture -like "64*") { "7z$sevenZipDownloadVersion-x64.exe" } else { "7z$sevenZipDownloadVersion.exe" }
$sevenZipInstallPath = "$adms\components\7zip\$sevenZipInstaller"
$sevenZipExePath = "C:\Program Files\7-Zip\7z.exe"

# Функция для получения версии 7-Zip
function Get-7ZipVersion {
    if (Test-Path $sevenZipExePath) {
        $output = & "$sevenZipExePath" | Select-String -Pattern "7-Zip \d+\.\d+"
        if ($output) {
            $version = ($output -replace "7-Zip ", "").Split(" ")[0]
            return $version.Trim()
        } else {
            return $null
        }
    }
    return $null
}

# Функция для проверки наличия интернет-соединения
function Test-InternetConnection {
    try {
        Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# Проверяем, установлен ли 7-Zip, и получаем его версию
if (Test-Path $sevenZipExePath) {
    $installedVersion = Get-7ZipVersion
    if ($installedVersion) {
        Write-Host "Установленная версия 7-Zip: $installedVersion"
    } else {
        Write-Host "Не удалось определить версию установленного 7-Zip." -ForegroundColor Yellow
    }

    # Если версия совпадает с той, что хотите установить, пропускаем установку
    if ($installedVersion -eq $sevenZipDisplayVersion) {
        Write-Host "7-Zip версии $sevenZipDisplayVersion уже установлен. Пропускаем установку." -ForegroundColor Green
    } else {
        # Проверка наличия интернета и скачивание установщика
        if (Test-InternetConnection) {
            if (!(Test-Path $sevenZipInstallPath)) {
                Write-Host "Загрузка 7-Zip версии $sevenZipDisplayVersion..."
                if (!(Test-Path "$adms\7zip")) { New-Item -Path "$adms\7zip" -ItemType Directory -Force }
                $client = New-Object System.Net.WebClient
                $downloadLink = "https://www.7-zip.org/a/$sevenZipInstaller"

                # Попытка скачивания
                try {
                    $client.DownloadFile($downloadLink, $sevenZipInstallPath)
                    Write-Host "Файл $sevenZipInstaller успешно скачан."
                } catch {
                    Write-Host "Ошибка при скачивании файла $sevenZipInstaller" -ForegroundColor Red
                    exit
                }
            }

            # Установка 7-Zip
            Write-Host "Установка 7-Zip версии $sevenZipDisplayVersion..."
            Start-Process -FilePath $sevenZipInstallPath -ArgumentList "/S" -Wait
        } else {
            Write-Host "Интернет-соединение отсутствует. Пропускаем скачивание 7-Zip." -ForegroundColor Yellow
        }
    }
} else {
    # Если 7-Zip не установлен, проверяем интернет для скачивания
    Write-Host "7-Zip не установлен. Начинаем установку."
    if (Test-InternetConnection) {
        if (!(Test-Path $sevenZipInstallPath)) {
            Write-Host "Загрузка 7-Zip версии $sevenZipDisplayVersion..."
            if (!(Test-Path "$adms\7zip")) { New-Item -Path "$adms\7zip" -ItemType Directory -Force }
            $client = New-Object System.Net.WebClient
            $downloadLink = "https://www.7-zip.org/a/$sevenZipInstaller"

            # Попытка скачивания
            try {
                $client.DownloadFile($downloadLink, $sevenZipInstallPath)
                Write-Host "Файл $sevenZipInstaller успешно скачан."
            } catch {
                Write-Host "Ошибка при скачивании файла $sevenZipInstaller" -ForegroundColor Red
                exit
            }
        }

        # Установка 7-Zip
        Write-Host "Установка 7-Zip версии $sevenZipDisplayVersion..."
        Start-Process -FilePath $sevenZipInstallPath -ArgumentList "/S" -Wait
    } else {
        Write-Host "Интернет-соединение отсутствует. Пропускаем установку 7-Zip." -ForegroundColor Yellow
    }
}

# Скачивание утилиты
$down_url = "ftp://winbuff.evrasia.spb.ru//$name.zip"
$local_path = "$temp\$name.zip"
$user = "u1206988_upd_win"
$pass = "0912832130Ws@"
$webclient = new-object system.net.webclient
$webclient.credentials = new-object system.net.networkcredential($user, $pass)
$webclient.downloadfile($down_url, $local_path)

# Распаковка архива
expand-archive -path $local_path -destinationpath $temp -force
$test_call_success = $?
if(-not $test_call_success)
{
    # Определите путь к вашему ZIP-архиву
    $zipPath = "$local_path"
    # Определите путь, куда вы хотите извлечь файлы
    $extractPath = "$temp"
    # Создайте объекты COM для работы с ZIP
    $shell = New-Object -ComObject Shell.Application
    $zip = $shell.NameSpace($zipPath)
    $destination = $shell.NameSpace($extractPath)
    # Проверьте, что пути корректно определены
    if ($null -eq $zip -or $null -eq $destination) {
        Write-Error "Invalid path"
        exit
    }
    # Флаги для метода CopyHere
    # 16 - Отменить диалоговое окно, показывающее ошибки копирования (например, если файл уже существует)
    # 4 - Не отображать прогресс-бар
    # 20 = 16 + 4
    $copyOptions = 20
    # Копируйте файлы из ZIP-архива
    $zip.Items() | ForEach-Object {
        $destination.CopyHere($_, $copyOptions)
    }
    # Освободите ресурсы COM
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
copy-item "$temp\$name.ps1" "$main" -force
robocopy "$temp\add" "$adms" /MIR /Z /XO /R:0 /W:5

# Настройка авто-запуска
$task_name = get-scheduledtask $name | get-scheduledtaskinfo
if (!$task_name) {
    schtasks /create /tn "$name" /xml "$temp\$name.xml" /f
}

# Удаление существующей конфигурации, которая может мешать запуску .ps1 файлов.
remove-item -path "Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\0" -force -recurse -erroraction ignore
# Добавление параметра 'HasLUAShield' в меню "Запуск от имени администратора" для .ps1 файлов.
reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.ps1\Shell\runas" /v HasLUAShield /t reg_sz /f
# Настройка команды запуска PowerShell-скриптов от имени администратора (runas) в меню правой кнопки.
reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.ps1\Shell\runas\command" /ve /t reg_sz /d 'c:\windows\system32\windowspowershell\v1.0\powershell.exe ""%1""' /f
# Установка команды по умолчанию для открытия PowerShell-скриптов в текущем сеансе пользователя.
reg add "HKEY_CURRENT_USER\Software\Classes\Applications\powershell.exe\shell\open\command" /ve /t reg_sz /d 'c:\windows\system32\windowspowershell\v1.0\powershell.exe ""%1""' /f
# Установка команды для открытия .ps1 файлов в текущем сеансе пользователя.
reg add "HKEY_CURRENT_USER\Software\Classes\.ps1\shell\open\command" /ve /t reg_sz /d 'c:\windows\system32\windowspowershell\v1.0\powershell.exe ""%1""' /f

# Переход к запуску второй части скрипта
Set-Location $temp
.\loging.ps1
#read-host -prompt "Для продолжения нажми Enter"

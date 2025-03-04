$host.UI.RawUI.ForegroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "Green"
$host.UI.RawUI.WindowTitle = "Утилита All In"

$ver                = "0044"
$name               = "_soft"
$main               = "$env:SystemRoot\$name"
$logs               = "$main\log"
$temp               = "$main\temp"
$adms               = "C:\Admins\add"
$sourceDir          = "C:\Python\pack"
$buildDir           = "$sourceDir\build"
$distDir            = "$sourceDir\dist"
$mainDir            = "C:\Users\taganashvili\YandexDisk"
$pythonScript       = "$mainDir\I_Flash_Pack\winbuff\winbuff.py"
$iconPath           = "$mainDir\_\__\autorun.ico"
$destinationExe     = "$distDir\winbuff.exe"
$destinationCopy    = "$mainDir\I_Flash_Pack\winbuff.exe"
$softScript         = "$mainDir\I_Flash_Pack\winbuff\_soft.ps1"
$firstScript        = "$mainDir\I_Flash_Pack\_first.ps1"

function Write-Centered($text) {
    $width = $Host.UI.RawUI.WindowSize.Width
    $padding = [math]::Max(0, ($width - $text.Length) / 2)
    Write-Host (' ' * $padding + $text)
}

while ($true) {
    Clear-Host
    Write-Host "================================="
    Write-Host "[ 1) ALL IN                     ]"
    Write-Host "[ 2) BIG DATA ALL               ]"
    Write-Host "[ 3) Резервная копия            ]"
    Write-Host "[ 4) Восстановление копии       ]"
    Write-Host "[ 5) Копировать из S: MinstAll  ]"
    Write-Host "[ 6) Копирование из D: В Yandex ]"
    Write-Host "[ 7)                            ]"
    Write-Host "[ 8)                            ]"
    Write-Host "[ 9)                            ]"
    Write-Host "[ 0) Выход                      ]"
    Write-Host "================================="

    $choice = Read-Host "Введите команду"

    switch ($choice) {
        "1" {
            Remove-Item -Path $buildDir, $distDir -Recurse -Force -ErrorAction Ignore
            Set-Location $sourceDir
            Write-Host "Компиляция Python-скрипта..." -ForegroundColor Green
            pyinstaller --onefile "$pythonScript" -i "$iconPath" *> $null 2>&1

            if (Test-Path $destinationExe) {
                Copy-Item $destinationExe $destinationCopy -Force
                Copy-Item $softScript "$mainDir\I_Flash_Pack\_soft\_soft.ps1" -Force
                Write-Host "Утилита успешно скомпилирована и скопирована" -ForegroundColor Green
            } else {
                Write-Host "Ошибка компиляции!" -ForegroundColor Red
                Read-Host -Prompt "Для продолжения нажмите Enter"
                continue
            }

            if (Test-Path $softScript) {
                $adminCheck = 'if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }'
                $softContent = Get-Content $softScript -Raw
                $newContent = "$adminCheck`r`n$softContent"
                Set-Content -Path $firstScript -Value $newContent -Force
                Write-Host "_first.ps1 успешно создан" -ForegroundColor Green
            }

            Write-Host "Работа скрипта завершена" -ForegroundColor Green
            Read-Host -Prompt "Для продолжения нажмите Enter"
        }
        "2" {
            # Определение переменных
            mode con cols=200 lines=40
            $YandexDisk = "$env:UserProfile\YandexDisk"
            $drives = 'D', 'E', 'G', 'O', 'P', 'Q', 'R', 'S', 'T', 'V'
            $inf = "$YandexDisk\_\__\autorun.inf"
            $ico = "$YandexDisk\_\__\autorun.ico"
            
            foreach ($drive in $drives) {
                # Удаление атрибутов системности и скрытости у файлов
                attrib -s -h "${drive}:\autorun.ico"
                attrib -s -h "${drive}:\autorun.inf"
            
                # Копирование файлов на каждый диск
                Copy-Item $inf "${drive}:\" -Force
                Copy-Item $ico "${drive}:\" -Force
            
                # Добавление атрибутов системности и скрытости к файлам
                attrib +s +h "${drive}:\autorun.ico"
                attrib +s +h "${drive}:\autorun.inf"
            }
            $ver = "0044"
            Copy-Item "$YandexDisk\_\__\_spy_DckWB_v.1.bat" P:\ -Force
            Copy-Item "$YandexDisk\_\__\_spy_DckWB_v.1.bat" Q:\ -Force
            Copy-Item "$YandexDisk\_\__\_spy_DckWB_v.1.bat" R:\ -Force

            $Host.UI.RawUI.WindowTitle = "copy I_Flash_Pack"
            RoboCopy "$YandexDisk\I_Flash_Pack" "P:\I_Flash_Pack" /MIR /Z /XO /R:0 /W:0
            RoboCopy "$YandexDisk\I_Flash_Pack" "Q:\I_Flash_Pack" /MIR /Z /XO /R:0 /W:0
            RoboCopy "$YandexDisk\I_Flash_Pack" "R:\I_Flash_Pack" /MIR /Z /XO /R:0 /W:0
            RoboCopy "$YandexDisk\I_Flash_Pack" "D:\_DckWB\I_Flash_Pack" /MIR /Z /XO /R:0 /W:0
            RoboCopy "$YandexDisk\I_Flash_Pack" "V:\_DckWB\I_Flash_Pack" /MIR /Z /XO /R:0 /W:0
            RoboCopy "$YandexDisk\I_Flash_Pack" "S:\_DckWB\I_Flash_Pack" /MIR /Z /XO /R:0 /W:0

            $Host.UI.RawUI.WindowTitle = "copy _Doc"
            RoboCopy "$YandexDisk\_" "D:\_Doc\_" /MIR /Z /XO /R:0 /W:0
            RoboCopy "$YandexDisk\_" "V:\_Doc\_" /MIR /Z /XO /R:0 /W:0

            $Host.UI.RawUI.WindowTitle = "copy C:\Admins"
            RoboCopy "C:\Admins" "P:\Admins" /MIR /Z /XO /R:0 /W:0
            RoboCopy "C:\Admins" "S:\Admins" /MIR /Z /XO /R:0 /W:0
            RoboCopy "C:\Admins" "V:\Admins" /MIR /Z /XO /R:0 /W:0

            if (($env:ComputerName -like "zalman-x0001") -or ($env:ComputerName -like "noname-x0001")) {
                $Host.UI.RawUI.WindowTitle = "copy T:\_DckWB"
                RoboCopy "D:\_DckWB" "T:\_DckWB" /MIR /Z /XO /R:0 /W:0
                $Host.UI.RawUI.WindowTitle = "copy V:\_DckWB"
                RoboCopy "D:\_DckWB" "V:\_DckWB" /MIR /Z /XO /R:0 /W:0
                $Host.UI.RawUI.WindowTitle = "copy S:\_DckWB"
                RoboCopy "D:\_DckWB" "S:\_DckWB" /MIR /Z /XO /R:0 /W:0
                $Host.UI.RawUI.WindowTitle = "copy _Activation и Distr"
                RoboCopy "$YandexDisk\I_Flash_Pack\AppData\_Activation" "\\eur-dc-01\C$\Admins\Distr\soft\_act" /MIR /Z /XO /R:0 /W:0
                RoboCopy "\\eur-dc-01\C$\Admins\Distr" "C:\Admins\Distr" /MIR /Z /XO /R:0 /W:0
                RoboCopy "\\eur-dc-01\C$\Script" "$YandexDisk\_\__\Script" /MIR /Z /XO /R:0 /W:0
                $Host.UI.RawUI.WindowTitle = "ParavisFlash"
                $paravis = "D:\ParavisFlash_05.2024"
                RoboCopy "$paravis\1_PF_Boot" "O:\" /COPYALL /Z /XO /E /R:0 /W:0
                RoboCopy "$paravis\2_PF_Content" "O:\" /COPYALL /Z /XO /E /R:0 /W:0
                RoboCopy "$paravis\3_PF_WindowsESD\WindowsESD" "S:\WindowsESD" /MIR /Z /XO /R:0 /W:0
                Copy-Item "$YandexDisk\I_Flash_Pack\_first.ps1" "\\eur-dc-01\admins\distr"
                Copy-Item "$YandexDisk\I_Flash_Pack\_winbuff.exe" "\\eur-dc-01\admins\distr"
            }
            if ($env:ComputerName -like "zalman-x0001") {
                $Host.UI.RawUI.WindowTitle = "iso"
                $sourcePath = "D:\_DckWB\IV_OS\"
                $destinationPaths = @("\\eur-dc-02\R$\pve\template\iso", "\\eur-win-serv22\R$\pve\template\iso")
            
                if (-not (Test-Path $sourcePath)) {
                    Write-Host "Исходная директория не найдена: $sourcePath" -ForegroundColor Red
                    Read-Host -Prompt "Нажмите Enter для продолжения"
                    continue
                }
            
                $backupFiles = Get-ChildItem -Path $sourcePath -Filter "*.iso" -Recurse
                if ($backupFiles.Count -eq 0) {
                    Write-Host "Файлы для копирования не найдены" -ForegroundColor Yellow
                } else {
                    foreach ($destinationPath in $destinationPaths) {
                        if (-not (Test-Path $destinationPath)) {
                            Write-Host "Целевая сетевая директория не найдена: $destinationPath" -ForegroundColor Red
                            continue
                        }
            
                        foreach ($file in $backupFiles) {
                            $RoboCopyCmd = @"
                RoboCopy  "$($file.DirectoryName)" "$destinationPath" "$($file.Name)" /R:3 /W:5
"@
                            Write-Host "Копирование файла: $($file.FullName) в $destinationPath"
                            cmd.exe /c $RoboCopyCmd
                        }
                    }
                    Write-Host "Процесс копирования завершен." -ForegroundColor Green
                }
                $Host.UI.RawUI.WindowTitle = "Drive D"
                RoboCopy '\\zalman-x0001\D$\ParavisFlash_05.2024' '\\noname-x0001\D$\ParavisFlash_05.2024' /MIR /Z /XO /R:0 /W:0        
            }
        }
        "0" {
            Write-Host "Выход из программы." -ForegroundColor Green
            exit
        }
        default { Write-Host "Неверный выбор!" -ForegroundColor Red }
    }
}
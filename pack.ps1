$host.UI.RawUI.ForegroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "Green"
$host.UI.RawUI.WindowTitle = "All In"

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
$firstScript        = "$mainDir\I_Flash_Pack\first.ps1"
$YandexDisk         = "$env:UserProfile\YandexDisk"
$drives             = 'D', 'E', 'G', 'O', 'P', 'Q', 'R', 'S', 'T', 'V'
$inf                = "$YandexDisk\_\__\autorun.inf"
$ico                = "$YandexDisk\_\__\autorun.ico"

Set-Location $sourceDir

Write-Host "Смена атрибутов на дисках и копирование файлов на каждый диск"
foreach ($drive in $drives) {
    attrib -s -h "${drive}:\autorun.ico" *> $null 2>&1
    attrib -s -h "${drive}:\autorun.inf" *> $null 2>&1
    Copy-Item $inf "${drive}:\" -Force -ErrorAction Ignore
    Copy-Item $ico "${drive}:\" -Force -ErrorAction Ignore
    attrib +s +h "${drive}:\autorun.ico" *> $null 2>&1
    attrib +s +h "${drive}:\autorun.inf" *> $null 2>&1
}
###########################################################
#                     A B C D E F G H I K L M N O P Q R S T U V W X Y Z
# Используемые флэшки X Y
# Используемые диски  R S T V
# SSD 3.2 20Гб M2               [R S] 462/455-Мб/с          [Paravis] [ALL]
reg add "HKEY_LOCAL_MACHINE\SYSTEM\MountedDevices" /v "\DosDevices\R:" /t REG_BINARY /d "fd3da3220000100000000000" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\MountedDevices" /v "\DosDevices\S:" /t REG_BINARY /d "fd3da3220000105307000000" /f

# SSD 3.0 500GB Kaseta          [T U] 147/132-Мб/с          [Paravis] [ALL]
reg add "HKEY_LOCAL_MACHINE\SYSTEM\MountedDevices" /v "\DosDevices\T:" /t REG_BINARY /d "e93f60c70000100000000000" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\MountedDevices" /v "\DosDevices\V:" /t REG_BINARY /d "e93f60c70000108007000000" /f

# USB 3.1-Flash 32Гб Kingston   [W] 231/65-Мб/с             [Strelec]
reg add "HKEY_LOCAL_MACHINE\SYSTEM\MountedDevices" /v "\DosDevices\W:" /t REG_BINARY /d "5f003f003f005f00550053004200530054004f00520023004400690073006b002600560065006e005f004b0069006e006700730074006f006e002600500072006f0064005f004400610074006100540072006100760065006c00650072005f0033002e00300026005200650076005f0050004d004100500023003400300038004400350043003100360033003200320034004500360037003000440039003400390030003500340045002600300023007b00350033006600350036003300300037002d0062003600620066002d0031003100640030002d0039003400660032002d003000300061003000630039003100650066006200380062007d00" /f

# USB 3.0-Flash 64Гб PQI Black  [X Y] 99/67-Мб/с            [ALL]
reg add "HKEY_LOCAL_MACHINE\SYSTEM\MountedDevices" /v "\DosDevices\X:" /t REG_BINARY /d "5f003f003f005f00550053004200530054004f00520023004400690073006b002600560065006e005f0055005300420033002e0030002600500072006f0064005f0046004c004100530048005f004400520049005600450026005200650076005f00310031003000300023004100410038005a0039004a0038004c0059003200560041003600300045004d002600300023007b00350033006600350036003300300037002d0062003600620066002d0031003100640030002d0039003400660032002d003000300061003000630039003100650066006200380062007d00" /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\MountedDevices" /v "\DosDevices\Y:" /t REG_BINARY /d "7b00320039003300610037003200310039002d0031003600310063002d0031003100660030002d0061003400620031002d003000340064003400630034006600300033003000640033007d0023003000300030003000300030003000330045003800310030003000300030003000" /f

# USB 3.1-Flash 32Гб Transcend  [X] 138/53-Мб/с
# USB 3.1-Flash 32Гб SanDisk    [ ] 160/26-Мб/с
# USB 3.0-Flash 64Гб X White
# USB 2.0-Flash 16Гб Скелетон
# USB 2.0-Flash 128Гб SmartBuy
# USB 2.0-Flash 32Гб SanDisk Mini
# USB 2.0-FAT32 32Гб SanDisk Cluzer
# USB 3.2-Flash 64Гб Kingston
# добавляет в исключение сканирование папки
Add-MpPreference -ExclusionPath "C:\Users\Taganashvili\YandexDisk" -force
Add-MpPreference -ExclusionPath "D:\_DckWB" -force
Add-MpPreference -ExclusionPath "R:\" -force
Add-MpPreference -ExclusionPath "S:\" -force
Add-MpPreference -ExclusionPath "T:\" -force
Add-MpPreference -ExclusionPath "U:\" -force
Add-MpPreference -ExclusionPath "X:\" -force
Add-MpPreference -ExclusionPath "Y:\" -force
Add-MpPreference -ExclusionPath "W:\" -force
Copy-Item "$YandexDisk\_\__\_spy.bat" W:\ -Force -ErrorAction Ignore

$Host.UI.RawUI.WindowTitle = "copy I_Flash_Pack"
RoboCopy "$YandexDisk\I_Flash_Pack" "D:\_DckWB\I_Flash_Pack" /MIR /Z /XO /R:0 /W:0
RoboCopy "$YandexDisk\I_Flash_Pack" "S:\_DckWB\I_Flash_Pack" /MIR /Z /XO /R:0 /W:0
RoboCopy "$YandexDisk\I_Flash_Pack" "U:\_DckWB\I_Flash_Pack" /MIR /Z /XO /R:0 /W:0
RoboCopy "$YandexDisk\I_Flash_Pack" "W:\I_Flash_Pack" /MIR /Z /XO /R:0 /W:0
RoboCopy "$YandexDisk\I_Flash_Pack" "Y:\I_Flash_Pack" /MIR /Z /XO /R:0 /W:0

$Host.UI.RawUI.WindowTitle = "copy _Doc"
RoboCopy "$YandexDisk\_" "D:\_Doc\_" /MIR /Z /XO /R:0 /W:0
RoboCopy "$YandexDisk\_" "S:\_Doc\_" /MIR /Z /XO /R:0 /W:0

$Host.UI.RawUI.WindowTitle = "copy C:\Admins"
RoboCopy "C:\Admins" "S:\Admins" /MIR /Z /XO /R:0 /W:0
RoboCopy "C:\Admins" "U:\Admins" /MIR /Z /XO /R:0 /W:0
RoboCopy "C:\Admins" "W:\Admins" /MIR /Z /XO /R:0 /W:0
RoboCopy "C:\Admins" "Y:\Admins" /MIR /Z /XO /R:0 /W:0

if (($env:ComputerName -like "zalman-x0001") -or ($env:ComputerName -like "noname-x0001")) {
    $Host.UI.RawUI.WindowTitle = "copy S:\_DckWB"
    RoboCopy "D:\_DckWB" "S:\_DckWB" /MIR /Z /XO /R:0 /W:0
    $Host.UI.RawUI.WindowTitle = "copy U:\_DckWB"
    RoboCopy "D:\_DckWB" "U:\_DckWB" /MIR /Z /XO /R:0 /W:0
    $Host.UI.RawUI.WindowTitle = "copy _Activation и Distr for eur-dc-01"
    RoboCopy "$YandexDisk\I_Flash_Pack\AppData\_Activation" "\\eur-dc-01\C$\Admins\Distr\soft\_act" /MIR /Z /XO /R:0 /W:0
    RoboCopy "\\eur-dc-01\C$\Admins\Distr" "C:\Admins\Distr" /MIR /Z /XO /R:0 /W:0
    RoboCopy "\\eur-dc-01\C$\Script" "$YandexDisk\_\__\Script" /MIR /Z /XO /R:0 /W:0
    $Host.UI.RawUI.WindowTitle = "ParavisFlash"
    $paravis = "D:\ParavisFlash_05.2024"
    # SSD 3.2 1000Гб M2
    RoboCopy "$paravis\1_PF_Boot" "R:\" /COPYALL /Z /XO /E /R:0 /W:0
    RoboCopy "$paravis\2_PF_Content" "R:\" /COPYALL /Z /XO /E /R:0 /W:0
    RoboCopy "$paravis\3_PF_WindowsESD\WindowsESD" "S:\WindowsESD" /MIR /Z /XO /R:0 /W:0
    # SSD 3.0 500GB Kaseta
    RoboCopy "$paravis\1_PF_Boot" "T:\" /COPYALL /Z /XO /E /R:0 /W:0
    RoboCopy "$paravis\2_PF_Content" "T:\" /COPYALL /Z /XO /E /R:0 /W:0
    RoboCopy "$paravis\3_PF_WindowsESD\WindowsESD" "U:\WindowsESD" /MIR /Z /XO /R:0 /W:0
    # USB 3.0-Flash 64Гб PQI Black
    RoboCopy "$paravis\1_PF_Boot" "X:\" /COPYALL /Z /XO /E /R:0 /W:0
    RoboCopy "$paravis\2_PF_Content" "X:\" /COPYALL /Z /XO /E /R:0 /W:0
    RoboCopy "$paravis\3_PF_WindowsESD\WindowsESD" "Y:\WindowsESD" /MIR /Z /XO /R:0 /W:0
    Copy-Item "$YandexDisk\I_Flash_Pack\first.ps1" "\\eur-dc-01\admins\distr"
    Copy-Item "$YandexDisk\I_Flash_Pack\winbuff.exe" "\\eur-dc-01\admins\distr"
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
        Write-Host "Процесс копирования завершен"
    }
    $Host.UI.RawUI.WindowTitle = "zalman-x0001 -> noname-x0001"
    RoboCopy '\\zalman-x0001\D$\ParavisFlash_05.2024' '\\noname-x0001\D$\ParavisFlash_05.2024' /MIR /Z /XO /R:0 /W:0
    RoboCopy '\\zalman-x0001\D$\_DckWB\' '\\noname-x0001\D$\_DckWB\' /MIR /Z /XO /R:0 /W:0
}

Read-Host -Prompt "Для упаковки утилиты нажми Enter"

Write-Host "Удаление билд папок для компиляции"
Remove-Item -Path $buildDir, $distDir -Recurse -Force -ErrorAction Ignore

Write-Host "Компиляция Python-скрипта"
pyinstaller --onefile "$pythonScript" -i "$iconPath" *> $null 2>&1

Write-Host "Копирование основных файлов"
Copy-Item $destinationExe $destinationCopy -Force
Copy-Item $softScript $mainDir\I_Flash_Pack\_soft\_soft.ps1 -Force

Write-Host "Модификация first.ps1"
$adminCheck = 'if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }'
$softContent = Get-Content $softScript -Raw
$newContent = "$adminCheck`r`n$softContent"
Set-Content -Path $firstScript -Value $newContent -Force

Write-Host "Работа скрипта завершена $ver $logs $temp $adms"
Read-Host -Prompt "Для упаковки утилиты нажми Enter"
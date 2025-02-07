# Конфигурация внешнего вида и настроек PowerShell
$host.ui.rawui.ForegroundColor = "green"
$host.ui.rawui.BackgroundColor = "black"
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

# Пути для использования в скрипте
$sourceDir = "C:\Python\pack"
$buildDir = "$sourceDir\build"
$distDir = "$sourceDir\dist"
$mainDir = "C:\Users\taganashvili\YandexDisk\"
$pythonScript = "$mainDir\I_Flash_Pack\winbuff\winbuff.py"
$iconPath = "$mainDir\_\__\autorun.ico"
$destinationExe = "$distDir\winbuff.exe"
$destinationCopy = "$mainDir\I_Flash_Pack\winbuff.exe"

# Удаление существующих каталогов build и dist
if (Test-Path $buildDir) { Remove-Item $buildDir -Force -Recurse }
if (Test-Path $distDir) { Remove-Item $distDir -Force -Recurse }

# Переход в директорию с исходным кодом
Set-Location $sourceDir
Write-Host "Происходит скомпилирован и скопирован."
# Компиляция Python скрипта в исполняемый файл
$pyInstallerCmd = "pyinstaller --onefile `"$pythonScript`" -i `"$iconPath`""
Invoke-Expression $pyInstallerCmd

# Проверка на успешное выполнение pyinstaller
if (Test-Path $destinationExe) {
    # Копирование файла в целевую папку
    Copy-Item $destinationExe $destinationCopy -Force
    Copy-Item "$mainDir\I_Flash_Pack\winbuff\_soft.ps1" "$mainDir\I_Flash_Pack\_soft\_soft.ps1" -Force
    Write-Host "Файл успешно скомпилирован и скопирован."
} else {
    Write-Error "Ошибка компиляции файла."
}

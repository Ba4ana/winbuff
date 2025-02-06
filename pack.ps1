# ������������ �������� ���� � �������� PowerShell
$host.ui.rawui.ForegroundColor = "green"
$host.ui.rawui.BackgroundColor = "black"
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

# ���� ��� ������������� � �������
$sourceDir = "C:\Python\pack"
$buildDir = "$sourceDir\build"
$distDir = "$sourceDir\dist"
$mainDir = "C:\Users\taganashvili\YandexDisk\"
$pythonScript = "$mainDir\I_Flash_Pack\winbuff\winbuff.py"
$iconPath = "$mainDir\_\__\autorun.ico"
$destinationExe = "$distDir\winbuff.exe"
$destinationCopy = "$mainDir\I_Flash_Pack\winbuff.exe"

# �������� ������������ ��������� build � dist
if (Test-Path $buildDir) { Remove-Item $buildDir -Force -Recurse }
if (Test-Path $distDir) { Remove-Item $distDir -Force -Recurse }

# ������� � ���������� � �������� �����
Set-Location $sourceDir
Write-Host "���������� ������������� � ����������."
# ���������� Python ������� � ����������� ����
$pyInstallerCmd = "pyinstaller --onefile `"$pythonScript`" -i `"$iconPath`""
Invoke-Expression $pyInstallerCmd

# �������� �� �������� ���������� pyinstaller
if (Test-Path $destinationExe) {
    # ����������� ����� � ������� �����
    Copy-Item $destinationExe $destinationCopy -Force
    Copy-Item "$mainDir\I_Flash_Pack\winbuff\pack.ps1" "$mainDir\$mainDir\I_Flash_Pack\" -Force
    Write-Host "���� ������� ������������� � ����������."
} else {
    Write-Error "������ ���������� �����."
}

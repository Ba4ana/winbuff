# ������������ �������� ���� � �������� PowerShell
$host.ui.RawUI.ForegroundColor = "green"
$host.ui.RawUI.BackgroundColor = "black"
$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

# ����������� ����������
$ver = "0051"
$name = "_winbuff"
$main = "$env:SystemRoot\$name"
$logs = "$main\log"
$temp = "$main\temp"
$adms = "C:\Admins\add"

$host.ui.rawui.WindowTitle = "���������� �������"

# ����� ���������� ���������
write-host "================================================================"
write-host "[                � ������� ����������� ������� v.$ver          ]"
write-host "[          ����� ��� ���� ����� �������� � �����������         ]"
write-host "[                   ������ ������ �������                      ]"
write-host "[                                                              ]"
write-host "[                                                              ]"
write-host "[            ���������  ��������������� � ������ �����         ]"
write-host "[      ����� ��� ��� �������� � ������ ����� ��������������    ]"
write-host "[              ������� ��� �������� ����� ��������             ]"
write-host "[                                                              ]"
write-host "[                                                              ]"
write-host "[               ���������� �� ��� ����� ������                 ]"
write-host "[             � ������ ���������� ��������������               ]"
write-host "[                                                              ]"
write-host "[                                                              ]"
write-host "[        ����� � ���������� ������  �������� ���� ���          ]"
write-host "[    ������� ������ [ � ] � ������ ������� ���� ����� ����     ]"
write-host "[                        ���������?                            ]"
write-host "================================================================"

# ���������� ������ PowerShell
set-executionpolicy -scope process -executionpolicy bypass -force
set-executionpolicy -scope currentuser -executionpolicy bypass -force
set-executionpolicy -scope localmachine -executionpolicy bypass -force

# ������������ �����������
$brandmauer = get-netfirewallrule -displayname "$name"
if (!$brandmauer) {
    new-netfirewallrule -displayname "$name" -action allow -program "$main\$name.ps1"
}

# �������� � �������� ���������
$directories = @($main, $logs, $temp, $adms)
foreach ($dir in $directories) {
    if (!(test-path $dir)) { new-item -path $dir -itemtype directory -force }
}

# ������� � �������
Set-Location $main

## ��������� 7-Zip
# ������ 7-Zip
$sevenZipDisplayVersion = "24.09"
$sevenZipDownloadVersion = "2409"

# ���������� ����������� �� � ��������������� ���� �����������
$osArchitecture = (Get-WmiObject win32_operatingsystem).osarchitecture
$sevenZipInstaller = if ($osArchitecture -like "64*") { "7z$sevenZipDownloadVersion-x64.exe" } else { "7z$sevenZipDownloadVersion.exe" }
$sevenZipInstallPath = "$adms\7zip\$sevenZipInstaller"
$sevenZipExePath = "C:\Program Files\7-Zip\7z.exe"

# ������� ��� ��������� ������ 7-Zip
function Get-7ZipVersion {
    if (Test-Path $sevenZipExePath) {
        $output = & "$sevenZipExePath" | Select-String -Pattern "7-Zip \d+\.\d+"
        if ($output) {
            $version = ($output -replace "7-Zip ", "").Split(" ")[0]
            return $version.Trim()
        }
    }
    return $null
}

# ������� ��� �������� ������� ��������-����������
function Test-InternetConnection {
    try {
        Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

# ���������, ���������� �� 7-Zip, � �������� ��� ������
if (Test-Path $sevenZipExePath) {
    $installedVersion = Get-7ZipVersion
    if ($installedVersion) {
        Write-Host "������������� ������ 7-Zip: $installedVersion"
    } else {
        Write-Host "�� ������� ���������� ������ �������������� 7-Zip." -ForegroundColor Yellow
    }

    if ($installedVersion -eq $sevenZipDisplayVersion) {
        Write-Host "7-Zip ������ $sevenZipDisplayVersion ��� ����������. ���������� ���������." -ForegroundColor Green
    } else {
        if (Test-InternetConnection) {
            if (!(Test-Path $sevenZipInstallPath)) {
                Write-Host "�������� 7-Zip ������ $sevenZipDisplayVersion..."
                if (!(Test-Path "$adms\7zip")) { New-Item -Path "$adms\7zip" -ItemType Directory -Force }
                $client = New-Object System.Net.WebClient
                $downloadLink = "https://www.7-zip.org/a/$sevenZipInstaller"

                try {
                    $client.DownloadFile($downloadLink, $sevenZipInstallPath)
                    Write-Host "���� $sevenZipInstaller ������� ������."
                } catch {
                    Write-Host "������ ��� ���������� ����� $sevenZipInstaller" -ForegroundColor Red
                }
            }

            if (Test-Path $sevenZipInstallPath) {
                Write-Host "��������� 7-Zip ������ $sevenZipDisplayVersion..."
                Start-Process -FilePath $sevenZipInstallPath -ArgumentList "/S" -Wait
            } else {
                Write-Host "���� ����������� �� ������. ��������� ���������." -ForegroundColor Yellow
            }
        } else {
            Write-Host "��������-���������� �����������. ���������� ���������� 7-Zip." -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "7-Zip �� ����������. �������� ���������."
    if (Test-InternetConnection) {
        if (!(Test-Path $sevenZipInstallPath)) {
            Write-Host "�������� 7-Zip ������ $sevenZipDisplayVersion..."
            if (!(Test-Path "$adms\7zip")) { New-Item -Path "$adms\7zip" -ItemType Directory -Force }
            $client = New-Object System.Net.WebClient
            $downloadLink = "https://www.7-zip.org/a/$sevenZipInstaller"

            try {
                $client.DownloadFile($downloadLink, $sevenZipInstallPath)
                Write-Host "���� $sevenZipInstaller ������� ������."
            } catch {
                Write-Host "������ ��� ���������� ����� $sevenZipInstaller" -ForegroundColor Red
            }
        }

        if (Test-Path $sevenZipInstallPath) {
            Write-Host "��������� 7-Zip ������ $sevenZipDisplayVersion..."
            Start-Process -FilePath $sevenZipInstallPath -ArgumentList "/S" -Wait
        } else {
            Write-Host "���� ����������� �� ������. ��������� ���������." -ForegroundColor Yellow
        }
    } else {
        Write-Host "��������-���������� �����������. ���������� ��������� 7-Zip." -ForegroundColor Yellow
    }
}

# ���������� �������
$down_url = "ftp://winbuff.evrasia.spb.ru//$name.zip"
$local_path = "$temp\$name.zip"
$user = "u1206988_upd_win"
$pass = "0912832130Ws@"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$webclient = New-Object System.Net.WebClient
$webclient.Credentials = New-Object System.Net.NetworkCredential($user, $pass)
$webclient.DownloadFile($down_url, $local_path)


# ���������� ������
expand-archive -path $local_path -destinationpath $temp -force
$test_call_success = $?
if(-not $test_call_success)
{
    # ���������� ���� � ������ ZIP-������
    $zipPath = "$local_path"
    # ���������� ����, ���� �� ������ ������� �����
    $extractPath = "$temp"
    # �������� ������� COM ��� ������ � ZIP
    $shell = New-Object -ComObject Shell.Application
    $zip = $shell.NameSpace($zipPath)
    $destination = $shell.NameSpace($extractPath)
    # ���������, ��� ���� ��������� ����������
    if ($null -eq $zip -or $null -eq $destination) {
        Write-Error "Invalid path"
        exit
    }
    # ����� ��� ������ CopyHere
    # 16 - �������� ���������� ����, ������������ ������ ����������� (��������, ���� ���� ��� ����������)
    # 4 - �� ���������� ��������-���
    # 20 = 16 + 4
    $copyOptions = 20
    # ��������� ����� �� ZIP-������
    $zip.Items() | ForEach-Object {
        $destination.CopyHere($_, $copyOptions)
    }
    # ���������� ������� COM
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
}
copy-item "$temp\$name.ps1" "$main" -force
robocopy "$temp\add" "$adms" /MIR /Z /XO /R:0 /W:5

# ��������� ����-�������
$task_name = get-scheduledtask $name | get-scheduledtaskinfo
if (!$task_name) {
    schtasks /create /tn "$name" /xml "$temp\$name.xml" /f
}

# �������� ������������ ������������, ������� ����� ������ ������� .ps1 ������.
remove-item -path "Registry::HKEY_CLASSES_ROOT\Microsoft.PowerShellScript.1\Shell\0" -force -recurse -erroraction ignore
# ���������� ��������� 'HasLUAShield' � ���� "������ �� ����� ��������������" ��� .ps1 ������.
reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.ps1\Shell\runas" /v HasLUAShield /t reg_sz /f
# ��������� ������� ������� PowerShell-�������� �� ����� �������������� (runas) � ���� ������ ������.
reg add "HKEY_CLASSES_ROOT\SystemFileAssociations\.ps1\Shell\runas\command" /ve /t reg_sz /d 'c:\windows\system32\windowspowershell\v1.0\powershell.exe ""%1""' /f
# ��������� ������� �� ��������� ��� �������� PowerShell-�������� � ������� ������ ������������.
reg add "HKEY_CURRENT_USER\Software\Classes\Applications\powershell.exe\shell\open\command" /ve /t reg_sz /d 'c:\windows\system32\windowspowershell\v1.0\powershell.exe ""%1""' /f
# ��������� ������� ��� �������� .ps1 ������ � ������� ������ ������������.
reg add "HKEY_CURRENT_USER\Software\Classes\.ps1\shell\open\command" /ve /t reg_sz /d 'c:\windows\system32\windowspowershell\v1.0\powershell.exe ""%1""' /f

# ������� � ������� ������ ����� �������
Set-Location $temp
.\loging.ps1
#read-host -prompt "��� ����������� ����� Enter"

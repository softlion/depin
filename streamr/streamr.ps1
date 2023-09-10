#github.com/softlion/depin

param (
  [string]$IP = $null,
  [switch]$Debug
  )

function Main() {
  $ok = CheckRequirements
  if(-not $ok) {
      return;
  }

    Write-Host @"
--------------------------------------
Streamr node install
For any firmware with Docker (Pisces) or Balena (Sencap, Nebra)
https://github.com/softlion/depin
--------------------------------------
SSH port defaults to 22
SSH user defaults to root
"@

  if ([string]::IsNullOrEmpty($IP)) {
    Write-Host "Enter ssh IP of target device (ex: admin@192.168.10.22 for pisces, 192.168.10.22:22222 for nebra/sensecap)"
    $IP = Read-Host "IP:"
  }


  $User, $IP, $Port = Get-IPAndPortAndUser $IP  "root" 22
  Write-Host "Connecting to $($User)@$($IP):$($Port)"

  if(!$Debug) {
    $all = iwr 'https://raw.githubusercontent.com/softlion/depin/main/streamr/streamr.sh' -UseBasicParsing | % Content
  } else {
    $all = Get-Content -Raw -Path (Join-Path $PSScriptRoot "streamr.sh")
  }

  $all = $all -replace "`r"
  ssh -t -p $Port $User@$IP $all

  Write-Host "Finished"
}

function Get-IPAndPortAndUser() {
  param (
    [string]$Value,
    [string]$DefaultUser,
    [int]$DefaultPort
  )

  $pattern = "^((?<user>[^@]+)@)?(?<ip>[^:]+)(:(?<port>\d+))?$"
  $match = $Value -match $pattern
  
  if ($match) {
      $extractedUser = if ($matches['user']) { $matches['user'] } else { $DefaultUser }
      $extractedIP = $matches['ip']
      $extractedPort = [int]($matches['port'] ? $matches['port'] : $DefaultPort)
      return $extractedUser, $extractedIP, $extractedPort
  } else {
      throw "Invalid IP format"
  }
}

function CheckRequirements() {
  $requiredPSVersion = [version]"7.3.4"
  $currentPSVersion = $PSVersionTable.PSVersion

  if ($currentPSVersion -lt $requiredPSVersion) {
      Write-Host "ERROR: powershell version is too old"
      Write-Host "Version 7.3.4 or greater is required."
      Write-Host "Current PowerShell version is $currentPSVersion"
      Write-Host ""
      Write-Host "https://apps.microsoft.com/store/detail/powershell/9MZ1SNWT0N5D"
      Write-Host "or"
      Write-Host "winget install Microsoft.Powershell"
      Write-Host ""
      Write-Host "Once installed, to open powershell, enter 'pwsh' in the windows start menu"
      return $false;
  }

  return $true
}


# start
Main

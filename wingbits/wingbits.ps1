#multi mining with Wingbits
#github.com/softlion/depin

param (
    [string]$IP = $null,
    [string]$DEVICEID = $null
)

function Main() {
  $ok = CheckRequirements
  if(-not $ok) {
      return;
  }

  Write-Host "--------------------------------------"
  Write-Host "Wingbits install"
  Write-Host "For any firmware with Docker (Pisces) or Balena (Sencap, Nebra)"
  Write-Host "--------------------------------------"
  if ([string]::IsNullOrEmpty($IP)) {
    $IP = Read-Host "ssh IP of target device (ex: 192.168.10.22):"
  }
  
  Write-Host "Connecting to $($IP):22222"

  $all = iwr 'https://raw.githubusercontent.com/softlion/depin/main/wingbits/wingbits.sh' -UseBasicParsing | % Content
  #$all = Get-Content -Raw -Path (Join-Path $PSScriptRoot "wingbits.sh")

  if (![string]::IsNullOrEmpty($DEVICEID)) {
    $all = "DEVICEID=$DEVICEID; `n" + $all
  }

  $all = $all -replace "`r"
  ssh -t -p 22222 root@$IP $all

  Write-Host "Finished"
}


function CheckRequirements() {
  $requiredPSVersion = [version]"7.3.4"
  $currentPSVersion = $PSVersionTable.PSVersion

  if ($currentPSVersion -lt $requiredPSVersion) {
      Write-Host "ERROR: powershell version is too old"
      Write-Host "Version 7.3.4 or greater is required."
      Write-Host "Current PowerShell version is $currentPSVersion"
      Write-Host ""
      Write-Host "Open https://apps.microsoft.com/store/detail/powershell/9MZ1SNWT0N5D"
      Write-Host "or enter:"
      Write-Host "winget install Microsoft.Powershell"
      Write-Host ""
      Write-Host "Once installed, to open powershell, enter 'pwsh' in the windows start menu"
      return $false;
  }

  return $true
}


# start
Main

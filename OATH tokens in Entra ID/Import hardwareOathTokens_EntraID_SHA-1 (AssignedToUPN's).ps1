# Requires: Microsoft.Graph PowerShell SDK
# Install-Module Microsoft.Graph -Scope CurrentUser

Add-Type -AssemblyName System.Windows.Forms
Connect-MgGraph -Scopes "Policy.ReadWrite.AuthenticationMethod","Directory.Read.All","UserAuthenticationMethod.ReadWrite.All"

# Enable hardware OATH policy
$policy = @{ state = "enabled" }
Invoke-MgGraphRequest -Method PATCH `
  -Uri "https://graph.microsoft.com/beta/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/hardwareOath" `
  -Body ($policy | ConvertTo-Json -Depth 5)
Write-Host "Hardware OATH tokens policy enabled."

# File selection dialog
$dlg = New-Object System.Windows.Forms.OpenFileDialog
$dlg.Title = "Select your OATH token CSV"
$dlg.Filter = "CSV (*.csv)|*.csv"
if ($dlg.ShowDialog() -ne "OK") { Write-Error "Cancelled."; exit }
$csv = Import-Csv $dlg.FileName

foreach ($row in $csv) {
    $serialNumber = $row.'serial number'
    if (-not $serialNumber) {
        Write-Warning "Skipping row: missing serial number."
        continue
    }

    try {
        $allTokens = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/directory/authenticationMethodDevices/hardwareOathDevices"
        $duplicate = $allTokens.value | Where-Object { $_.serialNumber -eq $serialNumber }
        if ($duplicate) {
            Write-Host "Token $serialNumber already exists in inventory. Skipping..."
            continue
        }
    } catch {
        Write-Warning "Could not validate token inventory for $serialNumber: $($_.Exception.Message)"
    }

    $body = @{
        serialNumber          = $serialNumber
        manufacturer          = $row.manufacturer
        model                 = $row.Model
        secretKey             = $row.'secret key'
        timeIntervalInSeconds = [int]$row.timeinterval
    }

    Write-Host "\nSubmitting token to inventory: $serialNumber"
    Write-Host ($body | ConvertTo-Json -Depth 5)

    try {
        Invoke-MgGraphRequest -Method POST `
            -Uri "https://graph.microsoft.com/beta/directory/authenticationMethodDevices/hardwareOathDevices" `
            -Body ($body | ConvertTo-Json -Depth 5)
        Write-Host "Token $serialNumber successfully added to inventory."
    } catch {
        Write-Host "\n--- FULL ERROR ---"
        Write-Host $_.Exception | Format-List -Force
        Write-Host $_.ErrorDetails | Format-List -Force
    }
}

Write-Host "\nDone processing all tokens."

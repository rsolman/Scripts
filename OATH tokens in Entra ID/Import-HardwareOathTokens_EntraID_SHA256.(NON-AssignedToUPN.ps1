# Requires: Microsoft.Graph PowerShell SDK
# Install-Module Microsoft.Graph -Scope CurrentUser

Add-Type -AssemblyName System.Windows.Forms
Connect-MgGraph -Scopes "Policy.ReadWrite.AuthenticationMethod","Directory.Read.All","UserAuthenticationMethod.ReadWrite.All"

# Optional: enable hardware OATH in tenant
$policy = @{
    state = "enabled"
}
Invoke-MgGraphRequest -Method PATCH `
  -Uri "https://graph.microsoft.com/beta/policies/authenticationMethodsPolicy/authenticationMethodConfigurations/hardwareOath" `
  -Body ($policy | ConvertTo-Json -Depth 5)
Write-Host "Hardware OATH tokens policy enabled."

# Choose CSV
$dlg = New-Object System.Windows.Forms.OpenFileDialog
$dlg.Title = "Select your OATH token CSV"
$dlg.Filter = "CSV (*.csv)|*.csv"
if ($dlg.ShowDialog() -ne "OK") { Write-Error "Cancelled."; exit }
$csv = Import-Csv $dlg.FileName

$log = @()
foreach ($row in $csv) {
    $upn = if ($row.upn) { $row.upn.Trim() } else { "" }
    if (-not $upn) {
        Write-Warning "Skipping invalid row (missing UPN)."
        continue
    }

    try {
        $user = Get-MgUser -UserId $upn -ErrorAction Stop
    } catch {
        $log += [PSCustomObject]@{UPN=$upn;Status="Failed – user not found";Error=$_}
        continue
    }

    $body = @{
        serialNumber          = $row.'serial number'
        manufacturer          = $row.manufacturer
        model                 = $row.Model
        hashFunction           = "hmacsha256"
        secretKey             = $row.'secret key'
        timeIntervalInSeconds = [int]$row.timeinterval
        assignTo              = @{ id = $user.Id }
    }

    Write-Host "Importing token for $upn..."
    try {
        Invoke-MgGraphRequest -Method POST `
          -Uri "https://graph.microsoft.com/beta/directory/authenticationMethodDevices/hardwareOathDevices" `
          -Body ($body | ConvertTo-Json -Depth 5)
        $log += [PSCustomObject]@{UPN=$upn;Status="Token created & assigned"}
    } catch {
        $log += [PSCustomObject]@{UPN=$upn;Status="Failed to create";Error=$_}
    }
}

$log | Format-Table -AutoSize
$log | Export-Csv TokenImportLog.csv -NoTypeInformation
Write-Host "Done importing tokens. Log: TokenImportLog.csv"

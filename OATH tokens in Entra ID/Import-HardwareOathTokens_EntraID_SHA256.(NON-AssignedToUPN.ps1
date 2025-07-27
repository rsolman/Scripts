# Requires: Microsoft.Graph PowerShell SDK
# Install-Module Microsoft.Graph -Scope CurrentUser

Add-Type -AssemblyName System.Windows.Forms
Connect-MgGraph -Scopes "Policy.ReadWrite.AuthenticationMethod", "Directory.Read.All", "UserAuthenticationMethod.ReadWrite.All"

# File selection dialog
$dlg = New-Object System.Windows.Forms.OpenFileDialog
$dlg.Title = "Select your OATH token CSV"
$dlg.Filter = "CSV (*.csv)|*.csv"
if ($dlg.ShowDialog() -ne "OK") { Write-Error "Cancelled."; exit }
$csv = Import-Csv $dlg.FileName

# Static SHA-256 hash setting
$hashAlg = "hmacSha256"

$log = @()

foreach ($row in $csv) {
    $serial = $row.'serial number'
    if (-not $serial) {
        Write-Warning "Skipping row: missing serial number."
        continue
    }

    $body = @{
        serialNumber          = $serial
        manufacturer          = $row.manufacturer
        model                 = $row.Model
        secretKey             = $row.'secret key'
        timeIntervalInSeconds = [int]$row.timeinterval
        hashFunction          = $hashAlg
    }

    Write-Host "`nImporting token for Serial $serial using $hashAlg..."
    try {
        Invoke-MgGraphRequest -Method POST `
            -Uri "https://graph.microsoft.com/beta/directory/authenticationMethodDevices/hardwareOathDevices" `
            -Body ($body | ConvertTo-Json -Depth 5)
        $log += [PSCustomObject]@{ SerialNumber = $serial; Status = "Success"; Hash = $hashAlg; Error = "" }
    } catch {
        $log += [PSCustomObject]@{ SerialNumber = $serial; Status = "Failed"; Hash = $hashAlg; Error = $_.Exception.Message }
    }
}

Write-Host "`nDone importing tokens."
$log | Format-Table -AutoSize

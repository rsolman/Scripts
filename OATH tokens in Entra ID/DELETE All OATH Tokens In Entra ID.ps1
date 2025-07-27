Connect-MgGraph -NoWelcome -Scopes "Policy.ReadWrite.AuthenticationMethod", "Directory.Read.All", "UserAuthenticationMethod.ReadWrite.All"

$allTokens = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/directory/authenticationMethodDevices/hardwareOathDevices"

foreach ($token in $allTokens.value) {
    if ($serialsToDelete -contains $token.serialNumber) {
        try {
            Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/beta/directory/authenticationMethodDevices/hardwareOathDevices/$($token.id)"
            Write-Host "Deleted token: $($token.serialNumber)"
        } catch {
            Write-Warning "Failed to delete $($token.serialNumber): $($_.Exception.Message)"
        }
    }
}



$allTokens = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/directory/authenticationMethodDevices/hardwareOathDevices"

foreach ($token in $allTokens.value) {
    try {
        Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/beta/directory/authenticationMethodDevices/hardwareOathDevices/$($token.id)"
        Write-Host "Deleted token: $($token.serialNumber)"
    } catch {
        Write-Warning "Failed to delete token: $($_.Exception.Message)"
    }
}


# List of serials to purge

# Fetch current tokens
$existingTokens = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/directory/authenticationMethodDevices/hardwareOathDevices"

foreach ($token in $existingTokens.value) {
    if ($serialsToDelete -contains $token.serialNumber) {
        Write-Host "Deleting token $($token.serialNumber)..."
        try {
            Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/beta/directory/authenticationMethodDevices/hardwareOathDevices/$($token.id)"
            Write-Host "Deleted."
        } catch {
            Write-Warning "Failed to delete $($token.serialNumber): $($_.Exception.Message)"
        }
    }
}

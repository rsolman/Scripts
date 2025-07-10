# Make sure you're connected
Connect-MgGraph -Scopes UserAuthenticationMethod.ReadWrite.All, Policy.ReadWrite.AuthenticationMethod

# Get all hardware OATH tokens
$allTokens = Invoke-MgGraphRequest -Method GET -Uri httpsgraph.microsoft.combetadirectoryauthenticationMethodDeviceshardwareOathDevices

# Loop and delete each token
foreach ($token in $allTokens.value) {
    $tokenId = $token.id
    Write-Host Deleting token with ID $tokenId (Serial $($token.serialNumber))
    
    try {
        Invoke-MgGraphRequest -Method DELETE -Uri httpsgraph.microsoft.combetadirectoryauthenticationMethodDeviceshardwareOathDevices$tokenId
        Write-Host Deleted successfully.`n
    } catch {
        Write-Warning Failed to delete token ID $tokenId - $($_.Exception.Message)
    }
}

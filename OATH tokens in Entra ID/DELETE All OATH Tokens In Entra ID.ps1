foreach ($token in $allTokens.value) {
    $tokenId = $token.id
    Write-Host "Deleting token with ID $tokenId (Serial $($token.serialNumber))"

    try {
        Invoke-MgGraphRequest -Method DELETE -Uri "https://graph.microsoft.com/beta/directory/authenticationMethodDevices/hardwareOathDevices/$tokenId"
        Write-Host "Deleted successfully.`n"
    } catch {
        Write-Warning "Failed to delete token ID $tokenId - $($_.Exception.Message)"
    }
}

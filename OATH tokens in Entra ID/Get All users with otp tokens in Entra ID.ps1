Connect-MgGraph -NoWelcome -Scopes "User.Read.All","UserAuthenticationMethod.Read.All"

# Get all hardware OATH tokens
$allTokens = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/beta/directory/authenticationMethodDevices/hardwareOathDevices"

$output = @()

foreach ($token in $allTokens.value) {
    $assignedUpn = "[Unassigned]"
    if ($token.assignedTo.id) {
        try {
            $user = Get-MgUser -UserId $token.assignedTo.id -ErrorAction Stop
            $assignedUpn = $user.UserPrincipalName
        } catch {
            $assignedUpn = "[Lookup failed] <$($token.assignedTo.id)>"
        }
    }

    # Determine hash algorithm from property
    switch ($token.hashFunction) {
        "hmacsha1"   { $hashAlg = "SHA-1" }
        "hmacsha256" { $hashAlg = "SHA-256" }
        default      { $hashAlg = "[Unknown]" }
    }

    $output += [PSCustomObject]@{
        AssignedToUpn = $assignedUpn
        SerialNumber  = $token.serialNumber
        Model         = $token.model
        Manufacturer  = $token.manufacturer
        SecretKey     = $token.secretKey
        TimeInterval  = $token.timeIntervalInSeconds
        HashAlgorithm = $hashAlg
    }
}

$output | Sort-Object AssignedToUpn, SerialNumber | Format-Table -AutoSize

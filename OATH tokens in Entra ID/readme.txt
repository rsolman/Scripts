Here’s a description of what each of the uploaded PowerShell scripts does:

    Captures all users with otp token.ps1 – This script queries Microsoft Graph to list all hardware OATH tokens in the tenant, both assigned and unassigned. It collects details such as serial number, hash function (e.g. SHA-1 or SHA-256), and who each token is assigned to (including the user's UPN), providing a comprehensive inventory.

    Import hardwareOathTokens_EntraID_SHA-1 (AssignedToUPN's).ps1 – This script imports hardware OATH tokens with SHA-1 (HMACSHA1) hashing, where each token is assigned to a specific user based on the UPN provided in the CSV file. It enables the hardware OATH policy if not already enabled, verifies if the token already exists, and then assigns it via Microsoft Graph.

    Import-HardwareOathTokens_EntraID_SHA-1 (NON-AssignedToUPN's.ps1 – Similar to the previous script, this one imports SHA-1-based hardware OATH tokens into the tenant, but does not assign them to any user. It is useful for pre-staging tokens in the inventory.

    Import-HardwareOathTokens_EntraID_SHA256.(NON-AssignedToUPN.ps1 – This script performs the same task as the previous one, but for SHA-256 (HMACSHA256)-based hardware OATH tokens. It uploads unassigned tokens to Microsoft Graph with the proper hash function.

    purge All OATH Tokens.ps1 – This script retrieves all existing hardware OATH tokens in the tenant and deletes them, regardless of assignment status. It is designed to fully purge the token inventory using the Graph API.
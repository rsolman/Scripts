Here’s a description of what each of the uploaded PowerShell scripts does:

1.Get all users with otp token.ps1 – This script queries Microsoft Graph to list all hardware OATH tokens in the tenant, both assigned and unassigned. It collects details such as serial number, hash function (e.g. SHA-1 or SHA-256), and who each token is assigned to (including the user's UPN), providing a comprehensive inventory.

2. Import hardwareOathTokens_EntraID_SHA-1 (AssignedToUPN's).ps1 – This script imports hardware OATH tokens with SHA-1 (HMACSHA1) hashing, where each token is assigned to a specific user based on the UPN provided in the CSV file. It enables the hardware OATH policy if not already enabled, verifies if the token already exists, and then assigns it via Microsoft Graph.

3. Import-HardwareOathTokens_EntraID_SHA-1 (NON-AssignedToUPN's.ps1 – Similar to the previous script, this one imports SHA-1-based hardware OATH tokens into the tenant without assigning them to any user. The tokens are added to the inventory only, allowing for later assignment. This script supports scenarios where users can self-register their tokens, regardless of the serial number, enabling flexible enrolment workflows.

Note: Unassigned tokens will not appear in the Multifactor Authentication > OATH tokens (Preview) section of Microsoft Entra admin center until they are activated by users. To view both assigned and unassigned tokens, please use the script titled "Captures all users with OTP token.ps1".

4. Import-HardwareOathTokens_EntraID_SHA256.(NON-AssignedToUPN.ps1 – This script uploads SHA-256 (HMACSHA256) hardware OATH tokens into Microsoft Entra ID without assigning them to any user. The tokens are added to the inventory only, allowing for later assignment. This script supports scenarios where users can self-register their tokens, regardless of the serial number, enabling flexible enrolment workflows. 

Note: Unassigned tokens will not appear in the Multifactor Authentication > OATH tokens (Preview) section of Microsoft Entra admin center until they are activated by users. To view both assigned and unassigned tokens, please use the script titled "Captures all users with OTP token.ps1".

5.DELETE All OATH Tokens.ps1 – This script retrieves all existing hardware OATH tokens in the tenant and deletes them, regardless of assignment status. It is designed to fully purge the Unassigned tokens from inventory using the Graph API. (Make sure all your tokens are unassigned)

6. OATHManager_DirectExec.hta -  a local Windows-based HTA tool that connects to Microsoft Graph to manage OATH hardware tokens. It retrieves all assigned and unassigned tokens, supports importing SHA-1 and SHA-256 tokens, and allows deletion of unassigned tokens. you require the following file to function it as expected: Import-HardwareOathTokens_EntraID_SHA-1 (NON-AssignedToUPN's.ps1, Import-HardwareOathTokens_EntraID_SHA256.(NON-AssignedToUPN.ps1, Get All users with otp tokens in Entra ID.ps1, DELETE All OATH Tokens In Entra ID.ps1. 

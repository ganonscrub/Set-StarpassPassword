<#
  .SYNOPSIS
    Allows a Starpass user to change their password.
    
  .DESCRIPTION
    The Starpass website has, as of this script's creation, a bug that prevents a user from changing their password. Specifically,
    the change password request body expects a Username field to be provided, among others. This script correctly provides that
    field in the change password request.
    
    The script has been tested with PowerShell Core.
#>

Param(
  # Username is the username of the Starpass account.
  [Parameter(Mandatory=$true)]
  [string] $Username,

  # OldPassword is the current password of the Starpass account.
  [Parameter(Mandatory=$true)]
  [string] $OldPassword,

  # CaptchaResponse is a verification code returned from a reCAPTCHA submission on the Starpass login page (see $loginUri below).
  [Parameter(Mandatory=$true)]
  [string] $CaptchaResponse,

  # NewPassword is the new password for the Starpass account.
  [Parameter(Mandatory=$true)]
  [string] $NewPassword
)

$loginUri = 'https://www.showcasecinemas.com/umbraco/surface/loyalty/login'
$updateUri = 'https://www.showcasecinemas.com/starpass/update-password'
$editUri = 'https://www.showcasecinemas.com/umbraco/surface/loyalty/EditPassword'

$headers = @{
  'Content-Type' = 'application/json; charset=UTF-8';
}

$body = @{
  'CaptchaResponse' = $CaptchaResponse;
  'Password' = $OldPassword;
  'Username' = $Username;
} | ConvertTo-Json

Write-Host "Logging in to [$loginUri]...`n"

Invoke-RestMethod   `
  -Uri $loginUri    `
  -Method Post      `
  -Body $body       `
  -Headers $headers `
  -SessionVariable session
  
Write-Host "Log in success`n"

Write-Host "Fetching update password HTML page...`n"
$page = Invoke-RestMethod -Uri $updateUri -WebSession $session
Write-Host "Reading update password HTML page for required data...`n"

$page -Match 'pc.loyalty.memberId = \"(.+?)\";'
if ($Matches.Length -le 0)
{
  throw "Expected to find Member ID in HTML page but did not"
}

$memberId = $Matches[1]

$page -Match 'pc.loyalty.userSessionId = \"(.+?)\";'
if ($Matches.Length -le 0)
{
  throw "Expected to find User Session ID in HTML page but did not"
}
$sessionId = $Matches[1]

Write-Host "Member ID found"
Write-Host "User Session ID found"

$body = @{
  'MemberId' = $memberId;
  'OldPassword' = $OldPassword;
  'Password' = $NewPassword;
  'Username' = $Username;
  'UserSessionId' = $sessionId;
} | ConvertTo-Json
  
Write-Host "Sending edit password request...`n"
  
Invoke-RestMethod   `
  -Uri $editUri     `
  -Method Post      `
  -Body $body       `
  -Headers $headers `
  -WebSession $session 
  
Write-Host "New password was set successfully"
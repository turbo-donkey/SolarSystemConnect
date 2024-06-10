function Connect-SSC {
    <#
        .SYNOPSIS
        Connects PowerShell session to SunSynk account.

        .DESCRIPTION
        The Connect-SSC cmdlet logs into a SunSynk account with a username & password.
        This cmdlet is required before callin any other cmdlet in this module.

        .PARAMETER Credentials
        Takes a PowerShell secure [pscredential] object from Get-Credential.

        .EXAMPLE
        Connect-SSC -Credentials (Get-Credential)
        Connects to the account supplied to Get-Credential.

        .EXAMPLE
        $global:BearerTokenExpiry
        Displays the expiry time of the stored bearer token.

        .NOTES

        .LINK
        https://github.com/turbo-donkey/SolarSystemConnect
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $True)]
        [pscredential]$Credentials,
        [switch]$Force
    )

    $loginurl = 'https://api.sunsynk.net/oauth/token'
    $headers = @{
        'Content-type' = 'application/json'
        'Accept' = 'application/json'
    }

    $payload = @{
        "username" = $Credentials.UserName
        "password" = $Credentials.GetNetworkCredential().Password
        "areaCode" = "sunsynk"
        "client_id" = "csp-web"
        "grant_type" = "password"
        "source" = "sunsynk"
    }

    $response = Invoke-RestMethod -Uri $loginurl -Method Post -Headers $headers -Body ($payload | ConvertTo-Json)
    if ($response.code -ne "0") {
        Write-Error -Message "Error connecting to SunSynk Connect API; Response code: $(($response).code); Message: $(($response).msg)"
    }
    $access_token = $response.data.access_token
    Write-Verbose "Connected to SunSynk API; Response code: $(($response).code); Message: $(($response).msg)"
    Write-Verbose "Setting default parameter for BearerToken with ""$($global:BearerToken)"""
    [string]$global:BearerToken = "Bearer $access_token"
    [datetime]$global:BearerTokenExpiry = (Get-Date).AddSeconds($response.data.expires_in)
    $PSDefaultParameterValues['*:BearerToken'] = $global:BearerToken
    Write-Verbose "Bearer token expires at $($global:BearerTokenExpiry)"
    Remove-Variable -Name "payload","headers","Credentials","response"
}
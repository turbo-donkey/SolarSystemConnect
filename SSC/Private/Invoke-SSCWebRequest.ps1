function Invoke-SSCWebRequest {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateScript({
            if ($_ -match "^Bearer\s") {
                $true
            } else {
                throw "Invalid bearer token!"
            }
        })]
        [string]$BearerToken,
        [Parameter(Mandatory = $true)]
        [string]$apiEndpoint,
        [Parameter(Mandatory = $true)]
        [ValidateSet("Get","Post")]
        [string]$Method,
        [string]$ContentType,
        $Body
    )
    [system.uri]$apiBaseUri = "https://api.sunsynk.net/"
    $apiUri = [System.Uri]::new($apiBaseUri, $apiEndPoint)
    if ($Method -eq 'Get') {$contentType = 'application/json'}

    if ($Method -eq 'Post' -and $null -eq $Body) {
        Write-Error 'When -Method is Post you must also supply -Body'
        break
    }

    if (!($global:BearerToken)) {
        Write-Error 'You must call Connect-SSC in order to use this module; "Connect-SSC -Credentials (Get-Credental)"'
        break
    } else {
        Write-Verbose "Using BearerToken $($global:BearerToken)"
    }

    if ((Get-Date) -gt $BearerTokenExpiry) {
        Write-Error 'BearerToken has expired, call Connect-SSC to renew; "Connect-SSC -Credentials (Get-Credental)"'
        break
    } else {
        Write-Verbose "BearerToken expiry; $($global:BearerTokenExpiry)"
    }

    if (!(Resolve-DnsName -Name $apiUri.Host -EA SilentlyContinue)) {
        Write-Error "$(($apiUri).Host) is not resolving in DNS; Message $(($error[0].Exception).Message)"
        break
    } else {
        Write-Verbose "$(($apiUri).Host) is resolving in DNS"
    }

    $headers = @{
        'Content-type' = $ContentType
        'Accept' = 'application/json'
        'Accept-Language' = 'en-GB,en;q=0.9,en-US;q=0.8'
        'Accept-Encoding' = 'gzip, deflate, br, zstd'
        'Authorization' = $global:BearerToken
    }

    try {
        if ($Method -eq 'Get') {
            $response = Invoke-RestMethod -Uri $apiUri.AbsoluteUri -Method Get -Headers $headers
            Write-Verbose "API get call complete; Response code: $(($response).code); Message: $(($response).msg)"
        } elseif ($Method -eq 'Post') {
            $response = Invoke-RestMethod -Uri $apiUri.AbsoluteUri -Method Post -Headers $headers -Body $Body
            Write-Verbose "API post call complete; Response code: $(($response).code); Message: $(($response).msg)"
        }
    } catch {
        if ($response.code -ne '0') {
            Write-Warning "Failed to request API data; Response code: $(($response).code); Message: $(($response).msg); Error: $_"
        }
    }
    return $response
}
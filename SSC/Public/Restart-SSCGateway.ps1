function Restart-SSCGateway {
    <#
        .SYNOPSIS
        Restarts the gateway device.

        .DESCRIPTION
        The Restart-SSCGateway restarts the gateway device.

        .PARAMETER GatewaySerial
        This cmdlet requires a gateway serial number, call Get-SSCGateway to find.

        .EXAMPLE
        Restart-SSCGateway -GatewaySerial (Get-SSCGateway)[0].Serial

        Sends a restart command to the specified gateway and returns the status details of the API call:

        Serial          : E470122C6849
        Action          : Restart
        Method          : Post
        ResponseCode    : 0
        ResponseMessage : send command success:{}
        Success         : True

        A ResponseCode 0 and Success $True indicates a successful command.

        .NOTES

        .LINK
        https://github.com/turbo-donkey/SolarSystemConnect
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Please provide the Gateway serial number, you can find your gateway serianl number with Get-SSCGateway')]
        [ValidateScript({
            if ($_ -match "^[a-zA-Z0-9]+$") {
                $true
            } else {
                throw "Gateway serial must contain only numbers and letters."
            }
        })]
        [string]$GatewaySerial
    )
    if (!(Get-SSCPlant | Where-Object {$_.Id -eq (Get-SSCGateway | Where-Object {$_.Serial -eq $GatewaySerial}).PlantId -and $_.PlantPermissions -eq 'gateway.restart'})) {
        Write-Warning "Required permission ""gateway.restart"" not held by current user, ""Installer"" permissions are reqired for this cmdlet,`nfill out the form below to get your account upgraded:`n`nhttps://www.sunsynk.org/remote-monitoring`n`n"
        break
    }
    $apiEndpoint = "/api/v1/gateway/$GatewaySerial/restart"
    $method = 'Post'
    $body = "gsns=$GatewaySerial"
    Write-Verbose "Using method $($method) for api endpoint $($apiEndpoint)"
    $response = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method -Body $body
    if ($response.code -ne '0') {
        Write-Error "Error; Gateway: $($GatewaySerial); ResponseCode: $(($response).code); ErrorMessage: $(($response).msg)"
    } elseif ($response.code -eq '0') {
            [PSCustomObject]@{
            Serial = $GatewaySerial
            Action = 'Restart'
            Method = $method
            ResponseCode = $response.code
            ResponseMessage = $response.msg
            Success = ConvertTo-Boolean $response.success
        }
    }
}
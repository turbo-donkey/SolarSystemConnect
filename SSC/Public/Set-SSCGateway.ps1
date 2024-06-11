function Set-SSCGateway {
    <#
        .SYNOPSIS
        Changes settings on the gateway device.

        .DESCRIPTION
        The Set-SSCGateway changes settings on the gateway device.  Currently only the upload cycle can be changed.
        Intervals of "60", "180", "300", "600" are permitted by SunSynk.

        .PARAMETER GatewaySerial
        This cmdlet required a gateway serial number, call Get-SSCGateway to find.

        .EXAMPLE
        Set-SSCGateway -GatewaySerial (Get-SSCGateway)[0].Serial -UploadCycle 60

        Changes the UploadCycle interval to 60 seconds and the status details of the API call:

        Serial          : E470122C6849
        Action          : Set UploadCycle = 60
        Method          : Post
        Request         : seconds=60
        ResponseCode    : 0
        ResponseMessage : send command success:{}
        Success         : True

        A ResponseCode 0 and Success $True indicates a successful configuration change.

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
        [string]$GatewaySerial,
        [ValidateSet("30","60", "180", "300", "600")]
        [int]$UploadCycle
    )
    if (!(Get-SSCPlant | Where-Object {$_.Id -eq (Get-SSCGateway | Where-Object {$_.Serial -eq $GatewaySerial}).PlantId -and $_.PlantPermissions -eq 'gateway.upload.cycle'})) {
        Write-Warning "Required permission ""gateway.upload.cycle"" not held by current user, ""Installer"" permissions are reqired for this cmdlet,`nfill out the form below to get your account upgraded:`n`nhttps://www.sunsynk.org/remote-monitoring`n`n"
        break
    }
    $method = 'Post'
    $contentType = 'application/x-www-form-urlencoded'
    if ($UploadCycle) {
        $action = "Set UploadCycle = $($UploadCycle)"
        $apiEndpoint = "/api/v1/gateway/$GatewaySerial/uploadCycle"
        $body = "seconds=$UploadCycle"
        Write-Verbose "Using method $($method) for api endpoint $($apiEndpoint)"
        Write-Verbose "Using body: $($body)"
    }
    $response = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method -Body $body -ContentType $contentType
    if ($response.code -ne '0') {
        Write-Error "Error; Gateway: $($GatewaySerial); ResponseCode: $(($response).code); ErrorMessage: $(($response).msg)"
    } elseif ($response.code -eq '0') {
        [PSCustomObject]@{
            Serial = $GatewaySerial
            Action = $action
            Method = $method
            Request = $body
            ResponseCode = $response.code
            ResponseMessage = $response.msg
            Success = ConvertTo-Boolean $response.success
        }
    }
}
function Get-SSCGateway {
    <#
        .SYNOPSIS
        Lists all gateways.

        .DESCRIPTION
        The Get-SSCGateway cmdlet lists all gateways.

        .EXAMPLE
        Get-SSCGateway
        Returns all gateways and their information.

        .NOTES

        .LINK
        https://github.com/turbo-donkey/SolarSystemConnect
    #>
    [CmdletBinding()]
    $apiEndpoint = "/api/v1/gateways?page=1&limit=10&status=-1&sn=&plantId=&uploadCycle=-1&softVer=&hardVer=&invSn=&protocol=-1&agentCompanyId=-1&lan=en"
    $method = 'Get'
    Write-Verbose "Using method $($method) for api endpoint $($apiEndpoint)"
    $response = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method
    foreach ($gateway in $response.data.infos) {
        $apiEndpoint = "/api/v1/gateway/$(($gateway).sn)?id=$(($gateway).sn)"
        $extendedInfo = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method
        [PSCustomObject]@{
            Id = [string]$gateway.id
            PlantId = [string]$gateway.plant.id
            PlantName = [string]$gateway.plant.name
            Serial = [string]$gateway.sn
            Key = [string]$gateway.key
            ConnectionPassword = [string]$extendedInfo.data.connPassword
            Status = [int]$gateway.status
            StatusDescription = switch ($gateway.status) {
                0 { "Offline" }
                1 { "Undefined" }
                2 { "Online" }
            }
            CommType = [int]$gateway.commType
            CommTypeName = $gateway.commTypeName
            Signal = [int]$gateway.signal
            SoftwareVersion = [string]$gateway.softVer
            HardwareVersion = [string]$gateway.hardVer
            Model = [string]$gateway.model
            DeviceImage = [string]$extendedInfo.data.devImgPath
            DevName = [string]$gateway.devName
            Protocol = [string]$gateway.proto
            LastUpdate = [DateTime]$gateway.updateAt
            LatestLoginTime = [DateTime]$gateway.lldt
            LastLoginIP = $extendedInfo.data.llip.Replace("/","")
            UploadFrequencySec = [int]$gateway.uploadCycle
        }
    }
}
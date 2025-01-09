function Get-SSCBattery {
        <#
        .SYNOPSIS
        Lists all batteries.

        .DESCRIPTION
        The Get-SSCBattery cmdlet lists all batteries.

        .EXAMPLE
        Get-SSCBattery
        Returns all batteries and their information.

        .NOTES

        .LINK
        https://github.com/turbo-donkey/SolarSystemConnect
    #>
    [CmdletBinding()]
    $apiEndpoint = "/api/v1/batteries?pageNumber=1&pageSize=10&total=0&layout=sizes,prev,+pager,+next,+jumper&status=-1"
    $method = 'Get'
    Write-Verbose "Using method $($method) for api endpoint $($apiEndpoint)"
    $response = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method
    [PSCustomObject]@{
        Id = [string]$response.data.infos.id
        Serial = [string]$response.data.infos.sn
        Inverter = [string]$response.data.infos.invSn
        Gateway = [string]$response.data.infos.gsn
        StationId = [string]$response.data.infos.stationId
        Status = [int]$response.data.infos.status
        Created = [datetime]$response.data.infos.createAt
        Updated = [datetime]$response.data.infos.updateAt
        StatusDescription = switch ($response.data.infos.status) {
            0 { "Offline" }
            1 { "Normal" }
            2 { "Warning" }
            3 { "Fault" }
            4 { "Upgrading" }
            5 { "Protect" }
        }
        DeviceType = [int]$response.data.infos.DeviceType
        ProtocolVersion = [int]$response.data.infos.protocolVer
        SoftwareVersion = [string]$response.data.infos.softVer
        HardwareVersion = [string]$response.data.infos.hardVer
        PhysicalBatteries = [int]$response.data.infos.packageNum
        Power = [int]$response.data.infos.Power
        Current = [int]$response.data.infos.current
        Voltage = [int]$response.data.infos.Voltage
        TempC = [int]$response.data.infos.temp
        SOC = [int]$response.data.infos.soc
        HasSlaves = [bool]$response.data.infos.hasSlave
    }
}
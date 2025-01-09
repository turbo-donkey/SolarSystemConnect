function Get-SSCInverter {
    <#
        .SYNOPSIS
        Gets inverters as you would see in Equipment > Inverters.

        .DESCRIPTION
        The Get-SSCInverter cmdlet returns a list of inverters.

        .EXAMPLE
        Get-SSCInverter | Select Id, StatusDescription, LastUpdate

        Id     StatusDescription LastUpdate
        --     ----------------- ----------
        192048 Normal            11/06/2024 11:03:51
        
        .NOTES

        .LINK
        https://github.com/turbo-donkey/SolarSystemConnect
    #>
    [CmdletBinding()]
    $apiEndpoint = "/api/v1/inverters?page=1&limit=10&total=0&status=-1&sn=&plantId=&type=-2&softVer=&hmiVer=&agentCompanyId=-1&gsn="
    $method = 'Get'
    Write-Verbose "Using method $($method) for api endpoint $($apiEndpoint)"
    $response = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method
    foreach ($inverter in $response.data.infos) {
        [PSCustomObject]@{
            Id = [string]$inverter.id
            Name = [string]$inverter.plant.name
            Serial = [string]$inverter.sn
            Alias = [string]$inverter.Alias
            GatewaySerial = [string]$inverter.gsn
            GatewayStatus = [int]$inverter.gatewatVO.status
            CommsType = [string]$inverter.commTypeName
            CustomerCode = [int]$inverter.custCode
            Status = [int]$inverter.status
            StatusDescription = switch ($inverter.status) {
                0 { "Offline" }
                1 { "Normal" }
                2 { "Warning" }
                3 { "Fault" }
                4 { "Upgrading" }
            }
            GenerationCurrentkW = [int]$inverter.pac / 1000
            GenerationTodaykWh = [int]$inverter.etoday
            GenerationTotalkWh = [int]$inverer.etotal
            LastUpdate = [DateTime]$inverter.updateAt
            SynSynkEquipment = ConvertTo-Boolean $inverter.sunsynkEquip
            ProtocolIdentifier = [string]$inverter.protocolIdentifier
            EquipmentType = [int]$inverter.equipType
        }
    }
}
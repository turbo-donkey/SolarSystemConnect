function Get-SSCInverterPowerFlow {
    <#
        .SYNOPSIS
        Returns powerflow info.

        .DESCRIPTION
        The Get-SSCInverterPowerFlow cmdlet returns a inverters current powerflow information like current power loads,
        SoC and boolean values for powerflow direction i.e. GridImport / GridExport.
        
        .PARAMETER InverterId
        This cmdlet requires an inverter serial, call Get-SSCInverter to find.

        .EXAMPLE
        Get-SSCInverterPowerFlow -InverterSerial (Get-SSCInverter)[0].Serial

        Returns the current powerflow of the first inverter returned by Get-SSCInverter:

        Date             : 10-06-2024
        Time             : 07:43
        PVPower          : 715
        BatteryPower     : 105
        GridPower        : 17
        LoadPower        : 446
        GenPower         : 0
        SmartLoadPower   : 0
        UPSPower         : 0
        HomeLoadPower    : 0
        BatterySOC       : 43.0
        GridExists       : True
        GridImport       : True
        GridExport       : False
        BatteryCharge    : True
        BatteryDischarge : False
        BMSFault         : False
        GenExists        : False
        GenOn            : False
        GenLoad          : False
        LoadSupply       : True
        UPSSupply        : False
        ThinkPowerExists : False
        ThreeLoadExists  : False
        SmartLoadExists  : False

        .NOTES

        .LINK
        https://github.com/turbo-donkey/SolarSystemConnect
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, HelpMessage = 'Use Get-SSCInverter to find your inverter serial')]
        [ValidateScript({
            if ($_ -match '^\d{10}$') {
                $true
            } else {
                throw "Invalid format for InverterSerial. Expecting 10 digits (0-9)."
            }
        })]
        [string]$InverterSerial
    )
    $apiEndpoint = "/api/v1/inverter/$($InverterSerial)/flow"
    $method = 'Get'
    Write-Verbose "Using method $($method) for api endpoint $($apiEndpoint)"
    $response = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method
    [PSCustomObject]@{
        Date = (Get-Date).ToString("dd-MM-yyyy")
        Time = (Get-Date).ToString("HH:mm")
        PVStringCount = ($response.data.pv.power | Measure-Object -Sum).Count
        PVPower = ($response.data.pv.power | Measure-Object -Sum).Sum
        BatteryPower = $response.data.battPower
        GridPower = $response.data.gridOrMeterPower
        LoadPower = $response.data.loadOrEpsPower
        GenPower = $response.data.genPower
        SmartLoadPower = $response.data.smartLoadPower
        UPSPower = $response.data.upsLoadPower
        HomeLoadPower = $response.data.homeLoadPower
        BatterySOC = $response.data.soc
        GridExists = ConvertTo-Boolean $response.data.existsGrid
        GridImport = ConvertTo-Boolean $response.data.gridTo
        GridExport = ConvertTo-Boolean $response.data.toGrid
        BatteryCharge = ConvertTo-Boolean $response.data.toBat
        BatteryDischarge = ConvertTo-Boolean $response.data.batTo
        BMSFault = ConvertTo-Boolean $response.data.bmsCommFaultFlag
        GenExists = ConvertTo-Boolean $response.data.existsGen
        GenOn = ConvertTo-Boolean $response.data.genOn
        GenLoad = ConvertTo-Boolean $response.data.genTo
        LoadSupply = ConvertTo-Boolean $response.data.toLoad
        UPSSupply = ConvertTo-Boolean $response.data.toUpsLoad
        ThinkPowerExists = ConvertTo-Boolean $response.data.existThinkPower
        ThreeLoadExists = ConvertTo-Boolean $response.data.existsThreeLoad
        SmartLoadExists = ConvertTo-Boolean $response.data.existsSmartLoad
    }
}
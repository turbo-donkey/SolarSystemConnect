function Get-SSCPowerFlow {
    <#
        .SYNOPSIS
        Returns powerflow info.

        .DESCRIPTION
        The Get-SSCPowerFlow cmdlet returns a plants current powerflow information like current power loads,
        SoC and boolean values for powerflow direction i.e. GridImport / GridExport.
        
        .PARAMETER PlantId
        This cmdlet required a pland id, call Get-SSCPlant to find.

        .EXAMPLE
        Get-SSCPowerFlow -PlantId (Get-SSCPlant)[0].Id

        Returns the current powerflow of the first plant returned by Get-SSCPlant:

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
        [Parameter(Mandatory = $true, HelpMessage = "Specify the plant ID, find your plant ID with Get-SSCPlant")]
        [ValidateScript({
            if ($_ -match '^\d{6}$') {
                $true
            } else {
                throw "Invalid format for PlantId. Expecting 6 digits (0-9)."
            }
        })]
        [string]$PlantId
    )
    $apiEndpoint = "/api/v1/plant/energy/$($PlantId)/flow"
    $method = 'Get'
    Write-Verbose "Using method $($method) for api endpoint $($apiEndpoint)"
    $response = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method
    [PSCustomObject]@{
        Date = (Get-Date).ToString("dd-MM-yyyy")
        Time = (Get-Date).ToString("HH:mm")
        PVPower = $response.data.pvPower
        BatteryPower = $response.data.battPower
        GridPower = $response.data.gridOrMeterPower
        LoadPower = $response.data.loadOrEpsPower
        GenPower = $response.data.genPower
        SmartLoadPower = $response.data.smartLoadPower
        UPSPower = $response.data.upsLoadPower
        HomeLoadPower = $response.data.homeLoadPower
        BatterySOC = $response.data.soc
        GridExists = [bool]$response.data.existsGrid
        GridImport = [bool]$response.data.gridTo
        GridExport = [bool]$response.data.toGrid
        BatteryCharge = [bool]$response.data.toBat
        BatteryDischarge = [bool]$response.data.batTo
        BMSFault = [bool]$response.data.bmsCommFaultFlag
        GenExists = [bool]$response.data.existsGen
        GenOn = [bool]$response.data.genOn
        GenLoad = [bool]$response.data.genTo
        LoadSupply = [bool]$response.data.toLoad
        UPSSupply = [bool]$response.data.toUpsLoad
        ThinkPowerExists = [bool]$response.data.existThinkPower
        ThreeLoadExists = [bool]$response.data.existsThreeLoad
        SmartLoadExists = [bool]$response.data.existsSmartLoad
    }
}
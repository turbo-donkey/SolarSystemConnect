function Get-SSCPlantInfo {
    <#
        .SYNOPSIS
        Returns plant info.

        .DESCRIPTION
        The Get-SSCPlantInfo cmdlet returns a plants information like name, address, latitude and longitude,
        generation totals, installer details, plant permissions and valuation charges.

        .PARAMETER PlantId
        This cmdlet required a pland id, call Get-SSCPlant to find.

        .EXAMPLE
        $plantInfo = Get-SSCPlantInfo -PlantId (Get-SSCPlant)[0].Id
        Write-Output $plantInfo.Charges

        Returns the valuation purpose charges and times.

        .EXAMPLE
        Get-SSCPlantInfo -PlantId (Get-SSCPlant)[0].Id | Select CommissioningDate, Installer, Engineer, Contact, Email
        
        Returns the contact details of the installer for the first inverter returned by Get-SSCPlant:

        CommissioningDate : 11/04/2024 01:00:00
        Installer         : Solar Installers
        Engineer          : Bob Dobalina
        Contact           : 0112 112 1112
        Email             : installer@solarinstallers.ninja
        
        .NOTES

        .LINK
        https://github.com/turbo-donkey/SolarSystemConnect
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Specify the plant ID.")]
        [ValidateScript({
            if ($_ -match '^\d{6}$') {
                $true
            } else {
                throw "Invalid format for PlantId. Expecting 6 digits (0-9)."
            }
        })]
        [string]$PlantId
    )
    $apiEndpoint = "/api/v1/plant/$PlantId" + '?lan=en&id=' + "$PlantId"
    $method = 'Get'
    Write-Verbose "Using method $($method) for api endpoint $($apiEndpoint)"
    $response = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method
    [PSCustomObject]@{
        AccountId = [string]$response.data.id
        Name = [string]$response.data.name
        Address = [string]$response.data.address
        Latitude = [string]$response.data.lat
        Longitude = [string]$response.data.lon
        CapacitykWp = [string]$response.data.totalPower
        CommissioningDate = [DateTime]$response.data.joinDate
        Investment = [int]$response.data.invest
        GenerationCurrentlykW = [int]$response.data.realtime.pac
        GenerationTodaykWh = [int]$response.data.realtime.etoday
        GenerationMonthkWh = [int]$response.data.realtime.emonth
        GenerationYearkWh = [int]$response.data.realtime.eyear
        GenerationTotalkWh = [int]$response.data.realtime.etotal
        GenerationTotalsLastUpdated = [DateTime]$response.data.realtime.updateAt
        RevenueToday = [int]$response.data.realtime.income
        Currency = [PSCustomObject]@{
            Id = [string]$response.data.currency.id
            Code = [string]$response.data.currency.code
            Symbol = [string]$response.data.currency.text
        }
        Efficiency = [int]$response.data.realtime.efficiency
        Type = [int]$response.data.type
        Status = [int]$response.data.status
        TimeZone = [PSCustomObject]@{
            Id = $response.data.timezone.id
            Code = $response.data.timezone.code
            Description = $response.data.timezone.text
        }
        Charges = $response.data.charges
        Installer = [string]$response.data.installer
        Engineer = [string]$response.data.principal
        Contact = [string]$response.data.phone
        Email = [string]$response.data.email
        Master = [string]$response.data.master
        PlantPermissions = $response.data.plantPermission
        FluxProducts = $response.data.fluxProducts
    }
}
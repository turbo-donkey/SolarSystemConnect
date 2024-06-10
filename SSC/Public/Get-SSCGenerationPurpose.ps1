function Get-SSCGenerationPurpose {
    <#
        .SYNOPSIS
        Gets a breakdown of the days generation purpose.

        .DESCRIPTION
        The Get-SSCGenerationPurpose cmdlet returns a breakdown of a plants
        generation by total PV kWh, consumption kWh, export kWh & charging kWh

        .PARAMETER PlantId
        This cmdlet required a pland id, call Get-SSCPlant to find.

        .EXAMPLE
        Get-SSCGenerationPurpose -PlantId (Get-SSCPlant)[0].Id
        Returns the generation purpose for your first plant.

        .EXAMPLE
        Get-SSCGenerationPurpose -PlantId 123456
        Returns the generation purpose for the plant with Id 123456.

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
    $apiEndpoint = "/api/v1/plant/energy/$PlantId/generation/use"
    $method = 'Get'
    Write-Verbose "Using method $($method) for api endpoint $($apiEndpoint)"
    $response = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method
    [PSCustomObject]@{
        DateTime = [DateTime](Get-Date)
        PVGenerationkWh = [double]$response.data.pv
        ConsumptionkWh = [double]$response.data.load
        ExportkWh = [double]$response.data.gridSell
        ChargingkWh = [double]$response.data.batteryCharge
    }
}
function Get-SSCAbnormalStatistics {
    <#
        .SYNOPSIS
        Gets abnormal statistics

        .DESCRIPTION
        The Get-SSCAbnormalStatistics cmdlet gets warning/fault count for a plant.

        .PARAMETER PlantId
        This cmdlet required a pland id, call Get-SSCPlant to find.

        .EXAMPLE
        Get-SSCAbnormalStatistics -PlantId (Get-SSCPlant)[0].Id
        Returns warning/fault count for your first plant.

        .EXAMPLE
        Get-SSCAbnormalStatistics -PlantId 123456
        Returns warning/fault count the plant with Id 123456.

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
    $apiEndpoint = "/api/v1/plant/$PlantId/eventCount"
    $method = 'Get'
    Write-Verbose "Using method $($method) for api endpoint $($apiEndpoint)"
    $response = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method
    [PSCustomObject]@{
        Warning = [int]$response.data.warning
        Fault = [int]$response.data.fault
        LastUpdated = [DateTime]$response.data.updateAt
    }
}
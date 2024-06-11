function Get-SSCPlant {
    <#
        .SYNOPSIS
        Lists all plants.

        .DESCRIPTION
        The Get-SSCPlant cmdlet lists all plants visible to the logged in user.

        .EXAMPLE
        Get-SSCPlant | Where-Object {$_.PlantPermissions -eq 'gateway.upload.cycle'}
        Returns all plants where the logged in user has permission to edit the gateway upload cycle.

        .NOTES

        .LINK
        https://github.com/turbo-donkey/SolarSystemConnect
    #>
    [CmdletBinding()]
    $apiEndpoint = "/api/v1/plants?page=1&limit=10&name=&status="
    $method = 'Get'
    Write-Verbose "Using method $($method) for api endpoint $($apiEndpoint)"
    $response = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method
    foreach ($plant in $response.data.infos) {
        [PSCustomObject]@{
            Id = [int]$plant.Id
            Name = [string]$plant.Name
            Status = [int]$plant.status
            StatusDescription = switch ($plant.status) {
                0 { "Offline" }
                1 { "Normal" }
                2 { "Warning" }
                3 { "Fault" }
            }
            Address = [string]$plant.address
            GenerationCurrentkW = [int]$plant.pac /1000
            GenerationTodaykWh = [int]$plant.etoday
            GenerationTotalkWh = [int]$plant.etotal
            LastUpdate = [DateTime]$plant.updateAt
            Commissioned = [DateTime]$plant.createAt
            Type = [int]$plant.type
            MasterAccountId = [string]$plant.masterId
            Shared = ConvertTo-Boolean $plant.Shared
            HasCamera = ConvertTo-Boolean $plant.existCamera
            ContactEmail = [string]$plant.email
            ContactPhone = [string]$plant.phone
            PlantPermissions = $plant.plantPermission
        }
    }
}
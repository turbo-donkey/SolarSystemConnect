function Get-SSCWeatherInfo {
    <#
        .SYNOPSIS
        Returns weather info.

        .DESCRIPTION
        The Get-SSCWeatherInfo cmdlet returns a plants current weather information.

        .PARAMETER PlantId
        This cmdlet required a pland id, call Get-SSCPlant to find.

        .EXAMPLE
        Get-SSCWeatherInfo -PlantId (Get-SSCPlant)[0].Id

        Returns the current weather info for te first plant returned by Get-SSCPlant:

        DateTime      : 10/06/2024 07:58:58
        Descrpition   : Broken Clouds
        CurrentTempC  : 9
        MaxTempC      : 11
        MinTempC      : 7
        WindSpeed     : 2
        WindDirection : 310
        SunRise       : 10/06/2024 04:27:00
        SunSet        : 10/06/2024 21:56:00
        IconURL       : https://s3-eu-central-2.ionoscloud.com/sunsynk/weather/openweather/04d.png
        Latitude      : 55.935662370175
        Longitude     : -3.091086465865
        
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
    $latlon = Get-SSCPlantInfo -PlantId $PlantId | Select-Object Latitude, Longitude
    Write-Verbose "Using latitude: $(($latlon).Latitude), longitude: $(($latlon).Longitude)"
    $apiEndpoint = "/api/v1/weather?lan=en&date=$((Get-Date).toString("yyyy-MM-dd"))&lonLat=$(($latlon).Latitude),$(($latlon).Longitude)"
    $method = 'Get'
    Write-Verbose "Using method $($method) for api endpoint $($apiEndpoint)"
    $response = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method
    [PSCustomObject]@{
        DateTime = [datetime](Get-Date)
        Descrpition = [string](Get-Culture).TextInfo.ToTitleCase($response.data.currWea.desc)
        CurrentTempC = [int]$response.data.currWea.currTemp
        MaxTempC = [int]$response.data.currWea.tempMaxC
        MinTempC = [int]$response.data.currWea.tempMinC
        WindSpeed = [int]$response.data.currWea.windSpeed
        WindDirection = [int]$response.data.currWea.windDirection
        SunRise = [DateTime]$response.data.currWea.sunrise
        SunSet = [DateTime]$response.data.currWea.sunset
        IconURL = [string]$response.data.currWea.iconUrl
        Latitude = [string]$latlon.Latitude
        Longitude = [string]$latlon.Longitude
    }
}
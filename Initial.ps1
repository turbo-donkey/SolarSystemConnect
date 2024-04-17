<#
$latitude = "55.935594"
$longitude = "-3.091098"
$azimuth = "0"
$declination = "45"
$kwp = "6020"
$mutator = "1.58"
#>
function Get-SolarForecast {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Latitude of the location (e.g., 51.5)")]
        [double]$Latitude,
        
        [Parameter(Mandatory = $true, HelpMessage = "Longitude of the location (e.g., -0.1)")]
        [double]$Longitude,
        
        [Parameter(Mandatory = $true, HelpMessage = "Declination angle (e.g., 23.5 for northern hemisphere)")]
        [double]$Declination,
        
        [Parameter(Mandatory = $true, HelpMessage = "Azimuth angle (e.g., 180 for due south)")]
        [int]$Azimuth,
        
        [Parameter(Mandatory = $true, HelpMessage = "kW potential of the solar system")]
        [double]$kWp,

        [Parameter(Mandatory = $true, HelpMessage = "Mutator to compensate for better panels etc...")]
        [double]$Mutator
    )

    $baseUrl = "https://api.forecast.solar/estimate/watthours/day"
    $url = "$baseUrl/$latitude/$longitude/$declination/$azimuth/$kwp"
    $todayDateString = (Get-Date).ToString("yyyy-MM-dd")
    $tomorrowDateString = ((Get-Date).AddDays(1)).ToString("yyyy-MM-dd")

    try {
        $response = Invoke-RestMethod -Uri $url -Method Get
        
        if ($response.message.type -eq "success") {
            Write-Verbose "Solar forecast for Latitude: $latitude, Longitude: $longitude, Declination: $declination, Azimuth: $azimuth, kWp: $kwp"
            [PSCustomObject]@{
                RawPredictedkWhToday = [math]::Round(($response.result.$todayDateString / 1000000),2)
                AdjustedPredictedkWhToday = [math]::Round(($response.result.$todayDateString / 1000000),2) * $mutator
                RawPredictedkWhTomorrow = [math]::Round(($response.result.$tomorrowDateString / 1000000),2)
                AdjustedPredictedkWhTomorrow = [math]::Round(($response.result.$tomorrowDateString / 1000000),2) * $mutator
                Place = $response.message.info.place
                Latitude = $response.message.info.latitude
                Longitude = $response.message.info.longitude
                Timezone = $response.message.info.Timezone
            }
        } else {
            Write-Error "Failed to retrieve solar forecast. Error: $(($error[0].ErrorDetails.Message | ConvertFrom-Json).result)"
        }
    }
    catch {
        Write-Error "Failed to retrieve solar forecast. Error: $(($error[0].ErrorDetails.Message | ConvertFrom-Json).result)"
    }
}

function Get-SunriseSunset {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [DateTime]$Date,
        
        [Parameter(Mandatory = $true)]
        [double]$Latitude,
        
        [Parameter(Mandatory = $true)]
        [double]$Longitude
    )

    $url = "https://api.sunrise-sunset.org/json?lat=$latitude&lng=$longitude&date=$($date.ToString('yyyy-MM-dd'))&formatted=0"

    try {
        $response = Invoke-RestMethod -Uri $url -Method Get

        if ($response.status -eq "OK") {
            #$sunrise = [DateTime]$response.results.sunrise
            #$sunset = [DateTime]$response.results.sunset
            
            [PSCustomObject]@{
                Latitude = $Latitude
                Longitude = $Longitude
                Date = $Date.ToString("dd/MM/yyyy")
                Sunrise = [DateTime]$response.results.sunrise
                Sunset = [DateTime]$response.results.sunset
            }
        } else {
            Write-Error "Failed to retrieve sunrise and sunset times. Error: $($response.status)"
        }
    }
    catch {
        Write-Error "Error occurred while calling Sunrise-Sunset API: $_"
    }
}

function Get-SolarDeclination {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [DateTime]$Date
    )
    $dayOfYear = $date.DayOfYear
    $declination = 23.45 * [Math]::Sin((360 * ($dayOfYear + 284) / 365) * [Math]::PI / 180)
    return [math]::Round($declination,2)
}

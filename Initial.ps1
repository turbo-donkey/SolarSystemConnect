<#
AccountId is visible in the URL when you're logged into SunSynk Connect:
https://www.sunsynk.net/plants/overview/XXXXXX/2
                                        ^^^^^^
#>

# Define username and password here for static script
$UserName = "john@uk-cns.com"
$Password = "INSVxv5EJgIX4WDY"
$AccountId = "397094"
$Longitude = "55.935662370175"
$Latitude = "-3.091086465865"

<#
# Or allow incoming params instead
param (
    [string]$UserName = $args[0],
    [string]$Passwword = $args[1],
    [string]$AccountId = $args[2]
)

if (-not $UserName -or -not $Password -or -not $AccountId) {
    Write-Warning 'Missing or empty required parameter(s). Please provide all parameters:
    Get-BearerToken -UserName "joe@bloggs.com" -Password "StronKPass1234" -AccountId "1234567"
    '
    exit 1  # Optionally exit the script with a non-zero exit code indicating failure
}
#>

# Function to request a bearer token for api access
function Get-SSCBearerToken {
    $loginurl = 'https://api.sunsynk.net/oauth/token'
    $headers = @{
        'Content-type' = 'application/json'
        'Accept' = 'application/json'
    }

    $payload = @{
        "username" = $UserName
        "password" = $Password
        "areaCode" = "sunsynk"
        "client_id" = "csp-web"
        "grant_type" = "password"
        "source" = "sunsynk"
    }

    $response = Invoke-RestMethod -Uri $loginurl -Method Post -Headers $headers -Body ($payload | ConvertTo-Json)
    $access_token = $response.data.access_token
    return "Bearer $access_token"
}

# Function to get plant id and current generation in Watts
function Get-SSCPowerFlow {
    param (
        [string]$BearerToken,
        [string]$AccountId
    )

    $api_endpoint_powerflow = "https://api.sunsynk.net/api/v1/plant/energy/$($AccountId)/flow?date=$((Get-Date).ToString("yyyy-MM-dd"))"

    $headers = @{
        'Content-type' = 'application/json'
        'Accept' = 'application/json'
        'Accept-Language' = 'en-US,en;q=0.5'
        'Accept-Encoding' = 'gzip, deflate, br'
        'Authorization' = $BearerToken
    }

    try {
        $response = Invoke-RestMethod -Uri $api_endpoint_powerflow -Method Get -Headers $headers
        [PSCustomObject]@{
            CurrentGeneration = $response.data.pvPower
            CurrentBatteryPower = $response.data.battPower
            CurrentGridPower = $response.data.gridOrMeterPower
            CurrentHouseLoad = $response.data.loadOrEpsPower
            BatteryChargeLevel = $response.data.soc
            GridImport = [bool]$response.data.gridTo
            GridExport = [bool]$response.data.toGrid
            BatteryCharge = [bool]$response.data.toBat
            BatteryDischarge = [bool]$response.data.batTo
        }
    }
    catch {
        if ($error[0].ErrorDetails.Message -match '"code":401') {
            Write-Warning "Failed to retrieve plant data (401) - try renewing the bearer token."
        } else {
            Write-Warning "Failed to retrieve plant data. Error: $_"
        }
    }

}

function Get-SSCGenerationPurpose {
    param (
        [string]$BearerToken,
        [string]$AccountId
    )

    $api_endpoint_generation_purpose = "https://api.sunsynk.net/api/v1/plant/energy/$AccountId/generation/use"

    $headers = @{
        'Content-type' = 'application/json'
        'Accept' = 'application/json'
        'Accept-Language' = 'en-US,en;q=0.5'
        'Accept-Encoding' = 'gzip, deflate, br'
        'Authorization' = $BearerToken
    }
    try {
        $response = Invoke-RestMethod -Uri $api_endpoint_generation_purpose -Method Get -Headers $headers
        [PSCustomObject]@{
            PVGenerationkWh = $response.data.pv
            ConsumptionkWh = $response.data.load
            ExportkWh = $response.data.gridSell
            ChargingkWh = $response.data.batteryCharge
        }
    }
    catch {
        if ($error[0].ErrorDetails.Message -match '"code":401') {
            Write-Warning "Failed to retrieve plant data (401) - try renewing the bearer token."
        } else {
            Write-Warning "Failed to retrieve plant data. Error: $_"
        }
    }
}

function Get-SSCAbnormalStatistics {
    param (
        [string]$BearerToken,
        [string]$AccountId
    )

    $api_endpoint_event_count = "https://api.sunsynk.net/api/v1/plant/$AccountId/eventCount"
    $headers = @{
        'Content-type' = 'application/json'
        'Accept' = 'application/json'
        'Accept-Language' = 'en-US,en;q=0.5'
        'Accept-Encoding' = 'gzip, deflate, br'
        'Authorization' = $BearerToken
    }
    try {
        $response = Invoke-RestMethod -Uri $api_endpoint_event_count -Method Get -Headers $headers
        [PSCustomObject]@{
            Warning = [int]$response.data.warning
            Fault = [int]$response.data.fault
            LastUpdated = [DateTime]$response.data.updateAt
        }
    }
    catch {
        if ($error[0].ErrorDetails.Message -match '"code":401') {
            Write-Warning "Failed to retrieve plant data (401) - try renewing the bearer token."
        } else {
            Write-Warning "Failed to retrieve plant data. Error: $_"
        }
    }
}

function Get-SSCWeatherInfo {
    param (
        [string]$BearerToken,
        [string]$AccountId,
        [string]$Longitude,
        [string]$Latitude
    )

    $api_endpoint_current_weather = "https://api.sunsynk.net/api/v1/weather?lan=en&date=2024-05-03&lonLat=$Longitude,$Latitude"
    $headers = @{
        'Content-type' = 'application/json'
        'Accept' = 'application/json'
        'Accept-Language' = 'en-US,en;q=0.5'
        'Accept-Encoding' = 'gzip, deflate, br'
        'Authorization' = $BearerToken
    }
    try {
        $response = Invoke-RestMethod -Uri $api_endpoint_current_weather -Method Get -Headers $headers
        [PSCustomObject]@{
            Descrpition = [string](Get-Culture).TextInfo.ToTitleCase($response.data.currWea.desc)
            CurrentTempC = [int]$response.data.currWea.currTemp
            MaxTempC = [int]$response.data.currWea.tempMaxC
            MinTempC = [int]$response.data.currWea.tempMinC
            WindSpeed = [int]$response.data.currWea.windSpeed
            WindDirection = [int]$response.data.currWea.windDirection
            SunRise = [DateTime]$response.data.currWea.sunrise
            SunSet = [DateTime]$response.data.currWea.sunset
            IconURL = [string]$response.data.currWea.iconUrl  
        }
    }
    catch {
        if ($error[0].ErrorDetails.Message -match '"code":401') {
            Write-Warning "Failed to retrieve plant data (401) - try renewing the bearer token."
        } else {
            Write-Warning "Failed to retrieve plant data. Error: $_"
        }
    }
}

function Get-SSCPlantInfo {
    
    param (
        [string]$BearerToken,
        [string]$AccountId
    )

    $api_endpoint_plant_info = "https://api.sunsynk.net/api/v1/plant/$AccountId" + '?lan=en&id=' + "$AccountId"
    $headers = @{
        'Content-type' = 'application/json'
        'Accept' = 'application/json'
        'Accept-Language' = 'en-US,en;q=0.5'
        'Accept-Encoding' = 'gzip, deflate, br'
        'Authorization' = $BearerToken
    }
    try {
        $response = Invoke-RestMethod -Uri $api_endpoint_plant_info -Method Get -Headers $headers
        [PSCustomObject]@{
            AccountId = [string]$response.data.id
            Name = [string]$response.data.name
            Address = [string]$response.data.address
            Latitude = [int]$response.data.lat
            Longitude = [int]$response.data.lon
            CapacitykWp = [string]$response.data.totalPower
            CommissioningDate = [DateTime]$response.data.joinDate
            Installer = [string]$response.data.installer
            Engineer = [string]$response.data.principal
            Contact = [string]$response.data.phone
            Email = [string]$response.data.email
            Master = [string]$response.data.master


        }
    }
    catch {
        if ($error[0].ErrorDetails.Message -match '"code":401') {
            Write-Warning "Failed to retrieve plant data (401) - try renewing the bearer token."
        } else {
            Write-Warning "Failed to retrieve plant data. Error: $_"
        }
    }

}


function Get-SSCInverterSystemMode {
    param (
        [string]$BearerToken,
        [string]$InverterSerial
    )

    $api_endpoint_inverter_settings_read = "https://api.sunsynk.net/api/v1/common/setting/$InverterSerial/read"

    $headers = @{
        'Content-type' = 'application/json'
        'Accept' = 'application/json'
        'Accept-Language' = 'en-US,en;q=0.5'
        'Accept-Encoding' = 'gzip, deflate, br'
        'Authorization' = $BearerToken
    }

    try {
        $dirtyresponse = Invoke-RestMethod -Uri $api_endpoint_inverter_settings_read -Method Get -Headers $headers
        $response = $dirtyresponse  -replace '("time1On":)', '"time2OnNumericBool":' `
                                    -replace '("time2On":)', '"time2OnNumericBool":' `
                                    -replace '("time3On":)', '"time3OnNumericBool":' `
                                    -replace '("time4On":)', '"time4OnNumericBool":' `
                                    -replace '("time5On":)', '"time5OnNumericBool":' `
                                    -replace '("time6On":)', '"time6OnNumericBool":'
        $response = $response | ConvertFrom-Json

        [PSCustomObject]@{
            WeekDays = @{
                MondayEnabled = [bool]$response.data.mondayOn
                TuesdayEnabled = [bool]$response.data.tuesdayOn
                WednesdayEnabled = [bool]$response.data.wednesdayOn
                ThursdayEnabled = [bool]$response.data.thursdayOn
                FridayEnabled = [bool]$response.data.fridayOn
                SaturdayEnabled = [bool]$response.data.saturdayOn
                SundayEnabled = [bool]$response.data.sundayOn
            }
            SellTimes = @{
                1 = @{
                    Time = $response.data.sellTime1
                    Enabled = [bool]$response.data.time1on
                    Voltage = $response.data.sellTime1Volt
                    Power = $response.data.sellTime1Pac
                }
                2 = @{
                    Time = $response.data.sellTime2
                    Enabled = [bool]$response.data.time2on
                    Voltage = $response.data.sellTime2Volt
                    Power = $response.data.sellTime2Pac
                }
                3 = @{
                    Time = $response.data.sellTime3
                    Enabled = [bool]$response.data.time3on
                    Voltage = $response.data.sellTime3Volt
                    Power = $response.data.sellTime3Pac
                }
                4 = @{
                    Time = $response.data.sellTime4
                    Enabled = [bool]$response.data.time4on
                    Voltage = $response.data.sellTime4Volt
                    Power = $response.data.sellTime4Pac
                }
                5 = @{
                    Time = $response.data.sellTime5
                    Enabled = [bool]$response.data.time5on
                    Voltage = $response.data.sellTime5Volt
                    Power = $response.data.sellTime5Pac
                }
                6 = @{
                    Time = $response.data.sellTime6
                    Enabled = [bool]$response.data.time6on
                    Voltage = $response.data.sellTime6Volt
                    Power = $response.data.sellTime6Pac
                }

            }
            WorkMode = $response.data.sysWorkMode
            WorkModeDescription = switch ($response.data.sysWorkMode) {
                0 { "Sell First" }
                1 { "Zero Export, Limit to Load Only" }
                2 { "Limited to Home" }
            }
            SolarExport = [bool]$response.data.solarSell
            MaxSellPower = $response.data.pvMaxLimit
            EnergyPriority = $response.data.energyMode
            EnergyPriorityDescription = switch ($response.data.energyMode) {
                0 { "Battery" }
                1 { "Load" }
            }
        }
    }
    catch {
        if ($error[0].ErrorDetails.Message -match '"code":401') {
            Write-Warning "Failed to retrieve plant data (401) - try renewing the bearer token."
        } else {
            Write-Warning "Failed to retrieve plant data. Error: $_"
        }
    }
}

function Set-SSCInverterSystemMode {
    param(
        [string]$InverterSerial,
        [string]$BearerToken,
        [bool]$SolarExport,
        [int]$EnergyPriority,
        [int]$WorkMode,
        [string]$SellTime1,
        [string]$SellTime2,
        [string]$SellTime3,
        [string]$SellTime4,
        [string]$SellTime5,
        [string]$SellTime6,
        [string]$SellTime1Power,
        [string]$SellTime2Power,
        [string]$SellTime3Power,
        [string]$SellTime4Power,
        [string]$SellTime5Power,
        [string]$SellTime6Power,
        [string]$SellTime1StateOfCharge,
        [string]$SellTime2StateOfCharge,
        [string]$SellTime3StateOfCharge,
        [string]$SellTime4StateOfCharge,
        [string]$SellTime5StateOfCharge,
        [string]$SellTime6StateOfCharge,
        [bool]$SellTime1Enabled,
        [bool]$SellTime2Enabled,
        [bool]$SellTime3Enabled,
        [bool]$SellTime4Enabled,
        [bool]$SellTime5Enabled,
        [bool]$SellTime6Enabled
    )

    # Define the API endpoint URL
    $api_endpoint_inverter_settings_set = "https://api.sunsynk.net/api/v1/common/setting/$InverterSerial/set"

    # Get the current settings
    $currentSettings = Get-SSCInverterSystemMode -BearerToken $bearerToken -InverterSerial $InverterSerial

    # Define the headers including the Bearer token
    $headers = @{
        'Content-type' = 'application/json'
        'Accept' = 'application/json'
        'Accept-Language' = 'en-US,en;q=0.5'
        'Accept-Encoding' = 'gzip, deflate, br'
        'Authorization' = $BearerToken
    }

    function ConvertTo-NumericBoolean($bool) {
        if ($bool) {
            return "1"
        } else {
            return "0"
        }
    }

    # Define the JSON body data
    $body = $null
    $body = @{
        "sn" = $InverterSerial
    }

    # Add items to the body only if the corresponding parameter has been set
    if ($null -ne $SolarExport) {$body["solarSell"] = ConvertTo-NumericBoolean $SolarExport}
    if ($null -ne $EnergyPriority) {$body["energyMode"] = $EnergyPriority}
    if ($null -ne $WorkMode) {$body["sysWorkMode"] = $WorkMode}
    if ($null -ne $SellTime1) {$body["sellTime1"] = $SellTime1}
    if ($null -ne $SellTime2) {$body["sellTime2"] = $SellTime2}
    if ($null -ne $SellTime3) {$body["sellTime3"] = $SellTime3}
    if ($null -ne $SellTime4) {$body["sellTime4"] = $SellTime4}
    if ($null -ne $SellTime5) {$body["sellTime5"] = $SellTime5}
    if ($null -ne $SellTime6) {$body["sellTime6"] = $SellTime6}
    if ($null -ne $SellTime1Power) {$body["sellTime1Pac"] = $SellTime1Power}
    if ($null -ne $SellTime2Power) {$body["sellTime2Pac"] = $SellTime2Power}
    if ($null -ne $SellTime3Power) {$body["sellTime3Pac"] = $SellTime3Power}
    if ($null -ne $SellTime4Power) {$body["sellTime4Pac"] = $SellTime4Power}
    if ($null -ne $SellTime5Power) {$body["sellTime5Pac"] = $SellTime5Power}
    if ($null -ne $SellTime6Power) {$body["sellTime6Pac"] = $SellTime6Power}
    if ($null -ne $SellTime1StateOfCharge) {$body["cap1"] = $SellTime1StateOfCharge}
    if ($null -ne $SellTime2StateOfCharge) {$body["cap2"] = $SellTime2StateOfCharge}
    if ($null -ne $SellTime3StateOfCharge) {$body["cap3"] = $SellTime3StateOfCharge}
    if ($null -ne $SellTime4StateOfCharge) {$body["cap4"] = $SellTime4StateOfCharge}
    if ($null -ne $SellTime5StateOfCharge) {$body["cap5"] = $SellTime5StateOfCharge}
    if ($null -ne $SellTime6StateOfCharge) {$body["cap6"] = $SellTime6StateOfCharge}
    if ($null -ne $SellTime1Enabled) {$body["time1on"] = $SellTime1Enabled.ToString().ToLower()} else {$body["time1on"] = ($currentSettings.SellTimes.1).Enabled}
    if ($null -ne $SellTime2Enabled) {$body["time2on"] = $SellTime2Enabled.ToString().ToLower()} else {$body["time2on"] = ($currentSettings.SellTimes.2).Enabled}
    if ($null -ne $SellTime3Enabled) {$body["time3on"] = $SellTime3Enabled.ToString().ToLower()} else {$body["time3on"] = ($currentSettings.SellTimes.3).Enabled}
    if ($null -ne $SellTime4Enabled) {$body["time4on"] = $SellTime4Enabled.ToString().ToLower()} else {$body["time4on"] = ($currentSettings.SellTimes.4).Enabled}
    if ($null -ne $SellTime5Enabled) {$body["time5on"] = $SellTime5Enabled.ToString().ToLower()} else {$body["time5on"] = ($currentSettings.SellTimes.5).Enabled}
    if ($null -ne $SellTime6Enabled) {$body["time6on"] = $SellTime6Enabled.ToString().ToLower()} else {$body["time6on"] = ($currentSettings.SellTimes.6).Enabled}
    $body["genTime1on"] = $false
    $body["genTime2on"] = $false
    $body["genTime3on"] = $false
    $body["genTime4on"] = $false
    $body["genTime5on"] = $false
    $body["genTime6on"] = $false

    $body = $body | ConvertTo-Json

    try {
        # Make the POST request using Invoke-RestMethod
        $response = Invoke-RestMethod -Uri $api_endpoint_inverter_settings_set -Method Post -Headers $headers -Body $body

        # Output the response (if needed)
        $response
    } catch {
        Write-Error "Error occurred while making the API request: $_"
    }
}

function Send-TelegramMessage {
    param (
        [string]$MessageText
    )
    if (-not $MessageText) {
        Write-Warning 'Missing or empty required parameter(s). Please provide message text:
        Send-TelegramMessage -MessageText "Test Message!"
        '
        exit 1  # Optionally exit the script with a non-zero exit code indicating failure
    }
    #[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $botToken = '6519272425:AAF-OHk0m28QOr_oiqxEICu8a-ajw6bTOyg'
    $chatID = "6764802462" 
    $url = "https://api.telegram.org/bot$botToken/sendMessage?chat_id=$chatID&text=$messageText"

    Invoke-RestMethod -Uri $url -Method Post 
}

# Execute functions to get token and show current generation data
$bearerToken = Get-SSCBearerToken
$currentUsage = Get-SSCPowerFlow -BearerToken $bearerToken

#if ($currentUsage.BatteryChargeLevel -eq "100.0" -and $currentUsage.GridExport -eq $true) {Send-TelegramMessage -MessageText "Solar battery is fully charged! $emojie `n`nCurrent Generation: $($currentUsage.CurrentGeneration)W`nCurrent Export: $($currentUsage.CurrentGridPower)W`nCurrent Load: $($currentUsage.CurrentHouseLoad)W"}
clear
do {
    $powerflow  = Get-SSCPowerFlow -BearerToken $bearerToken
    Write-Host "Charge %: $($powerflow.BatteryChargeLevel)`n`nCurrent Generation: $($powerflow.CurrentGeneration)W`nCurrent Export: $($powerflow.CurrentGridPower)W`nCurrent Load: $($powerflow.CurrentHouseLoad)W`nExporting: $($powerflow.GridExport)"
    Start-Sleep -Seconds 60
    clear
}
until ($powerflow.BatteryChargeLevel -eq "100.0") {
    } ; Send-TelegramMessage -MessageText "Solar battery is fully charged!`n`nCurrent Generation: $($powerflow.CurrentGeneration)W`nCurrent Export: $($powerflow.CurrentGridPower)W`nCurrent Load: $($powerflow.CurrentHouseLoad)W`nExporting: $($powerflow.GridExport)"

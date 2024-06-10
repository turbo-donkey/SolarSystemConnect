function Get-SSCInverterSystemMode {
        <#
        .SYNOPSIS
        Returns the system mode settings

        .DESCRIPTION
        The Get-SSCInverterSystemMode cmdlet returns all system mode settings for an inverter.

        .PARAMETER InverterSerial
        This cmdlet requires an inverter serial, call Get-SSCInverter to find.

        .EXAMPLE
        Get-SSCInverterSystemMode -InverterSerial (Get-SSCInverter)[0].Serial
        Returns the system mode settings for your first inverter.

        .EXAMPLE
        $SystemMode = Get-SSCInverterSystemMode -InverterSerial 1234567890
        Write-Output $SystemMode.SellTimes.1

        Name                           Value
        ----                           -----
        Voltage                        58
        Time                           02:00
        Power                          3600
        Enabled                        False
        
        Returns the system mode configuration for Time 1 from your inverter with serial 1234567890.

        .NOTES

        .LINK
        https://github.com/turbo-donkey/SolarSystemConnect
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = 'Use Get-SSCEquipmentInverters to find your inverter serial')]
        [ValidateScript({
            if ($_ -match '^\d{10}$') {
                $true
            } else {
                throw "Invalid format for InverterSerial. Expecting 10 digits (0-9)."
            }
        })]
        [string]$InverterSerial
    )
    $apiEndpoint = "/api/v1/common/setting/$InverterSerial/read"
    $method = 'Get'
    Write-Verbose "Using method $($method) for api endpoint $($apiEndpoint)"
    $dirtyresponse = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method
    $response = $dirtyresponse -creplace '("time1On":)', '"time2OnNumericBool":' `
    -creplace '("time2On":)', '"time2OnNumericBool":' `
    -creplace '("time3On":)', '"time3OnNumericBool":' `
    -creplace '("time4On":)', '"time4OnNumericBool":' `
    -creplace '("time5On":)', '"time5OnNumericBool":' `
    -creplace '("time6On":)', '"time6OnNumericBool":'
    $response = $response | ConvertFrom-Json
    [PSCustomObject]@{
        WeekDays = @{
            MondayEnabled = ConvertTo-Boolean $response.data.mondayOn
            TuesdayEnabled = ConvertTo-Boolean $response.data.tuesdayOn
            WednesdayEnabled = ConvertTo-Boolean $response.data.wednesdayOn
            ThursdayEnabled = ConvertTo-Boolean $response.data.thursdayOn
            FridayEnabled = ConvertTo-Boolean $response.data.fridayOn
            SaturdayEnabled = ConvertTo-Boolean $response.data.saturdayOn
            SundayEnabled = ConvertTo-Boolean $response.data.sundayOn
        }
        Times = [PSCustomObject]@{
            Time1 = [PSCustomObject]@{
                Time = $response.data.sellTime1
                GridChargeEnabled = ConvertTo-Boolean $response.data.time1on
                GeneratorChargeEnabled = ConvertTo-Boolean $response.data.genTime1on
                Voltage = $response.data.sellTime1Volt
                StateOfCharge = $response.data.cap1
                Power = $response.data.sellTime1Pac
            }
            Time2 = [PSCustomObject]@{
                Time = $response.data.sellTime2
                GridChargeEnabled = ConvertTo-Boolean $response.data.time2on
                GeneratorChargeEnabled = ConvertTo-Boolean $response.data.genTime2on
                Voltage = $response.data.sellTime2Volt
                StateOfCharge = $response.data.cap2
                Power = $response.data.sellTime2Pac
            }
            Time3 = [PSCustomObject]@{
                Time = $response.data.sellTime3
                GridChargeEnabled = ConvertTo-Boolean $response.data.time3on
                GeneratorChargeEnabled = ConvertTo-Boolean $response.data.genTime3on
                Voltage = $response.data.sellTime3Volt
                StateOfCharge = $response.data.cap3
                Power = $response.data.sellTime3Pac
            }
            Time4 = [PSCustomObject]@{
                Time = $response.data.sellTime4
                GridChargeEnabled = ConvertTo-Boolean $response.data.time4on
                GeneratorChargeEnabled = ConvertTo-Boolean $response.data.genTime4on
                Voltage = $response.data.sellTime4Volt
                StateOfCharge = $response.data.cap4
                Power = $response.data.sellTime4Pac
            }
            Time5 = [PSCustomObject]@{
                Time = $response.data.sellTime5
                GridChargeEnabled = ConvertTo-Boolean $response.data.time5on
                GeneratorChargeEnabled = ConvertTo-Boolean $response.data.genTime5on
                Voltage = $response.data.sellTime5Volt
                StateOfCharge = $response.data.cap5
                Power = $response.data.sellTime5Pac
            }
            Time6 = [PSCustomObject]@{
                Time = $response.data.sellTime6
                GridChargeEnabled = ConvertTo-Boolean $response.data.time6on
                GeneratorChargeEnabled = ConvertTo-Boolean $response.data.genTime6on
                Voltage = $response.data.sellTime6Volt
                StateOfCharge = $response.data.cap6
                Power = $response.data.sellTime6Pac
            }

        }
        WorkMode = $response.data.sysWorkMode
        WorkModeDescription = switch ($response.data.sysWorkMode) {
            0 { "Sell First" }
            1 { "Zero Export & Limit to Load Only" }
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
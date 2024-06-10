function Set-SSCInverterSystemMode {
    <#
        .SYNOPSIS
        Changes system mode settings on an inverter.

        .DESCRIPTION
        The Set-SSCInverterSystemMode changes system mode settings on an inverter.

        .PARAMETER InverterSerial
        This cmdlet requires an inverter serial number, call Get-SSCInverter to find.

        .PARAMETER SolarExport
        Toggles "Solar Export" on and off.  A boolean value $true / $false is expected.

        .PARAMETER EnergyPriority
        Sets "Energy Pattern" to "Priority Battery" / "Priority Load".
        Values of 0, 1, Battery & Load are supported.

        .PARAMETER WorkMode
        Sets "Work Mode" to "Selling First", "Zero Export + Limit to Load Only" and "Limited to Home".
        Values of 0, 1, 2, SellingFirst, ZeroExport, LimitedToHome are supported.

        .PARAMETER Time1
        Sets "Time 1", SunSynk Connect expects "hh:mm" in 30 min intervals so "14:30" or "14:00" would be valid.

        .PARAMETER Time1Power
        Sets "Power" for time 1, expects a value of "0" - "3600", anything else use SunSynk Connect.

        .PARAMETER Time1StateOfCharge
        Sets "Battery SOC1" for time 1, expects a value of "0" - "100"

        .PARAMETER GridCharge1Enabled
        Toggles the "Grid Charge" time to enabled / disabled.  A boolean value $true / $false is expected.

        .EXAMPLE
        Set-SSCInverterSystemMode -InverterSerial (Get-SSCInverter)[0].Serial -Time1 02:00 -Time1Power 3600 
        -Time1StateOfCharge 100 -GridCharge1Enabled $true

        Sets "Time 1" to 02:00, "Power1" to 3600 "Battery SOC1" to 100 and toggles "Grid Charge Time 1" to on.

        .NOTES
        Gen charge enable controls not implimented.

        .LINK
        https://github.com/turbo-donkey/SolarSystemConnect
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = 'Use Get-SSCEquipmentInverters to find your inverter serial')]
        [ValidateScript({
            if ($_ -match '^\d{10}$') {
                $true
            } else {
                throw "Invalid format for InverterSerial. Expecting 10 digits (0-9)."
            }
        })]
        [string]$InverterSerial,
        [bool]$SolarExport,
        [Parameter(Mandatory = $false)]
        [ValidateSet("Load", "Battery", "0", "1")]
        [string]$EnergyPriority,
        [Parameter(Mandatory = $false)]
        [ValidateSet("0", "1", "2", "SellingFirst", "ZeroExport", "LimitedToHome")]
        [string]$WorkMode,
        [Parameter(Mandatory = $false)]
        [ValidateScript({ Test-SSCInverterSystemModeTimeFormat $_ })]
        [string]$Time1,
        [Parameter(Mandatory = $false)]
        [ValidateScript({ Test-SSCInverterSystemModeTimeFormat $_ })]
        [string]$Time2,
        [Parameter(Mandatory = $false)]
        [ValidateScript({ Test-SSCInverterSystemModeTimeFormat $_ })]
        [string]$Time3,
        [Parameter(Mandatory = $false)]
        [ValidateScript({ Test-SSCInverterSystemModeTimeFormat $_ })]
        [string]$Time4,
        [Parameter(Mandatory = $false)]
        [ValidateScript({ Test-SSCInverterSystemModeTimeFormat $_ })]
        [string]$Time5,
        [Parameter(Mandatory = $false)]
        [ValidateScript({ Test-SSCInverterSystemModeTimeFormat $_ })]
        [string]$Time6,
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 3600)]
        [int]$Time1Power,
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 3600)]
        [int]$Time2Power,
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 3600)]
        [int]$Time3Power,
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 3600)]
        [int]$Time4Power,
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 3600)]
        [int]$Time5Power,
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 3600)]
        [int]$Time6Power,
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 100)]
        [int]$Time1StateOfCharge,
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 100)]
        [int]$Time2StateOfCharge,
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 100)]
        [int]$Time3StateOfCharge,
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 100)]
        [int]$Time4StateOfCharge,
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 100)]
        [int]$Time5StateOfCharge,
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 100)]
        [int]$Time6StateOfCharge,
        [bool]$GridCharge1Enabled,
        [bool]$GridCharge2Enabled,
        [bool]$GridCharge3Enabled,
        [bool]$GridCharge4Enabled,
        [bool]$GridCharge5Enabled,
        [bool]$GridCharge6Enabled
    )
    if ($EnergyPriority) {
        $EnergyPriorityValue = switch ($EnergyPriority) {
            "Load"    { 1 }
            "Battery" { 0 }
            "0"       { 0 }
            "1"       { 1 }
        }
    }
    if ($WorkMode) {
        $WorkModeValue = switch ($WorkMode) {
            "SellingFirst"  { 0 }
            "ZeroExport"    { 1 }
            "LimitedToHome" { 2 }
            "0"             { 0 }
            "1"             { 1 }
            "2"             { 2 }
        }
    }

    $apiEndpoint = "/api/v1/common/setting/$InverterSerial/set"
    $method = 'Post'
    $contentType = 'application/json;charset=UTF-8'
    $currentSettings = Get-SSCInverterSystemMode -InverterSerial $InverterSerial
    [int]$changes = '0'
    $body = $null
    $body = @{
        "sn" = $InverterSerial
    }

    # Add items to the body only if the corresponding parameter has been set otherwise fill with current setting
    if ($SolarExport) {$body["solarSell"] = ConvertTo-NumericBoolean $SolarExport; $changes++} else {$body["solarSell"] = ConvertTo-NumericBoolean ($currentSettings).SolarExport}
    if ($EnergyPriority) {$body["energyMode"] = $EnergyPriorityValue; $changes++} else {$body["energyMode"] = ($currentSettings).EnergyPriority}
    if ($WorkMode) {$body["sysWorkMode"] = $WorkModeValue; $changes++} else {$body["sysWorkMode"] = ($currentSettings).WorkMode}
    if ($Time1) {$body["sellTime1"] = $Time1; $changes++} else {$body["sellTime1"] = $currentSettings.Times.Time1.Time}
    if ($Time2) {$body["sellTime2"] = $Time2; $changes++} else {$body["sellTime2"] = $currentSettings.Times.Time2.Time}
    if ($Time3) {$body["sellTime3"] = $Time3; $changes++} else {$body["sellTime3"] = $currentSettings.Times.Time3.Time}
    if ($Time4) {$body["sellTime4"] = $Time4; $changes++} else {$body["sellTime4"] = $currentSettings.Times.Time4.Time}
    if ($Time5) {$body["sellTime5"] = $Time5; $changes++} else {$body["sellTime5"] = $currentSettings.Times.Time5.Time}
    if ($Time6) {$body["sellTime6"] = $Time6; $changes++} else {$body["sellTime6"] = $currentSettings.Times.Time6.Time}
    if ($Time1Power) {$body["sellTime1Pac"] = $Time1Power; $changes++} else {$body["sellTime1Pac"] = $currentSettings.Times.Time1.Power}
    if ($Time2Power) {$body["sellTime2Pac"] = $Time2Power; $changes++} else {$body["sellTime2Pac"] = $currentSettings.Times.Time2.Power}
    if ($Time3Power) {$body["sellTime3Pac"] = $Time3Power; $changes++} else {$body["sellTime3Pac"] = $currentSettings.Times.Time3.Power}
    if ($Time4Power) {$body["sellTime4Pac"] = $Time4Power; $changes++} else {$body["sellTime4Pac"] = $currentSettings.Times.Time4.Power}
    if ($Time5Power) {$body["sellTime5Pac"] = $Time5Power; $changes++} else {$body["sellTime5Pac"] = $currentSettings.Times.Time5.Power}
    if ($Time6Power) {$body["sellTime6Pac"] = $Time6Power; $changes++} else {$body["sellTime6Pac"] = $currentSettings.Times.Time6.Power}
    if ($Time1StateOfCharge) {$body["cap1"] = $Time1StateOfCharge; $changes++} else {$body["cap1"] = $currentSettings.Times.Time1.StateOfCharge}
    if ($Time2StateOfCharge) {$body["cap2"] = $Time2StateOfCharge; $changes++} else {$body["cap2"] = $currentSettings.Times.Time2.StateOfCharge}
    if ($Time3StateOfCharge) {$body["cap3"] = $Time3StateOfCharge; $changes++} else {$body["cap3"] = $currentSettings.Times.Time3.StateOfCharge}
    if ($Time4StateOfCharge) {$body["cap4"] = $Time4StateOfCharge; $changes++} else {$body["cap4"] = $currentSettings.Times.Time4.StateOfCharge}
    if ($Time5StateOfCharge) {$body["cap5"] = $Time5StateOfCharge; $changes++} else {$body["cap5"] = $currentSettings.Times.Time5.StateOfCharge}
    if ($Time6StateOfCharge) {$body["cap6"] = $Time6StateOfCharge; $changes++} else {$body["cap6"] = $currentSettings.Times.Time6.StateOfCharge}
    if ($GridCharge1Enabled) {$body["time1on"] = $GridCharge1Enabled.ToString().ToLower(); $changes++} else {$body["time1on"] = ($currentSettings.Times.Time1.GridChargeEnabled).ToString().ToLower()}
    if ($GridCharge2Enabled) {$body["time2on"] = $GridCharge2Enabled.ToString().ToLower(); $changes++} else {$body["time2on"] = ($currentSettings.Times.Time2.GridChargeEnabled).ToString().ToLower()}
    if ($GridCharge3Enabled) {$body["time3on"] = $GridCharge3Enabled.ToString().ToLower(); $changes++} else {$body["time3on"] = ($currentSettings.Times.Time3.GridChargeEnabled).ToString().ToLower()}
    if ($GridCharge4Enabled) {$body["time4on"] = $GridCharge4Enabled.ToString().ToLower(); $changes++} else {$body["time4on"] = ($currentSettings.Times.Time4.GridChargeEnabled).ToString().ToLower()}
    if ($GridCharge5Enabled) {$body["time5on"] = $GridCharge5Enabled.ToString().ToLower(); $changes++} else {$body["time5on"] = ($currentSettings.Times.Time5.GridChargeEnabled).ToString().ToLower()}
    if ($GridCharge6Enabled) {$body["time6on"] = $GridCharge6Enabled.ToString().ToLower(); $changes++} else {$body["time6on"] = ($currentSettings.Times.Time6.GridChargeEnabled).ToString().ToLower()}
    $body["genTime1on"] = ($currentSettings.Times.Time1.GeneratorChargeEnabled).ToString().ToLower()
    $body["genTime2on"] = ($currentSettings.Times.Time2.GeneratorChargeEnabled).ToString().ToLower()
    $body["genTime3on"] = ($currentSettings.Times.Time3.GeneratorChargeEnabled).ToString().ToLower()
    $body["genTime4on"] = ($currentSettings.Times.Time4.GeneratorChargeEnabled).ToString().ToLower()
    $body["genTime5on"] = ($currentSettings.Times.Time5.GeneratorChargeEnabled).ToString().ToLower()
    $body["genTime6on"] = ($currentSettings.Times.Time6.GeneratorChargeEnabled).ToString().ToLower()
    $body = $body | ConvertTo-Json #-Compress
    if ($changes -eq '0') {Write-Warning "No changes have been made, nothing to do."; break}
    Write-Verbose "Compiled $($changes) changes in request body:"
    Write-Verbose "Body: $($body)"
    Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method -Body $body -ContentType $contentType
}
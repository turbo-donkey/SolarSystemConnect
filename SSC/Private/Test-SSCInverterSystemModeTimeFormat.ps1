function Test-SSCInverterSystemModeTimeFormat {
    param (
        [string]$TimeString
    )

    if ($TimeString -match '^(0[0-9]|1[0-9]|2[0-3]):(00|30)$') {
        return $true
    } else {
        throw "Invalid time format. Expecting 'hh:00' or 'hh:30'."
    }
}
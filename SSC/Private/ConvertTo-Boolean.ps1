function ConvertTo-Boolean($string) {
    $booleanValue = if ($string -eq "true" -or $string -eq $true -or $string -eq "1") {
        $true
    } elseif ($string -eq "false" -or $string -eq $false -or $string -eq "0") {
        $false
    } else {
        $null
    }
    return $booleanValue
}
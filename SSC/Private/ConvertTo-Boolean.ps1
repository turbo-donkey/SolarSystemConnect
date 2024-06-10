function ConvertTo-Boolean($string) {
    $booleanValue = if ($String -eq "true") {
        $true
    } elseif ($String -eq "false") {
        $false
    } else {
        $null
    }
    return $booleanValue
}
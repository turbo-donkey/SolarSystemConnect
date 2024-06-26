function Write-PercentageBar {
    param (
        [int]$Width,
        [int]$Percent
    )

    # Ensure Percent is between 0 and 100
    if ($Percent -lt 0) { $Percent = 0 }
    if ($Percent -gt 100) { $Percent = 100 }

    # Calculate the number of filled and empty blocks
    $filledCount = [math]::Round($Width * ($Percent / 100))
    $emptyCount = $Width - $filledCount

    # Create the filled and empty blocks
    $filledBlocks = "$([char]0x2588)" * $filledCount
    $emptyBlocks = "$([char]0x2591)" * $emptyCount

    # Combine and return the percentage bar
    return "$filledBlocks$emptyBlocks"
}
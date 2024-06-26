function Get-PSHostDimensions {
    $PShost = Get-Host
    $windowSize = $PShost.UI.RawUI.WindowSize

    [PSCustomObject]@{
        Rows = $windowSize.Height
        Cols = $windowSize.Width
    }
}

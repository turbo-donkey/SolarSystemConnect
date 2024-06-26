function Write-TableLine {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("Top", "Bottom", "DoubleDivider", "SingleDivider", "Blank", "Empty", "SingleItem", "DoubleItem")]
        [string]$LineStyle,
        
        [string]$Item1 = "",
        [string]$Item2 = ""
    )

    $dimensions = Get-PSHostDimensions
    $width = $dimensions.Cols


    switch ($LineStyle) {
        "Top" {
            $line = [char]0x2554 + ([string]([char]0x2550) * ($width - 2)) + [char]0x2557
        }
        "Bottom" {
            $line = [char]0x255A + ([string]([char]0x2550) * ($width - 2)) + [char]0x255D
        }
        "DoubleDivider" {
            $line = [char]0x2560 + ([string]([char]0x2550) * ($width - 2)) + [char]0x2563
        }
        "SingleDivider" {
            $line = [char]0x255F + ([string]([char]0x2500) * ($width - 2)) + [char]0x2562
        }
        "Blank" {
            $line = [char]0x2551 + (" " * ($width - 2)) + [char]0x2551
        }
        "Empty" {
            $line = " " * ($width)
        }
        "SingleItem" {
            $itemLength = $Item1.Length
            $padding = ($width - 2 - $itemLength) / 2
            $leftPadding = " " * [Math]::Floor($padding)
            $rightPadding = " " * [Math]::Ceiling($padding)
            $line = [char]0x2551 + $leftPadding + $Item1 + $rightPadding + [char]0x2551
        }
        "DoubleItem" {
            $item1Length = $Item1.Length
            $item2Length = $Item2.Length
            $totalItemLength = $item1Length + $item2Length
            $spacesBetweenItems = ($width - 2 - $totalItemLength) / 3
            $leftPadding = " " * [Math]::Floor($spacesBetweenItems)
            $middlePadding = " " * [Math]::Ceiling($spacesBetweenItems)
            $rightPadding = " " * [Math]::Floor($spacesBetweenItems)
            $line = [char]0x2551 + $leftPadding + $Item1 + $middlePadding + $Item2 + $rightPadding + [char]0x2551
        }
    }    

    return $line
}
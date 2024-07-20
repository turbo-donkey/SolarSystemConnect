function Show-SSCPlantDashboard {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [switch]$Tail
    )

    do {
        if (-not($plant)) {$plant = Get-SSCPlant}
        if (-not($plantInfo)) {$plantInfo = Get-SSCPlantInfo -PlantId $plant.Id}
        if (-not($user)) {$user = Get-SSCUser}
        if (-not($inverter)) {$inverter = Get-SSCInverter}
        if (-not($inverterSystemMode)) {$inverterSystemMode = Get-SSCInverterSystemMode -InverterSerial $inverter.Serial}
    
        $powerFlow = Get-SSCPowerFlow -PlantId $plant.Id
        $generationPurpose = Get-SSCGenerationPurpose -PlantId $plant.Id
        $maxSellPower = $inverterSystemMode.MaxSellPower
        $weatherInfo = Get-SSCWeatherInfo -PlantId $plant.Id
        [single]$pvPercent = (($powerflow.PVPower * 100 ) / ([double]$plantInfo.CapacitykWp * 1000))
        [single]$exportPercent = (($powerflow.GridPower * 100 ) / $maxSellPower)
        $icons = [PSCustomObject]@{
            Solar = "[$([string]([char]0x263C))]"
            Inverter = '[=/~]'
            Home = "[$([string]([char]0x2302))]"
            Battery = "[$([string]([char]0x2263))]"
            Grid = "[$([string]([char]0x253C))]"
            BottomLeft = [string]([char]0x250F)
            BottomRight = [string]([char]0x2513)
            TopLeft = [string]([char]0x2517)
            TopRight = [string]([char]0x251B)
            UpTee = [string]([char]0x2533)
            DownTee = [string]([char]0x253B)
            Dash = $([string]$([char]0x2501))
            RightArrow = "$([string]$([char]0x2501) * 8)$([string]$([char]0x276F) * 2)$([string]$([char]0x2501) * 8)"
            LeftArrow = "$([string]$([char]0x2501) * 8)$([string]$([char]0x276E) * 2)$([string]$([char]0x2501) * 8)"
            NoDirection = "$([string]$([char]0x2501) * 8)$([string]$([char]0x2503) * 2)$([string]$([char]0x2501) * 8)"
            NoConnection = "$([string]$([char]0x2501) * 8)$([string]$([char]0x2503))"
            Error = "$([string]$([char]0x2501) * 7)$([string]$([char]0x2503))ERR$([string]$([char]0x2503))$([string]$([char]0x2501) * 7)"
        }
    
        # Solarflow
        if ($powerFLow.PVPower -eq '0') {
            $solarFlow = "$($icons.TopLeft)$($icons.Dash)$($icons.Solar)$($icons.NoDirection)"
        } else {
            $solarFlow = "$($icons.TopLeft)$($icons.Dash)$($icons.Solar)$($icons.RightArrow)"
        }
        # Gridflow
        if ($Powerflow.GridExists) {
            if ($powerFLow.GridExport) {
                $gridFlow = "$($icons.RightArrow)$($icons.Grid)$($icons.Dash)$($icons.TopRight)"
            } elseif ($powerFLow.GridImport) {
                $gridFlow = "$($icons.LeftArrow)$($icons.Grid)$($icons.Dash)$($icons.TopRight)"
            } else {
                $gridFlow = "$($icons.NoDirection)$($icons.Grid)$($icons.Dash)$($icons.TopRight)"
            }
        }
        $solarGridLine = "$solarFlow$($icons.UpTee)$gridFlow"
    
        # Batteryflow
        if ($Powerflow.BatterySOC) {
            if ($powerFLow.BatteryCharge) {
                $batteryFlow = "$($icons.BottomLeft)$($icons.Dash)$($icons.Battery)$($icons.LeftArrow)"
            } elseif ($powerFLow.BatteryDischarge) {
                $batteryFlow = "$($icons.BottomLeft)$($icons.Dash)$($icons.Battery)$($icons.RightArrow)"
            } elseif ((-not($powerFLow.BatteryDischarge)) -and (-not($powerFLow.BatteryDischarge))) {
                $batteryFlow = "$($icons.BottomLeft)$($icons.Dash)$($icons.Battery)$($icons.NoDirection)"
            }
        } else {
            $batteryFlow = "$($icons.TopLeft)$($icons.Dash)$($icons.Battery)$($icons.NoConnection)"
        }
        #LoadFlow
        if ($powerFLow.LoadPower -eq '0') {
            $loadFlow = "$($icons.NoDirection)$($icons.Home)$($icons.Dash)$($icons.BottomRight)"
        } else {
            $loadFlow = "$($icons.RightArrow)$($icons.Home)$($icons.Dash)$($icons.BottomRight)"
        }
        $batteryLoadLine = "$batteryFlow$(($icons).DownTee)$loadFlow"
    
        $dimensions = Get-PSHostDimensions
        $display = (Write-TableLine -LineStyle "Top")
        $display += (Write-TableLine -LineStyle "Blank")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "$(($plant).Name) ($(($plantInfo).CapacitykWp)kWp)$(($plant).Name) [ID:$(($plant).Id)]")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "$((Get-Date).ToString("HH:mm:ss dd-MM-yyyy"))")
        $display += (Write-TableLine -LineStyle "Blank") 
        $display += (Write-TableLine -LineStyle "SingleDivider")
        $display += (Write-TableLine -LineStyle "Blank")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "Sunset: $(($weatherInfo).SunSet)")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "Weather: $(($weatherInfo).Descrpition)")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "Temperature: $($weatherInfo.CurrentTempC)$([char]0x00B0)C")
        $display += (Write-TableLine -LineStyle "Blank")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "$([Math]::Round(($powerFlow.PVPower),2) / 1000)kW                                           $(if ($powerFlow.GridPower -eq '0') {"0.000"} else {$([double](($powerFlow.GridPower) / 1000))})kW")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "$solarGridLine")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "$($icons.Inverter)")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "$batteryLoadLine")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "$([Math]::Round(($powerFlow.BatteryPower),2) / 1000)kW                                           $([Math]::Round(($powerFlow.LoadPower),2) / 1000)kW")
        $display += (Write-TableLine -LineStyle "Blank")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "$(if ($powerflow.GridExport) {"Grid Power (Export)"} else {if ($powerflow.GridExport) {"Grid Power (Importing)"} else {"Grid Power (Idle)"}}): $(($powerflow).GridPower)W / $($maxSellPower)W")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "$(Write-PercentageBar -Width ($dimensions.cols - 60) -Percent $exportPercent)")
        $display += (Write-TableLine -LineStyle "Blank")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "PV Generation: $(($powerflow).PVPower)W / $([double]$(($plantInfo).CapacitykWp) * 1000)kWp")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "$(Write-PercentageBar -Width ($dimensions.cols - 60) -Percent $pvPercent)")
        $display += (Write-TableLine -LineStyle "Blank")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "State of Charge: $(($powerflow).BatterySOC)%")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "$(Write-PercentageBar -Width ($dimensions.cols - 60) -Percent $(($powerflow).BatterySOC))")
        $display += (Write-TableLine -LineStyle "Blank")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "Total PV Generation Today: $($generationPurpose.PVGenerationkWh)kWh")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "Total Consumption Today: $($generationPurpose.ConsumptionkWh)kWh")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "Total Export Today: $($generationPurpose.ExportkWh)kWh")
        $display += (Write-TableLine -LineStyle "SingleItem" -Item1 "Total Charging Today: $($generationPurpose.ChargingkWh)kWh")
        $display += (Write-TableLine -LineStyle "Blank")
        $display += (Write-TableLine -LineStyle "DoubleDivider")
        $display += (Write-TableLine -LineStyle "DoubleItem" -Item1 "Status: $(($plant).StatusDescription)" -Item2 "$(($user).NickName) [ID:$(($user).ID)]")
        $display += (Write-TableLine -LineStyle "Bottom")
        $displayLines = ($display.Length / $dimensions.Cols)
        if ($displayLines -gt $dimensions.Rows) {Write-Host -NoNewline "`rPowershell host window isn't big enough, increase to a minimum of $([int]$displayLines +3) rows, 100 cols."; continue}
        $displayPadding = [math]::Floor(($dimensions.Rows - $displayLines) / 2)
        $output += (Write-TableLine -LineStyle "Empty") * ($displayPadding -2)
        $output += $display
        $output += (Write-TableLine -LineStyle "Empty") * ($displayPadding + 1)
        Clear-Host; Write-Host $output -ForegroundColor Black -BackgroundColor DarkYellow
        if (-not $Tail) {
            break
        }
        Start-Sleep -Seconds 60
    } while ($true)
}
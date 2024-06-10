function Get-SSCInverterLogs {
        <#
        .SYNOPSIS
        Returns inverter logs.

        .DESCRIPTION
        The Get-SSCInverterLogs cmdlet returns inverter logs for a given date range.

        .PARAMETER InverterSerial
        Not required but lets you filter by inverter serial.

        .EXAMPLE
        Get-SSCInverterLogs -LogType InverterSettings -StartDate "2024-06-01" -EndDate "2024-06-09"
        Returns all InverterSettings logs between 2024-06-01 and 2024-06-09

        .EXAMPLE
        Get-SSCInverterLogs -LogType InverterUpgrade -StartDate "2024-01-01" -EndDate "2024-06-09" -InverterSerial 123456
        Returns all InverterUpgrade logs between 2024-01-01 and 2024-06-09 for inverter with serial 123456

        .NOTES

        .LINK
        https://github.com/turbo-donkey/SolarSystemConnect
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, HelpMessage = 'Use Get-SSCInverter to find your inverter serial')]
        [ValidateScript({
            if ($_ -match '^\d{10}$') {
                $true
            } else {
                throw "Invalid format for InverterSerial. Expecting 10 digits (0-9)."
            }
        })]
        [string]$InverterSerial,
        [ValidateSet("InverterUpgrade","InverterSettings")]
        $LogType,
        [Parameter(Mandatory = $true)]
        [ValidateScript({
            try {
                [DateTime]::ParseExact($_, 'yyyy-MM-dd', $null) | Out-Null
                $true
            } catch {
                throw "StartDate must be a valid date in the format 'yyyy-MM-dd'."
            }
        })]
        [string]$StartDate,
        [Parameter(Mandatory = $true)]
        [ValidateScript({
            try {
                [DateTime]::ParseExact($_, 'yyyy-MM-dd', $null) | Out-Null
                $true
            } catch {
                throw "EndDate must be a valid date in the format 'yyyy-MM-dd'."
            }
        })]
        [string]$EndDate
    )
    $startDateParsed = [DateTime]::ParseExact($StartDate, 'yyyy-MM-dd', $null)
    $endDateParsed = [DateTime]::ParseExact($EndDate, 'yyyy-MM-dd', $null)
    if ($startDateParsed -gt $endDateParsed) {
        throw "StartDate cannot be after EndDate."
    }
    $requestOperation = switch ($LogType) {
        InverterUpgrade { "4" }
        InverterSettings { "10" }
    }

    [int]$request = '1'
    $apiEndpoint = "/api/v1/logger?sn=$(if ($InverterSerial) {"$($InverterSerial)"})&operation=$requestOperation&plantId=&startDate=$($startDateParsed.ToString("yyyy-MM-dd"))&endDate=$($endDateParsed.ToString("yyyy-MM-dd"))&type=2&page=$request&limit=1&lan=en"
    $method = 'Get'
    Write-Verbose "Using method $($method) for api endpoint $($apiEndpoint)"
    $response = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method
    Write-Verbose "$(($response.data).total) logs in requested date range, pagesize $(($response.data).pageSize)"
    $requestsNeeded = [math]::Ceiling($response.data.total / 10)
    [int]$logsTotal = $response.data.total
    [int]$logCounter = '0'
    Write-Verbose "$($requestsNeeded) calls to the API required."
    while ($request -le $requestsNeeded) {
        $apiEndpoint = "/api/v1/logger?sn=$(if ($InverterSerial) {"$($InverterSerial)"})&operation=$requestOperation&plantId=&startDate=$($startDateParsed.ToString("yyyy-MM-dd"))&endDate=$($endDateParsed.ToString("yyyy-MM-dd"))&type=2&page=$request&limit=10&lan=en"
        Write-Progress -Id 1 -Activity "Gathering $($logType) logs" -Status "API request $($request) of $($requestsNeeded)" -PercentComplete ((($request++) / $requestsNeeded) * 100)
        $method = 'Get'
        Write-Verbose "Request $($request) of $($requestsNeeded)"
        Write-Verbose "Using method $($method) for api endpoint $($apiEndpoint)"
        $response = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method
        foreach ($logEntry in $response.data.infos) {
            $logcounter++
            Write-Progress -ParentId 1 -Activity "Parsing logs" -Status "$($logCounter) of $($logsTotal)" -PercentComplete ((($logCounter) / $logsTotal) * 100)
            [PSCustomObject]@{
                Operation = switch ($logEntry.operation) {
                    4  { "InverterUpgrade" }
                    10 { "InverterSettings" }
                }
                SN = $logEntry.sn
                Time = [DateTime]$logEntry.operationTime
                Changes = $logEntry.column
                PlantId = [string]$logEntry.plant.id
                PlantName = [string]$logEntry.plant.name
                UserId = [string]$logEntry.user.id
                UserNickName = [string]$logEntry.user.nickname
                UserMobilePhone = [string]$logEntry.user.mobile
                UserEMail = [string]$logEntry.user.email
                UserName = [string]$logEntry.user.realName
            }
        }
    }
    Write-Progress -ParentId 1 -Activity "Parsing logs" -Status "Finished" -Completed
    Write-Progress -Id 1 -Activity "Gathering $($logType) logs" -Status "Finished" -Completed
}
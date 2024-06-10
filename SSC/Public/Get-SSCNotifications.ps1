function Get-SSCNotifications {
    <#
        .SYNOPSIS
        Lists all notifications for the logged in user.

        .DESCRIPTION
        The Get-SSCGateway cmdlet lists all notifications for the logged in user as you would see in under
        the user profile in SunSynk Connect.

        .EXAMPLE
        Get-SSCNotifications | Where-Object {$_.StatusDescription -ne 'Read'}
        Returns all unread notifications.

        .NOTES

        .LINK
        https://github.com/turbo-donkey/SolarSystemConnect
    #>
    [CmdletBinding()]
    $apiEndpoint = "/api/v1/messages?pageSize=10&pageNumber=1&status=-1&lan=en"
    $method = 'Get'
    Write-Verbose "Using method $($method) for api endpoint $($apiEndpoint)"
    $response = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method
    foreach ($message in $response.data.infos) {
        [PSCustomObject]@{
            MessageId = [string]$message.id
            Serial = [string]$message.sn
            Type = [int]$message.type
            Status = [int]$message.status
            StatusDescription = switch ($message.status) {
                0 { "Unread" }
                1 { "Read" }
                2 { "Unread" }
            }
            MessageType = [int]$message.MessageType
            MessageTypeDescription = switch ($message.MessageType) {
                0 { "System Notice" }
                1 { "Device Alarm" }
                2 { "Notice" }
            }
            UserId = [string]$message.UserId
            Recieved = [DateTime]$message.createAt
            StationName = [string]$message.stationName
            Contents = ([string]$message.description).Replace("(#{stationName})","`($(($message).stationName)`)")
        }
    }
}
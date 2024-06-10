function Get-SSCUser {
    <#
        .SYNOPSIS
        Returns details of the logged in user.

        .DESCRIPTION
        The Get-SSCUser cmdlet returns details of the logged in user as SunSynk Connect would show in
        Personal Settings

        .EXAMPLE
        Get-SSCUser
        
        Returns details of the logged in user

        .NOTES

        .LINK
        https://github.com/turbo-donkey/SolarSystemConnect
    #>
    $apiEndpoint = "/api/v1/user?lan=en"
    $method = 'Get'
    Write-Verbose "Using method $($method) for api endpoint $($apiEndpoint)"
    $response = Invoke-SSCWebRequest -apiEndpoint $apiEndpoint -Method $method
    [PSCustomObject]@{
        Id = [string]$response.data.id
        NickName = [string]$response.data.nickname
        Gender = [string]$response.data.gender
        GenderDescription = switch ($response.data.gender) {
            0 { "Male" }
            1 { "Female" }
        }
        MobilePhone = [string]$response.data.mobile
        Created = [DateTime]$response.data.createAt
        TempUnit = [string]$response.data.tempUnit
        ProfilePicture = [string]$response.data.avatar
        CompanyId = [string]$response.data.company.id
        CompanyName = [string]$response.data.company.name
    }
}
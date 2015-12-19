#Requires -Version 4.0

<#
 # Script FileName: func_Update-DOImage.ps1
 # Current Version: A01
 # Description: Update DigitalOcean Images Name
 # Created By: Adam Listek
 # Version Notes
 #      A01 - Initial Release
 #>

Function Update-DOImage {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High"
    )] # Terminate CmdletBinding

    Param(
        [Parameter(Position=0,Mandatory=$true)][Int]$ID,
        [Parameter(Position=1,Mandatory=$true)][String]$Name,
        [Parameter(Position=2)][String]$ApiKey
    ) # Terminate Param

	Begin {
        If ($MyInvocation.BoundParameters.Verbose -match $true) {
            $local:VerbosePreference = "Continue"
            $local:ErrorActionPreference = "Continue"
            $local:verbose = $true
        } Else {
            $local:VerbosePreference = "SilentlyContinue"
            $local:ErrorActionPreference = "SilentlyContinue"
            $local:verbose = $false
        } # Terminate If - Verbose Parameter Check

        If ($MyInvocation.BoundParameters.Debug -eq $true) {
            $local:debug = $true
        } Else {
            $local:debug = $false
        } # Terminate Preferences

        If ($MyInvocation.BoundParameters.WhatIf -eq $true) {
            $local:whatif = $true
        } Else {
            $local:whatif = $false
        } # Terminate Preferences

        # Current Script Name
        $scriptName = $MyInvocation.MyCommand.Name

        $url = "https://api.digitalocean.com/v2"
        $header = @{
            "Authorization"="Bearer $apikey"
            "Content-Type"="application/json"
        }
    } # Terminate Begin

    Process {
        Write-Verbose $apikey
        Write-Verbose $url
        Write-Verbose ($header | Out-String)
        Write-Verbose $name

        If ($ID) { 
            $filter = "/$ID"   
        } # Terminate If - Filter

        $URI = "$url/images$($filter)"

        $body = [Ordered]@{
            "name" = $name
        } | ConvertTo-Json

        $response = Invoke-WebRequest -Uri $URI -Method POST -Headers $header -Body $body            
        
        Write-Verbose ($response | Out-String)

        If ($response.StatusCode -EQ 200) {
            Write-Host "Name successfully changed."
        } Else {
            Write-Host "Error" -BackgroundColor Red
        } # Terminate If - Response     
    } # Terminate Process
} # Terminate Function
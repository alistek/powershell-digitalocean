#Requires -Version 4.0

<#
 # Script FileName: func_Remove-DOImage.ps1
 # Current Version: A01
 # Description: Remove DigitalOcean Image
 # Created By: Adam Listek
 # Version Notes
 #      A01 - Initial Release
 #>

Function Remove-DOImage {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High"
    )] # Terminate CmdletBinding

    Param(
        [Parameter(Position=0,Mandatory=$true)][Int]$ID,
        [Parameter(Position=1)][String]$ApiKey
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

        $response = Invoke-WebRequest -Uri $URI -Method DELETE -Headers $header           
        
        Write-Verbose ($response | Out-String)

        If ($response.StatusCode -EQ 204) {
            Write-Host "Image successfully removed."
        } Else {
            Write-Host "Error" -BackgroundColor Red
        } # Terminate If - Response     
    } # Terminate Process
} # Terminate Function
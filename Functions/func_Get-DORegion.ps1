#Requires -Version 4.0

<#
 # Script FileName: func_Get-DORegion.ps1
 # Current Version: A01
 # Description: Retrieve DigitalOcean Regions
 # Created By: Adam Listek
 # Version Notes
 #      A01 - Initial Release
 #>

Function Get-DORegion {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Medium"
    )] # Terminate CmdletBinding

    Param(
        [Parameter(Position=0)][String]$Name,
        [Parameter(Position=1)][String]$Slug,
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

        If ($name -and $slug) {
            Write-Host "Please choose Name or Slug, not both." -BackgroundColor Red
            Break
        } # Terminate If - Parameters

        $response = Invoke-WebRequest -Uri "$url/regions" -Method GET -Headers $header `
            | Select -ExpandProperty Content `
            | ConvertFrom-Json `
            | Select -ExpandProperty regions
                
        If ($response) {
            If ($Name) {
                $response | Where Name -Match $name
            } ElseIf ($Slug) {
                $response | Where Slug -EQ $slug
            } Else {
                $response
            } # Terminate If - Qualifiers
        } Else {
            Write-Host "Error" -BackgroundColor Red
        } # Terminate If - Response     
    } # Terminate Process
} # Terminate Function
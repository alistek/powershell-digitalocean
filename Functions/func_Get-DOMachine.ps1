#Requires -Version 4.0

<#
 # Script FileName: func_Get-DOMachine.ps1
 # Current Version: A01
 # Description: Retrieve DigitalOcean Machine
 # Created By: Adam Listek
 # Version Notes
 #      A01 - Initial Release
 #>

Function Get-DOMachine {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Medium"
    )] # Terminate CmdletBinding

    Param(
        [Parameter(Position=0)][String]$Name,
        [Parameter(Position=1)][String]$apikey
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

        $droplets = Invoke-WebRequest -Uri "$url/droplets" -Method GET -Headers $header

        Write-Verbose $droplets

        If (-not $Name) {
            $droplets.Content | ConvertFrom-Json | Select -ExpandProperty droplets
        } Else {
            $droplets.Content | ConvertFrom-Json | Select -ExpandProperty droplets | Where Name -eq $Name
        } # Terminate If - List All
    } # Terminate Process
} # Terminate Function
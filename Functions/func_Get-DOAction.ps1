#Requires -Version 4.0

<#
 # Script FileName: func_Get-DOAction.ps1
 # Current Version: A01
 # Description: Retrieve DigitalOcean Account Actions
 # Created By: Adam Listek
 # Version Notes
 #      A01 - Initial Release
 #>

Function Get-DOAction {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Medium"
    )] # Terminate CmdletBinding

    Param(
        [Parameter(Position=0)][Int]$ID,
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

        If ($ID) { 
            $URI = "$url/actions/$ID"
        } Else {
            $URI = "$url/actions"
        } # Terminate If - Filter

        $response = Invoke-WebRequest -Uri $URI -Method GET -Headers $header `
            | Select -ExpandProperty Content `
            | ConvertFrom-Json            

        Write-Verbose ($response | Out-String)

        If ($response) {
            If ($ID) {
                $response | Select -ExpandProperty Action
            } Else {
                $response | Select -ExpandProperty Actions
            }
        } Else {
            Write-Host "Error" -BackgroundColor Red
        } # Terminate If - Response     
    } # Terminate Process
} # Terminate Function
#Requires -Version 4.0

<#
 # Script FileName: func_Get-DOSSHKey.ps1
 # Current Version: A01
 # Description: Retrieve DigitalOcean SSH Key
 # Created By: Adam Listek
 # Version Notes
 #      A01 - Initial Release
 #>

Function Get-DOSSHKey {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Medium"
    )] # Terminate CmdletBinding

    Param(
        [Parameter(Position=0)][String]$Name,
        [Parameter(Position=1)][Int]$ID,
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

        If ($name -and $ID) {
            Write-Host "Please choose Name or ID, not both." -BackgroundColor Red
            Break
        } # Terminate If - Parameters

        If ($ID) { 
            $URI = "$url/account/keys/$ID"
        } Else {
            $URI = "$url/account/keys"
        } # Terminate If - Filter

        $response = Invoke-WebRequest -Uri $URI -Method GET -Headers $header `
            | Select -ExpandProperty Content `
            | ConvertFrom-Json
        
        If ($response) {
            If ($name -or $ID) {
                If ($name) {
                    $response | Select -ExpandProperty ssh_keys | Where Name -EQ $name
                } ElseIf ($ID) {
                    $response | Select -ExpandProperty ssh_key
                } # Terminate If - Name or ID
            } Else {
                $response | Select -ExpandProperty ssh_keys
            } # Terminate If - Name or ID
        } Else {
            Write-Host "Error" -BackgroundColor Red
        } # Terminate If - Response     
    } # Terminate Process
} # Terminate Function
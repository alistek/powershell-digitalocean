#Requires -Version 4.0

<#
 # Script FileName: func_Remove-DOSSHKey.ps1
 # Current Version: A01
 # Description: Remove DigitalOcean SSH Key
 # Created By: Adam Listek
 # Version Notes
 #      A01 - Initial Release
 #>

Function Remove-DOSSHKey {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="High"
    )] # Terminate CmdletBinding

    Param(
        [Parameter(Position=0)][Int]$ID,
        [Parameter(Position=1)][String]$FingerPrint,
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

        If (-not ($ID -or $FingerPrint)) {
            Write-Host "Please provide an ID or FingerPrint." -BackgroundColor Red
            Break
        } # Terminate If - Parameter

        If ($ID) { 
            $URI = "$url/actions/$ID"
        } ElseIf ($FingerPrint) {
            $URI = "$url/actions/$FingerPrint"
        } # Terminate If - Filter

        $response = Invoke-WebRequest -Uri $URI -Method DELETE -Headers $header
        
        If ($response.StatusCode -EQ 204) {
            $response
        } Else {
            Write-Host "Error" -BackgroundColor Red
        } # Terminate If - Response     
    } # Terminate Process
} # Terminate Function
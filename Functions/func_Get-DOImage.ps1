#Requires -Version 4.0

<#
 # Script FileName: func_Get-DOImage.ps1
 # Current Version: A01
 # Description: Retrieve DigitalOcean Images
 # Created By: Adam Listek
 # Version Notes
 #      A01 - Initial Release
 #>

Function Get-DOImage {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Medium"
    )] # Terminate CmdletBinding

    Param(
        [Parameter(Position=0)][String]$Name,
        [Parameter(Position=1)][Int]$ID,
        [Parameter(Position=2)][String]$Slug,
        [Parameter(Position=3)][String]$ApiKey,
        [Switch]$Distribution,
        [Switch]$Application,
        [Switch]$Private,
        [Switch]$Actions
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

        If (
            ($Distribution -and $Application) -or
            ($Distribution -and $Private) -or
            ($Application -and $Private) -or
            ($Application -and $Private -and $Distribution)
        ) {
            Write-Host "Please choose Application, Distribution or Private, not more than one." -BackgroundColor Red
            Break
        } # Terminate If - Parameters

        If (
            ($Name -and $ID) -or
            ($Name -and $Slug) -or
            ($ID -and $Slug) -or
            ($Name -and $Slug -and $ID)
        ) {
            Write-Host "Please choose to filter by Name, ID or Slug, not more than one." -BackgroundColor Red
            Break
        } # Terminate If - Parameters

        If ($Actions -and (-not ($ID -or $Slug))) {
            Write-Host "If retrieving actions, you need to specify an ID or Slug." -BackgroundColor Red
            Break            
        } # Terminate If - Parameters

        If ($Actions) {
            $actionFilter = "/actions"
        } Else {
            $actionFilter = $null 
        } # Terminate

        If ($ID) { 
            $filter = "/$ID"   
        } ElseIf ($Slug) {
            $filter = "/$Slug"
        } Else {
            $filter = $null
        } # Terminate If - Filter

        If ($Distribution) {
            $URI = "$url/images$($filter)?type=distribution"
        } ElseIf ($Application) {
            $URI = "$url/images$($filter)?type=application"
        } ElseIf ($Private) {
            $URI = "$url/images$($filter)?type=private"
        } Else {
            $URI = "$url/images$($filter)$($actionFilter)"
        } # Terminate If - Distribution

        $response = Invoke-WebRequest -Uri $URI -Method GET -Headers $header `
            | Select -ExpandProperty Content `
            | ConvertFrom-Json
        
        Write-Verbose ($response | Out-String)

        If (($response | Select -ExpandProperty Meta).Total -NE 0) {
            If ($Name) {
                $response | Select -ExpandProperty Images | Where Name -EQ $name
            } Else {
                If ($ID -or $Slug) {
                    $response | Select -ExpandProperty Image
                } Else {
                    $response | Select -ExpandProperty Images
                } # Terminate If - ID or Slug
            } # Terminate If - Name or ID
        } Else {
            Write-Host "Error" -BackgroundColor Red
        } # Terminate If - Response     
    } # Terminate Process
} # Terminate Function
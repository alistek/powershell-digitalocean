#Requires -Version 4.0

<#
 # Script FileName: func_New-DOMachine.ps1
 # Current Version: A01
 # Description: New DigitalOcean Machine
 # Created By: Adam Listek
 # Version Notes
 #      A01 - Initial Release
 #>

Function New-DOMachine {
    [CmdletBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact="Medium"
    )] # Terminate CmdletBinding

    Param(
        [Parameter(Mandatory=$true,Position=0)][String]$Name,

        [Parameter(Position=1)]
        [ValidateScript({ If (Get-DORegion -ApiKey:$ApiKey | Where Slug -EQ $_) { $true } Else { $false } })]
        [String]$Region = "nyc3",
        
        [Parameter(Position=2)]
        [ValidateScript({ If (Get-DOSize -ApiKey:$ApiKey | Where Slug -EQ $_) { $true } Else { $false } })]
        [String]$Size = "512mb",
        
        [Parameter(Position=3)]
        [ValidateScript({ If (Get-DOImage -ApiKey:$ApiKey | Where Slug -EQ $_) { $true } Else { $false } })]
        [String]$Image = "ubuntu-15-10-x64",

        [Parameter(Position=4)][Int[]]$Keys = $(Get-DOSSHKey -ApiKey:$ApiKey | Select -ExpandProperty id),
        [Parameter(Position=5)][Switch]$Backups = $false,
        [Parameter(Position=6)][Switch]$IPv6 = $true,
        [Parameter(Position=7)][String]$UserData,
        [Parameter(Position=8)][Switch]$PrivateNetwork = $true,
        [Parameter(Position=9)][String]$ApiKey
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

        If (-not $userData) {
            If ($Image -eq "ubuntu-14-04-x64") {
                $userData = "
                    #cloud-config
                    write_files:
                        - path: /etc/ssh/sshd_config
                          content: |
                            # SSH Port
                            Port 55567
                            # Protocol, 2 is most recent, 1 is legacy
                            Protocol 2
                            # Following keys identify the server to the client
                            HostKey /etc/ssh/ssh_host_rsa_key
                            HostKey /etc/ssh/ssh_host_dsa_key
                            HostKey /etc/ssh/ssh_host_ecdsa_key
                            HostKey /etc/ssh/ssh_host_ed25519_key
                            # Allows SSH to spawn child processes that only have
                            # the necessary privileges for their tasks
                            UsePrivilegeSeparation yes
                            # Disable DNS reverse lookup on connection requests, speeds
                            # up connecting
                            UseDNS no
                            # Both options below are for protocol version 1 only
                            KeyRegenerationInterval 3600
                            ServerKeyBits 1024
                            # What code to use in Syslog to differentiate the messages
                            SyslogFacility AUTH
                            # What level of loggin to use
                            LogLevel INFO
                            # Amount of time server waits before disconnecting from
                            # a client if there has been no successful login
                            LoginGraceTime 120
                            # Allow Root to login via SSH
                            PermitRootLogin yes
                            # Disregard any user-level configs without correct
                            # permissions: chmod 600
                            StrictModes yes
                            # Protocol 1 Option, not relevant
                            RSAAuthentication yes
                            # Allow Public-Private Key Authentication
                            PubkeyAuthentication yes
                            # Protocol 1 options, not relevant
                            IgnoreRhosts yes
                            RhostsRSAAuthentication no
                            # Allow authentication based on host defined in
                            # /etc/ssh/shosts.equiv file, easy to spoof, should
                            # not be used
                            HostbasedAuthentication no
                            # Do allow accounts with not password to connect
                            PermitEmptyPasswords no
                            # This line enables or disables a challenge-response
                            # authentication type that can be configured through PAM
                            ChallengeResponseAuthentication no
                            # Forward X11, disabled because we should not use GUI
                            X11Forwarding no
                            # Port offset for X11 servers to avoid clashing with
                            # regular X11 windows not spawned by SSH
                            X11DisplayOffset 10
                            # SSH Daemon should not read MOTD file, shell may
                            # read this though anyways
                            PrintMotd no
                            # Print out last time this account logged on
                            PrintLastLog yes
                            # Send keepalive messages 
                            TCPKeepAlive yes
                            # Accept certain environmental variables from the
                            # client, in this case the language variables
                            AcceptEnv LANG LC_*
                            # Define additional subsystems used with SSH, below
                            # is SFTP server and the path to it
                            Subsystem sftp /usr/lib/openssh/sftp-server
                            # Use PAM to assist with authenticating users
                            UsePAM yes
                "
            } ElseIf (($Image -eq "ubuntu-15-04-x64") -or ($Image -eq "ubuntu-15-10-x64")) {
                $userData = "
                    #cloud-config
                    write_files:
                        - path: /etc/ssh/sshd_config
                          content: |
                            # SSH Port
                            Port 55567
                            # Protocol, 2 is most recent, 1 is legacy
                            Protocol 2
                            # Following keys identify the server to the client
                            HostKey /etc/ssh/ssh_host_rsa_key
                            HostKey /etc/ssh/ssh_host_dsa_key
                            HostKey /etc/ssh/ssh_host_ecdsa_key
                            HostKey /etc/ssh/ssh_host_ed25519_key
                            # Allows SSH to spawn child processes that only have
                            # the necessary privileges for their tasks
                            UsePrivilegeSeparation yes
                            # Disable DNS reverse lookup on connection requests, speeds
                            # up connecting
                            UseDNS no
                            # Both options below are for protocol version 1 only
                            KeyRegenerationInterval 3600
                            ServerKeyBits 1024
                            # What code to use in Syslog to differentiate the messages
                            SyslogFacility AUTH
                            # What level of loggin to use
                            LogLevel INFO
                            # Amount of time server waits before disconnecting from
                            # a client if there has been no successful login
                            LoginGraceTime 120
                            # Allow Root to login via SSH
                            PermitRootLogin yes
                            # Disregard any user-level configs without correct
                            # permissions: chmod 600
                            StrictModes yes
                            # Protocol 1 Option, not relevant
                            RSAAuthentication yes
                            # Allow Public-Private Key Authentication
                            PubkeyAuthentication yes
                            # Protocol 1 options, not relevant
                            IgnoreRhosts yes
                            RhostsRSAAuthentication no
                            # Allow authentication based on host defined in
                            # /etc/ssh/shosts.equiv file, easy to spoof, should
                            # not be used
                            HostbasedAuthentication no
                            # Do allow accounts with not password to connect
                            PermitEmptyPasswords no
                            # This line enables or disables a challenge-response
                            # authentication type that can be configured through PAM
                            ChallengeResponseAuthentication no
                            # Forward X11, disabled because we should not use GUI
                            X11Forwarding no
                            # Port offset for X11 servers to avoid clashing with
                            # regular X11 windows not spawned by SSH
                            X11DisplayOffset 10
                            # SSH Daemon should not read MOTD file, shell may
                            # read this though anyways
                            PrintMotd no
                            # Print out last time this account logged on
                            PrintLastLog yes
                            # Send keepalive messages 
                            TCPKeepAlive yes
                            # Accept certain environmental variables from the
                            # client, in this case the language variables
                            AcceptEnv LANG LC_*
                            # Define additional subsystems used with SSH, below
                            # is SFTP server and the path to it
                            Subsystem sftp /usr/lib/openssh/sftp-server
                            # Use PAM to assist with authenticating users
                            UsePAM yes
                    apt_update: true
                    packages:
                        - python2.7
                    runcmd:
                        - `"ln -s /usr/bin/python2.7 /usr/bin/python`"
                "
            } # Terminate If - Image
        } # Terminate If - No UserData, use Default
    } # Terminate Begin

    Process {
        Write-Verbose $apikey
        Write-Verbose $url
        Write-Verbose ($header | Out-String)

        $body = [Ordered]@{
            "name" = $name
            "region" = $region
            "size" = $size
            "image" = $image
            "ssh_keys" = $keys
            "backups" = $(If ($backups -eq $false) { "false" } Else { "true" })
            "ipv6" = $(If ($ipv6 -eq $false) { "false" } Else { "true" })
            "user_data" = $userData
            "private_networking" = $(If ($privateNetwork -eq $false) { "false" } Else { "true" })
        } | ConvertTo-Json

        If ($pscmdlet.ShouldProcess("$body", "Create Droplet")) {
            Try {
                $response = Invoke-WebRequest -Uri "$url/droplets" -Method POST -Headers $header -Body $body
            } Catch {
                Write-Host $error[0] -BackgroundColor Red
                Break
            } # Terminate Try-Catch

            If ($response) {
                $response
            } Else {
                Write-Host "Something went wrong..." -BackgroundColor Red
            } # Terminate If - Response
        } # Terminate WhatIF
    } # Terminate Process
} # Terminate Function

#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Connect-ArubaSW {

    <#
      .SYNOPSIS
      Connect to an ArubaOS Switches (Provision)

      .DESCRIPTION
      Connect to an ArubaOS Switches
      Support connection to HTTPS (default) or HTTP

      .EXAMPLE
      Connect-ArubaSW -Server 192.0.2.1

      Connect to an ArubaOS Switch using HTTPS with IP 192.0.2.1 using (Get-)credential

      .EXAMPLE
      Connect-ArubaSW -Server 192.0.2.1 -SkipCertificateCheck

      Connect to an ArubaOS Switch using HTTPS (without check certificate validation) with IP 192.0.2.1 using (Get-)credential

      .EXAMPLE
      Connect-ArubaSW -Server 192.0.2.1 -httpOnly

      Connect to an ArubaOS Switch using HTTP (unsecure !) with IP 192.0.2.1 using (Get-)credential

      .EXAMPLE
      Connect-ArubaSW -Server 192.0.2.1 -port 4443

      Connect to an ArubaOS Switch using HTTPS (with port 4443) with IP 192.0.2.1 using (Get-)credential

      .EXAMPLE
      $cred = get-credential
      Connect-ArubaSW -Server 192.0.2.1 -credential $cred

      Connect to an ArubaOS Switch with IP 192.0.2.1 and passing (Get-)credential

      .EXAMPLE
      $mysecpassword = ConvertTo-SecureString aruba -AsPlainText -Force
      Connect-ArubaSW -Server 192.0.2.1 -Username manager -Password $mysecpassword

      Connect to an ArubaOS Switch with IP 192.0.2.1 using Username and Password

      .EXAMPLE
      $sw1 = Connect-ArubaSW -Server 192.0.2.1

      Connect to an ArubaOS Switch with IP 192.0.2.1 and store connection info to $sw1 variable

      .EXAMPLE
      $sw2 = Connect-ArubaSW -Server 192.0.2.1 -DefaultConnection:$false

      Connect to an ArubaOS Switch with IP 192.0.2.1 and store connection info to $sw2 variable
      and don't store connection on global ($DefaultArubaSWConnection) variable

     .EXAMPLE
      Connect-ArubaSW -Server 192.0.2.1 -api_version 2

      Connect to an ArubaOS Switch with IP 192.0.2.1 using v2 API
  #>

    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$Server,
        [Parameter(Mandatory = $false)]
        [String]$Username,
        [Parameter(Mandatory = $false)]
        [SecureString]$Password,
        [Parameter(Mandatory = $false)]
        [PSCredential]$Credentials,
        [Parameter(Mandatory = $false)]
        [switch]$noverbose = $false,
        [Parameter(Mandatory = $false)]
        [switch]$httpOnly = $false,
        [Parameter(Mandatory = $false)]
        [switch]$SkipCertificateCheck = $false,
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 65535)]
        [int]$port,
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 10)]
        [int]$api_version,
        [Parameter(Mandatory = $false)]
        [boolean]$DefaultConnection = $true
    )

    Begin {
    }

    Process {

        $version = @{min = ""; cur = ""; max = "" }
        $connection = @{server = ""; session = ""; cookie = ""; httpOnly = $false; port = ""; invokeParams = ""; switch_type = "" ; api_version = $version ; product_number = "" }

        #If there is a password (and a user), create a credentials
        if ($Password) {
            $Credentials = New-Object System.Management.Automation.PSCredential($Username, $Password)
        }
        #Not Credentials (and no password)
        if ($NULL -eq $Credentials) {
            $Credentials = Get-Credential -Message 'Please enter administrative credentials for your ArubaOS Switch'
        }

        $postParams = @{userName = $Credentials.username; password = $Credentials.GetNetworkCredential().Password }
        $invokeParams = @{DisableKeepAlive = $true; UseBasicParsing = $true; SkipCertificateCheck = $SkipCertificateCheck }

        if ("Desktop" -eq $PSVersionTable.PsEdition) {
            #Remove -SkipCertificateCheck from Invoke Parameter (not supported <= PS 5)
            $invokeParams.remove("SkipCertificateCheck")
        }
        else {
            #Core Edition
            #Remove -UseBasicParsing (Enable by default with PowerShell 6/Core)
            $invokeParams.remove("UseBasicParsing")
        }

        if ($httpOnly) {
            if (!$port) {
                $port = 80
            }
            $connection.httpOnly = $true
            $uri = "http://${Server}:${port}/"
        }
        else {
            if (!$port) {
                $port = 443
            }

            #for PowerShell (<=) 5 (Desktop), Enable TLS 1.1, 1.2 and Disable SSL chain trust
            if ("Desktop" -eq $PSVersionTable.PsEdition) {
                #Enable TLS 1.1 and 1.2
                Set-ArubaSWCipherSSL
                if ($SkipCertificateCheck) {
                    #Disable SSL chain trust...
                    Set-ArubaSWuntrustedSSL
                }
            }
            $uri = "https://${Server}:${port}/"
        }

        if ($PsBoundParameters.ContainsKey('api_version')) {
            $uri += "rest/v${api_version}/login-sessions"
        }
        else {
            #By default use v3 API (some 'new' device don't support v1/v2 API...)
            $uri += "rest/v3/login-sessions"
        }

        try {
            $response = Invoke-WebRequest -uri $uri -Method POST -Body ($postParams | ConvertTo-Json ) -SessionVariable arubasw @invokeParams
        }
        catch {
            Show-ArubaSWException -Exception $_
            throw "Unable to connect"
        }
        $cookie = ($response.content | ConvertFrom-Json).cookie
        $smallcookie = $cookie.split("=")[1]
        $arubasw.Cookies.Add((Set-Cookie -name "sessionId" -value $smallcookie -domain $server));

        $connection.server = $server
        $connection.cookie = $cookie
        $connection.session = $arubasw
        $connection.port = $port
        $connection.invokeParams = $invokeParams

        if ( $DefaultConnection ) {
            Set-Variable -name DefaultArubaSWConnection -value $connection -scope Global
        }

        $restversion = Get-ArubaSWRestversion -connection $connection
        #Remove v and .x (.0, 1)
        $vers = $restversion.version -replace "v" -replace ".0" -replace ".1"

        $connection.api_version.min = ($vers | Measure-Object -Minimum).Minimum
        $connection.api_version.max = ($vers | Measure-Object -Maximum).Maximum

        if ($PsBoundParameters.ContainsKey('api_version')) {
            $connection.api_version.cur = $api_version
        }
        else {
            #use by default the high version release supported
            $connection.api_version.cur = $connection.api_version.max
        }

        $switchstatus = Get-ArubaSWSystemStatusSwitch -connection $connection
        $connection.switch_type = $switchstatus.switch_type

        if ('ST_STACKED' -eq $switchstatus.switch_type) {
            if ( $switchstatus.blades.count -eq "1") {
                $connection.product_number = $switchstatus.blades.product_number
            }
            else {
                $connection.product_number = $switchstatus.blades.product_number[0]
            }

        }
        else {
            $connection.product_number = $switchstatus.product_number
        }

        if (-not $noverbose) {
            $switchsystem = Get-ArubaSWSystem -connection $connection


            if ($switchstatus.switch_type -eq "ST_STACKED") {
                $product_name = $NULL;
                foreach ($blades in $switchstatus.blades) {
                    if ($blades.product_name) {
                        if ($product_name) {
                            $product_name += ", "
                        }
                        $product_name += $blades.product_name
                    }
                }
            }
            else {
                $product_name = $switchstatus.product_name
            }
            Write-Output "Welcome on $($switchsystem.name) -$product_name"

        }

        #Return connection info
        $connection
    }

    End {
    }
}

function Disconnect-ArubaSW {

    <#
        .SYNOPSIS
        Disconnect to an ArubaOS Switches (Provision)

        .DESCRIPTION
        Disconnect the connection on ArubaOS Switchs

        .EXAMPLE
        Disconnect-ArubaSW

        Disconnect the connection

        .EXAMPLE
        Disconnect-ArubaSW -confirm:$false

        Disconnect the connection with no confirmation

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "login-sessions"

        if ($PSCmdlet.ShouldProcess($connection.server, 'Remove Connection')) {
            $null = Invoke-ArubaSWWebRequest -method "DELETE" -uri $uri -connection $connection
            if (Test-Path variable:global:DefaultArubaSWConnection) {
                Remove-Variable -name DefaultArubaSWConnection -scope global
            }
        }

    }

    End {
    }
}

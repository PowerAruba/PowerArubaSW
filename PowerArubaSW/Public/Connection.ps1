
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
        [int]$port
    )

    Begin {
    }

    Process {

        $connection = @{server = ""; session = ""; cookie = ""; httpOnly = $false; port = ""; invokeParams = ""; switch_type = "" }

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
            $url = "http://${Server}:${port}/rest/v3/login-sessions"
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
            $url = "https://${Server}:${port}/rest/v3/login-sessions"
        }

        try {
            $response = Invoke-WebRequest -uri $url -Method POST -Body ($postParams | ConvertTo-Json ) -SessionVariable arubasw @invokeParams
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

        Set-Variable -name DefaultArubaSWConnection -value $connection -scope Global

        $switchstatus = Get-ArubaSWSystemStatusSwitch
        $connection.switch_type = $switchstatus.switch_type

        if (-not $noverbose) {
            $switchsystem = Get-ArubaSWSystem


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
            Write-Host "Welcome on"$switchsystem.name"-"$product_name

        }
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
        Disconnect-ArubaSW -noconfirm

        Disconnect the connection with no confirmation

    #>

    Param(
        [Parameter(Mandatory = $false)]
        [switch]$noconfirm
    )

    Begin {
    }

    Process {

        $url = "rest/v3/login-sessions"

        if ( -not ( $Noconfirm )) {
            $message = "Remove Aruba Switch connection."
            $question = "Proceed with removal of Aruba Switch connection ?"
            $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

            $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
        }
        else { $decision = 0 }
        if ($decision -eq 0) {
            Write-Progress -activity "Remove Aruba SW connection"
            $null = Invoke-ArubaSWWebRequest -method "DELETE" -url $url
            Write-Progress -activity "Remove Aruba SW connection" -completed
            if (Get-Variable -Name DefaultArubaSWConnection -scope global ) {
                Remove-Variable -name DefaultArubaSWConnection -scope global
            }
        }

    }

    End {
    }
}
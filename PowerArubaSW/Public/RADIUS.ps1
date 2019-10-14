#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWRadius {

    <#
        .SYNOPSIS
        Get RADIUS information.

        .DESCRIPTION
        Get RADIUS information configured on the device.

        .EXAMPLE
        Get-ArubaSWRadius

        This function give you all the informations about the radius servers parameters configured on the switch.

        .EXAMPLE
        Get-ArubaSWRadius -address 192.0.2.1

        This function give you all the informations about the radius server with address 192.0.2.1 configured on the switch.
    #>

    Param(
        [Parameter (Mandatory = $false)]
        [string]$address,
        [Parameter (Mandatory = $false)]
        [string]$id,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/radius_servers"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $run = ($response | ConvertFrom-Json).radius_server_element

        if ( $address -And !$id ) {
            $run | Where-Object { $_.address.octets -eq $address }
        }

        if ( $id -And !$address ) {
            $run | Where-Object { $_.radius_server_id -eq $id }
        }

        if ( $id -And $address ) {
            $run | Where-Object { $_.radius_server_id -eq $id -And $_.address.octets -eq $address }  
        }

        if ( !$id -And !$address ) {
            $run   
        }
    }

    End {
    }
}

function Add-ArubaSWRadius {

    <#
        .SYNOPSIS
        Add a RADIUS server

        .DESCRIPTION
        Add a RADIUS server parameters

        .EXAMPLE
        Add-ArubaSWRadius -address 192.0.2.1 -shared_secret powerarubasw

        Add this server with the mandatory parameters for a radius server.

        .EXAMPLE
        Add-ArubaSWRadius -address 192.0.2.2 -shared_secret powerarubasw -authentication_port 1645 -accounting_port 1646 -is_dyn_autorization_enabled -time_window_type TW_PLUS_OR_MINUS_TIME_WINDOW -time_window 0 -is_oobm

        Add all the parameters for a radius server, with dynamic autorization and oobm enable.
    #>

    Param(
        [Parameter (Mandatory = $true)]
        [string]$address,
        [Parameter (Mandatory = $true)]
        [string]$shared_secret,
        [Parameter (Mandatory = $false)]
        [int]$authentication_port,
        [Parameter (Mandatory = $false)]
        [int]$accounting_port,
        [Parameter (Mandatory = $false)]
        [switch]$is_dyn_authorization_enabled,
        [Parameter (Mandatory = $false)]
        [ValidateSet ("TW_POSITIVE_TIME_WINDOW", "TW_PLUS_OR_MINUS_TIME_WINDOW")]
        [string]$time_window_type,
        [Parameter (Mandatory = $false)]
        [ValidateRange (0, 65535)]
        [int]$time_window,
        [Parameter (Mandatory = $false)]
        [switch]$is_oobm,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/radius_servers"

        $conf = New-Object -TypeName PSObject

        $ip = New-Object -TypeName PSObject

        $ip | Add-Member -name "version" -MemberType NoteProperty -Value "IAV_IP_V4"

        $ip | Add-Member -name "octets" -MemberType NoteProperty -Value $address

        $conf | Add-Member -name "address" -membertype NoteProperty -Value $ip

        $conf | Add-Member -name "shared_secret" -MemberType NoteProperty -Value $shared_secret

        if ($PsBoundParameters.ContainsKey('authentication_port')) {
            $conf | Add-Member -name "authentication_port" -membertype NoteProperty -Value $authentication_port
        }

        if ($PsBoundParameters.ContainsKey('accounting_port')) {
            $conf | Add-Member -name "accounting_port" -membertype NoteProperty -Value $accounting_port
        }

        if ( $PsBoundParameters.ContainsKey('is_dyn_authorization_enabled') ) {
            if ( $is_dyn_authorization_enabled ) {
                $conf | Add-Member -name "is_dyn_authorization_enabled" -membertype NoteProperty -Value $true
            }
            else {
                $conf | Add-Member -name "is_dyn_authorization_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ($PsBoundParameters.ContainsKey('time_window_type')) {
            $conf | Add-Member -name "time_window_type" -membertype NoteProperty -Value $time_window_type
        }

        if ($PsBoundParameters.ContainsKey('time_window')) {
            $conf | Add-Member -name "time_window" -membertype NoteProperty -Value $time_window
        }

        if ( $PsBoundParameters.ContainsKey('is_oobm') ) {
            if ( $is_oobm ) {
                $conf | Add-Member -name "is_oobm" -membertype NoteProperty -Value $true
            }
            else {
                $conf | Add-Member -name "is_oobm" -membertype NoteProperty -Value $false
            }
        }

        $response = Invoke-ArubaSWWebRequest -method "POST" -body $conf -uri $uri -connection $connection

        $run = $response | ConvertFrom-Json

        $run
    }

    End {
    }
}

function Set-ArubaSWRadius {

    <#
        .SYNOPSIS
        Set a RADIUS server.

        .DESCRIPTION
        Set a RADIUS server parameters.

        .EXAMPLE
        Set-ArubaSWRadius -id 1 -address 192.0.2.1 -shared_secret powerarubasw

        Change parameters for a radius server.

        .EXAMPLE
        Set-ArubaSWRadius -id 2 -address 192.0.2.2 -shared_secret powerarubasw -authentication_port 1812 -accounting_port 1813 -is_dyn_autorization_enabled -time_window_type TW_PLUS_OR_MINUS_TIME_WINDOW -time_window 0 -is_oobm

        Change all the parameters for a radius server, with dynamic autorization and oobm enable.
    #>

    Param(
        [Parameter (Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateRange (1, 15)]
        [int]$id,
        [Parameter (Mandatory = $true)]
        [string]$address,
        [Parameter (Mandatory = $false)]
        [string]$shared_secret,
        [Parameter (Mandatory = $false)]
        [int]$authentication_port,
        [Parameter (Mandatory = $false)]
        [int]$accounting_port,
        [Parameter (Mandatory = $false)]
        [switch]$is_dyn_authorization_enabled,
        [Parameter (Mandatory = $false)]
        [ValidateSet ("TW_POSITIVE_TIME_WINDOW", "TW_PLUS_OR_MINUS_TIME_WINDOW")]
        [string]$time_window_type,
        [Parameter (Mandatory = $false)]
        [ValidateRange (0, 65535)]
        [int]$time_window,
        [Parameter (Mandatory = $false)]
        [switch]$is_oobm,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/radius_servers/${id}"

        $conf = New-Object -TypeName PSObject

        $ip = New-Object -TypeName PSObject

        if ($PsBoundParameters.ContainsKey('address')) {
            $ip = New-Object -TypeName PSObject

            $ip | Add-Member -name "version" -MemberType NoteProperty -Value "IAV_IP_V4"

            $ip | Add-Member -name "octets" -MemberType NoteProperty -Value $address

            $conf | Add-Member -name "address" -membertype NoteProperty -Value $ip
        }

        if ($PsBoundParameters.ContainsKey('shared_secret')) {
            $conf | Add-Member -name "shared_secret" -MemberType NoteProperty -Value $shared_secret
        }

        if ($PsBoundParameters.ContainsKey('authentication_port')) {
            $conf | Add-Member -name "authentication_port" -membertype NoteProperty -Value $authentication_port
        }

        if ($PsBoundParameters.ContainsKey('accounting_port')) {
            $conf | Add-Member -name "accounting_port" -membertype NoteProperty -Value $accounting_port
        }

        if ( $PsBoundParameters.ContainsKey('is_dyn_authorization_enabled') ) {
            if ( $is_dyn_authorization_enabled ) {
                $conf | Add-Member -name "is_dyn_authorization_enabled" -membertype NoteProperty -Value $true
            }
            else {
                $conf | Add-Member -name "is_dyn_authorization_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ($PsBoundParameters.ContainsKey('time_window_type')) {
            $conf | Add-Member -name "time_window_type" -membertype NoteProperty -Value $time_window_type
        }

        if ($PsBoundParameters.ContainsKey('time_window')) {
            $conf | Add-Member -name "time_window" -membertype NoteProperty -Value $time_window
        }

        if ( $PsBoundParameters.ContainsKey('is_oobm') ) {
            if ( $is_oobm ) {
                $conf | Add-Member -name "is_oobm" -membertype NoteProperty -Value $true
            }
            else {
                $conf | Add-Member -name "is_oobm" -membertype NoteProperty -Value $false
            }
        }

        $response = Invoke-ArubaSWWebRequest -method "PUT" -body $conf -uri $uri -connection $connection

        $run = $response | ConvertFrom-Json

        $run
    }

    End {
    }
}
    

function Remove-ArubaSWRadius {

    <#
        .SYNOPSIS
        Remove a RADIUS server.

        .DESCRIPTION
        Remove a RADIUS server parameters.

        .EXAMPLE
        Remove-ArubaSWRadius -id 1 -noconfirm

        Remove the radius server with ID 1.
    #>

    Param(
        [Parameter (Mandatory = $false)]
        [ValidateRange (1, 15)]
        [int]$id,
        [Parameter (Mandatory = $false)]
        [string]$address,
        [Parameter(Mandatory = $false)]
        [switch]$noconfirm,
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        if ($PsBoundParameters.ContainsKey('address')) {
            $radius = Get-ArubaSWRadius -address $address
            $id = $radius.radius_server_id
        }

        $uri = "rest/v4/radius_servers/${id}"

        if ( -not ( $Noconfirm )) {
            $message = "Remove RADIUS Server on switch"
            $question = "Proceed with removal of RADIUS server $id ?"
            $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

            $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
        }
        else { $decision = 0 }
        if ($decision -eq 0) {
            Write-Progress -activity "Remove RADIUS Server"
            $null = Invoke-ArubaSWWebRequest -method "DELETE" -uri $uri -connection $connection
            Write-Progress -activity "Remove RADIUS Server" -completed
        }
    }
    

    End {
    }
}
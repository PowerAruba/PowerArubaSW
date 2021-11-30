#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWLLDPRemote {

    <#
        .SYNOPSIS
        Get LLDP information about remote devices connected to the switch you are log on.

        .DESCRIPTION
        Get lldp informations about the remote devices.

        .EXAMPLE
        Get-ArubaSWLLDPRemote

        Get all the informations about the remote devices connected to the ports of the switch you are log on.

        .EXAMPLE
        Get-ArubaSWLLDPRemote -port_id 5

        Get LLDP neighbor informations on port 5
    #>

    Param(
        [Parameter (Mandatory = $false, Position = 1)]
        [string]$port_id,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )
    Begin {
    }

    Process {

        $uri = "rest/v4/lldp/remote-device"

        if ($port_id) {
            $uri += "/$port_id"
        }

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $run = ($response.content | ConvertFrom-Json)

        if ($port_id) {
            $run
        }
        else {
            $run.lldp_remote_device_element
        }
    }

    End {
    }
}

function Get-ArubaSWLLDPGlobalStatus {

    <#
        .SYNOPSIS
        Get information about LLDP global status.

        .DESCRIPTION
        Get lldp informations.

        .EXAMPLE
        Get-ArubaSWLLDPGlobalStatus
        Get all the informations about the global status of LLDP.
    #>

    Param(
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/lldp"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $run = $response | ConvertFrom-Json

        $run
    }

    End {
    }
}

function Set-ArubaSWLLDPGlobalStatus {

    <#
        .SYNOPSIS
        Set global configuration about LLDP

        .DESCRIPTION
        Set lldp global parameters

        .EXAMPLE
        Set-ArubaSWLLDPGlobalStatus -transmit 400
        Set the transmit interval to 400.

        .EXAMPLE
        Set-ArubaSWLLDPGlobalStatus -enable:$false -holdtime 10 -faststart 1
        Set LLDP disable and configure holdtime to 10 and faststart to 1
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $false)]
        [switch]$enable,
        [Parameter (Mandatory = $false)]
        [ValidateRange (8, 32768)]
        [int]$transmit,
        [Parameter (Mandatory = $false)]
        [ValidateRange (2, 10)]
        [int]$holdtime,
        [Parameter (Mandatory = $false)]
        [ValidateRange (1, 10)]
        [int]$faststart,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/lldp"

        $conf = New-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('enable') ) {
            if ( $enable ) {
                $enable_status = "LLAS_ENABLED"
            }
            else {
                $enable_status = "LLAS_DISABLED"
            }

            $conf | Add-Member -name "admin_status" -membertype NoteProperty -Value $enable_status
        }

        if ( $PsBoundParameters.ContainsKey('transmit') ) {
            $conf | Add-Member -name "transmit_interval" -membertype NoteProperty -Value $transmit
        }

        if ( $PsBoundParameters.ContainsKey('holdtime') ) {
            $conf | Add-Member -name "hold_time_multiplier" -membertype NoteProperty -Value $holdtime
        }

        if ( $PsBoundParameters.ContainsKey('faststart') ) {
            $conf | Add-Member -name "fast_start_count" -membertype NoteProperty -Value $faststart
        }

        $response = Invoke-ArubaSWWebRequest -method "PUT" -body $conf -uri $uri -connection $connection

        if ($PSCmdlet.ShouldProcess("", 'Configure LLDP Global Status')) {
            $run = $response | ConvertFrom-Json

            $run
        }
    }

    End {
    }
}

function Get-ArubaSWLLDPNeighborStats {

    <#
        .SYNOPSIS
        Get information about LLDP neighbor stats

        .DESCRIPTION
        Get lldp neighbor stats informations

        .EXAMPLE
        Get-ArubaSWLLDPNeighborStats
        Get all the informations about the neighbor stats
    #>

    Param(
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/lldp/stats/device"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $run = $response | ConvertFrom-Json

        $run
    }

    End {
    }
}

function Get-ArubaSWLLDPPortStats {

    <#
        .SYNOPSIS
        Get information about LLDP port stats

        .DESCRIPTION
        Get lldp port stats informations

        .EXAMPLE
        Get-ArubaSWLLDPPortStats
        Gat all the LLDP stats informations about all the ports.

        .EXAMPLE
        Get-ArubaSWLLDPPortStats -port 5
        Get all the LLDP stats informations about the port 5
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'port', Justification = 'False positive see PSSA #1472')]
    Param(
        [Parameter (Mandatory = $false, ParameterSetName = "port")]
        [string]$port,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/lldp/stats/ports"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $run = ($response | ConvertFrom-Json).lldp_port_stats_element

        switch ( $PSCmdlet.ParameterSetName ) {
            "port" { $run | Where-Object { $_.port_name -match $port } }
            default { $run }
        }
    }

    End {
    }
}

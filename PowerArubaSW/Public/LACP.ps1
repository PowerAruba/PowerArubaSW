#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWLACP {

    <#
        .SYNOPSIS
        Get LACP information about the ports in a lacp configuration on ArubaOS Switch.

        .DESCRIPTION
        Get the list of all ports in a lacp configuration.

        .EXAMPLE
        Get-ArubaSWLACP

        Get the list of ports in a lacp configuration with the link aggregation interface and the name of ports in this interface.
    #>

    param(
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )
    Begin {
    }

    Process {

        $uri = "lacp/port"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $run = ($response | ConvertFrom-Json).lacp_element

        $run
    }

    End {
    }
}

function Add-ArubaSWLACP {

    <#
        .SYNOPSIS
        Add ports into a lacp configuration on ArubaOS Switch.

        .DESCRIPTION
        Add ports in a lacp trunk group.

        .EXAMPLE
        Add-ArubaSWLACP trk2 3

        Add port 3 in trunk group trk2.

        .EXAMPLE
        Add-ArubaSWLACP -trunk_group trk3 -port 5

        Add port 5 in lacp trunk group trk3.

        .EXAMPLE
        Add-ArubaSWLACP -trunk_group trk6 -port 3
        PS C:\>Add-ArubaSWLACP -trunk_group trk6 -port 5

        Configure ports 3 and 5 in trunk group 6
    #>

    Param(
        [Parameter (Mandatory = $true, Position = 1)]
        [string]$trunk_group,
        [Parameter (Mandatory = $true, Position = 2)]
        [string]$port,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "lacp/port"

        $lacp = New-Object -TypeName PSObject

        $lacp | Add-Member -name "port_id" -membertype NoteProperty -Value $port

        $lacp | Add-Member -name "trunk_group" -membertype NoteProperty -Value $trunk_group

        $response = Invoke-ArubaSWWebRequest -method "POST" -body $lacp -uri $uri -connection $connection

        $run = $response | ConvertFrom-Json

        $run

    }

    End {
    }
}

function Remove-ArubaSWLACP {

    <#
        .SYNOPSIS
        Remove a port from a lacp trunk group on ArubaOS Switch.

        .DESCRIPTION
        Remove port of the lacp trunk group.

        .EXAMPLE
        Remove-ArubaSWLACP -trunk_group trk6 -port 3

        Remove port 3 of the lacp trunk group trk6.

        .EXAMPLE
        Remove-ArubaSWLACP -trunk_group trk6 -port 3 -confirm:$false
        PS C:\>Remove-ArubaSWLACP -trunk_group trk6 -port 5 -confirm:$false

        Remove ports 3 and 5 in trunk group 6 without confirmation.
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, Position = 1)]
        [string]$trunk_group,
        [Parameter (Mandatory = $true, Position = 2)]
        [string]$port,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $lacp = New-Object -TypeName PSObject

        $lacp | Add-Member -name "port_id" -membertype NoteProperty -Value $port

        $lacp | Add-Member -name "trunk_group" -membertype NoteProperty -Value $trunk_group

        $id = $lacp.port_id

        $uri = "lacp/port/${id}"

        if ($PSCmdlet.ShouldProcess($id, 'Remove LACP')) {
            $null = Invoke-ArubaSWWebRequest -method "DELETE" -body $lacp -uri $uri -connection $connection
        }
    }

    End {
    }
}

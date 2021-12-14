#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2018, Cedric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWTrunk {

    <#
        .SYNOPSIS
        Get Trunk information about the ports in a trunk configuration on ArubaOS Switch.

        .DESCRIPTION
        Get the list of all ports in a trunk configuration.

        .EXAMPLE
        Get-ArubaSWTrunk

        Get the list of ports in a trunk configuration with the link aggregation interface and the name of ports in this interface.
    #>

    Param(
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )
    Begin {
    }

    Process {

        $uri = "trunk/port"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $run = ($response | ConvertFrom-Json).trunk_element

        $run

    }

    End {
    }
}

function Add-ArubaSWTrunk {

    <#
        .SYNOPSIS
        Add ports into a trunk configuration on ArubaOS Switch.

        .DESCRIPTION
        Add ports in a trunk group.

        .EXAMPLE
        Add-ArubaSWTrunk trk5 4

        Add port 4 in trunk group trk5

        .EXAMPLE
        Add-ArubaSWTrunk -trunk_group trk4 -port 6

        Add port 6 in trunk group trk4.

        .EXAMPLE
        Add-ArubaSWTrunk -trunk_group trk6 -port 3
        PS C:\>Add-ArubaSWTrunk -trunk_group trk6 -port 5

        Configure ports 3 and 5 in trunk group 6.
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

        $uri = "trunk/port"

        $trunk = New-Object -TypeName PSObject

        $trunk | Add-Member -name "port_id" -membertype NoteProperty -Value $port

        $trunk | Add-Member -name "trunk_group" -membertype NoteProperty -Value $trunk_group

        $response = Invoke-ArubaSWWebRequest -method "POST" -body $trunk -uri $uri -connection $connection

        $run = $response | ConvertFrom-Json

        $run

    }

    End {
    }
}

function Remove-ArubaSWTrunk {

    <#
        .SYNOPSIS
        Remove a port from a trunk group on ArubaOS Switch

        .DESCRIPTION
        Remove port of the trunk group

        .EXAMPLE
        Remove-ArubaSWTrunk -trunk_group trk4 -port 5
        Remove port 5 of the trunk group trk4.

        .EXAMPLE
        Remove-ArubaSWTrunk -trunk_group -port 3 trk6 -noconfirm
        PS C:\>Remove-ArubaSWTrunk -trunk_group trk6 -port 5 -noconfirm

        Remove ports 3 and 5 in trunk group 6 without confirm
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

        $trunk = New-Object -TypeName PSObject

        $trunk | Add-Member -name "port_id" -membertype NoteProperty -Value $port

        $trunk | Add-Member -name "trunk_group" -membertype NoteProperty -Value $trunk_group

        $id = $trunk.port_id

        $uri = "trunk/port/${id}"

        if ($PSCmdlet.ShouldProcess($id, 'Remove Trunk')) {
            $null = Invoke-ArubaSWWebRequest -method "DELETE" -body $trunk -uri $uri -connection $connection
        }
    }

    End {
    }
}

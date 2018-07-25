#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, C�dric Moreau <moreaucedric0 at gmail dot com>
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
        This function give you the list of ports in a lacp configuration with the link aggregation interface and the name of ports in this interface.
    #>

    Begin {
    }

    Process {

        $url = "rest/v4/lacp/port"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $run = ($response | convertfrom-json).lacp_element

        foreach ($run in $run)
        {
            $status = [pscustomobject]@{
            LocalPort  = $run.port_id
            TrunkGroup = $run.trunk_group
            }

            $status
        }
    }

    End {
    }
}

function Add-ArubaSWLACP {

    <#
        .SYNOPSIS
        Add ports into a lacp configuration on ArubaOS Switch.

        .DESCRIPTION
        Add ports in a lacp interface.

        .EXAMPLE
        Add-ArubaSWLACP <port> <interface>
        This function allow you to add port in a lacp configuration with the name of the lacp interface and the name of the port.

        .EXAMPLE
        Add-ArubaSWLACP -port [X] -interface [trkY]
        This function allow you to add port in a lacp interface with the parameter "interface" for the name of the lacp interface (examples : trk1, trk2 ....)
        and "port" for the name of the port that you want to add to this lacp interface.

        .EXAMPLE
        If you want to configure ports 3 and 5 in trunk group 6 :
        Add-ArubaSWLACP -port 3 -interface trk6
        Add-ArubaSWLACP -port 5 -interface trk6
        OR
        Add-ArubaSWLACP 3 trk6
        Add-ArubaSWLACP 5 trk6
    #>

    Param(
    [Parameter (Mandatory=$true, Position=1)]
    [string]$port,
    [Parameter (Mandatory=$true, Position=2)]
    [string]$interface
    )

    Begin {
    }

    Process {

        $url = "rest/v4/lacp/port"

        $lacp = new-Object -TypeName PSObject

        $lacp | add-member -name "port_id" -membertype NoteProperty -Value $port

        $lacp | add-member -name "trunk_group" -membertype NoteProperty -Value $interface

        $response = invoke-ArubaSWWebRequest -method "POST" -body $lacp -url $url

        $run = $response | convertfrom-json

        $status = [pscustomobject]@{
        LocalPort  = $run.port_id
        TrunkGroup = $run.trunk_group
        }

        $status

    }

    End {
    }
}

function Remove-ArubaSWLACP {

    <#
        .SYNOPSIS
        Remove a port from a lacp interface on ArubaOS Switch

        .DESCRIPTION
        Remove port of the lacp interface

        .EXAMPLE
        Remove-ArubaSWLACP -port [X] -interface [trkY]
        Remove port X of the lacp interface trkY.

        .EXAMPLE
        If you want to remove ports 3 and 5 in trunk group 6 :
        Remove-ArubaSWLACP -port 3 -interface trk6
        Remove-ArubaSWLACP -port 5 -interface trk6
        OR
        Remove-ArubaSWLACP 3 trk6
        Remove-ArubaSWLACP 5 trk6
    #>

    Param(
        [Parameter (Mandatory=$true, Position=1)]
        [string]$port,
        [Parameter (Mandatory=$true, Position=2)]
        [string]$interface
    )

    Begin {
    }

    Process {

        $lacp = new-Object -TypeName PSObject

        $lacp | add-member -name "port_id" -membertype NoteProperty -Value $port

        $lacp | add-member -name "trunk_group" -membertype NoteProperty -Value $interface

        $id = $lacp.port_id

        $url = "rest/v4/lacp/port/${id}"

        invoke-ArubaSWWebRequest -method "DELETE" -body $lacp -url $url

    }

    End {
    }
}
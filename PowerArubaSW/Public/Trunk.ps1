#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, C�dric Moreau <moreaucedric0 at gmail dot com>
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
        This function give you the list of ports in a trunk configuration with the link aggregation interface and the name of ports in this interface.
    #>

    Begin {
    }

    Process {

        $url = "rest/v4/trunk/port"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $run = ($response | convertfrom-json).trunk_element

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

function Add-ArubaSWTrunk {

    <#
        .SYNOPSIS
        Add ports into a trunk configuration on ArubaOS Switch.

        .DESCRIPTION
        Add ports in a trunk interface.

        .EXAMPLE
        Add-ArubaSWTrunk <port> <interface>
        This function allow you to add port in a trunk configuration with the name of the trunk interface and the name of the port.

        .EXAMPLE
        Add-ArubaSWTrunk -port [X] -interface [trkY]
        This function allow you to add port in a trunk interface with the parameter "interface" for the name of the trunk interface (examples : trk1, trk2 ....)
        and "port" for the name of the port that you want to add to this trunk interface.

        .EXAMPLE
        If you want to configure ports 3 and 5 in trunk group 6 :
        Add-ArubaSWTrunk -port 3 -interface trk6
        Add-ArubaSWTrunk -port 5 -interface trk6
        OR
        Add-ArubaSWTrunk 3 trk6
        Add-ArubaSWTrunk 5 trk6
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

        $url = "rest/v4/trunk/port"

        $trunk = new-Object -TypeName PSObject

        $trunk | add-member -name "port_id" -membertype NoteProperty -Value $port

        $trunk | add-member -name "trunk_group" -membertype NoteProperty -Value $interface

        $response = invoke-ArubaSWWebRequest -method "POST" -body $trunk -url $url

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

function Remove-ArubaSWTrunk {

    <#
        .SYNOPSIS
        Remove a port from a trunk interface on ArubaOS Switch

        .DESCRIPTION
        Remove port of the trunk interface

        .EXAMPLE
        Remove-ArubaSWTrunk -port [X] -interface [trkY]
        Remove port X of the trunk interface trkY.

        .EXAMPLE
        If you want to remove ports 3 and 5 in trunk group 6 :
        Remove-ArubaSWTrunk -port 3 -interface trk6
        Remove-ArubaSWTrunk -port 5 -interface trk6
        OR
        Remove-ArubaSWTrunk 3 trk6
        Remove-ArubaSWTrunk 5 trk6
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

        $trunk = new-Object -TypeName PSObject

        $trunk | add-member -name "port_id" -membertype NoteProperty -Value $port

        $trunk | add-member -name "trunk_group" -membertype NoteProperty -Value $interface

        $id = $trunk.port_id

        $url = "rest/v4/trunk/port/${id}"

        $response = invoke-ArubaSWWebRequest -method "DELETE" -body $trunk -url $url

        Write-Host "The port $port has been removed from the trunk group $interface !"

    }

    End {
    }
}
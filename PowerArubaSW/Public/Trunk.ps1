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
        Add-ArubaSWTrunk <port> <trunk_group>
        Add port in a trunk configuration with the name of the trunk group and the name of the port.

        .EXAMPLE
        Add-ArubaSWTrunk -trunk_group [trkY] -port [X]
        Add port in a trunk group with the parameter "trunk_group" for the name of the trunk group (examples : trk1, trk2 ....)
        and "port" for the name of the port that you want to add to this trunk group.

        .EXAMPLE
        Add-ArubaSWTrunk -trunk_group trk6 -port 3
        PS C:>Add-ArubaSWTrunk -trunk_group trk6 -port 5
        OR
        Add-ArubaSWTrunk trk6 3
        PS C:>Add-ArubaSWTrunk trk6 5
        If you want to configure ports 3 and 5 in trunk group 6
    #>

    Param(
    [Parameter (Mandatory=$true, Position=1)]
    [string]$port,
    [Parameter (Mandatory=$true, Position=2)]
    [string]$trunk_group
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
        Remove-ArubaSWTrunk -port [X] -trunk_group [trkY]
        Remove port X of the trunk group trkY.

        .EXAMPLE
        
        Remove-ArubaSWTrunk -port 3 -trunk_group trk6 -noconfirm
        PS C:>Remove-ArubaSWTrunk -port 5 -trunk_group trk6 -noconfirm
        OR
        Remove-ArubaSWTrunk 3 trk6 -noconfirm
        PS C:>Remove-ArubaSWTrunk 5 trk6 -noconfirm
        If you want to remove ports 3 and 5 in trunk group 6 without confirm
    #>

    Param(
        [Parameter (Mandatory=$true, Position=1)]
        [string]$port,
        [Parameter (Mandatory=$true, Position=2)]
        [string]$trunk_group,
        [Parameter(Mandatory = $false)]
        [switch]$noconfirm
    )

    Begin {
    }

    Process {

        $trunk = new-Object -TypeName PSObject

        $trunk | add-member -name "port_id" -membertype NoteProperty -Value $port

        $trunk | add-member -name "trunk_group" -membertype NoteProperty -Value $interface

        $id = $trunk.port_id

        $url = "rest/v4/trunk/port/${id}"

        if ( -not ( $Noconfirm )) {
            $message  = "Remove trunk group on switch"
            $question = "Proceed with removal of trunk group ${id} ?"
            $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

            $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
        }
        else { $decision = 0 }
        if ($decision -eq 0) {
            Write-Progress -activity "Remove trunk group"
            $null = Invoke-ArubaSWWebRequest -method "DELETE" -body $trunk -url $url
            Write-Progress -activity "Remove trunk group" -completed
        }
    }

    End {
    }
}
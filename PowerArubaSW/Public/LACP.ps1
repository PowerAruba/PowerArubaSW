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
        Add-ArubaSWLACP <port> <trunk_group>
        This function allow you to add port in a lacp configuration with the name of the lacp interface and the name of the port.

        .EXAMPLE
        Add-ArubaSWLACP -port [X] -trunk_groupe [trkY]
        This function allow you to add port in a lacp trunk group with the parameter "trunk_group" for the name of the lacp trunkgroup (examples : trk1, trk2 ....)
        and "port" for the name of the port that you want to add to this lacp trunk group.

        .EXAMPLE
        Add-ArubaSWLACP -trunk_group trk6 -port 3
        PS C:>Add-ArubaSWLACP -trunk_group trk6 -port 5
        OR
        Add-ArubaSWLACP trk6 3
        PS C:>Add-ArubaSWLACP trk6 5
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

        $url = "rest/v4/lacp/port"

        $lacp = new-Object -TypeName PSObject

        $lacp | add-member -name "port_id" -membertype NoteProperty -Value $port

        $lacp | add-member -name "trunk_group" -membertype NoteProperty -Value $trunk_group

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
        Remove a port from a lacp trunk group on ArubaOS Switch

        .DESCRIPTION
        Remove port of the lacp trunk group

        .EXAMPLE
        Remove-ArubaSWLACP -trunk_group [trkY] -port [X]
        Remove port X of the lacp trunk group trkY.

        .EXAMPLE
        If you want to remove ports 3 and 5 in trunk group 6 :
        Remove-ArubaSWLACP -trunk_group trk6 -port 3
        PS C:>Remove-ArubaSWLACP -trunk_group trk6 -port 5
        OR
        Remove-ArubaSWLACP trk6 3
        PS C:>Remove-ArubaSWLACP trk6 5
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

        $lacp = new-Object -TypeName PSObject

        $lacp | add-member -name "port_id" -membertype NoteProperty -Value $port

        $lacp | add-member -name "trunk_group" -membertype NoteProperty -Value $trunk_group

        $id = $lacp.port_id

        $url = "rest/v4/lacp/port/${id}"

        if ( -not ( $Noconfirm )) {
            $message  = "Remove LACP on switch"
            $question = "Proceed with removal of lacp ${id} ?"
            $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

            $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
        }
        else { $decision = 0 }
        if ($decision -eq 0) {
            Write-Progress -activity "Remove LACP"
            $null = Invoke-ArubaSWWebRequest -method "DELETE" -body $lacp -url $url
            Write-Progress -activity "Remove LACP" -completed
        }
    }

    End {
    }
}
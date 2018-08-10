#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
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
        [Parameter (Mandatory=$true, Position=1)]
        [string]$trunk_group,
        [Parameter (Mandatory=$true, Position=2)]
        [string]$port
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
        Remove-ArubaSWLACP -trunk_group trk6 -port 3 -noconfirm
        PS C:\>Remove-ArubaSWLACP -trunk_group trk6 -port 5 -noconfirm

        Remove ports 3 and 5 in trunk group 6 without confirmation.
    #>

    Param(
        [Parameter (Mandatory=$true, Position=1)]
        [string]$trunk_group,
        [Parameter (Mandatory=$true, Position=2)]
        [string]$port,
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
            $question = "Proceed with removal of LACP ${id} ?"
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
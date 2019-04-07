#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
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

    Begin {
    }

    Process {

        $url = "rest/v4/trunk/port"

        $response = Invoke-ArubaSWWebRequest -method "GET" -url $url

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
        [string]$port

    )

    Begin {
    }

    Process {

        $url = "rest/v4/trunk/port"

        $trunk = New-Object -TypeName PSObject

        $trunk | Add-Member -name "port_id" -membertype NoteProperty -Value $port

        $trunk | Add-Member -name "trunk_group" -membertype NoteProperty -Value $trunk_group

        $response = Invoke-ArubaSWWebRequest -method "POST" -body $trunk -url $url

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

    Param(
        [Parameter (Mandatory = $true, Position = 1)]
        [string]$trunk_group,
        [Parameter (Mandatory = $true, Position = 2)]
        [string]$port,
        [Parameter(Mandatory = $false)]
        [switch]$noconfirm
    )

    Begin {
    }

    Process {

        $trunk = New-Object -TypeName PSObject

        $trunk | Add-Member -name "port_id" -membertype NoteProperty -Value $port

        $trunk | Add-Member -name "trunk_group" -membertype NoteProperty -Value $trunk_group

        $id = $trunk.port_id

        $url = "rest/v4/trunk/port/${id}"

        if ( -not ( $Noconfirm )) {
            $message = "Remove trunk group on switch"
            $question = "Proceed with removal of trunk group $trunk_group on port $port ?"
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
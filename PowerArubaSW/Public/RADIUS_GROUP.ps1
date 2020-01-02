#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWRadiusGroup {

    <#
        .SYNOPSIS
        Get RADIUS group informations.

        .DESCRIPTION
        Get RADIUS group informations configured on the device.

        .EXAMPLE
        Get-ArubaSWRadiusGroup -server_group_name PowerArubaSW

        This function give you all the informations about the radius servers in the group PowerArubaSW configured on the switch.
    #>

    Param(
        [Parameter (Mandatory = $true)]
        [string]$server_group_name,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/radius/server_group/${server_group_name}"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $run = ($response | ConvertFrom-Json)

        $run
    }

    End {
    }
}

function Add-ArubaSWRadiusGroup {

    <#
        .SYNOPSIS
        Add a RADIUS server group.

        .DESCRIPTION
        Add a RADIUS server group with radius servers.

        .EXAMPLE
        Add-ArubaSWRadiusGroup -server_group_name PowerArubaSWGroup -server1 192.0.2.1 -server2 192.0.2.2 -server3 192.0.2.3

        Add the group PowerArubaSWGroup with servers.
    #>

    Param(
        [Parameter (Mandatory = $true)]
        [string]$server_group_name,
        [Parameter (Mandatory = $true)]
        [ipaddress]$server1,
        [Parameter (Mandatory = $false)]
        [ipaddress]$server2,
        [Parameter (Mandatory = $false)]
        [ipaddress]$server3,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/radius/server_group"

        $conf = New-Object -TypeName PSObject

        $serverip1 = New-Object -TypeName PSObject

        $servers = @()

        $serverip1 | Add-Member -name "version" -MemberType NoteProperty -Value "IAV_IP_V4"

        $serverip1 | Add-Member -name "octets" -MemberType NoteProperty -Value $server1.ToString()

        $servers += $serverip1

        if ($PsBoundParameters.ContainsKey('server2')) {
            $serverip2 = New-Object -TypeName PSObject

            $serverip2 | Add-Member -name "version" -MemberType NoteProperty -Value "IAV_IP_V4"

            $serverip2 | Add-Member -name "octets" -MemberType NoteProperty -Value $server2.ToString()

            $servers += $serverip2
        }

        if ($PsBoundParameters.ContainsKey('server3')) {
            $serverip3 = New-Object -TypeName PSObject

            $serverip3 | Add-Member -name "version" -MemberType NoteProperty -Value "IAV_IP_V4"

            $serverip3 | Add-Member -name "octets" -MemberType NoteProperty -Value $server3.ToString()

            $servers += $serverip3
        }

        $conf | Add-Member -name "server_ip" -Membertype NoteProperty -Value $servers

        $conf | Add-Member -name "server_group_name" -MemberType NoteProperty -Value $server_group_name

        $response = Invoke-ArubaSWWebRequest -method "POST" -body $conf -uri $uri -connection $connection

        $run = $response | ConvertFrom-Json

        $run
    }

    End {
    }
}

function Remove-ArubaSWRadiusGroup {

    <#
        .SYNOPSIS
        Remove a RADIUS GROUP server.

        .DESCRIPTION
        Remove a RADIUS GROUP server.

        .EXAMPLE
        Remove-ArubaSWRadius -server_group_name PowerArubaSW

        Remove the radius server group with name PowerArubaSW.
    #>

    Param(
        [Parameter (Mandatory = $true)]
        [string]$server_group_name,
        [Parameter(Mandatory = $false)]
        [switch]$noconfirm,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/radius/server_group/${server_group_name}"

        if ( -not ( $Noconfirm )) {
            $message = "Remove RADIUS Server Group on switch"
            $question = "Proceed with removal of RADIUS server Group $server_group_name ?"
            $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

            $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
        }
        else { $decision = 0 }
        if ($decision -eq 0) {
            Write-Progress -activity "Remove RADIUS Server Group"
            $null = Invoke-ArubaSWWebRequest -method "DELETE" -uri $uri -connection $connection
            Write-Progress -activity "Remove RADIUS Server Group" -completed
        }
    }


    End {
    }
}
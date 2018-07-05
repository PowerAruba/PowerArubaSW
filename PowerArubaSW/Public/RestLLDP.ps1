#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWRestLLDP {

    <#
        .SYNOPSIS
        Get LLDP information about remote devices connected to the switch you are log on

        .DESCRIPTION
        Get lldp informations about the remote devices

        .EXAMPLE
        Get-ArubaSWRestLLDP
        This function give you all the informations about the remote devices connected to the ports of the switch you are log on 
    #>

    Begin {
    }

    Process {

        $url = "rest/v4/lldp/remote-device"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $run = ($response | convertfrom-json).lldp_remote_device_element

        $lldp = [pscustomobject]@{
        LocalPort  = $run.local_port 
        RemotePort = $run.port_id 
        SystemName = $run.system_name
        PortDescription = $run.port_description
        }

        $lldp
    }

    End {
    }
}
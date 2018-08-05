#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWPort {

    <#
        .SYNOPSIS
        Get Port of the Switch

        .DESCRIPTION
        Get Portinformation

        .EXAMPLE
        Get-ArubaSWPort

        Get Port information (name, status, config mode, flow control...)

        .EXAMPLE
        Get-ArubaSWPort -port_id 3

        Get Port information of port_id 3
    #>

    Param(
        [Parameter (Mandatory=$false)]
        [string]$port_id
    )

    Begin {
    }

    Process {

        $url = "rest/v4/ports"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $run = ($response | convertfrom-json).port_element

        if ( $port_id ) {
            $run | where-object { $_.id -match $port_id}
        } else {
            $run
        }

    }

    End {
    }
}


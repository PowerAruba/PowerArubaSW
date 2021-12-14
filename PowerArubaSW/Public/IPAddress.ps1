#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWIpAddress {

    <#
        .SYNOPSIS
        Get IP Address information.

        .DESCRIPTION
        Get IP Address(es) information about the device

        .EXAMPLE
        Get-ArubaSWIPAddress
        This function give you all the informations about the ip parameters configured on the switch
    #>

    Param(
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "ipaddresses"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $run = ($response | ConvertFrom-Json)

        $run.ip_address_subnet_element
    }

    End {
    }
}

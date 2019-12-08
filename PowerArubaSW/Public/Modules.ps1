#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWModules {

    <#
        .SYNOPSIS
        Get list of modules from ArubaOS Switch (Provision)

        .DESCRIPTION
        Get list of modules (Slot, description, serial number, version...)

        .EXAMPLE
        Get-ArubaSWModules

        Get modules information

    #>

    Param(
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )
    Begin {
    }

    Process {

        $uri = "rest/v4/modules"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        ($response.content | ConvertFrom-Json)
    }

    End {
    }
}

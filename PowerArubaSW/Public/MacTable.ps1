#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWMacTable {

    <#
        .SYNOPSIS
        Get Mac Table information.

        .DESCRIPTION
        Get Mac Table information about the device

        .EXAMPLE
        Get-ArubaSWMacTable

        Get Mac Table (ARP) with mac_address, port_id and vlan_id
    #>

    Param(
        [Parameter (Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection=$DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/mac-table"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $run = ($response | ConvertFrom-Json)

        $run.mac_table_entry_element
    }

    End {
    }
}

#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Test-ArubaSWPing {

    <#
        .SYNOPSIS
        Send a PING (ICMP) to a target

        .DESCRIPTION
        Send a PING (ICMP) to a target
        Get the status and latency

        .EXAMPLE
        Test-ArubaSWPing -ipv4_address 192.2.0.1

        Send a PING to IPv4 address 192.2.0.1
    #>

    Param(
        [Parameter (Mandatory = $false, ParameterSetName = "ipv4_address")]
        [ipaddress]$ipv4_address,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $dest = New-Object -TypeName PSObject

        if ($PsBoundParameters.ContainsKey('ipv4_address')) {
            $uri = "rest/v4/ping"

            $ipv4 = New-Object -TypeName PSObject
            $ipv4 | Add-Member -name "version" -MemberType NoteProperty -Value "IAV_IP_V4"

            $ipv4 | Add-Member -name "octets" -MemberType NoteProperty -Value $ipv4_address

            $dest | Add-Member -name "ip_address" -membertype NoteProperty -Value $ipv4
        } else {
            throw "You need to use a parameter (-ipv4_address)"
        }

        $ping = New-Object -TypeName PSObject
        $ping | Add-Member -name "destination" -membertype NoteProperty -Value $dest

        $response = Invoke-ArubaSWWebRequest -method "POST" -body $ping -uri $uri -connection $connection

        $run = ($response | ConvertFrom-Json)
        $run
    }

    End {
    }
}

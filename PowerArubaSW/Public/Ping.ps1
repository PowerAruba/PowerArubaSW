#
# Copyright 2018-2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
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

        .EXAMPLE
        Test-ArubaSWPing -hostname www.arubanetworks.com

        Send a PING to hostname www.arubanetworks.com
    #>

    Param(
        [Parameter (Mandatory = $false, ParameterSetName = "ipv4_address")]
        [ipaddress]$ipv4_address,
        [Parameter (Mandatory = $false, ParameterSetName = "hostname")]
        [string]$hostname,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/ping"
        $dest = New-Object -TypeName PSObject

        if ($PsBoundParameters.ContainsKey('ipv4_address')) {

            $ipv4 = New-Object -TypeName PSObject
            $ipv4 | Add-Member -name "version" -MemberType NoteProperty -Value "IAV_IP_V4"

            $ipv4 | Add-Member -name "octets" -MemberType NoteProperty -Value $ipv4_address.ToString()

            $dest | Add-Member -name "ip_address" -Membertype NoteProperty -Value $ipv4
        }
        elseif ($PsBoundParameters.ContainsKey('hostname')) {
            $dest | Add-Member -name "hostname" -Membertype NoteProperty -Value $hostname
        }
        else {
            throw "You need to use a parameter (-ipv4_address, -hostname)"
        }

        $ping = New-Object -TypeName PSObject
        $ping | Add-Member -name "destination" -Membertype NoteProperty -Value $dest

        $response = Invoke-ArubaSWWebRequest -method "POST" -body $ping -uri $uri -connection $connection

        $run = ($response | ConvertFrom-Json)
        $run
    }

    End {
    }
}

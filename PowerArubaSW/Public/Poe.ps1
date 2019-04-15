#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#


function Get-ArubaSWPoE {

    <#
        .SYNOPSIS
        Get PoE info about ArubaOS Switch (Provision)

        .DESCRIPTION
        Get PoE Info (Status, Priority, Allocation...)

        .EXAMPLE
        Get-ArubaSWVlans

        Get ALL PoE Settings on the switch

        .EXAMPLE
        Get-ArubaSWPoe -port 3

        Get Poe settings on port 3
    #>
    Param(
        [Parameter (Mandatory = $false, position = 1)]
        [string]$port
    )

    Begin {
    }

    Process {

        $url = "rest/v4/poe/ports"

        if ( $port ) {
            $url = "rest/v4/ports/$port/poe"
        }

        $response = Invoke-ArubaSWWebRequest -method "GET" -url $url

        $poe = ($response.Content | ConvertFrom-Json)

        if ( $port ) {
            $poe
        }
        else {
            $poe.port_poe
        }
    }

    End {
    }
}
function Set-ArubaSWPoE {

    <#
        .SYNOPSIS
        Configure PoE Settings on ArubaOS Switch (Provision)

        .DESCRIPTION
        Configure PoE Settings (Status, Priority, Allocation...)

        .EXAMPLE
        $port_poe = Get-ArubaSWPoE -port 3
        PS C:\>$port_poe | Set-ArubaSWPoE -is_poe_enabled:$disabled -priority high -poe_allocation_method class

        Configure port 3 and disable PoE with priority high and allocation method class

        .EXAMPLE
        Set-ArubaSWPoE -port_id 3 -allocated_power_in_watts 33 -pre_standard_detect_enabled:$disable

        Configure port 3 and set allocated power to 33 and disable pre_standard_detect

    #>

    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "port_id")]
        [int]$port_id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "port_poe")]
        #ValidateScript({ ValidatePoE $_ })]
        [psobject]$port_poe,
        [Parameter (Mandatory = $false)]
        [switch]$is_poe_enabled,
        [Parameter (Mandatory = $false)]
        [ValidateSet ("low", "high", "critical")]
        [string]$poe_priority,
        [Parameter (Mandatory = $false)]
        [ValidateSet ("usage", "class", "value")]
        [string]$poe_allocation_method,
        [Parameter (Mandatory = $false)]
        [ValidateRange (1,33)]
        [int]$allocated_power_in_watts,
        [Parameter (Mandatory = $false)]
        [string]$port_configured_type,
        [Parameter (Mandatory = $false)]
        [switch]$pre_standard_detect_enabled
    )

    Begin {
    }

    Process {

        #get vlan id from vlan ps object
        if ($port_poe) {
            $port_id = $port_poe.port_id
        }
        $url = "rest/v4/ports/${port_id}/poe"

        $_poe = New-Object -TypeName PSObject


        if ( $PsBoundParameters.ContainsKey('is_poe_enabled') ) {
            if ( $is_poe_enabled ) {
                $_poe | Add-Member -name "is_poe_enabled" -membertype NoteProperty -Value $true
            }
            else {
                $_poe | Add-Member -name "is_poe_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('poe_priority') ) {
            switch ( $poe_priority ) {
                low {
                    $priority = "PPP_LOW"
                }
                high {
                    $priority = "PPP_HIGH"
                }
                critical {
                    $priority = "PPP_CRITICAL"
                }
            }
            $_poe | Add-Member -name "poe_priority" -membertype NoteProperty -Value $priority
        }

        if ( $PsBoundParameters.ContainsKey('poe_allocation_method') ) {
            switch ( $poe_allocation_method ) {
                usage {
                    $allocation_method = "PPAM_USAGE"
                }
                class {
                    $allocation_method = "PPAM_CLASS"
                }
                value {
                    $allocation_method = "PPAM_VALUE"
                }
            }
            $_poe | Add-Member -name "poe_allocation_method" -membertype NoteProperty -Value $allocation_method
        }

        if ( $PsBoundParameters.ContainsKey('allocated_power_in_watts') ) {
            $_poe | Add-Member -name "allocated_power_in_watts" -membertype NoteProperty -Value $allocated_power_in_watts
        }

        if ( $PsBoundParameters.ContainsKey('port_configured_type') ) {
            $_poe | Add-Member -name "port_configured_type" -membertype NoteProperty -Value $port_configured_type
        }

        if ( $PsBoundParameters.ContainsKey('pre_standard_detect_enabled') ) {
            if ( $pre_standard_detect_enabled ) {
                $_poe | Add-Member -name "pre_standard_detect_enabled" -membertype NoteProperty -Value $true
            }
            else {
                $_poe | Add-Member -name "pre_standard_detect_enabled" -membertype NoteProperty -Value $false
            }
        }

        $response = Invoke-ArubaSWWebRequest -method "PUT" -body $_poe -url $url
        $rep_poe = ($response.Content | ConvertFrom-Json)

        $rep_poe
    }

    End {
    }
}

function Get-ArubaSWPoEStats {

    <#
        .SYNOPSIS
        Get PoE statistics about ArubaOS Switch (Provision)

        .DESCRIPTION
        Get PoE statistics (Voltage, Class ...)

        .EXAMPLE
        Get-ArubaSWPoEStats

        Get ALL PoE ports statistics on the switch

        .EXAMPLE
        Get-ArubaSWPoEstats -port 3

        Get Poe statistics on port 3
    #>
    Param(
        [Parameter (Mandatory = $false, position = 1)]
        [string]$port
    )

    Begin {
    }

    Process {

        $url = "rest/v4/poe/ports/stats"

        if ( $port ) {
            $url = "rest/v4/ports/$port/poe/stats"
        }

        $response = Invoke-ArubaSWWebRequest -method "GET" -url $url

        $poe = ($response.Content | ConvertFrom-Json)

        if ( $port ) {
            $poe
        }
        else {
            $poe.port_poe_stats
        }
    }

    End {
    }
}
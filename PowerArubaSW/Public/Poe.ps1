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
        Get-ArubaSWPoE

        Get ALL PoE Settings on the switch

        .EXAMPLE
        Get-ArubaSWPoE -port 3

        Get PoE settings on port 3
    #>
    Param(
        [Parameter (Mandatory = $false, position = 1)]
        [string]$port_id,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "poe/ports"

        if ( $port_id ) {
            $uri = "ports/$port_id/poe"
        }

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $poe = ($response.Content | ConvertFrom-Json)

        if ( $port_id ) {
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
        PS C:\>$port_poe | Set-ArubaSWPoE -is_poe_enabled:$false -poe_priority high -poe_allocation_method class

        Configure port 3 and disable PoE with priority high and allocation method class

        .EXAMPLE
        Set-ArubaSWPoE -port_id 3 -poe_allocation_method value -allocated_power_in_watts 33 -pre_standard_detect_enabled:$false

        Configure port 3 and set allocated method and allocated power to 33 (Watts) and disable pre_standard_detect

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "port_id")]
        [string]$port_id,
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
        [ValidateRange (1, 33)]
        [int]$allocated_power_in_watts,
        [Parameter (Mandatory = $false)]
        [string]$port_configured_type,
        [Parameter (Mandatory = $false)]
        [switch]$pre_standard_detect_enabled,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        #get port id from poe ps object
        if ($port_poe) {
            $port_id = $port_poe.port_id
        }
        $uri = "ports/${port_id}/poe"

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

        if ($PSCmdlet.ShouldProcess("", 'Configure Banner')) {
            $response = Invoke-ArubaSWWebRequest -method "PUT" -body $_poe -uri $uri -connection $connection
            $rep_poe = ($response.Content | ConvertFrom-Json)

            $rep_poe
        }
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

        Get PoE statistics on port 3
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    Param(
        [Parameter (Mandatory = $false, position = 1)]
        [string]$port_id,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "poe/ports/stats"

        if ( $port_id ) {
            $uri = "ports/$port_id/poe/stats"
        }

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $poe = ($response.Content | ConvertFrom-Json)

        if ( $port_id ) {
            $poe
        }
        else {
            $poe.port_poe_stats
        }
    }

    End {
    }
}
#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWLLDPRemote {

    <#
        .SYNOPSIS
        Get LLDP information about remote devices connected to the switch you are log on

        .DESCRIPTION
        Get lldp informations about the remote devices

        .EXAMPLE
        Get-ArubaSWLLDPRemote
        This function give you all the informations about the remote devices connected to the ports of the switch you are log on 
    #>

    Begin {
    }

    Process {

        $url = "rest/v4/lldp/remote-device"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $run = ($response | convertfrom-json).lldp_remote_device_element

        $run
    }

    End {
    }
}

function Get-ArubaSWLLDPGlobalStatus {

    <#
        .SYNOPSIS
        Get information about LLDP global status

        .DESCRIPTION
        Get lldp informations 

        .EXAMPLE
        Get-ArubaSWLLDPGlobalStatus
        This function give you all the informations about the global status of LLDP 
    #>

    Begin {
    }

    Process {

        $url = "rest/v4/lldp"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $run = $response | convertfrom-json

        $run
    }

    End {
    }
}

function Set-ArubaSWLLDPGlobalStatus {

    <#
        .SYNOPSIS
        Set global configuration about LLDP

        .DESCRIPTION
        Set lldp global parameters

        .EXAMPLE
        Set-ArubaLLDPGlobalStatus -transmit 400
        Set the transmit interval to 400.

        .EXAMPLE
        Set-ArubaSWLLDPGlobalStatus [-transmit <5-32768>] [-holdtime <2-10>] [-faststart <1-10>]
        Set the global parameters of LLDP : -transmit set the value of transmit interval, 
        -holdtime set the value of the hold time multiplier, and -faststart set the value of the LLDP fast start count. 
    #>

    Param(
        [Parameter (Mandatory=$false)]
        [ValidateSet ("On", "Off")]
        [string]$enable,
        [Parameter (Mandatory=$false)]
        [ValidateRange (8,32768)]
        [int]$transmit,
        [Parameter (Mandatory=$false)]
        [ValidateRange (2,10)]
        [int]$holdtime,
        [Parameter (Mandatory=$false)]
        [ValidateRange (1,10)]
        [int]$faststart
    )

    Begin {
    }

    Process {

        $url = "rest/v4/lldp"

        $conf = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('enable') )
        {
            switch( $enable ) {
                ON {
                    $enable_status = "LLAS_ENABLED"
                }
                OFF {
                    $enable_status = "LLAS_DISABLED"
                }
            }

            $conf | add-member -name "admin_status" -membertype NoteProperty -Value $enable_status
        }

        if ( $PsBoundParameters.ContainsKey('transmit') )
        {
            $conf | add-member -name "transmit_interval" -membertype NoteProperty -Value $transmit
        }

        if ( $PsBoundParameters.ContainsKey('holdtime') )
        {
            $conf | add-member -name "hold_time_multiplier" -membertype NoteProperty -Value $holdtime
        }

        if ( $PsBoundParameters.ContainsKey('faststart') )
        {
            $conf | add-member -name "fast_start_count" -membertype NoteProperty -Value $faststart
        }

        $response = invoke-ArubaSWWebRequest -method "PUT" -body $conf -url $url

        $run = $response | convertfrom-json

        $run

    }

    End {
    }
}
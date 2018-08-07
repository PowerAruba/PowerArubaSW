#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, C�dric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWSTP {

    <#
        .SYNOPSIS
        Get spanning tree information on ArubaOS Switch.

        .DESCRIPTION
        Get spanning tree configuration.

        .EXAMPLE
        Get-ArubaSWSTP
        This function give you the spanning tree configuration
    #>

    Begin {
    }

    Process {

        $url = "rest/v4/stp"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $stp = $response | convertfrom-json

        $stp
    }

    End {
    }
}

function Set-ArubaSWSTPGlobal {

    <#
        .SYNOPSIS
        Set spanning tree configuration on ArubaOS Switch.

        .DESCRIPTION
        Set spanning tree configuration.

        .EXAMPLE
        Set spanning tree -enable True -priority 7 -mode mstp
        Set the spanning tree protocol on, the priority to 7 and the mode to MSTP

        .EXAMPLE
        Set spanning tree False 4 rpvst
        Set the spanning tree protocol off, the priority to 4 and the mode to RPVST
    #>

    Param(
    [Parameter (Mandatory=$false, Position=1)]
    [ValidateSet ("On", "Off")]
    [string]$enable,
    [Parameter (Mandatory=$false, Position=2)]
    [int]$priority,
    [Parameter (Mandatory=$false, Position=3)]
    [string]$mode
    )

    Begin {
    }

    Process {

        $url = "rest/v4/stp"

        $stp = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('enable') )
        {
            switch( $enable ) {
                ON {
                    $enable_status = $true
                }
                OFF {
                    $enable_status = $false
                }
            }
            $stp | add-member -name "is_enabled" -membertype NoteProperty -Value $enable_status
        }

        if ( $PsBoundParameters.ContainsKey('priority') )
        {
            $stp | add-member -name "priority" -membertype NoteProperty -Value $priority
        }

        if ( $PsBoundParameters.ContainsKey('mode') )
        {
            If ($mode -eq "mstp")
            {
                $mode = "STM_MSTP"
            }
            If ($mode -eq "rpvst")
            {
                $mode = "STM_RPVST"
            }

            $stp | add-member -name "mode" -membertype NoteProperty -Value $mode
        }

        $response = invoke-ArubaSWWebRequest -method "PUT" -body $stp -url $url

        $run = $response | convertfrom-json

        $run

    }

    End {
    }
}
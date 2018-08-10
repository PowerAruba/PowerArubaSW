#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWSTP {

    <#
        .SYNOPSIS
        Get spanning-tree information on ArubaOS Switch.

        .DESCRIPTION
        Get spanning-tree configuration.

        .EXAMPLE
        Get-ArubaSWSTP
        This function give you the spanning-tree configuration
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

function Get-ArubaSWSTPPortStatus {

    <#
        .SYNOPSIS
        Get spanning-tree information of all ports on ArubaOS Switch.

        .DESCRIPTION
        Get spanning-tree configurationof all ports.

        .EXAMPLE
        Get-ArubaSWSTPPortStatus
        Get the spanning-tree configuration of all the ports. 
    #>

    Begin {
    }

    Process {

        $url = "rest/v4/stp/ports"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $stp = ($response | convertfrom-json).stp_port_element

        $stp
    }

    End {
    }
}

function Set-ArubaSWSTPGlobal {

    <#
        .SYNOPSIS
        Set spanning-tree configuration on ArubaOS Switch.

        .DESCRIPTION
        Set spanning-tree configuration.

        .EXAMPLE
        Set-ArubaSWSTPGlobal -enable on -priority 7 -mode mstp
        Set the spanning-tree protocol on, the priority to 7 and the mode to MSTP

        .EXAMPLE
        Set-ArubaSWSTPGlobal off 4 rpvst
        Set the spanning-tree protocol off, the priority to 4 and the mode to RPVST
    #>

    Param(
    [Parameter (Mandatory=$true, Position=1)]
    [ValidateSet ("On", "Off")]
    [string]$enable,
    [Parameter (Mandatory=$false, Position=2)]
    [ValidateRange (0,15)]
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

function Get-ArubaSWSTPPort {

    <#
        .SYNOPSIS
        Get spanning-tree information per port on ArubaOS Switch.

        .DESCRIPTION
        Get spanning-tree configuration per port.

        .EXAMPLE
        Get-ArubaSWSTPPort -port 5 
        Get the spanning-tree configuration for the port 5.
    #>

    Param(
        [Parameter (Mandatory=$true)]
        [int]$port
    )

    Begin {
    }

    Process {

        $url = "rest/v4/stp/ports/${port}"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $stp = $response | convertfrom-json

        $stp
    }

    End {
    }
}

function Set-ArubaSWSTPPort {

    <#
        .SYNOPSIS
        Set spanning-tree configuration per port on ArubaOS Switch.

        .DESCRIPTION
        Set spanning-tree configuration per port.

        .EXAMPLE
        Set-ArubaSWSTPPort -port 4 [-priority 6] [-admin_edge On] [-bpdu_protection Off] [-bpdu_filter Off] [-root_guard off]
        Set the priority to 6 for port 4, the admin edge on, and turn off bpdu protection, bpdu filter and root guard.
    #>

    Param(
    [Parameter (Mandatory=$true)]
    [string]$port,
    [Parameter (Mandatory=$false)]
    [ValidateRange (0,15)]
    [int]$priority,
    [Parameter (Mandatory=$false)]
    [ValidateSet ("On", "Off")]
    [string]$admin_edge,
    [Parameter (Mandatory=$false)]
    [ValidateSet ("On", "Off")]
    [string]$bpdu_protection,
    [Parameter (Mandatory=$false)]
    [ValidateSet ("On", "Off")]
    [string]$bpdu_filter,
    [Parameter (Mandatory=$false)]
    [ValidateSet ("On", "Off")]
    [string]$root_guard
    )

    Begin {
    }

    Process {

        $stp = new-Object -TypeName PSObject

        $stp | add-member -name "port_id" -membertype NoteProperty -Value $port

        $id = $stp.port_id

        $url = "rest/v4/stp/ports/${id}"

        if ( $PsBoundParameters.ContainsKey('priority') )
        {
            $stp | add-member -name "priority" -membertype NoteProperty -Value $priority
        }

        if ( $PsBoundParameters.ContainsKey('admin_edge') )
        {
            switch( $admin_edge ) {
                ON {
                    $admin_edge_status = $true
                }
                OFF {
                    $admin_edge_status = $false
                }
            }
            $stp | add-member -name "is_enable_admin_edge_port" -membertype NoteProperty -Value $admin_edge_status
        }

        if ( $PsBoundParameters.ContainsKey('bpdu_protection') )
        {
            switch( $bpdu_protection ) {
                ON {
                    $bpdu_protection_status = $true
                }
                OFF {
                    $bpdu_protection_status = $false
                }
            }
            $stp | add-member -name "is_enable_bpdu_protection" -membertype NoteProperty -Value $bpdu_protection_status
        }

        if ( $PsBoundParameters.ContainsKey('bpdu_filter') )
        {
            switch( $bpdu_filter ) {
                ON {
                    $bpdu_filter_status = $true
                }
                OFF {
                    $bpdu_filter_status = $false
                }
            }
            $stp | add-member -name "is_enable_bpdu_filter" -membertype NoteProperty -Value $bpdu_filter_status
        }

        if ( $PsBoundParameters.ContainsKey('root_guard') )
        {
            switch( $root_guard ) {
                ON {
                    $root_guard_status = $true
                }
                OFF {
                    $root_guard_status = $false
                }
            }
            $stp | add-member -name "is_enable_root_guard" -membertype NoteProperty -Value $root_guard_status
        }

        $response = invoke-ArubaSWWebRequest -method "PUT" -body $stp -url $url

        $run = $response | convertfrom-json

        $run

    }

    End {
    }
}
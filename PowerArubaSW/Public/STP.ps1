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

function Set-ArubaSWSTP {

    <#
        .SYNOPSIS
        Set spanning-tree configuration on ArubaOS Switch.

        .DESCRIPTION
        Set spanning-tree configuration.

        .EXAMPLE
        Set-ArubaSWSTPGlobal -enable -priority 7 -mode mstp

        Set the spanning-tree protocol on, the priority to 7 and the mode to MSTP

        .EXAMPLE
        Set-ArubaSWSTPGlobal $false 4 rpvst

        Set the spanning-tree protocol off, the priority to 4 and the mode to RPVST
    #>

    Param(
    [Parameter (Mandatory=$true, Position=1)]
    [switch]$enable,
    [Parameter (Mandatory=$false, Position=2)]
    [ValidateRange (0,15)]
    [int]$priority,
    [Parameter (Mandatory=$false, Position=3)]
    [ValidateSet ("MSTP", "RPVST")]
    [string]$mode
    )

    Begin {
    }

    Process {

        $url = "rest/v4/stp"

        $_stp = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('enable') )
        {
            if ( $enable ) {
                $_stp | add-member -name "is_enabled" -membertype NoteProperty -Value $True
            }
            else {
                $_stp | add-member -name "is_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('priority') )
        {
            $_stp | add-member -name "priority" -membertype NoteProperty -Value $priority
        }

        if ( $PsBoundParameters.ContainsKey('mode') )
        {
            switch( $mode ) {
                mstp {
                    $_mode = "STM_MSTP"
                }
                rpvst {
                    $_mode = "STM_RPVST"
                }
            }

            $_stp | add-member -name "mode" -membertype NoteProperty -Value $_mode
        }

        $response = invoke-ArubaSWWebRequest -method "PUT" -body $_stp -url $url

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
        Get-ArubaSWSTPPort

        Get the spanning-tree configuration for ALL ports.

        .EXAMPLE
        Get-ArubaSWSTPPort -port 5

        Get the spanning-tree configuration for the port 5.
    #>


    Param(
        [Parameter (Mandatory=$false)]
        [string]$port
    )

    Begin {
    }

    Process {


        $url = "rest/v4/stp/ports"

        if($port) {
            $url += "/$port"
        }

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $stp = $response | convertfrom-json
        if($port) {
            $stp
        } else {
            $stp.stp_port_element
        }
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
        $stp_port = Get-ArubaSWSTPPort -port 5
        PS C:\>$stp_port | Set-ArubaSWSTPPort -priority 4 -admin_edge:$false -bpdu_protection -bpdu_filter -root_guard

        Configure the port 5 and set the priority 4, disable admin edge, and enable bpdu protection, bpdu filter and root guard.

        .EXAMPLE
        Set-ArubaSWSTPPort -port 4 -priority 6 -admin_edge -bpdu_protection:$false -bpdu_filter:$false -root_guard:$false

        Configure the port 4 and set the priority 6, enable admin edge, and disable bpdu protection, bpdu filter and root guard.
    #>

    Param(
    [Parameter (Mandatory = $true, ParameterSetName = "port_id")]
    [string]$port,
    [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "port_stp")]
    #ValidateScript({ ValidateSTPPort $_ })]
    [psobject]$port_stp,
    [Parameter (Mandatory=$false)]
    [ValidateRange (0,15)]
    [int]$priority,
    [Parameter (Mandatory=$false)]
    [switch]$admin_edge,
    [Parameter (Mandatory=$false)]
    [switch]$bpdu_protection,
    [Parameter (Mandatory=$false)]
    [switch]$bpdu_filter,
    [Parameter (Mandatory=$false)]
    [switch]$root_guard
    )

    Begin {
    }

    Process {

        #get port id from port STP ps object
        if ($port_stp) {
            $port = $port_stp.port_id
        }

        $_stp = new-Object -TypeName PSObject

        $_stp | add-member -name "port_id" -membertype NoteProperty -Value $port

        $url = "rest/v4/stp/ports/${port}"

        if ( $PsBoundParameters.ContainsKey('priority') )
        {
            $_stp | add-member -name "priority" -membertype NoteProperty -Value $priority
        }

        if ( $PsBoundParameters.ContainsKey('admin_edge') )
        {
            if ( $admin_edge ) {
                $_stp | add-member -name "is_enable_admin_edge_port" -membertype NoteProperty -Value $true
            }
            else {
                $_stp | add-member -name "is_enable_admin_edge_port" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('bpdu_protection') )
        {
            if ( $bpdu_protection ) {
                $_stp | add-member -name "is_enable_bpdu_protection" -membertype NoteProperty -Value $true
            }
            else {
                $_stp | add-member -name "is_enable_bpdu_protection" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('bpdu_filter') )
        {
            if ( $bpdu_filter ) {
                $_stp | add-member -name "is_enable_bpdu_filter" -membertype NoteProperty -Value $true
            }
            else {
                $_stp | add-member -name "is_enable_bpdu_filter" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('root_guard') )
        {
            if ( $root_guard ) {
                $_stp | add-member -name "is_enable_root_guard" -membertype NoteProperty -Value $true
            }
            else {
                $_stp | add-member -name "is_enable_root_guard" -membertype NoteProperty -Value $false
            }
        }

        $response = invoke-ArubaSWWebRequest -method "PUT" -body $_stp -url $url

        $run = $response | convertfrom-json

        $run

    }

    End {
    }
}
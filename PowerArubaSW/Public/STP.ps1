#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
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

    Param(
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )
    Begin {
    }

    Process {

        $uri = "stp"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $stp = $response | ConvertFrom-Json

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

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, Position = 1)]
        [switch]$enable,
        [Parameter (Mandatory = $false, Position = 2)]
        [ValidateRange (0, 15)]
        [int]$priority,
        [Parameter (Mandatory = $false, Position = 3)]
        [ValidateSet ("MSTP", "RPVST")]
        [string]$mode,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "stp"

        $_stp = New-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('enable') ) {
            if ( $enable ) {
                $_stp | Add-Member -name "is_enabled" -membertype NoteProperty -Value $True
            }
            else {
                $_stp | Add-Member -name "is_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('priority') ) {
            $_stp | Add-Member -name "priority" -membertype NoteProperty -Value $priority
        }

        if ( $PsBoundParameters.ContainsKey('mode') ) {
            switch ( $mode ) {
                mstp {
                    $_mode = "STM_MSTP"
                }
                rpvst {
                    $_mode = "STM_RPVST"
                }
            }

            $_stp | Add-Member -name "mode" -membertype NoteProperty -Value $_mode
        }

        if ($PSCmdlet.ShouldProcess($connection.server, 'Configure STP')) {
            $response = Invoke-ArubaSWWebRequest -method "PUT" -body $_stp -uri $uri -connection $connection

            $run = $response | ConvertFrom-Json

            $run
        }
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
        [Parameter (Mandatory = $false)]
        [string]$port,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {


        $uri = "stp/ports"

        if ($port) {
            $uri += "/$port"
        }

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $stp = $response | ConvertFrom-Json
        if ($port) {
            $stp
        }
        else {
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

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "port_id")]
        [string]$port,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "port_stp")]
        #ValidateScript({ ValidateSTPPort $_ })]
        [psobject]$port_stp,
        [Parameter (Mandatory = $false)]
        [ValidateRange (0, 15)]
        [int]$priority,
        [Parameter (Mandatory = $false)]
        [switch]$admin_edge,
        [Parameter (Mandatory = $false)]
        [switch]$bpdu_protection,
        [Parameter (Mandatory = $false)]
        [switch]$bpdu_filter,
        [Parameter (Mandatory = $false)]
        [switch]$root_guard,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        #get port id from port STP ps object
        if ($port_stp) {
            $port = $port_stp.port_id
        }

        $_stp = New-Object -TypeName PSObject

        $_stp | Add-Member -name "port_id" -membertype NoteProperty -Value $port

        $uri = "stp/ports/${port}"

        if ( $PsBoundParameters.ContainsKey('priority') ) {
            $_stp | Add-Member -name "priority" -membertype NoteProperty -Value $priority
        }

        if ( $PsBoundParameters.ContainsKey('admin_edge') ) {
            if ( $admin_edge ) {
                $_stp | Add-Member -name "is_enable_admin_edge_port" -membertype NoteProperty -Value $true
            }
            else {
                $_stp | Add-Member -name "is_enable_admin_edge_port" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('bpdu_protection') ) {
            if ( $bpdu_protection ) {
                $_stp | Add-Member -name "is_enable_bpdu_protection" -membertype NoteProperty -Value $true
            }
            else {
                $_stp | Add-Member -name "is_enable_bpdu_protection" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('bpdu_filter') ) {
            if ( $bpdu_filter ) {
                $_stp | Add-Member -name "is_enable_bpdu_filter" -membertype NoteProperty -Value $true
            }
            else {
                $_stp | Add-Member -name "is_enable_bpdu_filter" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('root_guard') ) {
            if ( $root_guard ) {
                $_stp | Add-Member -name "is_enable_root_guard" -membertype NoteProperty -Value $true
            }
            else {
                $_stp | Add-Member -name "is_enable_root_guard" -membertype NoteProperty -Value $false
            }
        }

        if ($PSCmdlet.ShouldProcess($port, 'Configure STP Port')) {
            $response = Invoke-ArubaSWWebRequest -method "PUT" -body $_stp -uri $uri -connection $connection

            $run = $response | ConvertFrom-Json

            $run
        }

    }

    End {
    }
}

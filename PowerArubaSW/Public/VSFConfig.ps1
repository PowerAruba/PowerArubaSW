#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWVsfGlobalConfig {

    <#
        .SYNOPSIS
        Get Vsf global configuration on ArubaOS Switch.

        .DESCRIPTION
        Get all the vsf global configuration on ArubaOS Switch.

        .EXAMPLE
        Get-ArubaSWVsfGlobalConfig
        Get the vsf global configuration on the switch.
    #>

    Param(
        [Parameter (Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection=$DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/stacking/vsf/global_config"

        $response = invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $run = $response | convertfrom-json

        $run
    }

    End {
    }
}

function Set-ArubaSWVsfGlobalConfig {

    <#
        .SYNOPSIS
        Set Vsf global configuration on ArubaOS Switch.

        .DESCRIPTION
        Set all the vsf global configuration on ArubaOS Switch.

        .EXAMPLE
        Set-ArubaSWVsfGlobalConfig
        Set the vsf global configuration on the switch.
    #>

    Param(
        [Parameter (Mandatory=$true)]
        [ValidateRange (1,4294967295)]
        [int]$domain_id,
        [Parameter (Mandatory=$false)]
        [ValidateSet ("1", "10", "40", "auto")]
        [string]$port_speed,
        [Parameter (Mandatory=$false)]
        [ValidateRange (1,4094)]
        [int]$mad_vlan,
        [Parameter (Mandatory=$false)]
        [string]$mad_ip,
        [Parameter (Mandatory=$false)]
        [string]$mad_community,
        [Parameter (Mandatory=$false)]
        [string]$oobm_mad,
        [Parameter (Mandatory=$false)]
        [object]$lldp_mad,
        [Parameter (Mandatory=$false)]
        [switch]$lldp_mad_enable,
        [Parameter (Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection=$DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/stacking/vsf/global_config"

        $vsf = new-Object -TypeName PSObject

        $ip = New-Object -TypeName PSObject

        $mad = New-Object -TypeName PSObject

        $vsf | add-member -name "domain_id" -membertype NoteProperty -Value $domain_id

        if ( $PsBoundParameters.ContainsKey('port_speed') )
        {
            switch( $port_speed ) {
                1 {
                    $port_speed = "PS_1G"
                }
                10 {
                    $port_speed = "PS_10G"
                }
                40 {
                    $port_speed = "PS_40G"
                }
                auto {
                    $port_speed = "PS_AUTO"
                }
            }
            $vsf | add-member -name "port_speed" -membertype NoteProperty -Value $port_speed
        }

        if ( $PsBoundParameters.ContainsKey('oobm_mad') )
        {
            switch( $oobm_mad ) {
                ON {
                    $oobm_mad = $true
                }
                OFF {
                    $oobm_mad = $false
                }
            }
            $vsf | add-member -name "is_oobm_mad_enabled" -membertype NoteProperty -Value $oobm_mad
        }

        if ( $PsBoundParameters.ContainsKey('lldp_mad_enable') ) {
            if ( $lldp_mad_enable ) {
                $vsf | add-member -name "is_lldp_mad_enabled" -membertype NoteProperty -Value $True
            } else {
                $vsf | add-member -name "is_lldp_mad_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ($PsBoundParameters.ContainsKey('mad_ip'))
        {
            $ip | add-member -name "version" -MemberType NoteProperty -Value "IAV_IP_V4"

            $ip | add-member -name "octets" -MemberType NoteProperty -Value $mad_ip

            $mad | add-member -name "mad_ip" -MemberType NoteProperty -Value $ip

            $mad | add-member -name "community_name" -MemberType NoteProperty -Value $mad_community

            $vsf | add-member -name "lldp_vlan" -membertype NoteProperty -Value $mad
        }

        if ( $PsBoundParameters.ContainsKey('mad_vlan') )
        {
            $vsf | add-member -name "mad_vlan" -membertype NoteProperty -Value $mad_vlan
        }

        $response = invoke-ArubaSWWebRequest -method "PUT" -uri $uri -body $vsf -connection $connection

        $run = $response | convertfrom-json

        $run
    }

    End {
    }
}

function Get-ArubaSWVsfMembers {

    <#
        .SYNOPSIS
        Get Vsf members on ArubaOS Switch.

        .DESCRIPTION
        Get all the vsf members on ArubaOS Switch.

        .EXAMPLE
        Get-ArubaSWVsfMembers
        Get the vsf members on the switch.
    #>

    Param(
        [Parameter (Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection=$DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/stacking/vsf/members"

        $response = invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $run = $response | convertfrom-json

        $run
    }

    End {
    }
}

function Set-ArubaSWVsfMember {

    <#
        .SYNOPSIS
        Set Vsf member on ArubaOS Switch.

        .DESCRIPTION
        Set the vsf member on ArubaOS Switch.

        .EXAMPLE
        Set-ArubaSWVsfMember -priority -member_id
        Set the vsf member on the switch.
    #>

    Param(
        [Parameter (Mandatory=$true)]
        [ValidateRange (1,4)]
        [int]$member_id,
        [Parameter (Mandatory=$true)]
        [ValidateRange (1,255)]
        [string]$priority,
        [Parameter (Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection=$DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/stacking/vsf/members"

        $vsf = new-Object -TypeName PSObject

        $vsf | add-member -name "member_id" -membertype NoteProperty -Value $member_id

        $vsf | add-member -name "priority" -membertype NoteProperty -Value $priority

        $response = invoke-ArubaSWWebRequest -method "POST" -body $vsf -uri $uri -connection $connection

        $run = $response | convertfrom-json

        $run
    }

    End {
    }
}
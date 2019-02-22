#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, C�dric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Set-ArubaSWVsfDisable {

    <#
        .SYNOPSIS
        Set Vsf Disable on ArubaOS Switch.

        .DESCRIPTION
        Set Vsf Disable on ArubaOS Switch.

        .EXAMPLE
        Set-ArubaSWVsfDisable
        Set the vsf disable on the switch.
    #>

    Begin {
    }

    Process {

        $url = "rest/v4/stacking/vsf/disable"

        $response = invoke-ArubaSWWebRequest -method "POST" -url $url -body " "

        $run = $response | convertfrom-json

        $run
    }

    End {
    }
}

function Set-ArubaSWVsfEnable {

    <#
        .SYNOPSIS
        Set Vsf enable on ArubaOS Switch.

        .DESCRIPTION
        Set Vsf enable on ArubaOS Switch.

        .EXAMPLE
        Set-ArubaSWVsfEnable -domain_id 1
        Set the vsf enable on the switch with the domain id 1.
    #>

    Param(
        [Parameter (Mandatory=$true)]
        [ValidateRange (1,4294967295)]
        [int]$domain_id
    )

    Begin {
    }

    Process {

        $url = "rest/v4/stacking/vsf/enable"

        $vsf = new-Object -TypeName PSObject

        $vsf | add-member -name "domain_id" -membertype NoteProperty -Value $domain_id

        $response = invoke-ArubaSWWebRequest -method "POST" -body $vsf -url $url

        $run = $response | convertfrom-json

        $run
    }

    End {
    }
}

function Remove-ArubaSWVsfMember {

    <#
        .SYNOPSIS
        Remove the vsf member on ArubaOS Switch.

        .DESCRIPTION
        Remove the vsf member with the member id and reboot or shutdown the member on ArubaOS Switch.
        The parameter -action has two different value : reboot to reboot the switch, or shutdown to shutdown the switch. 

        .EXAMPLE
        Remove-ArubaSWVsfMember -member 1 -action reboot
        Remove the vsf member on the switch with the member id 1 and reboot it.
    #>

    Param(
        [Parameter (Mandatory=$true)]
        [ValidateRange (1,4)]
        [int]$member,
        [Parameter (Mandatory=$true)]
        [ValidateSet ("reboot", "shutdown")]
        [string]$action
    )

    Begin {
    }

    Process {

        $url = "rest/v4/stacking/vsf/member/remove"

        $vsf = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('reboot') )
        {
            switch( $action ) {
                reboot {
                    $action_status = $true
                }
                shudown {
                    $action_status = $false
                }
            }

            $vsf | add-member -name "reboot" -membertype NoteProperty -Value $action_status
        }

        $vsf | add-member -name "member_id" -membertype NoteProperty -Value $member

        $response = invoke-ArubaSWWebRequest -method "POST" -body $vsf -url $url

        $run = $response | convertfrom-json

        $run
    }

    End {
    }
}

function Send-ArubaSWVsfShutdown {

    <#
        .SYNOPSIS
        Shutdown the vsf member on ArubaOS Switch.

        .DESCRIPTION
        Shutdown the vsf member with the member id on ArubaOS Switch. 

        .EXAMPLE
        Send-ArubaSWVsfShutdown -member 1
        Shutdown the vsf member on the switch with the member id 1.
    #>

    Param(
        [Parameter (Mandatory=$true)]
        [ValidateRange (1,4)]
        [int]$member
    )

    Begin {
    }

    Process {

        $url = "rest/v4/stacking/vsf/member/shutdown"

        $vsf = new-Object -TypeName PSObject

        $vsf | add-member -name "member_id" -membertype NoteProperty -Value $member

        $response = invoke-ArubaSWWebRequest -method "POST" -body $vsf -url $url

        $run = $response | convertfrom-json

        $run
    }

    End {
    }
}
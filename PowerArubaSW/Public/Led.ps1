#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWLed {

    <#
        .SYNOPSIS
        Get Led (Locator) of the Switch

        .DESCRIPTION
        Get led Locator information

        .EXAMPLE
        Get-ArubaSWLed

        Get Led locator information (Status, Duration, When, Remaning)

        .EXAMPLE
        Get-ArubaSWLed -member_id 3

        Get Led locator information of member 3 (Stacked switch)
    #>

    Param(
        [Parameter (Mandatory = $false)]
        [int]$member_id
    )

    Begin {
    }

    Process {

        $url = "rest/v4/led_locator_info"

        $response = Invoke-ArubaSWWebRequest -method "GET" -url $url

        $run = ($response | ConvertFrom-Json).locator_led_info

        if ( $member_id ) {
            $run | Where-Object { $_.member_id -match $member_id }
        }
        else {
            $run
        }

    }

    End {
    }
}


function Set-ArubaSWLed {

    <#
        .SYNOPSIS
        Set Led Locator Information

        .DESCRIPTION
        Configurate Led Locator Information (Status, Duration, When...)

        .EXAMPLE
        Set-ArubaSWLed -status On -duration 15
        Enable Led Locator during 15 (Minutes)

        .EXAMPLE
        Set-ArubaSWLed -status Blink -when Startup
        Enable Blink Led Locator at startup

        .EXAMPLE
        Set-ArubaSWLed -status On -member_id 2
        Enable Led Locator on member stack 2 (for stack unit)
    #>

    Param(
        [Parameter (Mandatory = $true)]
        [ValidateSet("On", "Off", "Blink")]
        [string]$status,
        [Parameter (Mandatory = $false)]
        [ValidateRange(1, 1440)]
        [int]$duration,
        [Parameter (Mandatory = $false)]
        [ValidateSet("Now", "Startup")]
        [String]$when,
        [Parameter (Mandatory = $false)]
        [ValidateRange(1, 4)]
        [int]$member_id
    )

    Begin {
    }

    Process {

        $url = "rest/v4/locator-led-blink"

        $led = New-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('status') ) {

            switch ( $status ) {
                ON {
                    $led_blink_status = "LS_ON"
                }
                OFF {
                    $led_blink_status = "LS_OFF"
                }
                BLINK {
                    $led_blink_status = "LS_BLINK"
                }
            }

            $led | Add-Member -name "led_blink_status" -membertype NoteProperty -Value $led_blink_status
        }

        if ( $PsBoundParameters.ContainsKey('duration') ) {
            $led | Add-Member -name "duration_in_minutes" -membertype NoteProperty -Value $duration
        }

        if ( $PsBoundParameters.ContainsKey('when') ) {

            switch ( $when ) {
                NOW {
                    $when_blink = "LBT_NOW"
                }
                STARTUP {
                    $when_blink = "LBT_STARTUP"
                }
            }

            $led | Add-Member -name "when" -membertype NoteProperty -Value $when_blink
        }

        if ( $PsBoundParameters.ContainsKey('member_id') ) {
            $led | Add-Member -name "member_id" -membertype NoteProperty -Value $member_id
        }

        Invoke-ArubaSWWebRequest -method "POST" -body $led -url $url | Out-Null

        #Display the led info...
        Get-ArubaSWLed

    }

    End {
    }
}
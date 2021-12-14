#
# Copyright 2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWRadiusProfile {

    <#
        .SYNOPSIS
        Get RADIUS Profile information.

        .DESCRIPTION
        Get RADIUS Profile information (retry, retransmit, dead time...) configured on the device.

        .EXAMPLE
        Get-ArubaSWRadiusProfile

        This function give you all the informations about the radius profile parameters configured on the switch.

    #>

    Param(
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {
        $uri = "radius_profile"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $run = ($response | ConvertFrom-Json)

        $run
    }

    End {
    }
}

function Set-ArubaSWRadiusProfile {

    <#
        .SYNOPSIS
        Set a RADIUS Profile.

        .DESCRIPTION
        Set a RADIUS Profile (retry, retransmit, dead time...) parameters.

        .EXAMPLE
        Set-ArubaSWRadiusProfile -retry_interval 15 -retransmit_attempts 1 -dead_time 30

        Configure RADIUS Profile settings retry interval to 15 (secs), retransmit attempts to 1 and dead time to 30 (secs)

        .EXAMPLE
        Set-ArubaSWRadiusProfile -key powerarubasw -dyn_autz_port 3800

        Configure Dynamic Authorization Port to 3800 and key to powerarubasw

        .EXAMPLE
        Set-ArubaSWRadiusProfile -is_tracking_enabled

        Enable RADIUS Tracking
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $false)]
        [ValidateRange(1, 15)]
        [int]$retry_interval,
        [Parameter (Mandatory = $false)]
        [ValidateRange(1, 5)]
        [int]$retransmit_attempts,
        [Parameter (Mandatory = $false)]
        [ValidateRange(1, 1440)]
        [int]$dead_time,
        [Parameter (Mandatory = $false)]
        [ValidateLength(0, 32)]
        [string]$key,
        [Parameter (Mandatory = $false)]
        [ValidateRange(1024, 49151)]
        [int]$dyn_autz_port,
        [Parameter (Mandatory = $false)]
        [ValidateLength(1, 64)]
        [string]$tracking_uname,
        [Parameter (Mandatory = $false)]
        [switch]$is_tracking_enabled,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "radius_profile"

        $conf = New-Object -TypeName PSObject

        if ($PsBoundParameters.ContainsKey('retry_interval')) {
            $conf | Add-Member -name "retry_interval" -MemberType NoteProperty -Value $retry_interval
        }

        if ($PsBoundParameters.ContainsKey('retransmit_attempts')) {
            $conf | Add-Member -name "retransmit_attempts" -membertype NoteProperty -Value $retransmit_attempts
        }

        if ($PsBoundParameters.ContainsKey('dead_time')) {
            $conf | Add-Member -name "dead_time" -membertype NoteProperty -Value $dead_time
        }

        if ($PsBoundParameters.ContainsKey('key')) {
            $conf | Add-Member -name "key" -membertype NoteProperty -Value $key
        }

        if ($PsBoundParameters.ContainsKey('dyn_autz_port')) {
            $conf | Add-Member -name "dyn_autz_port" -membertype NoteProperty -Value $dyn_autz_port
        }

        if ($PsBoundParameters.ContainsKey('tracking_uname')) {
            $conf | Add-Member -name "tracking_uname" -membertype NoteProperty -Value $tracking_uname
        }

        if ($PsBoundParameters.ContainsKey('is_tracking_enabled')) {
            if ($is_tracking_enabled) {
                $conf | Add-Member -name "is_tracking_enabled" -membertype NoteProperty -Value $true
            }
            else {
                $conf | Add-Member -name "is_tracking_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ($PSCmdlet.ShouldProcess($connection.server, 'Configure RADIUS Profile')) {
            $response = Invoke-ArubaSWWebRequest -method "PUT" -body $conf -uri $uri -connection $connection

            $run = $response | ConvertFrom-Json

            $run
        }
    }

    End {
    }
}

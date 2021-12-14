#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2018, Cedric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWRestSessionTimeout {

    <#
        .SYNOPSIS
        Get REST Session Timeout when you connect to a switch

        .DESCRIPTION
        Get REST Session Timeout

        .EXAMPLE
        Get-ArubaSWRestSessionTimeout
        This function give you idle time (in seconds) before being disconnected
    #>

    Param(
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )
    Begin {
    }

    Process {

        $uri = "session-idle-timeout"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $run = ($response | ConvertFrom-Json).timeout

        $run

    }

    End {
    }
}



function Set-ArubaSWRestSessionTimeout {

    <#
        .SYNOPSIS
        Set REST Session Timeout when you connect to a switch

        .DESCRIPTION
        Set REST Session Timeout

        .EXAMPLE
        Set-ArubaSWRestSessionTimeout 1200
        This function allow you to set idle time (in seconds) before being disconnected.

        .EXAMPLE
        Set-ArubaSWRestSessionTimeout -timeout 120
        This function allow you to set idle time (in seconds) before being disconnected with the parameter timeout.
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, Position = 1)]
        [ValidateRange(120, 7200)]
        [int]$timeout,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "session-idle-timeout"

        $time = New-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('timeout') ) {
            $time | Add-Member -name "timeout" -membertype NoteProperty -Value $timeout
        }

        if ($PSCmdlet.ShouldProcess($connection.server, 'Configure REST Timeout')) {
            $response = Invoke-ArubaSWWebRequest -method "PUT" -body $time -uri $uri -connection $connection

            $run = ($response | ConvertFrom-Json).timeout

            $run
        }
    }

    End {
    }
}

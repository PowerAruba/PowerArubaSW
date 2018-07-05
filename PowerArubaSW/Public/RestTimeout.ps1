#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
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

    Begin {
    }

    Process {

        $url = "rest/v4/session-idle-timeout"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $run = ($response | convertfrom-json).timeout

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

    Param(
        [Parameter (Mandatory=$true, Position=1)] 
            [ValidateRange(120,7200)]
            [int]$timeout
    )

    Begin {
    }

    Process {

        $url = "rest/v4/session-idle-timeout"

        $time = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('timeout') )
        {
            $time | add-member -name "timeout" -membertype NoteProperty -Value $timeout
        }

        $response = invoke-ArubaSWWebRequest -method "PUT" -body $time -url $url

        $run = ($response | convertfrom-json).timeout

        $run

    }

    End {
    }
}
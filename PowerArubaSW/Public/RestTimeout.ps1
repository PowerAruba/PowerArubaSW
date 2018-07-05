#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWRestSessionTimeout {

    <#
        .SYNOPSIS
        Get Session Timeout when you connect to a switch

        .DESCRIPTION
        Get Session Timeout

        .EXAMPLE
        Get-ArubaSWRestSessionTimeout
        This function give you idle time before being disconnected
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
        Set Session Timeout when you connect to a switch

        .DESCRIPTION
        Set Session Timeout

        .EXAMPLE
        Set-ArubaSWRestSessionTimeout <seconds>
        This function allow you to set idle time before being disconnected, if the value is in the validate range (120-7200).

        .EXAMPLE
        Set-ArubaSWRestSessionTimeout -timeout <seconds>
        This function allow you to set idle time before being disconnected with the parameter "timeout", if the value is in the validate range (120-7200).
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

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
        This function allow you to set idle time before being disconnected

        .EXAMPLE
        Set-ArubaSWRestSessionTimeout -timeout <seconds>
        This function allow you to set idle time before being disconnected with the parameter "timeout"

    #>

    Param(
        [Parameter (Mandatory=$true, Position=1)]
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
        if (($timeout -lt 7200) -and ($timeout -gt 120))
        {
        $response = invoke-ArubaSWWebRequest -method "PUT" -body $time -url $url

        $run = ($response | convertfrom-json).timeout

        $run
        }
        else 
        {
        Write-Host "The value you entered ($timeout) is not between 120 and 7200. Please enter a value which is between 120 and 7200"
        }

    }


    End {
    }
}
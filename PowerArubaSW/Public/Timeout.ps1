
#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#


function Get-ArubaSWSessionTimeout {

    <#
        .SYNOPSIS
        Get SessionTimeout when you connect to a switch
        .DESCRIPTION
        Get session timeout
        .EXAMPLE
        Get-ArubaSWRestSessionTimeout
        
    #>

    Begin {
    }

    Process {

        $url = "rest/v4/session-idle-timeout"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $run = ($response | convertfrom-json).timeout

		$print = $run.ToString() + " seconds remaining before disconnection !"
		
		$print
		
        }
    

    End {
    }
}



function Set-ArubaSWSessionTimeout {

    <#
        .SYNOPSIS
        Set SessionTimeout when you connect to a switch
        .DESCRIPTION
        Set session timeout
        .EXAMPLE
        Set-ArubaSWRestSessionTimeout <seconds>
		.EXAMPLE
        Set-ArubaSWRestSessionTimeout -time <seconds>
        
    #>

	Param(
        [Parameter (Mandatory=$true, Position=1)]
        [int]$time
		)
		
    Begin {
    }

    Process {

        $url = "rest/v4/session-idle-timeout"
		
		$timeout = new-Object -TypeName PSObject
		
		if ( $PsBoundParameters.ContainsKey('time') ) {		
		$timeout | add-member -name "timeout" -membertype NoteProperty -Value $time
		}
        $response = invoke-ArubaSWWebRequest -method "PUT" -body $timeout -url $url

        }
    

    End {
    }
}
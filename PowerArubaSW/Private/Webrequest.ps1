#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Invoke-ArubaSWWebRequest(){

    Param(
        [Parameter(Mandatory = $true)]
        [String]$url,
        [Parameter(Mandatory = $true)]
        #Valid POST, GET...
        [String]$method,
        [Parameter(Mandatory = $false)]
        [String]$body,
        [Parameter(Mandatory = $false)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$sessionvariable
    )

    Begin {
    }

    Process {

        $Server = ${DefaultArubaSWConnection}.Server
        $fullurl = "http://${Server}:80/${url}"


        if( -Not $PsBoundParameters.ContainsKey('sessionvariable') ){
            $sessionvariable = $DefaultArubaSWConnection.session
        }
        
        try {
            $response = Invoke-WebRequest $fullurl -Method $method -Websession $sessionvariable
        }
        catch {
            Write-host $_
            throw "Unable to connect"
        }
        $response

    }

}
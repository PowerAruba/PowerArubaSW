#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
function Invoke-ArubaSWWebRequest() {

    Param(
        [Parameter(Mandatory = $true)]
        [String]$url,
        [Parameter(Mandatory = $true)]
        #Valid POST, GET...
        [String]$method,
        [Parameter(Mandatory = $false)]
        [psobject]$body,
        [Parameter(Mandatory = $false)]
        [Microsoft.PowerShell.Commands.WebRequestSession]$sessionvariable
    )

    Begin {
    }

    Process {

        $Server = ${DefaultArubaSWConnection}.Server
        $httpOnly = ${DefaultArubaSWConnection}.httpOnly
        $port = ${DefaultArubaSWConnection}.port
        $invokeParams = ${DefaultArubaSWConnection}.InvokeParams

        if ($httpOnly) {
            $fullurl = "http://${Server}:${port}/${url}"
        }
        else {
            $fullurl = "https://${Server}:${port}/${url}"
        }

        if ( -Not $PsBoundParameters.ContainsKey('sessionvariable') ) {
            $sessionvariable = $DefaultArubaSWConnection.session
        }

        try {
            if ($body) {
                $response = Invoke-WebRequest $fullurl -Method $method -body ($body | ConvertTo-Json) -Websession $sessionvariable @invokeParams
            }
            else {
                $response = Invoke-WebRequest $fullurl -Method $method -Websession $sessionvariable @invokeParams
            }
        }
        catch {
            Show-ArubaSWException -Exception $_
            throw "Unable to use switch API"
        }
        $response

    }

}
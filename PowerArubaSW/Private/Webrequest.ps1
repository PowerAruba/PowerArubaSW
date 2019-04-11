#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
function Invoke-ArubaSWWebRequest() {

    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$uri,
        [ValidateSet("GET", "POST", "DELETE", "PUT")]
        [String]$method="get",
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
            $fullurl = "http://${Server}:${port}/${uri}"
        }
        else {
            $fullurl = "https://${Server}:${port}/${uri}"
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

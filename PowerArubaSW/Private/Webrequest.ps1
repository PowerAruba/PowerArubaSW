#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
function Invoke-ArubaSWWebRequest() {

    <#
      .SYNOPSIS
      Invoke WebRequest with ArubaSW connection (internal) variable

      .DESCRIPTION
       Invoke WebRequest with ArubaSW connection variable (IP Address, cookie, port...)

      .EXAMPLE
      Invoke-ArubaSWWebRequest -method "get" -uri "rest/v4/vlan"

      Invoke-WebRequest with ArubaSW connection for get rest/v4/vlan

      .EXAMPLE
      Invoke-ArubaSWWebRequest "rest/v1/system"

      Invoke-WebRequest with ArubaSW connection for get rest/v1/system uri with default GET method parameter

      .EXAMPLE
      Invoke-ArubaSWWebRequest -method "post" -uri "rest/v1/system" -body $body

      Invoke-WebRequest with ArubaSW connection for post rest/v1/system uri with $body payload

      .EXAMPLE
      Invoke-ArubaSWWebRequest -method "get" -uri "rest/v1/system" -depth 1 -selector configuration

      Invoke-WebRequest with ArubaSW connection for get rest/v1/system with depth 1 and select only configuration

    #>


    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$uri,
        [ValidateSet("GET", "POST", "DELETE", "PUT")]
        [String]$method="get",
        [Parameter(Mandatory = $false)]
        [psobject]$body,
        [Parameter(Mandatory = $false)]
        [psobject]$connection
    )

    Begin {
    }

    Process {

        if ($null -eq $connection ) {
            if ($null -eq $DefaultArubaSWConnection){
                Throw "Not Connected. Connect to the Switch with Connect-ArubaSW"
            }
            $connection = $DefaultArubaSWConnection
        }

        $Server = $connection.Server
        $httpOnly = $connection.httpOnly
        $port = $connection.port
        $invokeParams = $connection.InvokeParams
        $sessionvariable = $connection.session

        if ($httpOnly) {
            $fullurl = "http://${Server}:${port}/${uri}"
        }
        else {
            $fullurl = "https://${Server}:${port}/${uri}"
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

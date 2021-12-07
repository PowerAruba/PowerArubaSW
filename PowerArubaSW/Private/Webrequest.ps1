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
      Invoke-ArubaSWWebRequest -method "get" -uri "vlan"

      Invoke-WebRequest with ArubaSW connection for get rest/vX/vlan

      .EXAMPLE
      Invoke-ArubaSWWebRequest "system"

      Invoke-WebRequest with ArubaSW connection for get rest/vX/system uri with default GET method parameter

      .EXAMPLE
      Invoke-ArubaSWWebRequest -method "post" -uri "system" -body $body

      Invoke-WebRequest with ArubaSW connection for post est/vX/ssystem uri with $body payload

      .EXAMPLE
      Invoke-ArubaSWWebRequest -method "get" -uri "system" -version 4

      Invoke-WebRequest with ArubaSW connection for get rest/v4/ssystem uri

            .EXAMPLE
      Invoke-ArubaSWWebRequest -method "get" -uri "/rest/v8/system" -version 0

      Invoke-WebRequest with ArubaSW connection for get /rest/v8/system uri

    #>


    Param(
        [Parameter(Mandatory = $true, position = 1)]
        [String]$uri,
        [ValidateSet("GET", "POST", "DELETE", "PUT")]
        [String]$method = "get",
        [Parameter(Mandatory = $false)]
        [int]$version,
        [Parameter(Mandatory = $false)]
        [psobject]$body,
        [Parameter(Mandatory = $false)]
        [psobject]$connection
    )

    Begin {
    }

    Process {

        if ($null -eq $connection ) {
            if ($null -eq $DefaultArubaSWConnection) {
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
            $fullurl = "http://${Server}:${port}/"
        }
        else {
            $fullurl = "https://${Server}:${port}/"
        }

        if ( $PsBoundParameters.ContainsKey('version') ) {
            #Not Equal to 0, we add $version (if 0 we don't add rest info..)
            if ($version -ne "0") {
                $fullurl += "rest/v" + $version + "/"
            }
        }
        else {
            #Get info from connection
            $fullurl += "rest/v" + $connection.api_version.cur + "/"
        }

        $fullurl += $uri

        try {
            if ($body) {

                Write-Verbose ($body | ConvertTo-Json)
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

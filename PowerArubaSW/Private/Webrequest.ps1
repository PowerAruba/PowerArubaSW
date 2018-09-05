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

        if($httpOnly) {
            $fullurl = "http://${Server}:${port}/${url}"
        } else {
            $fullurl = "https://${Server}:${port}/${url}"
        }

        if( -Not $PsBoundParameters.ContainsKey('sessionvariable') ){
            $sessionvariable = $DefaultArubaSWConnection.session
        }
        
        try {
            if($body){
                $response = Invoke-WebRequest $fullurl -Method $method -body ($body | ConvertTo-Json) -Websession $sessionvariable -DisableKeepAlive
            } else {
                $response = Invoke-WebRequest $fullurl -Method $method -Websession $sessionvariable -DisableKeepAlive
            }
        }
        catch {
            If ($_.Exception.Response) {

                $result = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($result)
                $responseBody = $reader.ReadToEnd()

                $responseJson =  $responseBody | ConvertFrom-Json
                
                Write-Warning "The Switch API sends an error message:"
                Write-Warning "Error description (code): $($_.Exception.Response.StatusDescription) ($($_.Exception.Response.StatusCode.Value__))"
                if($responseBody){
                    if($responseJson.message) {
                        Write-Warning "Error details: $($responseJson.message)"
                    } else {
                        Write-Warning "Error details: $($responseBody)"
                    }
                } elseif($_.ErrorDetails.Message) {
                    Write-Warning "Error details: $($_.ErrorDetails.Message)"
                }

            }
            throw "Unable to use switch API"
        }
        $response

    }

}
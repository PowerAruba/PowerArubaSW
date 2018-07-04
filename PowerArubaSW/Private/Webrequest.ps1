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
        $fullurl = "http://${Server}:80/${url}"


        if( -Not $PsBoundParameters.ContainsKey('sessionvariable') ){
            $sessionvariable = $DefaultArubaSWConnection.session
        }
        
        try {
            if($body){
                $response = Invoke-WebRequest $fullurl -Method $method -body ($body | ConvertTo-Json) -Websession $sessionvariable
            } else {
                $response = Invoke-WebRequest $fullurl -Method $method -Websession $sessionvariable
            }
        }
        catch {
            If ($_.Exception.Response) {

                $result = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($result)
                $responseBody = $reader.ReadToEnd()
                $responseJson =  $responseBody | ConvertFrom-Json
                
                Write-Host "The Switch API sends an error message:" -foreground yellow
                Write-Host
                Write-Host "Error description (code): $($_.Exception.Response.StatusDescription) ($($_.Exception.Response.StatusCode.Value__))" -foreground yellow
                Write-Host "Error details: $($responseJson.message)" -foreground yellow
                Write-Host
            }
            throw "Unable to use switch API"
        }
        $response

    }

}
#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
function Show-ArubaSWWebRequestException() {
    Param(
        [parameter(Mandatory = $true)]
        $Exception
    )

    If ($Exception.Exception.Response) {
        $result = $Exception.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($result)
        $responseBody = $reader.ReadToEnd()

        $responseJson =  $responseBody | ConvertFrom-Json

        Write-Warning "The Switch API sends an error message:"
        Write-Warning "Error description (code): $($Exception.Exception.Response.StatusDescription) ($($Exception.Exception.Response.StatusCode.Value__))"
        if($responseBody) {
            if($responseJson.message) {
                Write-Warning "Error details: $($responseJson.message)"
            } else {
                Write-Warning "Error details: $($responseBody)"
            }
        } elseif($Exception.ErrorDetails.Message) {
            Write-Warning "Error details: $($Exception.ErrorDetails.Message)"
        }
    }
}
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
                $response = Invoke-WebRequest $fullurl -Method $method -body ($body | ConvertTo-Json) -Websession $sessionvariable -DisableKeepAlive -UseBasicParsing
            } else {
                $response = Invoke-WebRequest $fullurl -Method $method -Websession $sessionvariable -DisableKeepAlive -UseBasicParsing
            }
        }
        catch {
            Show-ArubaSWWebRequestException -Exception $_
            throw "Unable to use switch API"
        }
        $response

    }

}
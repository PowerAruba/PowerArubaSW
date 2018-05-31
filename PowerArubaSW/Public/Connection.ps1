
#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Connect-ArubaSW {

  <#
      .SYNOPSIS
      Connect to a ArubaOS Switches (Provision)

      .DESCRIPTION
      Connect to a ArubaOS Switches
      Actually only support to use HTTP

      .EXAMPLE
      Connect-ArubaSW -Server 192.0.2.1 -Username manager -Password aruba

      Connect to a ArubaOS Switch with IP 192.0.2.1

  #>

    Param(
        [Parameter(Mandatory = $true)]
        [String]$Server,
        [Parameter(Mandatory = $false)]
        [String]$Username,
        [Parameter(Mandatory = $false)]
        [String]$Password
    )

    Begin {
    }

    Process {

        $connection = @{server="";session="";cookie=""}

        $postParams = @{userName=$Username;password=$Password}
        $url = "http://${Server}:80/rest/v3/login-sessions"
        try {
            $response = Invoke-WebRequest $url -Method POST -Body ($postParams | Convertto-Json ) -SessionVariable arubasw
        }
        catch {
            #$_
            throw "Unable to connect"
        }
        $cookie = ($response.content | ConvertFrom-Json).cookie
        $smallcookie = $cookie.split("=")[1]
        $arubasw.Cookies.Add((Set-Cookie -name "sessionId" -value $smallcookie -domain $server));

        $connection.server = $server
        $connection.cookie = $cookie
        $connection.session = $arubasw

        set-variable -name DefaultArubaSWConnection -value $connection -scope Global

    }

    End {
    }
}
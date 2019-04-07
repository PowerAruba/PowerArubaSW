#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWCli {

    <#
        .SYNOPSIS
        Get the result of a cli command on ArubaOS Switch.

        .DESCRIPTION
        Get the result of a cli command.

        .EXAMPLE
        Get-ArubaSWCli -cmd "Show running-config"

        This function give you the result of a cli command on the switch.
    #>

    Param(
        [Parameter (Mandatory=$true, Position=1)]
        [string]$cmd
    )

    Begin {
    }

    Process {

        $url = "rest/v4/cli"

        $run = new-Object -TypeName PSObject

        $run | add-member -name "cmd" -membertype NoteProperty -Value "$cmd"

        $response = invoke-ArubaSWWebRequest -method "POST" -body $run -url $url

        $conf = ($response | ConvertFrom-Json)

        $result_base64_encoded = $conf.result_base64_encoded

        $result  = [System.Convert]::FromBase64String($result_base64_encoded)

        $result = [System.Text.Encoding]::UTF8.GetString($result)

        $conf | add-member -name "result" -membertype NoteProperty -value $result

        $conf

    }

    End {
    }
}

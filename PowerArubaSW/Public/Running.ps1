#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, C�dric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWRunning {

    <#
        .SYNOPSIS
        Get running configuration on ArubaOS Switch.

        .DESCRIPTION
        Get the running configuration.

        .EXAMPLE
        Get-ArubaSWRunning
        This function give you the running configuration of the switch.
    #>

    Begin {
    }

    Process {

        $url = "rest/v4/cli"

        $run = new-Object -TypeName PSObject

        $run | add-member -name "cmd" -membertype NoteProperty -Value "show running-config"

        $response = invoke-ArubaSWWebRequest -method "POST" -body $run -url $url

        $conf = ($response | ConvertFrom-Json).result_base64_encoded

        $b  = [System.Convert]::FromBase64String($conf)

        $decode = [System.Text.Encoding]::UTF8.GetString($b)

        $decode

    }

    End {
    }
}

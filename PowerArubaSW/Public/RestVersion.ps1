
#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWRestVersion {

    <#
        .SYNOPSIS
        Get supported REST API Version from ArubaOS Switch (Provision)

        .DESCRIPTION
        Get supported REST API version (1.0, 1.1...)

        .EXAMPLE
        Get-ArubaSWRestVersion

        Get REST API Version

    #>

    Begin {
    }

    Process {

        $uri = "rest/version"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri

        ($response.content | ConvertFrom-Json).version_element
    }

    End {
    }
}


#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
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

        $url = "rest/version"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        ($response.content | convertfrom-json).version_element
    }

    End {
    }
}

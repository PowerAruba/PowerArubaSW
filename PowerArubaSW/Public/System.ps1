
#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWSystem {

    <#
        .SYNOPSIS
        Get system info about ArubaOS Switch (Provision)

        .DESCRIPTION
        Get System Info (Name, location, contact, device mode)

        .EXAMPLE
        Get-ArubaSWSystem

        Get system info

    #>

    Begin {
    }

    Process {

        $url = "rest/v4/system"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $response.content | convertfrom-json
    }

    End {
    }
}

function Set-ArubaSWSystem {

    <#
        .SYNOPSIS
        Set system info about ArubaOS Switch (Provision)

        .DESCRIPTION
        Set System Info (Name, location, contact)

        .EXAMPLE
        Set-ArubaSWSystem -name PowerArubaSW -Location PowerArubaSW-Lab -Contact power@arubasw

        Set Aruba Switch system information (like name, location or contact)

    #>

    Param(
        [Parameter(Mandatory = $false)]
        [String]$name,
        [Parameter(Mandatory = $false)]
        [String]$location,
        [Parameter(Mandatory = $false)]
        [String]$contact
    )

    Begin {
    }

    Process {

        $url = "rest/v4/system"

        $system = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('name') ) {
            $system | add-member -name "name" -membertype NoteProperty -Value $name
        }

        if ( $PsBoundParameters.ContainsKey('location') ) {
            $system | add-member -name "location" -membertype NoteProperty -Value $location
        }

        if ( $PsBoundParameters.ContainsKey('contact') ) {
            $system | add-member -name "contact" -membertype NoteProperty -Value $contact
        }

        $response = invoke-ArubaSWWebRequest -method "PUT" -url $url -Body $system

        $response.content | convertfrom-json
    }

    End {
    }
}

function Get-ArubaSWSystemStatus {

    <#
        .SYNOPSIS
        Get System Status about ArubaOS Switch (Provision)

        .DESCRIPTION
        Get System Status (name, Serial Number, Firmware, Hardware revision, product model...)

        .EXAMPLE
        Get-ArubaSWSystemStatus

        Get System Status

    #>

    Begin {
    }

    Process {

        $url = "rest/v4/system/status"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $response.content | convertfrom-json
    }

    End {
    }
}

function Get-ArubaSWSystemStatusCpu {

    <#
        .SYNOPSIS
        Get System Status CPU about ArubaOS Switch (Provision)

        .DESCRIPTION
        Get System Status CPU

        .EXAMPLE
        Get-ArubaSWSystemStatusCpu

        Get System Status CPU

    #>

    Begin {
    }

    Process {

        $url = "rest/v4/system/status/cpu"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $response.content | convertfrom-json
    }

    End {
    }
}

function Get-ArubaSWSystemStatusSwitch {

    <#
        .SYNOPSIS
        Get System Status Switch about ArubaOS Switch (Provision)
        .DESCRIPTION
        Get System Status Switch Product and Hardware info
        .EXAMPLE
        Get-ArubaSWSystemStatusSwitch
        Get System Status Switch Product (Name / Number) and Hardware (FAN / ports) info
    #>

    Begin {
    }

    Process {

        $url = "rest/v4/system/status/switch"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $response.content | convertfrom-json
    }

    End {
    }
}
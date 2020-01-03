
#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
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

    Param(
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/system"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $response.content | ConvertFrom-Json
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
        [String]$contact,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/system"

        $system = New-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('name') ) {
            $system | Add-Member -name "name" -membertype NoteProperty -Value $name
        }

        if ( $PsBoundParameters.ContainsKey('location') ) {
            $system | Add-Member -name "location" -membertype NoteProperty -Value $location
        }

        if ( $PsBoundParameters.ContainsKey('contact') ) {
            $system | Add-Member -name "contact" -membertype NoteProperty -Value $contact
        }

        $response = Invoke-ArubaSWWebRequest -method "PUT" -uri $uri -Body $system -connection $connection

        $response.content | ConvertFrom-Json
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

    Param(
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        if ('ST_STACKED' -eq $connection.switch_type) {
            Throw "Unable to use this cmdlet, you need to use Get-ArubaSWSystemStatusGlobal"
        }

        $uri = "rest/v4/system/status"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $response.content | ConvertFrom-Json
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

    Param(
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/system/status/switch"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $response.content | ConvertFrom-Json
    }

    End {
    }
}

function Get-ArubaSWSystemStatusGlobal {

    <#
        .SYNOPSIS
        Get System Status Global Info about ArubaOS Switch (Provision)

        .DESCRIPTION
        Get System Status Global Info (Only work on VSF Switch !)

        .EXAMPLE
        Get-ArubaSWSystemStatusGlobal

        Get System Status Global Info (Name, Firmware...)

    #>

    Param(
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        if ('ST_STANDALONE' -eq $connection.switch_type -or 'ST_CHASSIS' -eq $connection.switch_type) {
            Throw "Unable to use this cmdlet, you need to use Get-ArubaSWSystemStatus"
        }
        $uri = "rest/v4/system/status/global_info"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $response.content | ConvertFrom-Json
    }

    End {
    }
}

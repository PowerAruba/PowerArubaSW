#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWLLDPRemote {

    <#
        .SYNOPSIS
        Get LLDP information about remote devices connected to the switch you are log on

        .DESCRIPTION
        Get lldp informations about the remote devices

        .EXAMPLE
        Get-ArubaSWLLDPRemote
        This function give you all the informations about the remote devices connected to the ports of the switch you are log on 
    #>

    Begin {
    }

    Process {

        $url = "rest/v4/lldp/remote-device"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $run = ($response | convertfrom-json).lldp_remote_device_element

        $lldp = [pscustomobject]@{
        LocalPort  = $run.local_port 
        RemotePort = $run.port_id 
        SystemName = $run.system_name
        PortDescription = $run.port_description
        }

        $lldp
    }

    End {
    }
}

function Get-ArubaSWLLDPStatus {

    <#
        .SYNOPSIS
        Get information about LLDP global staus

        .DESCRIPTION
        Get lldp informations 

        .EXAMPLE
        Get-ArubaSWLLDPStatus
        This function give you all the informations about the global status of LLDP 
    #>

    Begin {
    }

    Process {

        $url = "rest/v4/lldp"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $run = $response | convertfrom-json
        
        if ($run.admin_status = "LLAS_ENABLED")
        {
            $run.admin_status = "Enable"
        }
        else
        {
            $run.admin_status = "Disable"
        }

        $status = [pscustomobject]@{
        Status  = $run.admin_status
        TransmitInterval = $run.transmit_interval
        HoldTimeMultiplier = $run.hold_time_multiplier
        FastStartCount = $run.fast_start_count
        ReinitInterval = $run.reinit_interval
        NotificationInterval = $run.notification_interval
        }
        
        $status
    }

    End {
    }
}

function Set-ArubaSWLLDPStatus {

    <#
        .SYNOPSIS
        Set global configuration about LLDP

        .DESCRIPTION
        Set lldp global parameters 

        .EXAMPLE
        Set-ArubaSWLLDPStatus [-transmit <5-32768>] [-holdtime <2-10>] [-faststart <1-10>]
        This function set the global parameters of LLDP : -enable set the LLDP active or not, -transmit set the value of transmit interval, 
        -holdtime set the value of the hold time multiplier, and -faststart set the value of the LLDP fast start count. 
    #>

    Param(
    [Parameter (Mandatory=$false)]
    [ValidateRange (5,32768)]
    [int]$transmit,
    [Parameter (Mandatory=$false)]
    [ValidateRange (2,10)]
    [int]$holdtime,
    [Parameter (Mandatory=$false)]
    [ValidateRange (1,10)]
    [int]$faststart
    )

    Begin {
    }

    Process {

        $url = "rest/v4/lldp"

        Write-Host "The transmit interval must be greater than or equal to 8"

        $conf = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('transmit') )
        {
            $conf | add-member -name "transmit_interval" -membertype NoteProperty -Value $transmit
        }

        if ( $PsBoundParameters.ContainsKey('holdtime') )
        {
            $conf | add-member -name "hold_time_multiplier" -membertype NoteProperty -Value $holdtime
        }

        if ( $PsBoundParameters.ContainsKey('faststart') )
        {
            $conf | add-member -name "fast_start_count" -membertype NoteProperty -Value $faststart
        }

        $response = invoke-ArubaSWWebRequest -method "PUT" -body $conf -url $url

        $run = $response | convertfrom-json

        $status = [pscustomobject]@{
        TransmitInterval = $run.transmit_interval
        HoldTimeMultiplier = $run.hold_time_multiplier
        FastStartCount = $run.fast_start_count
        ReinitInterval = $run.reinit_interval
        NotificationInterval = $run.notification_interval
        }

        $status

    }

    End {
    }
}
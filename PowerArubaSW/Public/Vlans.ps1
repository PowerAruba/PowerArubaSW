#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaSWVlans {

    <#
        .SYNOPSIS
        Add a Vlan info on ArubaOS Switch (Provision)

        .DESCRIPTION
        Add vlan info (Id, Name, Voice, Snooping...)

        .EXAMPLE
        Add-ArubaSWVlans -id 85 -Name PowerArubaSW -is_voice_enabled -is_jumbo_enabled:$false

        Add vlan id 85 with name PowerArubaSW and enable voice vlan and disable jumbo

    #>

    Param(
        [Parameter (Mandatory = $true)]
        [int]$id,
        [Parameter (Mandatory = $false)]
        [string]$name,
        [Parameter (Mandatory = $false)]
        [switch]$is_voice_enabled,
        [Parameter (Mandatory = $false)]
        [switch]$is_jumbo_enabled,
        [Parameter (Mandatory = $false)]
        [switch]$is_dsnoop_enabled,
        [Parameter (Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection=$DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/vlans"

        $vlan = New-Object -TypeName PSObject

        $vlan | Add-Member -name "vlan_id" -membertype NoteProperty -Value $id

        if ( $PsBoundParameters.ContainsKey('name') ) {
            $vlan | Add-Member -name "name" -membertype NoteProperty -Value $name
        }
        else {
            #with APIv4, name is mandatory ... Set VLAN with number id
            $vlan | Add-Member -name "name" -membertype NoteProperty -Value "VLAN$($id)"
        }

        if ( $PsBoundParameters.ContainsKey('is_voice_enabled') ) {
            if ( $is_voice_enabled ) {
                $vlan | Add-Member -name "is_voice_enabled" -membertype NoteProperty -Value $True
            }
            else {
                $vlan | Add-Member -name "is_voice_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('is_jumbo_enabled') ) {
            if ( $is_jumbo_enabled ) {
                $vlan | Add-Member -name "is_jumbo_enabled" -membertype NoteProperty -Value $True
            }
            else {
                $vlan | Add-Member -name "is_jumbo_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('is_dsnoop_enabled') ) {
            if ( $is_dsnoop_enabled ) {
                $vlan | Add-Member -name "is_dsnoop_enabled" -membertype NoteProperty -Value $True
            }
            else {
                $vlan | Add-Member -name "is_dsnoop_enabled" -membertype NoteProperty -Value $false
            }
        }

        $response = Invoke-ArubaSWWebRequest -method "POST" -body $vlan -uri $uri -connection $connection
        $vlans = ($response.Content | ConvertFrom-Json)

        $vlans
    }

    End {
    }
}
function Get-ArubaSWVlans {

    <#
        .SYNOPSIS
        Get Vlans info about ArubaOS Switch (Provision)

        .DESCRIPTION
        Get Vlans Info (Id, Name, Voice, snooping...)

        .EXAMPLE
        Get-ArubaSWVlans

        Get ALL vlans on the switch

        .EXAMPLE
        Get-ArubaSWVlans Aruba

        Get info about vlan named Aruba on the switch

        .EXAMPLE
        Get-ArubaSWVlans -id 23

        Get info about vlan id 23 on the switch

    #>

    [CmdLetBinding(DefaultParameterSetName = "Default")]

    Param(
        [Parameter (Mandatory = $false, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $false, ParameterSetName = "name", Position = 1)]
        [string]$Name,
        [Parameter (Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection=$DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/vlans"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $vlans = ($response.Content | ConvertFrom-Json).vlan_element

        switch ( $PSCmdlet.ParameterSetName ) {
            "name" { $vlans | Where-Object { $_.name -match $name } }
            "id" { $vlans | Where-Object { $_.vlan_id -eq $id } }
            default { $vlans }
        }
    }

    End {
    }
}
function Set-ArubaSWVlans {

    <#
        .SYNOPSIS
        Configure Vlan info on ArubaOS Switch (Provision)

        .DESCRIPTION
        Configure vlan info (Id, Name, Voice, Snooping...)

        .EXAMPLE
        $vlan = Get-ArubaSWVlans -id 85
        PS C:\>$vlan | Set-ArubaSWVlans -Name PowerArubaSW -is_voice_enabled -is_jumbo_enabled:$false

        Configure vlan id 85 with name PowerArubaSW and enable voice vlan and disable jumbo
        .EXAMPLE
        Set-ArubaSWVlans -id 85 -Name PowerArubaSW2 -is_voice_enabled -is_dsnoop_enabled:$false

        Configure vlan id 85 with name PowerArubaSW2 and enable voice vlan and disable dsnoop

    #>

    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "vlan")]
        #ValidateScript({ ValidateVlan $_ })]
        [psobject]$vlan,
        [Parameter (Mandatory = $false)]
        [string]$name,
        [Parameter (Mandatory = $false)]
        [switch]$is_voice_enabled,
        [Parameter (Mandatory = $false)]
        [switch]$is_jumbo_enabled,
        [Parameter (Mandatory = $false)]
        [switch]$is_dsnoop_enabled,
        [Parameter (Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection=$DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        #get vlan id from vlan ps object
        if ($vlan) {
            $id = $vlan.vlan_id
            $oldname = $vlan.name
        }
        $uri = "rest/v4/vlans/${id}"

        $_vlan = New-Object -TypeName PSObject

        #with APIv4, vlan_id is mandatory...
        $_vlan | Add-Member -name "vlan_id" -membertype NoteProperty -Value $id

        if ( $PsBoundParameters.ContainsKey('name') ) {
            $_vlan | Add-Member -name "name" -membertype NoteProperty -Value $name
        }
        else {
            #with APIv4, name is also mandatory... (why ?!!) use already configured name.
            if (!$oldname) {
                #if you don't pipelining (and use -id), need to get vlan name...
                $oldname = (Get-ArubaSWVlans -id $id).name
            }

            $_vlan | Add-Member -name "name" -membertype NoteProperty -Value $oldname
        }
        $name

        if ( $PsBoundParameters.ContainsKey('is_voice_enabled') ) {
            if ( $is_voice_enabled ) {
                $_vlan | Add-Member -name "is_voice_enabled" -membertype NoteProperty -Value $True
            }
            else {
                $_vlan | Add-Member -name "is_voice_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('is_jumbo_enabled') ) {
            if ( $is_jumbo_enabled ) {
                $_vlan | Add-Member -name "is_jumbo_enabled" -membertype NoteProperty -Value $True
            }
            else {
                $_vlan | Add-Member -name "is_jumbo_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('is_dsnoop_enabled') ) {
            if ( $is_dsnoop_enabled ) {
                $_vlan | Add-Member -name "is_dsnoop_enabled" -membertype NoteProperty -Value $True
            }
            else {
                $_vlan | Add-Member -name "is_dsnoop_enabled" -membertype NoteProperty -Value $false
            }
        }

        $response = Invoke-ArubaSWWebRequest -method "PUT" -body $_vlan -uri $uri -connection $connection
        $rep_vlan = ($response.Content | ConvertFrom-Json)

        $rep_vlan
    }

    End {
    }
}

function Remove-ArubaSWVlans {

    <#
        .SYNOPSIS
        Remove a Vlan on ArubaOS Switch (Provision)

        .DESCRIPTION
        Remove vlan on the switch

        .EXAMPLE
        $vlan = Get-ArubaSWVlans -id 85
        PS C:\>$vlan | Remove-ArubaSWVlans

        Remove vlan id 85

        .EXAMPLE
        Remove-ArubaSWVlans -id 85 -noconfirm

        Remove vlan id 85 with no confirmation
    #>

    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "vlan")]
        #ValidateScript({ ValidateVlan $_ })]
        [psobject]$vlan,
        [Parameter(Mandatory = $false)]
        [switch]$noconfirm,
        [Parameter (Mandatory=$False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection=$DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        #get vlan id from vlan ps object
        if ($vlan) {
            $id = $vlan.vlan_id
        }

        $uri = "rest/v4/vlans/${id}"

        if ( -not ( $Noconfirm )) {
            $message = "Remove Vlan on switch"
            $question = "Proceed with removal of vlan ${id} ?"
            $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

            $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
        }
        else { $decision = 0 }
        if ($decision -eq 0) {
            Write-Progress -activity "Remove Vlan"
            $null = Invoke-ArubaSWWebRequest -method "DELETE" -uri $uri -connection $connection
            Write-Progress -activity "Remove Vlan" -completed
        }
    }

    End {
    }
}

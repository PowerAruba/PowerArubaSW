#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
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
        [Parameter (Mandatory=$true)]
        [int]$id,
        [Parameter (Mandatory=$false)]
        [string]$name,
        [Parameter (Mandatory=$false)]
        [switch]$is_voice_enabled,
        [Parameter (Mandatory=$false)]
        [switch]$is_jumbo_enabled,
        [Parameter (Mandatory=$false)]
        [switch]$is_dsnoop_enabled
    )

    Begin {
    }

    Process {

        $url = "rest/v3/vlans"

        $vlan = new-Object -TypeName PSObject

        $vlan | add-member -name "vlan_id" -membertype NoteProperty -Value $id

        if ( $PsBoundParameters.ContainsKey('name') ) {
            $vlan | add-member -name "name" -membertype NoteProperty -Value $name
        }
        if ( $PsBoundParameters.ContainsKey('is_voice_enabled') ) {
            if ( $is_voice_enabled ) {
                $vlan | add-member -name "is_voice_enabled" -membertype NoteProperty -Value $True
            } else {
                $vlan | add-member -name "is_voice_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('is_jumbo_enabled') ) {
            if ( $is_jumbo_enabled ) {
                $vlan | add-member -name "is_jumbo_enabled" -membertype NoteProperty -Value $True
            } else {
                $vlan | add-member -name "is_jumbo_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('is_dsnoop_enabled') ) {
            if ( $is_dsnoop_enabled ) {
                $vlan | add-member -name "is_dsnoop_enabled" -membertype NoteProperty -Value $True
            } else {
                $vlan | add-member -name "is_dsnoop_enabled" -membertype NoteProperty -Value $false
            }
        }
        $vlan | ConvertTo-Json
        $response = invoke-ArubaSWWebRequest -method "POST" -body $vlan -url $url
        $vlans = ($response.Content | convertfrom-json)

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

    [CmdLetBinding(DefaultParameterSetName="Default")]

    Param(
        [Parameter (Mandatory=$false, ParameterSetName="id")]
        [int]$id,
        [Parameter (Mandatory=$false, ParameterSetName="name", Position=1)]
        [string]$Name
    )

    Begin {
    }

    Process {

        $url = "rest/v4/vlans"

        $response = invoke-ArubaSWWebRequest -method "GET" -url $url

        $vlans = ($response.Content | convertfrom-json).vlan_element

        switch ( $PSCmdlet.ParameterSetName ) {
            "name" { $vlans  | where-object { $_.name -match $name}}
            "id" { $vlans | where-object { $_.vlan_id -eq $id}}
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
        Get-ArubaSWVlans -id 85
        PS /> $vlan | Set-ArubaSWVlans -Name PowerArubaSW -is_voice_enabled -is_jumbo_enabled:$false

        Configure vlan id 85 with name PowerArubaSW and enable voice vlan and disable jumbo
        .EXAMPLE
        Set-ArubaSWVlans -id 85 -Name PowerArubaSW2 -is_voice_enabled -is_dsnoop_enabled:$false

        Configure vlan id 85 with name PowerArubaSW2 and enable voice vlan and disable dsnoop

    #>

    Param(
        [Parameter (Mandatory=$true, ParameterSetName="id")]
        [int]$id,
        [Parameter (Mandatory=$true,ValueFromPipeline=$true,Position=1,ParameterSetName="vlan")]
        #ValidateScript({ ValidateVlan $_ })]
        [psobject]$vlan,
        [Parameter (Mandatory=$false)]
        [string]$name,
        [Parameter (Mandatory=$false)]
        [switch]$is_voice_enabled,
        [Parameter (Mandatory=$false)]
        [switch]$is_jumbo_enabled,
        [Parameter (Mandatory=$false)]
        [switch]$is_dsnoop_enabled
    )

    Begin {
    }

    Process {

        #get vlan id from vlan ps object
        if($vlan){
            $id = $vlan.vlan_id
        }
        $url = "rest/v3/vlans/${id}"

        $_vlan = new-Object -TypeName PSObject

        if ( $PsBoundParameters.ContainsKey('name') ) {
            $_vlan | add-member -name "name" -membertype NoteProperty -Value $name
        }
        if ( $PsBoundParameters.ContainsKey('is_voice_enabled') ) {
            if ( $is_voice_enabled ) {
                $_vlan | add-member -name "is_voice_enabled" -membertype NoteProperty -Value $True
            } else {
                $_vlan | add-member -name "is_voice_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('is_jumbo_enabled') ) {
            if ( $is_jumbo_enabled ) {
                $_vlan | add-member -name "is_jumbo_enabled" -membertype NoteProperty -Value $True
            } else {
                $_vlan | add-member -name "is_jumbo_enabled" -membertype NoteProperty -Value $false
            }
        }

        if ( $PsBoundParameters.ContainsKey('is_dsnoop_enabled') ) {
            if ( $is_dsnoop_enabled ) {
                $_vlan | add-member -name "is_dsnoop_enabled" -membertype NoteProperty -Value $True
            } else {
                $_vlan | add-member -name "is_dsnoop_enabled" -membertype NoteProperty -Value $false
            }
        }

        $response = invoke-ArubaSWWebRequest -method "PUT" -body $_vlan -url $url
        $rep_vlan = ($response.Content | convertfrom-json)

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
        Remove-ArubaSWVlans -id 85

        Remove vlan id 85

        .EXAMPLE
        Remove-ArubaSWVlans -id 85 -noconfirm

        Remove vlan id 85 with no confirmation
    #>

    Param(
        [Parameter (Mandatory=$true)]
        [int]$id,
        [Parameter(Mandatory = $false)]
        [switch]$noconfirm
    )

    Begin {
    }

    Process {

        $url = "rest/v4/vlans/${id}"

        if ( -not ( $Noconfirm )) {
            $message  = "Remove Vlan on switch"
            $question = "Proceed with removal of vlan ${id} ?"
            $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
            $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

            $decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
        }
        else { $decision = 0 }
        if ($decision -eq 0) {
            Write-Progress -activity "Remove Vlan"
            $null = Invoke-ArubaSWWebRequest -method "DELETE" -url $url
            Write-Progress -activity "Remove Vlan" -completed
        }
    }

    End {
    }
}
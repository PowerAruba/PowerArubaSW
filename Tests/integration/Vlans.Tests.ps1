#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get VLAN" {
    It "Get VLAN Does not throw an error" {
        {
            Get-ArubaSWVlans
        } | Should Not Throw
    }

    It "Get ALL vlan" {
        $VLANS = Get-ArubaSWVlans
        $VLANS.count | Should not be $NULL
    }

    It "Get the Vlan ID (1)" {
        $VLAN = Get-ArubaSWVlans -id 1
        $VLAN.vlan_id | Should Be 1
        $VLAN.name | Should be "DEFAULT_VLAN"
        $VLAN.status | Should be "VS_PORT_BASED"
        $VLAN.type | Should be "VT_STATIC"
        $VLAN.is_voice_enabled | Should be $false
        $VLAN.is_jumbo_enabled | Should be $false
        $VLAN.is_dsnoop_enabled | Should be $false
        $VLAN.is_management_vlan | Should be $false
    }

    It "Get the Vlan ID 1 by name (DEFAULT_VLAN)" {
        $VLAN = Get-ArubaSWVlans -name 'DEFAULT_VLAN'
        $VLAN.vlan_id | Should Be 1
        $VLAN.name | Should be "DEFAULT_VLAN"
        $VLAN.status | Should be "VS_PORT_BASED"
        $VLAN.type | Should be "VT_STATIC"
        $VLAN.is_voice_enabled | Should be $false
        $VLAN.is_jumbo_enabled | Should be $false
        $VLAN.is_dsnoop_enabled | Should be $false
        $VLAN.is_management_vlan | Should be $false
    }
}

Describe  "Add VLAN" {

    BeforeEach {
        #Always remove vlan $pester_vlan...
        $VLAN = Get-ArubaSWVlans -id $pester_vlan
        if ($VLAN) {
            if ($VLAN.is_dsnoop_enabled) {
                #fix stupid issue... when there is already dhcp snoop enable on a vlan, it is not remove (when remove the vlan)...
                Set-ArubaSWVlans -id $pester_vlan -name PowerArubaSW -is_dsnoop_enabled:$false
            }
            Remove-ArubaSWVlans -id $pester_vlan -noconfirm
        }
    }

    It "Add VLAN $pester_vlan (with only a id)" {
        Add-ArubaSWVlans -id $pester_vlan
        $VLAN = Get-ArubaSWVlans -id $pester_vlan
        $VLAN.vlan_id | Should Be $pester_vlan
        $VLAN.name | Should be "VLAN$pester_vlan"
        $VLAN.status | Should be "VS_PORT_BASED"
        $VLAN.type | Should be "VT_STATIC"
        $VLAN.is_voice_enabled | Should be $false
        $VLAN.is_jumbo_enabled | Should be $false
        $VLAN.is_dsnoop_enabled | Should be $false
        $VLAN.is_management_vlan | Should be $false
    }

    It "Add VLAN $pester_vlan (with only a id and name PowerArubaSW)" {
        Add-ArubaSWVlans -id $pester_vlan -name PowerArubaSW
        $VLAN = Get-ArubaSWVlans -id $pester_vlan
        $VLAN.vlan_id | Should Be $pester_vlan
        $VLAN.name | Should be "PowerArubaSW"
        $VLAN.status | Should be "VS_PORT_BASED"
        $VLAN.type | Should be "VT_STATIC"
        $VLAN.is_voice_enabled | Should be $false
        $VLAN.is_jumbo_enabled | Should be $false
        $VLAN.is_dsnoop_enabled | Should be $false
        $VLAN.is_management_vlan | Should be $false
    }

    It "Add VLAN $pester_vlan (with only a id and enable voice/jumbo/dhcp snoop)" {
        Add-ArubaSWVlans -id $pester_vlan -is_voice_enabled -is_jumbo_enabled -is_dsnoop_enabled
        $VLAN = Get-ArubaSWVlans -id $pester_vlan
        $VLAN.vlan_id | Should Be $pester_vlan
        $VLAN.name | Should be "VLAN$pester_vlan"
        $VLAN.status | Should be "VS_PORT_BASED"
        $VLAN.type | Should be "VT_STATIC"
        $VLAN.is_voice_enabled | Should be $true
        $VLAN.is_jumbo_enabled | Should be $true
        $VLAN.is_dsnoop_enabled | Should be $true
        $VLAN.is_management_vlan | Should be $false
    }

    AfterAll {
        #Always remove vlan $pester_vlan...
        $VLAN = Get-ArubaSWVlans -id $pester_vlan
        if ($VLAN) {
            if ($VLAN.is_dsnoop_enabled) {
                #fix stupid issue... when there is already dhcp snoop enable on a vlan, it is not remove (when remove the vlan)...
                Set-ArubaSWVlans -id $pester_vlan -name PowerArubaSW -is_dsnoop_enabled:$false
            }
            Remove-ArubaSWVlans -id $pester_vlan -noconfirm
        }
    }
}


Describe  "Configure VLAN" {

    Context "Configure VLAN via ID" {
        BeforeAll {
            #Always add vlan $pester_vlan...
            Add-ArubaSWVlans -id $pester_vlan
        }

        It "Configure VLAN name" {
            Set-ArubaSWVlans -id $pester_vlan -name "PowerArubaSW"
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            $VLAN.name | Should be "PowerArubaSW"
        }

        It "Configure Vlan option (enable jumbo/voice/snooping)" {
            Set-ArubaSWVlans -id $pester_vlan -is_voice_enabled -is_jumbo_enabled -is_dsnoop_enabled
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            $VLAN.vlan_id | Should Be $pester_vlan
            $VLAN.is_voice_enabled | Should be $true
            $VLAN.is_jumbo_enabled | Should be $true
            $VLAN.is_dsnoop_enabled | Should be $true
            $VLAN.is_management_vlan | Should be $false
        }

        It "Configure Vlan option (disable jumbo/voice/snooping)" {
            Set-ArubaSWVlans -id $pester_vlan -is_voice_enabled:$false -is_jumbo_enabled:$false -is_dsnoop_enabled:$false
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            $VLAN.vlan_id | Should Be $pester_vlan
            $VLAN.is_voice_enabled | Should be $false
            $VLAN.is_jumbo_enabled | Should be $false
            $VLAN.is_dsnoop_enabled | Should be $false
            $VLAN.is_management_vlan | Should be $false
        }

        AfterAll {
            #Always remove vlan $pester_vlan...
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            if ($VLAN) {
                if ($VLAN.is_dsnoop_enabled) {
                    #fix stupid issue... when there is already dhcp snoop enable on a vlan, it is not remove (when remove the vlan)...
                    Set-ArubaSWVlans -id $pester_vlan -name PowerArubaSW -is_dsnoop_enabled:$false
                }
                Remove-ArubaSWVlans -id $pester_vlan -noconfirm
            }
        }
    }

    Context "Configure VLAN via pipeline" {
        BeforeAll {
            #Always add vlan $pester_vlan...
            Add-ArubaSWVlans -id $pester_vlan
        }

        It "Configure VLAN name" {
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            $VLAN | Set-ArubaSWVlans -name "PowerArubaSW"
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            $VLAN.name | Should be "PowerArubaSW"
        }

        It "Configure Vlan option (enable jumbo/voice/snooping)" {
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            $VLAN | Set-ArubaSWVlans -is_voice_enabled -is_jumbo_enabled -is_dsnoop_enabled
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            $VLAN.vlan_id | Should Be $pester_vlan
            $VLAN.is_voice_enabled | Should be $true
            $VLAN.is_jumbo_enabled | Should be $true
            $VLAN.is_dsnoop_enabled | Should be $true
            $VLAN.is_management_vlan | Should be $false
        }

        It "Configure Vlan option (disable jumbo/voice/snooping)" {
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            $VLAN | Set-ArubaSWVlans -is_voice_enabled:$false -is_jumbo_enabled:$false -is_dsnoop_enabled:$false
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            $VLAN.vlan_id | Should Be $pester_vlan
            $VLAN.is_voice_enabled | Should be $false
            $VLAN.is_jumbo_enabled | Should be $false
            $VLAN.is_dsnoop_enabled | Should be $false
            $VLAN.is_management_vlan | Should be $false
        }

        AfterAll {
            #Always remove vlan $pester_vlan...
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            if ($VLAN) {
                if ($VLAN.is_dsnoop_enabled) {
                    #fix stupid issue... when there is already dhcp snoop enable on a vlan, it is not remove (when remove the vlan)...
                    Set-ArubaSWVlans -id $pester_vlan -name PowerArubaSW -is_dsnoop_enabled:$false
                }
                Remove-ArubaSWVlans -id $pester_vlan -noconfirm
            }
        }

    }
}

Describe  "Remove VLAN" {

    BeforeEach {
        #Always add vlan $pester_vlan...
        Add-ArubaSWVlans -id $pester_vlan
    }

    It "Remove VLAN $pester_vlan by id" {
        Remove-ArubaSWVlans -id $pester_vlan -noconfirm
        $VLAN = Get-ArubaSWVlans -id $pester_vlan
        $VLAN | Should be $NULL
    }

    It "Remove VLAN $pester_vlan by pipeline" {
        $VLAN = Get-ArubaSWVlans -id $pester_vlan
        $VLAN | Remove-ArubaSWVlans -noconfirm
        $VLAN = Get-ArubaSWVlans -id $pester_vlan
        $VLAN | Should be $NULL
    }

    AfterAll {
        #Always remove vlan $pester_vlan...
        $VLAN = Get-ArubaSWVlans -id $pester_vlan
        if ($VLAN) {
            if ($VLAN.is_dsnoop_enabled) {
                #fix stupid issue... when there is already dhcp snoop enable on a vlan, it is not remove (when remove the vlan)...
                Set-ArubaSWVlans -id $pester_vlan -name PowerArubaSW -is_dsnoop_enabled:$false
            }
            Remove-ArubaSWVlans -id $pester_vlan -noconfirm
        }
    }
}
Disconnect-ArubaSW -noconfirm
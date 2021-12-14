#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaSW @invokeParams
}

Describe  "Get VLAN" {
    It "Get VLAN Does not throw an error" {
        {
            Get-ArubaSWVlans
        } | Should -Not -Throw
    }

    It "Get ALL vlan" {
        $VLANS = Get-ArubaSWVlans
        @($VLANS).count | Should -Not -Be $NULL
    }

    It "Get the Vlan ID (1)" {
        $VLAN = Get-ArubaSWVlans -id 1
        $VLAN.vlan_id | Should -Be 1
        $VLAN.name | Should -Be "DEFAULT_VLAN"
        $VLAN.status | Should -Be "VS_PORT_BASED"
        $VLAN.type | Should -Be "VT_STATIC"
        $VLAN.is_voice_enabled | Should -Be $false
        $VLAN.is_jumbo_enabled | Should -Be $false
        $VLAN.is_dsnoop_enabled | Should -Be $false
        $VLAN.is_management_vlan | Should -Be $false
    }

    It "Get the Vlan ID 1 by name (DEFAULT_VLAN)" {
        $VLAN = Get-ArubaSWVlans -name 'DEFAULT_VLAN'
        $VLAN.vlan_id | Should -Be 1
        $VLAN.name | Should -Be "DEFAULT_VLAN"
        $VLAN.status | Should -Be "VS_PORT_BASED"
        $VLAN.type | Should -Be "VT_STATIC"
        $VLAN.is_voice_enabled | Should -Be $false
        $VLAN.is_jumbo_enabled | Should -Be $false
        $VLAN.is_dsnoop_enabled | Should -Be $false
        $VLAN.is_management_vlan | Should -Be $false
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
            Remove-ArubaSWVlans -id $pester_vlan -confirm:$false
        }
    }

    It "Add VLAN $pester_vlan (with only a id)" {
        Add-ArubaSWVlans -id $pester_vlan
        $VLAN = Get-ArubaSWVlans -id $pester_vlan
        $VLAN.vlan_id | Should -Be $pester_vlan
        $VLAN.name | Should -Be "VLAN$pester_vlan"
        $VLAN.status | Should -Be "VS_PORT_BASED"
        $VLAN.type | Should -Be "VT_STATIC"
        $VLAN.is_voice_enabled | Should -Be $false
        $VLAN.is_jumbo_enabled | Should -Be $false
        $VLAN.is_dsnoop_enabled | Should -Be $false
        $VLAN.is_management_vlan | Should -Be $false
    }

    It "Add VLAN $pester_vlan (with only a id and name PowerArubaSW)" {
        Add-ArubaSWVlans -id $pester_vlan -name PowerArubaSW
        $VLAN = Get-ArubaSWVlans -id $pester_vlan
        $VLAN.vlan_id | Should -Be $pester_vlan
        $VLAN.name | Should -Be "PowerArubaSW"
        $VLAN.status | Should -Be "VS_PORT_BASED"
        $VLAN.type | Should -Be "VT_STATIC"
        $VLAN.is_voice_enabled | Should -Be $false
        $VLAN.is_jumbo_enabled | Should -Be $false
        $VLAN.is_dsnoop_enabled | Should -Be $false
        $VLAN.is_management_vlan | Should -Be $false
    }

    It "Add VLAN $pester_vlan (with only a id and enable voice/jumbo/dhcp snoop)" {
        Add-ArubaSWVlans -id $pester_vlan -is_voice_enabled -is_jumbo_enabled -is_dsnoop_enabled
        $VLAN = Get-ArubaSWVlans -id $pester_vlan
        $VLAN.vlan_id | Should -Be $pester_vlan
        $VLAN.name | Should -Be "VLAN$pester_vlan"
        $VLAN.status | Should -Be "VS_PORT_BASED"
        $VLAN.type | Should -Be "VT_STATIC"
        $VLAN.is_voice_enabled | Should -Be $true
        $VLAN.is_jumbo_enabled | Should -Be $true
        $VLAN.is_dsnoop_enabled | Should -Be $true
        $VLAN.is_management_vlan | Should -Be $false
    }

    AfterAll {
        #Always remove vlan $pester_vlan...
        $VLAN = Get-ArubaSWVlans -id $pester_vlan
        if ($VLAN) {
            if ($VLAN.is_dsnoop_enabled) {
                #fix stupid issue... when there is already dhcp snoop enable on a vlan, it is not remove (when remove the vlan)...
                Set-ArubaSWVlans -id $pester_vlan -name PowerArubaSW -is_dsnoop_enabled:$false
            }
            Remove-ArubaSWVlans -id $pester_vlan -confirm:$false
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
            $VLAN.name | Should -Be "PowerArubaSW"
        }

        It "Configure Vlan option (enable jumbo/voice/snooping)" {
            Set-ArubaSWVlans -id $pester_vlan -is_voice_enabled -is_jumbo_enabled -is_dsnoop_enabled
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            $VLAN.vlan_id | Should -Be $pester_vlan
            $VLAN.is_voice_enabled | Should -Be $true
            $VLAN.is_jumbo_enabled | Should -Be $true
            $VLAN.is_dsnoop_enabled | Should -Be $true
            $VLAN.is_management_vlan | Should -Be $false
        }

        It "Configure Vlan option (disable jumbo/voice/snooping)" {
            Set-ArubaSWVlans -id $pester_vlan -is_voice_enabled:$false -is_jumbo_enabled:$false -is_dsnoop_enabled:$false
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            $VLAN.vlan_id | Should -Be $pester_vlan
            $VLAN.is_voice_enabled | Should -Be $false
            $VLAN.is_jumbo_enabled | Should -Be $false
            $VLAN.is_dsnoop_enabled | Should -Be $false
            $VLAN.is_management_vlan | Should -Be $false
        }

        AfterAll {
            #Always remove vlan $pester_vlan...
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            if ($VLAN) {
                if ($VLAN.is_dsnoop_enabled) {
                    #fix stupid issue... when there is already dhcp snoop enable on a vlan, it is not remove (when remove the vlan)...
                    Set-ArubaSWVlans -id $pester_vlan -name PowerArubaSW -is_dsnoop_enabled:$false
                }
                Remove-ArubaSWVlans -id $pester_vlan -confirm:$false
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
            $VLAN.name | Should -Be "PowerArubaSW"
        }

        It "Configure Vlan option (enable jumbo/voice/snooping)" {
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            $VLAN | Set-ArubaSWVlans -is_voice_enabled -is_jumbo_enabled -is_dsnoop_enabled
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            $VLAN.vlan_id | Should -Be $pester_vlan
            $VLAN.is_voice_enabled | Should -Be $true
            $VLAN.is_jumbo_enabled | Should -Be $true
            $VLAN.is_dsnoop_enabled | Should -Be $true
            $VLAN.is_management_vlan | Should -Be $false
        }

        It "Configure Vlan option (disable jumbo/voice/snooping)" {
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            $VLAN | Set-ArubaSWVlans -is_voice_enabled:$false -is_jumbo_enabled:$false -is_dsnoop_enabled:$false
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            $VLAN.vlan_id | Should -Be $pester_vlan
            $VLAN.is_voice_enabled | Should -Be $false
            $VLAN.is_jumbo_enabled | Should -Be $false
            $VLAN.is_dsnoop_enabled | Should -Be $false
            $VLAN.is_management_vlan | Should -Be $false
        }

        AfterAll {
            #Always remove vlan $pester_vlan...
            $VLAN = Get-ArubaSWVlans -id $pester_vlan
            if ($VLAN) {
                if ($VLAN.is_dsnoop_enabled) {
                    #fix stupid issue... when there is already dhcp snoop enable on a vlan, it is not remove (when remove the vlan)...
                    Set-ArubaSWVlans -id $pester_vlan -name PowerArubaSW -is_dsnoop_enabled:$false
                }
                Remove-ArubaSWVlans -id $pester_vlan -confirm:$false
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
        Remove-ArubaSWVlans -id $pester_vlan -confirm:$false
        $VLAN = Get-ArubaSWVlans -id $pester_vlan
        $VLAN | Should -Be $NULL
    }

    It "Remove VLAN $pester_vlan by pipeline" {
        $VLAN = Get-ArubaSWVlans -id $pester_vlan
        $VLAN | Remove-ArubaSWVlans -confirm:$false
        $VLAN = Get-ArubaSWVlans -id $pester_vlan
        $VLAN | Should -Be $NULL
    }

    AfterAll {
        #Always remove vlan $pester_vlan...
        $VLAN = Get-ArubaSWVlans -id $pester_vlan
        if ($VLAN) {
            if ($VLAN.is_dsnoop_enabled) {
                #fix stupid issue... when there is already dhcp snoop enable on a vlan, it is not remove (when remove the vlan)...
                Set-ArubaSWVlans -id $pester_vlan -name PowerArubaSW -is_dsnoop_enabled:$false
            }
            Remove-ArubaSWVlans -id $pester_vlan -confirm:$false
        }
    }
}

AfterAll {
    Disconnect-ArubaSW -confirm:$false
}

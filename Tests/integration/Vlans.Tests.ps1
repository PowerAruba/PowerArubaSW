#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1
#TODO: Add check if no ipaddress/login/password info...

$mysecpassword = ConvertTo-SecureString $password -AsPlainText -Force
Connect-ArubaSW -Server $ipaddress -Username $login -password $mysecpassword -httpOnly

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
        $VLAN.status | should be "VS_PORT_BASED"
        $VLAN.type | should be "VT_STATIC"
        $VLAN.is_voice_enabled | should be $false
        $VLAN.is_jumbo_enabled | should be $false
        $VLAN.is_dsnoop_enabled | should be $false
        $VLAN.is_management_vlan | should be $false
    }

    It "Get the Vlan ID 1 by name (DEFAULT_VLAN)" {
        $VLAN = Get-ArubaSWVlans -name 'DEFAULT_VLAN'
        $VLAN.vlan_id | Should Be 1
        $VLAN.name | Should be "DEFAULT_VLAN"
        $VLAN.status | should be "VS_PORT_BASED"
        $VLAN.type | should be "VT_STATIC"
        $VLAN.is_voice_enabled | should be $false
        $VLAN.is_jumbo_enabled | should be $false
        $VLAN.is_dsnoop_enabled | should be $false
        $VLAN.is_management_vlan | should be $false
    }
}

Describe  "Add VLAN" {

    BeforeEach {
        #Always remove vlan 85...
        $VLAN = Get-ArubaSWVlans -id 85
        if($VLAN) {
            if($VLAN.is_dsnoop_enabled) {
                #fix stupid issue... when there is already dhcp snoop enable on a vlan, it is not remove (when remove the vlan)...
                Set-ArubaSWVlans -id 85 -name PowerArubaSW -is_dsnoop_enabled:$false
            }
            Remove-ArubaSWVlans -id 85 -noconfirm
        }
    }

    It "Add VLAN 85 (with only a id)" {
        Add-ArubaSWVlans -id 85
        $VLAN = Get-ArubaSWVlans -id 85
        $VLAN.vlan_id | Should Be 85
        $VLAN.name | Should be "VLAN85"
        $VLAN.status | should be "VS_PORT_BASED"
        $VLAN.type | should be "VT_STATIC"
        $VLAN.is_voice_enabled | should be $false
        $VLAN.is_jumbo_enabled | should be $false
        $VLAN.is_dsnoop_enabled | should be $false
        $VLAN.is_management_vlan | should be $false
    }

    It "Add VLAN 85 (with only a id and name PowerArubaSW)" {
        Add-ArubaSWVlans -id 85 -name PowerArubaSW
        $VLAN = Get-ArubaSWVlans -id 85
        $VLAN.vlan_id | Should Be 85
        $VLAN.name | Should be "PowerArubaSW"
        $VLAN.status | should be "VS_PORT_BASED"
        $VLAN.type | should be "VT_STATIC"
        $VLAN.is_voice_enabled | should be $false
        $VLAN.is_jumbo_enabled | should be $false
        $VLAN.is_dsnoop_enabled | should be $false
        $VLAN.is_management_vlan | should be $false
    }

    It "Add VLAN 85 (with only a id and enable voice/jumbo/dhcp snoop)" {
        Add-ArubaSWVlans -id 85 -is_voice_enabled -is_jumbo_enabled -is_dsnoop_enabled
        $VLAN = Get-ArubaSWVlans -id 85
        $VLAN.vlan_id | Should Be 85
        $VLAN.name | Should be "VLAN85"
        $VLAN.status | should be "VS_PORT_BASED"
        $VLAN.type | should be "VT_STATIC"
        $VLAN.is_voice_enabled | should be $true
        $VLAN.is_jumbo_enabled | should be $true
        $VLAN.is_dsnoop_enabled | should be $true
        $VLAN.is_management_vlan | should be $false
    }

    AfterAll {
        #Always remove vlan 85...
        $VLAN = Get-ArubaSWVlans -id 85
        if($VLAN) {
            if($VLAN.is_dsnoop_enabled) {
                #fix stupid issue... when there is already dhcp snoop enable on a vlan, it is not remove (when remove the vlan)...
                Set-ArubaSWVlans -id 85 -name PowerArubaSW -is_dsnoop_enabled:$false
            }
            Remove-ArubaSWVlans -id 85 -noconfirm
        }
    }
}


Describe  "Configure VLAN" {

    Context "Configure VLAN via ID" {
        BeforeAll {
            #Always add vlan 85...
            Add-ArubaSWVlans -id 85
        }

        It "Configure VLAN name" {
            Set-ArubaSWVLans -id 85 -name "PowerArubaSW"
            $VLAN = Get-ArubaSWVlans -id 85
            $VLAN.name | should be "PowerArubaSW"
        }

        It "Configure Vlan option (enable jumbo/voice/snooping)" {
            Set-ArubaSWVLans -id 85 -is_voice_enabled -is_jumbo_enabled -is_dsnoop_enabled
            $VLAN = Get-ArubaSWVlans -id 85
            $VLAN.vlan_id | Should Be 85
            $VLAN.is_voice_enabled | should be $true
            $VLAN.is_jumbo_enabled | should be $true
            $VLAN.is_dsnoop_enabled | should be $true
            $VLAN.is_management_vlan | should be $false
        }

        It "Configure Vlan option (disable jumbo/voice/snooping)" {
            Set-ArubaSWVLans -id 85 -is_voice_enabled:$false -is_jumbo_enabled:$false -is_dsnoop_enabled:$false
            $VLAN = Get-ArubaSWVlans -id 85
            $VLAN.vlan_id | Should Be 85
            $VLAN.is_voice_enabled | should be $false
            $VLAN.is_jumbo_enabled | should be $false
            $VLAN.is_dsnoop_enabled | should be $false
            $VLAN.is_management_vlan | should be $false
        }

        AfterAll {
            #Always remove vlan 85...
            $VLAN = Get-ArubaSWVlans -id 85
            if($VLAN) {
                if($VLAN.is_dsnoop_enabled) {
                    #fix stupid issue... when there is already dhcp snoop enable on a vlan, it is not remove (when remove the vlan)...
                    Set-ArubaSWVlans -id 85 -name PowerArubaSW -is_dsnoop_enabled:$false
                }
                Remove-ArubaSWVlans -id 85 -noconfirm
            }
        }
    }

    Context "Configure VLAN via pipeline" {
        BeforeAll {
            #Always add vlan 85...
            Add-ArubaSWVlans -id 85
        }

        It "Configure VLAN name" {
            $VLAN = Get-ArubaSWVlans -id 85
            $VLAN | Set-ArubaSWVLans -name "PowerArubaSW"
            $VLAN = Get-ArubaSWVlans -id 85
            $VLAN.name | should be "PowerArubaSW"
        }

        It "Configure Vlan option (enable jumbo/voice/snooping)" {
            $VLAN = Get-ArubaSWVlans -id 85
            $VLAN | Set-ArubaSWVLans -is_voice_enabled -is_jumbo_enabled -is_dsnoop_enabled
            $VLAN = Get-ArubaSWVlans -id 85
            $VLAN.vlan_id | Should Be 85
            $VLAN.is_voice_enabled | should be $true
            $VLAN.is_jumbo_enabled | should be $true
            $VLAN.is_dsnoop_enabled | should be $true
            $VLAN.is_management_vlan | should be $false
        }

        It "Configure Vlan option (disable jumbo/voice/snooping)" {
            $VLAN = Get-ArubaSWVlans -id 85
            $VLAN | Set-ArubaSWVLans -is_voice_enabled:$false -is_jumbo_enabled:$false -is_dsnoop_enabled:$false
            $VLAN = Get-ArubaSWVlans -id 85
            $VLAN.vlan_id | Should Be 85
            $VLAN.is_voice_enabled | should be $false
            $VLAN.is_jumbo_enabled | should be $false
            $VLAN.is_dsnoop_enabled | should be $false
            $VLAN.is_management_vlan | should be $false
        }

        AfterAll {
            #Always remove vlan 85...
            $VLAN = Get-ArubaSWVlans -id 85
            if($VLAN) {
                if($VLAN.is_dsnoop_enabled) {
                    #fix stupid issue... when there is already dhcp snoop enable on a vlan, it is not remove (when remove the vlan)...
                    Set-ArubaSWVlans -id 85 -name PowerArubaSW -is_dsnoop_enabled:$false
                }
                Remove-ArubaSWVlans -id 85 -noconfirm
            }
        }

    }
}

Describe  "Remove VLAN" {

    BeforeEach {
        #Always add vlan 85...
        Add-ArubaSWVlans -id 85
    }

    It "Remove VLAN 85 by id" {
        Remove-ArubaSWVlans -id 85 -noconfirm
        $VLAN = Get-ArubaSWVlans -id 85
        $VLAN | should be $NULL
    }

    It "Remove VLAN 85 by pipeline" {
        $VLAN = Get-ArubaSWVlans -id 85
        $VLAN | Remove-ArubaSWVlans -noconfirm
        $VLAN = Get-ArubaSWVlans -id 85
        $VLAN | should be $NULL
    }

    AfterAll {
        #Always remove vlan 85...
        $VLAN = Get-ArubaSWVlans -id 85
        if($VLAN) {
            if($VLAN.is_dsnoop_enabled) {
                #fix stupid issue... when there is already dhcp snoop enable on a vlan, it is not remove (when remove the vlan)...
                Set-ArubaSWVlans -id 85 -name PowerArubaSW -is_dsnoop_enabled:$false
            }
            Remove-ArubaSWVlans -id 85 -noconfirm
        }
    }
}
Disconnect-ArubaSW -noconfirm
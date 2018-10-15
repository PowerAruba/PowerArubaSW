#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Get Vlans Ports" {
    BeforeAll {
        Add-ArubaSWVlans -id 85
    }
    It "Get VLAN Ports Does not throw an error" {
        {
            Get-ArubaSWVlansPorts
        } | Should Not Throw 
    }

    It "Get ALL vlans Ports" {
            $VLANS_PORTS = Get-ArubaSWVlansPorts
            $VLANS_PORTS.count | Should not be $NULL
    }

    It "Get the Vlan Port by port_id (8)" {
        $VLANP = Get-ArubaSWVlansPorts -port_id 8
        $VLANP.vlan_id | Should Be 1
        $VLANP.port_id | Should be 8
        $VLANP.port_mode | should be "POM_UNTAGGED"
    }

    It "Get the Vlan Port by vlan_id (85)" {
        Add-ArubaSWVlansPorts -vlan_id 85 -port_id 8 -port_mode Untagged
        $VLANP = Get-ArubaSWVlansPorts -port_id 8
        $VLANP.vlan_id | Should Be 85
        $VLANP.port_id | Should be 8
        $VLANP.port_mode | should be "POM_UNTAGGED"
    }
    
    AfterAll {
        Remove-ArubaSWVlans -id 85 -noconfirm
    }
}

Describe  "Configure (Add/Set/Remove) Vlans Ports" {
    BeforeAll {
        Add-ArubaSWVlans -id 85
    }

    Context "Configure Vlan via port_id" {
        It "Add vlan_id 85 on port_id 8 (untagged)" {
            Add-ArubaSWVlansPorts -vlan_id 85 -port_id 8 -port_mode Untagged
            $VLANP = Get-ArubaSWVlansPorts -port_id 8
            $VLANP.vlan_id | Should Be 85
            $VLANP.port_id | Should be 8
            $VLANP.port_mode | should be "POM_UNTAGGED"
        }

        It "Set vlan_id 85 on port_id 8 (tagged)" {
            Set-ArubaSWVlansPorts -vlan_id 85 -port_id 8 -port_mode tagged
            $VLANP = Get-ArubaSWVlansPorts -port_id 8
            $VLANP.vlan_id | Should Be 85
            $VLANP.port_id | Should be 8
            $VLANP.port_mode | should be "POM_TAGGED_STATIC"
        }

        It "Remove vlan_id 85 on port_id 8" {
            Remove-ArubaSWVlansPorts -vlan_id 85 -port_id 8 -noconfirm
            $VLANP = Get-ArubaSWVlansPorts -port_id 8
            $VLANP.vlan_id | Should Be 1
            $VLANP.port_id | Should be 8
            $VLANP.port_mode | should be "POM_UNTAGGED"
        }

        It "Add vlan_id 85 on port_id 8 (tagged)" {
            Add-ArubaSWVlansPorts -vlan_id 85 -port_id 8 -port_mode tagged
            $VLANP = Get-ArubaSWVlansPorts -port_id 8 -vlan_id 85
            $VLANP.vlan_id | Should Be 85
            $VLANP.port_id | Should be 8
            $VLANP.port_mode | should be "POM_TAGGED_STATIC"
        }

        It "Set vlan_id 85 on port_id 8 (untagged)" {
            Set-ArubaSWVlansPorts -vlan_id 85 -port_id 8 -port_mode untagged
            $VLANP = Get-ArubaSWVlansPorts -port_id 8
            $VLANP.vlan_id | Should Be 85
            $VLANP.port_id | Should be 8
            $VLANP.port_mode | should be "POM_UNTAGGED"
        }

        It "Remove vlan_id 85 on port_id 8" {
            Remove-ArubaSWVlansPorts -vlan_id 85 -port_id 8 -noconfirm
            $VLANP = Get-ArubaSWVlansPorts -port_id 8
            $VLANP.vlan_id | Should Be 1
            $VLANP.port_id | Should be 8
            $VLANP.port_mode | should be "POM_UNTAGGED"
        }
    }

    Context "Configure Vlan via pipeline (or position arg)" {
        It "Add vlan_id 85 on port_id 8 (untagged)" {
            Add-ArubaSWVlansPorts 85 8 Untagged
            $VLANP = Get-ArubaSWVlansPorts -port_id 8
            $VLANP.vlan_id | Should Be 85
            $VLANP.port_id | Should be 8
            $VLANP.port_mode | should be "POM_UNTAGGED"
        }

        It "Set vlan_id 85 on port_id 8 (tagged)" {
            $VLANP = Get-ArubaSWVlansPorts -port_id 8 -vlan_id 85
            $VLANP | Set-ArubaSWVlansPorts -port_mode tagged
            $VLANP = Get-ArubaSWVlansPorts -port_id 8
            $VLANP.vlan_id | Should Be 85
            $VLANP.port_id | Should be 8
            $VLANP.port_mode | should be "POM_TAGGED_STATIC"
        }

        It "Remove vlan_id 85 on port_id 8" {
            $VLANP = Get-ArubaSWVlansPorts -port_id 8 -vlan_id 85
            $VLANP | Remove-ArubaSWVlansPorts -noconfirm
            $VLANP = Get-ArubaSWVlansPorts -port_id 8
            $VLANP.vlan_id | Should Be 1
            $VLANP.port_id | Should be 8
            $VLANP.port_mode | should be "POM_UNTAGGED"
        }

        It "Add vlan_id 85 on port_id 8 (tagged)" {
            Add-ArubaSWVlansPorts 85 8 tagged
            $VLANP = Get-ArubaSWVlansPorts -port_id 8 -vlan_id 85
            $VLANP.vlan_id | Should Be 85
            $VLANP.port_id | Should be 8
            $VLANP.port_mode | should be "POM_TAGGED_STATIC"
        }

        It "Set vlan_id 85 on port_id 8 (untagged)" {
            $VLANP = Get-ArubaSWVlansPorts -port_id 8 -vlan_id 85
            $VLANP | Set-ArubaSWVlansPorts -port_mode untagged
            $VLANP = Get-ArubaSWVlansPorts -port_id 8
            $VLANP.vlan_id | Should Be 85
            $VLANP.port_id | Should be 8
            $VLANP.port_mode | should be "POM_UNTAGGED"
        }

        It "Remove vlan_id 85 on port_id 8" {
            $VLANP = Get-ArubaSWVlansPorts -port_id 8 -vlan_id 85
            $VLANP | Remove-ArubaSWVlansPorts -noconfirm
            $VLANP = Get-ArubaSWVlansPorts -port_id 8
            $VLANP.vlan_id | Should Be 1
            $VLANP.port_id | Should be 8
            $VLANP.port_mode | should be "POM_UNTAGGED"
        }
    }

    AfterAll {
        Remove-ArubaSWVlans -id 85 -noconfirm
    }
}

Disconnect-ArubaSW -noconfirm
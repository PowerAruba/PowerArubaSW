#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaSW @invokeParams
}

Describe  "Get Vlans Ports" {
    BeforeAll {
        Add-ArubaSWVlans -id $pester_vlan
    }
    It "Get VLAN Ports Does not throw an error" {
        {
            Get-ArubaSWVlansPorts
        } | Should -Not -Throw
    }

    It "Get ALL vlans Ports" {
        $VLANS_PORTS = Get-ArubaSWVlansPorts
        $VLANS_PORTS.count | Should -Not -Be $NULL
    }

    It "Get the Vlan Port by port_id ($pester_vlanport)" {
        $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport
        $VLANP.vlan_id | Should -Be 1
        $VLANP.port_id | Should -Be $pester_vlanport
        $VLANP.port_mode | Should -Be "POM_UNTAGGED"
    }

    It "Get the Vlan Port by vlan_id ($pester_vlan)" {
        Add-ArubaSWVlansPorts -vlan_id $pester_vlan -port_id $pester_vlanport -port_mode Untagged
        $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport
        $VLANP.vlan_id | Should -Be $pester_vlan
        $VLANP.port_id | Should -Be $pester_vlanport
        $VLANP.port_mode | Should -Be "POM_UNTAGGED"
    }

    AfterAll {
        Remove-ArubaSWVlans -id $pester_vlan -noconfirm
    }
}

Describe  "Configure (Add/Set/Remove) Vlans Ports" {
    BeforeAll {
        Add-ArubaSWVlans -id $pester_vlan
    }

    Context "Configure Vlan via port_id" {
        It "Add vlan_id $pester_vlan on port_id $pester_vlanport (untagged)" {
            Add-ArubaSWVlansPorts -vlan_id $pester_vlan -port_id $pester_vlanport -port_mode Untagged
            $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport
            $VLANP.vlan_id | Should -Be $pester_vlan
            $VLANP.port_id | Should -Be $pester_vlanport
            $VLANP.port_mode | Should -Be "POM_UNTAGGED"
        }

        It "Set vlan_id $pester_vlan on port_id $pester_vlanport (tagged)" {
            Set-ArubaSWVlansPorts -vlan_id $pester_vlan -port_id $pester_vlanport -port_mode tagged
            $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport
            $VLANP.vlan_id | Should -Be $pester_vlan
            $VLANP.port_id | Should -Be $pester_vlanport
            $VLANP.port_mode | Should -Be "POM_TAGGED_STATIC"
        }

        It "Remove vlan_id $pester_vlan on port_id $pester_vlanport" {
            Remove-ArubaSWVlansPorts -vlan_id $pester_vlan -port_id $pester_vlanport -noconfirm
            $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport
            $VLANP.vlan_id | Should -Be 1
            $VLANP.port_id | Should -Be $pester_vlanport
            $VLANP.port_mode | Should -Be "POM_UNTAGGED"
        }

        It "Add vlan_id $pester_vlan on port_id $pester_vlanport (tagged)" {
            Add-ArubaSWVlansPorts -vlan_id $pester_vlan -port_id $pester_vlanport -port_mode tagged
            $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport -vlan_id $pester_vlan
            $VLANP.vlan_id | Should -Be $pester_vlan
            $VLANP.port_id | Should -Be $pester_vlanport
            $VLANP.port_mode | Should -Be "POM_TAGGED_STATIC"
        }

        It "Set vlan_id $pester_vlan on port_id $pester_vlanport (untagged)" {
            Set-ArubaSWVlansPorts -vlan_id $pester_vlan -port_id $pester_vlanport -port_mode untagged
            $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport
            $VLANP.vlan_id | Should -Be $pester_vlan
            $VLANP.port_id | Should -Be $pester_vlanport
            $VLANP.port_mode | Should -Be "POM_UNTAGGED"
        }

        It "Remove vlan_id $pester_vlan on port_id $pester_vlanport" {
            Remove-ArubaSWVlansPorts -vlan_id $pester_vlan -port_id $pester_vlanport -noconfirm
            $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport
            $VLANP.vlan_id | Should -Be 1
            $VLANP.port_id | Should -Be $pester_vlanport
            $VLANP.port_mode | Should -Be "POM_UNTAGGED"
        }
    }

    Context "Configure Vlan via pipeline (or position arg)" {
        It "Add vlan_id $pester_vlan on port_id $pester_vlanport (untagged)" {
            Add-ArubaSWVlansPorts $pester_vlan $pester_vlanport Untagged
            $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport
            $VLANP.vlan_id | Should -Be $pester_vlan
            $VLANP.port_id | Should -Be $pester_vlanport
            $VLANP.port_mode | Should -Be "POM_UNTAGGED"
        }

        It "Set vlan_id $pester_vlan on port_id $pester_vlanport (tagged)" {
            $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport -vlan_id $pester_vlan
            $VLANP | Set-ArubaSWVlansPorts -port_mode tagged
            $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport
            $VLANP.vlan_id | Should -Be $pester_vlan
            $VLANP.port_id | Should -Be $pester_vlanport
            $VLANP.port_mode | Should -Be "POM_TAGGED_STATIC"
        }

        It "Remove vlan_id $pester_vlan on port_id $pester_vlanport" {
            $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport -vlan_id $pester_vlan
            $VLANP | Remove-ArubaSWVlansPorts -noconfirm
            $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport
            $VLANP.vlan_id | Should -Be 1
            $VLANP.port_id | Should -Be $pester_vlanport
            $VLANP.port_mode | Should -Be "POM_UNTAGGED"
        }

        It "Add vlan_id $pester_vlan on port_id $pester_vlanport (tagged)" {
            Add-ArubaSWVlansPorts $pester_vlan $pester_vlanport tagged
            $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport -vlan_id $pester_vlan
            $VLANP.vlan_id | Should -Be $pester_vlan
            $VLANP.port_id | Should -Be $pester_vlanport
            $VLANP.port_mode | Should -Be "POM_TAGGED_STATIC"
        }

        It "Set vlan_id $pester_vlan on port_id $pester_vlanport (untagged)" {
            $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport -vlan_id $pester_vlan
            $VLANP | Set-ArubaSWVlansPorts -port_mode untagged
            $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport
            $VLANP.vlan_id | Should -Be $pester_vlan
            $VLANP.port_id | Should -Be $pester_vlanport
            $VLANP.port_mode | Should -Be "POM_UNTAGGED"
        }

        It "Remove vlan_id $pester_vlan on port_id $pester_vlanport" {
            $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport -vlan_id $pester_vlan
            $VLANP | Remove-ArubaSWVlansPorts -noconfirm
            $VLANP = Get-ArubaSWVlansPorts -port_id $pester_vlanport
            $VLANP.vlan_id | Should -Be 1
            $VLANP.port_id | Should -Be $pester_vlanport
            $VLANP.port_mode | Should -Be "POM_UNTAGGED"
        }
    }

    AfterAll {
        Remove-ArubaSWVlans -id $pester_vlan -noconfirm
    }
}

AfterAll {
    Disconnect-ArubaSW -noconfirm
}
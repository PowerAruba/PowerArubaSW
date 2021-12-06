#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaSW @invokeParams
}

Describe  "Get Mac Table" {

    BeforeAll {
        #Select the first entry for search after...
        $pester_mactable = Get-ArubaSWMacTable
        $script:pester_mactable_port_id = $pester_mactable[0].port_id
        $script:pester_mactable_vlan_id = $pester_mactable[0].vlan_id
        $script:pester_mactable_mac_address = $pester_mactable[0].mac_address
    }

    It "Get Mac Table Does not throw an error" {
        {
            Get-ArubaSWMacTable
        } | Should -Not -Throw
    }

    It "Get ALL Mac Table" {
        $mactable = Get-ArubaSWMacTable
        $mactable.count | Should -Not -Be $NULL
    }

    It "Get the Mac Table by Port id ($pester_mactable_port_id)" {
        $mactable = Get-ArubaSWMacTable -port_id $pester_mactable_port_id
        $mactable[0].port_id | Should -Be $pester_mactable_port_id
    }

    It "Get the Mac Table by Vlan id ($pester_mactable_vlan_id)" {
        $mactable = Get-ArubaSWMacTable -vlan_id $pester_mactable_vlan_id
        $mactable[0].vlan_id | Should -Be $pester_mactable_vlan_id
    }

    Context "Get the Mac Table by MAC Address ($pester_mactable_mac_address)" {
        BeforeAll {
            #From https://github.com/lazywinadmin/PowerShell/blob/master/TOOL-Clean-MacAddress/Clean-MacAddress.ps1
            $mac_clean = $pester_mactable_mac_address
            $mac_clean = $mac_clean -replace "-", "" #Replace Dash
            $mac_clean = $mac_clean -replace ":", "" #Replace Colon
            $mac_clean = $mac_clean -replace "/s", "" #Remove whitespace
            $mac_clean = $mac_clean -replace " ", "" #Remove whitespace
            $mac_clean = $mac_clean -replace "\.", "" #Remove dots
            $mac_clean = $mac_clean.trim() #Remove space at the beginning
            $mac_clean = $mac_clean.trimend() #Remove space at the end
            $script:mac_nospace = $mac_clean
            $script:mac_colon = $mac_clean -replace '(..(?!$))', "`$1:"
            $script:mac_dash = $mac_clean -replace '(..(?!$))', "`$1-"
        }

        It "Get the Mac Table by MAC Address with colon ($mac_colon)" {
            $mactable = Get-ArubaSWMacTable -mac_address $mac_colon
            $mactable.mac_address | Should -Be $pester_mactable_mac_address
        }
        It "Get the Mac Table by MAC Address with dash ($mac_dash)" {
            $mactable = Get-ArubaSWMacTable -mac_address $mac_dash
            $mactable.mac_address | Should -Be $pester_mactable_mac_address
        }

        It "Get the Mac Table by MAC Address with central dash ($pester_mactable_mac_address)" {
            $mactable = Get-ArubaSWMacTable -mac_address $pester_mactable_mac_address
            $mactable.mac_address | Should -Be $pester_mactable_mac_address
        }

        It "Get the Mac Table by MAC Address with no space ($mac_nospace))" {
            $mactable = Get-ArubaSWMacTable -mac_address $mac_nospace
            $mactable.mac_address | Should -Be $pester_mactable_mac_address
        }
    }
}

AfterAll {
    Disconnect-ArubaSW -confirm:$false
}
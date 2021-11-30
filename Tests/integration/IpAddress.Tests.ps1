#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

BeforeAll {
    Connect-ArubaSW @invokeParams
}

Describe  "Get-ArubaSWIPAddress" {
    It "Get-ArubaSWIPAddress Does not throw an error" {
        { Get-ArubaSWIPAddress } | Should -Not -Throw
    }

    It "Get IP Address(es) of Switch" {
        $ipaddress = Get-ArubaSWIPAddress
        $ipaddress | Should -Not -Be $NULL
        $ipaddress.ip_address_mode | Should -BeOfType string
        $ipaddress.vlan_id | Should -BeOfType $pester_longint
    }
}

AfterAll {
    Disconnect-ArubaSW -noconfirm
}
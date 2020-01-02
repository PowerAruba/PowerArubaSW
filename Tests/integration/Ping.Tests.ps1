#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

Describe  "Ping (ipv4_address)" {
    beforeAll {
        $script:ipv4_gateway = (Get-ArubaSWSystem).default_gateway.octets
    }

    It "Ping a valid IP(v4) address (Default Gateway:$script:ipv4_gateway)" {
        $ping = Test-ArubaSWPing -ipv4_address $script:ipv4_gateway
        $ping.result | Should -Be "PR_OK"
        $ping.rtt_in_milliseconds | Should -Not -BeNullOrEmpty
    }

    It "Ping a invalid IP(v4) address (0.0.0.0)" {
        $ping = Test-ArubaSWPing -ipv4_address 0.0.0.0
        $ping.result | Should -Be "PR_INVALID_ADDRESS"
    }
}



Disconnect-ArubaSW -noconfirm

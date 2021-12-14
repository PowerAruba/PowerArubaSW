#
# Copyright 2018-2020, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

BeforeAll {
    Connect-ArubaSW @invokeParams
}

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


Describe  "Ping (-hostname)" {

    BeforeAll {
        #Always remove DNS Settings...
        Remove-ArubaSWDns -confirm:$false
    }

    It "Ping a hostname (without DNS config)" {
        $ping = Test-ArubaSWPing -hostname www.arubanetworks.com
        $ping.result | Should -Be "PR_UNABLE_TO_RESOLVE_HOST_NAME"
    }

    It "Ping a hostname (with DNS config $pester_dns1 / $pester_dns2)" {
        #Configure DNS
        Set-ArubaSWDns -mode Manual -server1 $pester_dns1 -server2 $pester_dns2
        $ping = Test-ArubaSWPing -hostname www.arubanetworks.com
        $ping.result | Should -Be "PR_OK"
        $ping.rtt_in_milliseconds | Should -Not -BeNullOrEmpty
    }

    AfterAll {
        #Always remove DNS Settings...
        Remove-ArubaSWDns -confirm:$false
    }

}

AfterAll {
    Disconnect-ArubaSW -confirm:$false
}

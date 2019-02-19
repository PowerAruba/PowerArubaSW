#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

Describe  "Get-ArubaSWDns" {
    It "Get-ArubaSWDns Does not throw an error" {
        { Get-ArubaSWDns } | Should Not Throw
    }
}

Describe  "Set-ArubaSWDns" {

    BeforeEach {
        #Always DNS Settings...
        Remove-ArubaSWDns -noconfirm
    }

    It "Set ArubaSWDns ip server 1" {
        Set-ArubaSWDns -mode Manual -server1 1.1.1.1
        $dns = Get-ArubaSWDns
        $dns.server_1.version | Should be "IAV_IP_V4"
        $dns.server_1.octets | Should be "1.1.1.1"
        $dns.server_2 | Should -BeNullOrEmpty
        $dns.dns_domain_names | Should -BeNullOrEmpty
    }

    It "Set ArubaSWDns ip server 2" {
        Set-ArubaSWDns -mode Manual -server2 8.8.8.8
        $dns = Get-ArubaSWDns
        $dns.server_1 | Should -BeNullOrEmpty
        $dns.server_2.version | Should be "IAV_IP_V4"
        $dns.server_2.octets | Should be "8.8.8.8"
        $dns.dns_domain_names | Should -BeNullOrEmpty
    }

    It "Set ArubaSWDns dns domain names" {
        Set-ArubaSWDns -mode Manual -server1 1.1.1.1 -server2 8.8.8.8 -domain example.org
        $dns = Get-ArubaSWDns
        $dns.server_1.version | Should be "IAV_IP_V4"
        $dns.server_1.octets | Should be "1.1.1.1"
        $dns.server_2.version | Should be "IAV_IP_V4"
        $dns.server_2.octets | Should be "8.8.8.8"
        $dns.dns_domain_names | Should be "example.org"
    }

    It "Set ArubaSWDns dns (multiple) domain names" {
        Set-ArubaSWDns -mode Manual -server1 1.1.1.1 -server2 8.8.8.8 -domain example.org, example.net
        $dns = Get-ArubaSWDns
        $dns.server_1.version | Should be "IAV_IP_V4"
        $dns.server_1.octets | Should be "1.1.1.1"
        $dns.server_2.version | Should be "IAV_IP_V4"
        $dns.server_2.octets | Should be "8.8.8.8"
        $dns.dns_domain_names[0] | Should be "example.org"
        $dns.dns_domain_names[1] | Should be "example.net"
    }

    AfterAll {
        #Always DNS Settings...
        Remove-ArubaSWDns -noconfirm
    }

}

Describe  "Remove-ArubaSWDns" {
    It "Remove ArubaSWDns" {
        Set-ArubaSWDns -mode Manual -server1 1.1.1.1 -server2 8.8.8.8 -domain example.org
        Remove-ArubaSWDns -noconfirm
        $dns = Get-ArubaSWDns
        $dns.dns_config_mode | Should be "DCM_DISABLED"
        $dns.server_1 | Should -BeNullOrEmpty
        $dns.server_2 | Should -BeNullOrEmpty
        $dns.dns_domain_names | Should -BeNullOrEmpty
    }
}

Disconnect-ArubaSW -noconfirm
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
    It "Set ArubaSWDns ip server 1" {
        Set-ArubaSWDns -mode Manual -server1 1.1.1.1
        $dns = Get-ArubaSWDns
        $dns.server_1.version | Should be "IAV_IP_V4"
        $dns.server_1.octets | Should be "1.1.1.1"
        $dns.server_2 | Should -BeNullOrEmpty
        $dns.dns_domain_names | Should -BeNullOrEmpty
        Remove-ArubaSWDns -mode Manual -noconfirm
    }

    It "Set ArubaSWDns ip server 2" {
        Set-ArubaSWDns -mode Manual -server2 8.8.8.8
        $dns = Get-ArubaSWDns
        $dns.server_1 | Should -BeNullOrEmpty
        $dns.server_2.version | Should be "IAV_IP_V4"
        $dns.server_2.octets | Should be "8.8.8.8"
        $dns.dns_domain_names | Should -BeNullOrEmpty
        Remove-ArubaSWDns -mode Manual -noconfirm
    }

    It "Set ArubaSWDns dns domain names" {
        Set-ArubaSWDns -mode Manual -server1 1.1.1.1 -server2 8.8.8.8 -domain example.org
        $dns = Get-ArubaSWDns
        $dns.server_1.version | Should be "IAV_IP_V4"
        $dns.server_1.octets | Should be "1.1.1.1"
        $dns.server_2.version | Should be "IAV_IP_V4"
        $dns.server_2.octets | Should be "8.8.8.8"
        $dns.dns_domain_names | Should be "example.org"
        Remove-ArubaSWDns -mode Manual -noconfirm
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
        Remove-ArubaSWDns -mode Manual -noconfirm
    }
}

Describe  "Remove-ArubaSWDns" {
    It "Remove ArubaSWDns (Mode Manual)" {
        Set-ArubaSWDns -mode Manual -server1 1.1.1.1 -server2 8.8.8.8 -domain example.org
        Remove-ArubaSWDns -mode Manual -noconfirm
        $dns = Get-ArubaSWDns
        $dns.dns_config_mode | Should be "DCM_MANUAL"
        $dns.server_1 | Should -BeNullOrEmpty
        $dns.server_2 | Should -BeNullOrEmpty
        $dns.dns_domain_names | Should -BeNullOrEmpty
    }
}

Disconnect-ArubaSW -noconfirm
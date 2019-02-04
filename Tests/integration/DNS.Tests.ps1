#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

../common.ps1

#$mysecpassword = ConvertTo-SecureString $password -AsPlainText -Force
#Connect-ArubaSW -Server $ipaddress -Username $login -password $mysecpassword

Describe  "Get-ArubaSWDns" {
    It "Get-ArubaSWDns Does not throw an error" {
        { Get-ArubaSWDns } | Should Not Throw 
    }
}

Describe  "Set-ArubaSWDns" {
    It "Set ArubaSWDns ip server 1" {
        Set-ArubaSWDns -mode Manual -server1 10.44.1.1
        $dns = Get-ArubaSWDns 
        $dns.server_1.octets | Should be "10.44.1.1"
        Remove-ArubaSWDns -mode Manual -server1 none
    }

    It "Set ArubaSWDns ip server 2" {
        Set-ArubaSWDns -mode Manual -server2 8.8.8.8
        $dns = Get-ArubaSWDns 
        $dns.server_2.octets | Should be "8.8.8.8"
        Remove-ArubaSWDns -mode Manual -server2 none
    }

    It "Set ArubaSWDns dns domain names" {
        Set-ArubaSWDns -mode Manual -server1 10.44.1.1 -server2 8.8.8.8 -domain test,tttt
        $dns = Get-ArubaSWDns
        $dns.dns_domain_names | Should be "test,tttt"
        Remove-ArubaSWDns -mode Manual -server1 none -server2 none 
    }
}

Disconnect-ArubaSW -noconfirm
#
# Copyright 2019, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
..\common.ps1

Describe  "Get VSF global config" {
    It "Get ArubaSWVsfGlobalConfig Does not throw an error" {
        {
            Get-ArubaSWVsfGlobalConfig
        } | Should Not Throw 
    }

    It "Get-ArubaSWVsfGlobalConfig" {
        $vsf = Get-ArubaSWVsfGlobalConfig
        $vsf | Should not be $NULL
    }
}

Describe  "Set-ArubaSWVsfGlobalConfig" {
    It "Change VSF global config value" {
        $default = Get-ArubaSWVsfGlobalConfig
        Set-ArubaSWVsfGlobalConfig -domain_id 2 -lldp_mad_enable True 
        $vsf = Get-ArubaSWVsfGlobalConfig
        $vsf.domain_id | Should be "2"
        $vsf.is_lldp_mad_enabled | Should be "True"
        Set-ArubaSWVsfGlobalConfig -domain_id $default.domain_id -lldp_mad_enable $default.is_lldp_mad_enabled
    }
}

Describe  "Get VSF members" {
    It "Get ArubaSWVsfGlobalConfig Does not throw an error" {
        {
            Get-ArubaSWVsfMembers
        } | Should Not Throw 
    }

    It "Get-ArubaSWVsfMembers" {
        $vsfmem = Get-ArubaSWVsfMembers
        $vsfmem | Should not be $NULL
    }
}

Describe  "Set-ArubaSWVsfMember" {
    It "Change VSF member value" {
        $default = Get-ArubaSWVsfMembers
        Set-ArubaSWVsfMember -member_id 1 -priority 255 
        $vsfme = Get-ArubaSWVsfMembers | Where-Object member_id -eq 1
        $vsfme.member_id | Should be "1"
        $vsfme.priority | Should be "255"
        Set-ArubaSWVsfMember -domain_id $default.domain_id -lldp_mad_enable $default.is_lldp_mad_enabled
    }
}

Disconnect-ArubaSW -noconfirm
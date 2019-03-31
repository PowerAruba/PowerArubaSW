#
# Copyright 2019, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

Describe  "Get ArubaSWSTP" {
    It "Get-ArubaSWSTP Does not throw an error" {
        {
            Get-ArubaSWSTP
        } | Should Not Throw
    }

    It "Get ArubaSWSTP" {
        $stp = Get-ArubaSWSTP
        $stp | Should not be $NULL
    }
}


Describe  "Get ArubaSWSTPPortStatus" {
    It "Get-ArubaSWSTPPortStatus Does not throw an error" {
        {
            Get-ArubaSWSTPPortStatus
        } | Should Not Throw
    }

    It "Get ArubaSWSTP" {
        $stp = Get-ArubaSWSTPPortStatus
        $stp | Should not be $NULL
    }
}

Describe  "Set ArubaSWSTPGlobal" {
    It "Change status, priority and mode" {
        $def = Get-ArubaSWSTP
        Set-ArubaSWSTPGlobal -enable Off -priority 2 -mode rpvst
        $stp = Get-ArubaSWSTP
        $stp.is_enabled | Should be "False"
        $stp.priority | Should be "2"
        $stp.mode | Should be "STM_RPVST"
        Set-ArubaSWSTPGlobal -enable $def.is_enabled -priority $def.priority -mode $def.mode
    }
}

Describe  "Get ArubaSWSTPPort" {
    It "Get-ArubaSWSTPPort Does not throw an error" {
        {
            Get-ArubaSWSTPPort -port 3
        } | Should Not Throw
    }

    It "Get-ArubaSWSTPPort" {
        $stp = Get-ArubaSWSTPPort -port 3
        $stp | Should not be $NULL
    }
}

Describe  "Set ArubaSWSTPPort" {
    It "Change priority, admin edge port, bpdu protection, bpdu filter, bpdu guard" {
        $def = Get-ArubaSWSTPPort -port 3
        Set-ArubaSWSTPPort -port 3 -priority 10 -admin_edge on -bpdu_protection on -bpdu_filter on -root_guard on
        $stp = Get-ArubaSWSTPPort -port 3
        $stp.priority | Should be "10"
        $stp.is_enable_admin_edge_port | Should be "True"
        $stp.is_enable_bpdu_protection | Should be "True"
        $stp.is_enable_bpdu_filter | Should be "True"
        $stp.is_enable_root_guard | Should be "True"
        Set-ArubaSWSTPPort -port 3 -priority $def.priority -admin_edge $def.is_enable_admin_edge_port -bpdu_protection $def.is_enable_bpdu_protection -bpdu_filter $def.is_enable_bpdu_filter -root_guard $def.is_enable_root_guard
    }
}


Disconnect-ArubaSW -noconfirm
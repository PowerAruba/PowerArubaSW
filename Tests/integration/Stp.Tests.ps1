#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

Describe  "Get Spanning Tree" {
    It "Get STP (Global) Does not throw an error" {
        {
            Get-ArubaSWSTP
        } | Should Not Throw
    }

    It "Get STP (Global) field" {
        $stp = Get-ArubaSWSTP
        $stp | Should not be $NULL
        $stp.is_enabled | Should -BeOfType boolean
        $stp.priority | Should -BeOfType $pester_longint
        $stp.mode | Should -BeOfType string
    }
}

Describe  "Configure STP (Global)" {
    BeforeAll {
        $script:stp_default = Get-ArubaSWSTP
        #force disable STP with mode RSTP and Priority 2
        Set-ArubaSWSTP -enable:$false -priority 10 -mode MSTP
    }
    It "Configure STP (Status, priority, mode...)" {
        Set-ArubaSWSTP -enable -priority 2 -mode rpvst
        $stp = Get-ArubaSWSTP
        $stp.is_enabled | Should be "True"
        $stp.priority | Should be "2"
        $stp.mode | Should be "STM_RPVST"
    }
    AfterAll {
        #Restore default value
        Set-ArubaSWSTP -enable:$stp_default.is_enabled -priority $stp_default.priority -mode ($stp_default.mode -replace 'STM_', '')
    }
}

Describe  "Get Spanning Tree Port" {
    It "Get-Spanning Tree Port Does not throw an error" {
        {
            Get-ArubaSWSTPPort
        } | Should Not Throw
    }

    It "Get ALL Spanning Tree Port " {
        $stp_port = Get-ArubaSWSTPPort
        $stp_port | Should not be $NULL
        $stp_port.port_id | Should -BeOfType string
        $stp_port.priority | Should -BeOfType $pester_longint
        $stp_port.is_enable_admin_edge_port | Should -BeOfType boolean
        $stp_port.is_enable_bpdu_protection | Should -BeOfType boolean
        $stp_port.is_enable_bpdu_filter | Should -BeOfType boolean
        $stp_port.is_enable_root_guard | Should -BeOfType boolean
    }

    It "Get Spanning Tree Port $pester_stp_port" {
        $stp_port = Get-ArubaSWSTPPort -port $pester_stp_port
        $stp_port | Should not be $NULL
        $stp_port.port_id | Should -Be $pester_stp_port
        $stp_port.priority | Should -BeOfType $pester_longint
        $stp_port.is_enable_admin_edge_port | Should -BeOfType boolean
        $stp_port.is_enable_bpdu_protection | Should -BeOfType boolean
        $stp_port.is_enable_bpdu_filter | Should -BeOfType boolean
        $stp_port.is_enable_root_guard | Should -BeOfType boolean
    }
}

Describe  "Configure Spanning Tree Port" {
    Context "Configure STP Port via Port ID" {
        It "Configure STP Port $pester_stp_port : priority, admin edge port, bpdu protection, bpdu filter, bpdu guard" {
            Set-ArubaSWSTPPort -port $pester_stp_port -priority 10 -admin_edge -bpdu_protection -bpdu_filter -root_guard
            $stp = Get-ArubaSWSTPPort -port $pester_stp_port
            $stp.port_id | Should be $pester_stp_port
            $stp.priority | Should be "10"
            $stp.is_enable_admin_edge_port | Should be "True"
            $stp.is_enable_bpdu_protection | Should be "True"
            $stp.is_enable_bpdu_filter | Should be "True"
            $stp.is_enable_root_guard | Should be "True"
        }
    }
    Context "Configure STP Port via pipeline" {
        It "Configure STP Port $pester_stp_port : priority, admin edge port, bpdu protection, bpdu filter, bpdu guard" {
            Get-ArubaSWSTPPort $pester_stp_port | Set-ArubaSWSTPPort -priority 9 -admin_edge:$false -bpdu_protection:$false -bpdu_filter:$false -root_guard:$false
            $stp = Get-ArubaSWSTPPort $pester_stp_port
            $stp.port_id | Should be $pester_stp_port
            $stp.priority | Should be "9"
            $stp.is_enable_admin_edge_port | Should be "False"
            $stp.is_enable_bpdu_protection | Should be "false"
            $stp.is_enable_bpdu_filter | Should be "false"
            $stp.is_enable_root_guard | Should be "false"
        }
    }
}


Disconnect-ArubaSW -noconfirm

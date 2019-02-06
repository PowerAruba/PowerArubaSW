#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1
#TODO: Add check if no ipaddress/login/password info...

Describe  "Get Port" {

    BeforeAll {
        #Always set name to DEFAULT_PORT (no way to remove Port name/description...)
        Set-ArubaSWPort -port_id $pester_port -name DEFAULT_PORT
        #Always enable the port (disabled on WorkBench...)
        Set-ArubaSWPort -port_id $pester_port -is_port_enable
    }

    It "Get Port Does not throw an error" {
        {
            Get-ArubaSWPort
        } | Should Not Throw
    }

    It "Get ALL Port" {
        $PORTS = Get-ArubaSWPort
        $PORTS.count | Should not be $NULL
    }

    It "Get the Port ID ($pester_port)" {
        $PORT = Get-ArubaSWPort -port_id $pester_port
        $PORT.id | Should be $pester_port
        $PORT.name | Should be "DEFAULT_PORT"
        $PORT.is_port_enabled | should be $true
        $PORT.is_port_up | should not be $null
        $PORT.config_mode | should be "PCM_AUTO"
        $PORT.trunk_mode | should be "PTT_NONE"
        $PORT.lacp_status | should be "LAS_DISABLED"
        $PORT.trunk_group | should be ""
        $PORT.is_flow_control_enabled | should be $false
        $PORT.is_dsnoop_port_trusted | should be $false
    }
}

Describe  "Configure Port" {

    Context "Configure Port via ID" {

        It "Configure Port name" {
            Set-ArubaSWPort -port_id $pester_port -name "PowerArubaSW-Port"
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT.name | should be "PowerArubaSW-Port"
        }

        It "Configure disable Port" {
            Set-ArubaSWPort -port_id $pester_port -is_port_enabled:$false
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT.is_port_enabled | Should Be $false
        }

        It "Configure enable Port" {
            Set-ArubaSWPort -port_id $pester_port -is_port_enabled
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT.is_port_enabled | Should Be $true
        }

        It "Configure Port option (enable flow control/dsnoop port trusted)" {
            Set-ArubaSWPort -port_id $pester_port -is_flow_control_enabled -is_dsnoop_port_trusted
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT.id | Should Be $pester_port
            $PORT.is_flow_control_enabled | should be $true
            $PORT.is_dsnoop_port_trusted | should be $true
        }

        It "Configure Port option (disable flow control/dsnoop port trusted)" {
            Set-ArubaSWPort -port_id $pester_port -is_flow_control_enabled:$false -is_dsnoop_port_trusted:$false
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT.id | Should Be $pester_port
            $PORT.is_flow_control_enabled | should be $false
            $PORT.is_dsnoop_port_trusted | should be $false
        }

        It "Configure Port config mode (10HDX, 100HDX, 10FDX, 100FDX, AUTO...)" {
            Set-ArubaSWPort -port_id $pester_port -config_mode PCM_100HDX
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT.id | Should Be $pester_port
        }

        AfterAll {
            #Always set name to DEFAULT_PORT (no way to remove Port name/description...)
            Set-ArubaSWPort -port_id $pester_port -name DEFAULT_PORT
            #Set to default config mode
            Set-ArubaSWPOrt -port_id $pester_port -config PCM_AUTO
        }
    }

    Context "Configure Port via pipeline" {

        It "Configure Port name" {
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT | Set-ArubaSWPort -name "PowerArubaSW-Port"
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT.name | should be "PowerArubaSW-Port"
        }

        It "Configure disable Port" {
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT | Set-ArubaSWPort -is_port_enabled:$false
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT.is_port_enabled | Should Be $false
        }

        It "Configure enable Port" {
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT | Set-ArubaSWPort -is_port_enabled
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT.is_port_enabled | Should Be $true
        }

        It "Configure Port option (enable flow control/dsnoop port trusted)" {
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT | Set-ArubaSWPort -is_flow_control_enabled -is_dsnoop_port_trusted
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT.id | Should Be $pester_port
            $PORT.is_flow_control_enabled | should be $true
            $PORT.is_dsnoop_port_trusted | should be $true
        }

        It "Configure Port option (disable flow control/dsnoop port trusted)" {
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT | Set-ArubaSWPort -is_flow_control_enabled:$false -is_dsnoop_port_trusted:$false
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT.id | Should Be $pester_port
            $PORT.is_flow_control_enabled | should be $false
            $PORT.is_dsnoop_port_trusted | should be $false
        }

        It "Configure Port config mode (10HDX, 100HDX, 10FDX, 100FDX, AUTO...)" {
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT | Set-ArubaSWPort -config_mode PCM_100HDX
            $PORT = Get-ArubaSWPort -port_id $pester_port
            $PORT.id | Should Be $pester_port
        }

        AfterAll {
            #Always set name to DEFAULT_PORT (no way to remove Port name/description...)
            Set-ArubaSWPort -port_id $pester_port -name DEFAULT_PORT
            #Set to default config mode
            Set-ArubaSWPOrt -port_id $pester_port -config PCM_AUTO
        }

    }
}

Describe  "Get Port Statistics" {

    It "Get Port Does not throw an error" {
        {
            Get-ArubaSWPortStatistics
        } | Should Not Throw
    }

    It "Get ALL Ports Stastistics" {
        $PORTS = Get-ArubaSWPortStatistics
        $PORTS.count | Should not be $NULL
    }

    It "Get the Port Stastistics ($pester_port)" {
        $PORT = Get-ArubaSWPortStatistics -port_id $pester_port
        $PORT.id | Should be $pester_port
        $PORT.name | Should -Not -BeNullOrEmpty
        $PORT.packets_tx | Should -Not -BeNullOrEmpty
        $PORT.packets_rx | Should -Not -BeNullOrEmpty
        $PORT.bytes_tx | Should -Not -BeNullOrEmpty
        $PORT.bytes_rx | Should -Not -BeNullOrEmpty
        $PORT.throughput_tx_bps | Should -Not -BeNullOrEmpty
        $PORT.throughput_rx_bps | Should -Not -BeNullOrEmpty
        $PORT.error_tx | Should -Not -BeNullOrEmpty
        $PORT.error_rx | Should -Not -BeNullOrEmpty
        $PORT.drop_tx | Should -Not -BeNullOrEmpty
        $PORT.port_speed_mbps | Should -Not -BeNullOrEmpty
    }

}

Disconnect-ArubaSW -noconfirm
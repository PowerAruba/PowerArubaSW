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

Describe  "Get RADIUS Server" {
    It "Get-ArubaSWRadiusServer Does not throw an error" {
        { Get-ArubaSWRadiusServer } | Should -Not -Throw
    }
}

Describe  "Add RADIUS Server" {

    It "Check Ip and Shared Secret" {
        Add-ArubaSWRadiusServer -address 192.0.2.1 -shared_secret powerarubasw
        $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
        $radius.address.version | Should -Be "IAV_IP_V4"
        $radius.address.octets | Should -Be "192.0.2.1"
        $radius.shared_secret | Should -Be "powerarubasw"
    }

    It "Check authentication port and accounting port" {
        Add-ArubaSWRadiusServer -address 192.0.2.1 -shared_secret powerarubasw -authentication_port 1800 -accounting_port 1801
        $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
        $radius.authentication_port | Should -Be "1800"
        $radius.accounting_port | Should -Be "1801"
    }

    It "Check time window settings" {
        Add-ArubaSWRadiusServer -address 192.0.2.1 -shared_secret powerarubasw -time_window_type TW_PLUS_OR_MINUS_TIME_WINDOW -time_window 0
        $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
        $radius.time_window_type | Should -Be "TW_PLUS_OR_MINUS_TIME_WINDOW"
        $radius.time_window | Should -Be "0"
    }

    It "Check dynamic authorization" {
        Add-ArubaSWRadiusServer -address 192.0.2.1 -shared_secret powerarubasw -is_dyn_authorization_enabled
        $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
        $radius.is_dyn_authorization_enabled | Should -Be "True"
    }

    AfterEach {
        $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
        Remove-ArubaSWRadiusServer -id $radius.radius_server_id -confirm:$false
    }
}

Describe  "Configure RADIUS Server" {

    BeforeAll {
        Add-ArubaSWRadiusServer -address 192.0.2.1 -shared_secret powerarubasw -authentication_port 1800 -accounting_port 1801 -time_window_type TW_PLUS_OR_MINUS_TIME_WINDOW -time_window 0 -is_dyn_authorization_enabled
    }

    Context "Configure RADIUS server via id" {

        It "Check change on shared secret" {
            $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
            Set-ArubaSWRadiusServer -id $radius.radius_server_id -shared_secret radius_test
            $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
            $radius.shared_secret | Should -Be "radius_test"
        }

        It "Check changes on authentication and accounting ports" {
            $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
            Set-ArubaSWRadiusServer -id $radius.radius_server_id -shared_secret radius_test -authentication_port 1700 -accounting_port 1701
            $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
            $radius.authentication_port | Should -Be "1700"
            $radius.accounting_port | Should -Be "1701"
        }

        It "Check changes on time window type " {
            $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
            Set-ArubaSWRadiusServer -id $radius.radius_server_id -shared_secret radius_test -time_window_type TW_POSITIVE_TIME_WINDOW -time_window 15
            $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
            $radius.time_window_type | Should -Be "TW_POSITIVE_TIME_WINDOW"
            $radius.time_window | Should -Be "15"
        }

        It "Check change dynamic autorization" {
            $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
            Set-ArubaSWRadiusServer -id $radius.radius_server_id -shared_secret radius_test -is_dyn_authorization_enabled:$false
            $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
            $radius.is_dyn_authorization_enabled | Should -Be "False"
        }

    }

    Context "Configure RADIUS server via pipeline" {

        It "Check change on shared secret" {
            Get-ArubaSWRadiusServer -address 192.0.2.1 | Set-ArubaSWRadiusServer -shared_secret radius_test
            $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
            $radius.shared_secret | Should -Be "radius_test"
        }

        It "Check changes on authentication and accounting ports" {
            Get-ArubaSWRadiusServer -address 192.0.2.1 | Set-ArubaSWRadiusServer -shared_secret radius_test -authentication_port 1700 -accounting_port 1701
            $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
            $radius.authentication_port | Should -Be "1700"
            $radius.accounting_port | Should -Be "1701"
        }

        It "Check changes on time window type " {
            Get-ArubaSWRadiusServer -address 192.0.2.1 | Set-ArubaSWRadiusServer -shared_secret radius_test -time_window_type TW_POSITIVE_TIME_WINDOW -time_window 15
            $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
            $radius.time_window_type | Should -Be "TW_POSITIVE_TIME_WINDOW"
            $radius.time_window | Should -Be "15"
        }

        It "Check change dynamic autorization" {
            Get-ArubaSWRadiusServer -address 192.0.2.1 | Set-ArubaSWRadiusServer -shared_secret radius_test -is_dyn_authorization_enabled:$false
            $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
            $radius.is_dyn_authorization_enabled | Should -Be "False"
        }

    }

    AfterAll {
        $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
        Remove-ArubaSWRadiusServer -id $radius.radius_server_id -confirm:$false
    }
}

Describe  "Remove RADIUS Server" {

    BeforeAll {
        Add-ArubaSWRadiusServer -address 192.0.2.1 -shared_secret .\PowerArubaSW
    }

    Context "Remove RADIUS server by id" {
        It "Remove ArubaSWRadiusServer server" {

            $id_server = Get-ArubaSWRadiusServer -address 192.0.2.1
            Remove-ArubaSWRadiusServer -id $id_server.radius_server_id -confirm:$false
            $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
            $radius | Should -BeNullOrEmpty
        }
    }

    Context "Remove RADIUS server by pipeline" {
        It "Remove ArubaSWRadiusServer server" {
            Get-ArubaSWRadiusServer -address 192.0.2.1 | Remove-ArubaSWRadiusServer -confirm:$false
            $radius = Get-ArubaSWRadiusServer -address 192.0.2.1
            $radius | Should -BeNullOrEmpty
        }
    }
}

AfterAll {
    Disconnect-ArubaSW -noconfirm
}
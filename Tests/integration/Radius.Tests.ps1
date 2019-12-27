#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

Describe  "Get-ArubaSWRadius" {
    It "Get-ArubaSWRadius Does not throw an error" {
        { Get-ArubaSWRadius } | Should Not Throw
    }
}

Describe  "Add-ArubaSWRadius" {

    It "Check Ip and Shared Secret" {
        Add-ArubaSWRadius -ipaddress 192.0.2.1 -shared_secret powerarubasw
        $radius = Get-ArubaSWRadius -ipaddress 192.0.2.1
        $radius.address.version | Should be "IAV_IP_V4"
        $radius.address.octets | Should be "192.0.2.1"
        $radius.shared_secret | Should be "powerarubasw"
    }

    It "Check authentication port and accounting port" {
        Add-ArubaSWRadius -ipaddress 192.0.2.1 -shared_secret powerarubasw -authentication_port 1800 -accounting_port 1801
        $radius = Get-ArubaSWRadius -ipaddress 192.0.2.1
        $radius.authentication_port | Should be "1800"
        $radius.accounting_port | Should be "1801"
    }

    It "Check time window settings" {
        Add-ArubaSWRadius -ipaddress 192.0.2.1 -shared_secret powerarubasw -time_window_type TW_PLUS_OR_MINUS_TIME_WINDOW -time_window 0
        $radius = Get-ArubaSWRadius -ipaddress 192.0.2.1
        $radius.time_window_type | Should be "TW_PLUS_OR_MINUS_TIME_WINDOW"
        $radius.time_window | Should be "0"
    }

    It "Check dynamic authorization" {
        Add-ArubaSWRadius -ipaddress 192.0.2.1 -shared_secret powerarubasw -is_dyn_authorization_enabled
        $radius = Get-ArubaSWRadius -ipaddress 192.0.2.1
        $radius.is_dyn_authorization_enabled | Should be "True"
    }

    AfterEach {
        $radius = Get-ArubaSWRadius -ipaddress 192.0.2.1
        Remove-ArubaSWRadius -id $radius.radius_server_id -noconfirm
    }
}

Describe  "Set-ArubaSWRadius" {

    BeforeAll {
        Add-ArubaSWRadius -ipaddress 192.0.2.1 -shared_secret powerarubasw -authentication_port 1800 -accounting_port 1801 -time_window_type TW_PLUS_OR_MINUS_TIME_WINDOW -time_window 0 -is_dyn_authorization_enabled
    }

    It "Check change on shared secret" {
        $radius = Get-ArubaSWRadius -ipaddress 192.0.2.1
        Set-ArubaSWRadius -id $radius.radius_server_id -shared_secret radius_test
        $radius = Get-ArubaSWRadius -ipaddress 192.0.2.1
        $radius.shared_secret | Should be "radius_test"
    }

    It "Check changes on authentication and accounting ports" {
        $radius = Get-ArubaSWRadius -ipaddress 192.0.2.1
        Set-ArubaSWRadius -id $radius.radius_server_id -shared_secret radius_test -authentication_port 1700 -accounting_port 1701
        $radius = Get-ArubaSWRadius -ipaddress 192.0.2.1
        $radius.authentication_port | Should be "1700"
        $radius.accounting_port | Should be "1701"
    }

    It "Check changes on time window type " {
        $radius = Get-ArubaSWRadius -ipaddress 192.0.2.1
        Set-ArubaSWRadius -id $radius.radius_server_id -shared_secret radius_test -time_window_type TW_POSITIVE_TIME_WINDOW -time_window 15
        $radius = Get-ArubaSWRadius -ipaddress 192.0.2.1
        $radius.time_window_type | Should be "TW_POSITIVE_TIME_WINDOW"
        $radius.time_window | Should be "15"
    }

    It "Check change dynamic autorization" {
        $radius = Get-ArubaSWRadius -ipaddress 192.0.2.1
        Set-ArubaSWRadius -id $radius.radius_server_id -shared_secret radius_test -is_dyn_authorization_enabled:$false
        $radius = Get-ArubaSWRadius -ipaddress 192.0.2.1
        $radius.is_dyn_authorization_enabled | Should be "False"
    }

    AfterAll {
        $radius = Get-ArubaSWRadius -ipaddress 192.0.2.1
        Remove-ArubaSWRadius -id $radius.radius_server_id -noconfirm
    }
}

Describe  "Remove-ArubaSWRadius" {
    It "Remove ArubaSWRadius server" {
        Add-ArubaSWRadius -ipaddress 192.0.2.1 -shared_secret powerarubasw
        $id_server = Get-ArubaSWRadius -ipaddress 192.0.2.1
        Remove-ArubaSWRadius -id $id_server.radius_server_id -noconfirm
        $radius = Get-ArubaSWRadius -ipaddress 192.0.2.1
        $radius | Should -BeNullOrEmpty
    }
}

Disconnect-ArubaSW -noconfirm
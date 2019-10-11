#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

Describe  "Add-ArubaSWRadiusGroup" {

    It "Check name of group" {
        Add-ArubaSWRadius -address 192.0.2.1 -shared_secret powerarubasw
        Add-ArubaSWRadiusGroup -server_group_name PowerArubaSW -server1 192.0.2.1
        $radius_group = Get-ArubaSWRadiusGroup -server_group_name PowerArubaSW
        $radius_group.server_group_name | Should be "PowerArubaSW"
    }

    It "Check IP of server added" {
        Add-ArubaSWRadius -address 192.0.2.1 -shared_secret powerarubasw
        Add-ArubaSWRadiusGroup -server_group_name PowerArubaSW -server1 192.0.2.1
        $radius_group = Get-ArubaSWRadiusGroup -server_group_name PowerArubaSW
        $radius_group.server_ip.octets | Should be "192.0.2.1"
    }

    It "Check IP of multiple RADIUS server" {
        Add-ArubaSWRadius -address 192.0.2.1 -shared_secret powerarubasw
        Add-ArubaSWRadius -address 192.0.2.2 -shared_secret powerarubasw
        Add-ArubaSWRadiusGroup -server_group_name PowerArubaSW -server1 192.0.2.1 -server2 192.0.2.2
        $radius_group = Get-ArubaSWRadiusGroup -server_group_name PowerArubaSW
        $radius_group.server_ip.octets[0] | Should be "192.0.2.1"
        $radius_group.server_ip.octets[1] | Should be "192.0.2.2"
        Remove-ArubaSWRadius -address 192.0.2.2 -noconfirm
    }

    AfterEach {
        Remove-ArubaSWRadiusGroup -server_group_name PowerArubaSW -noconfirm
        Remove-ArubaSWRadius -address 192.0.2.1 -noconfirm
    }
}

Describe  "Set-ArubaSWRadius" {

    BeforeAll {
        Add-ArubaSWRadius -address 192.0.2.1 -shared_secret powerarubasw -authentication_port 1800 -accounting_port 1801 -time_window_type TW_PLUS_OR_MINUS_TIME_WINDOW -time_window 0 -is_dyn_authorization_enabled
    }

    It "Check change on shared secret" {
        $radius = Get-ArubaSWRadius -address 192.0.2.1
        Set-ArubaSWRadius -id $radius.radius_server_id -address $radius.address.octets -shared_secret radius_test
        $radius = Get-ArubaSWRadius -address 192.0.2.1
        $radius.shared_secret | Should be "radius_test"
    }

    It "Check changes on authentication and accounting ports" {
        $radius = Get-ArubaSWRadius -address 192.0.2.1
        Set-ArubaSWRadius -id $radius.radius_server_id -address $radius.address.octets -shared_secret radius_test -authentication_port 1700 -accounting_port 1701
        $radius = Get-ArubaSWRadius -address 192.0.2.1
        $radius.authentication_port | Should be "1700"
        $radius.accounting_port | Should be "1701"
    }

    It "Check changes on time window type " {
        $radius = Get-ArubaSWRadius -address 192.0.2.1
        Set-ArubaSWRadius -id $radius.radius_server_id -address $radius.address.octets -shared_secret radius_test -time_window_type TW_POSITIVE_TIME_WINDOW -time_window 15
        $radius = Get-ArubaSWRadius -address 192.0.2.1
        $radius.time_window_type | Should be "TW_POSITIVE_TIME_WINDOW"
        $radius.time_window | Should be "15"
    }

    It "Check change dynamic autorization" {
        $radius = Get-ArubaSWRadius -address 192.0.2.1
        Set-ArubaSWRadius -id $radius.radius_server_id -address $radius.address.octets -shared_secret radius_test -is_dyn_authorization_enabled:$false
        $radius = Get-ArubaSWRadius -address 192.0.2.1
        $radius.is_dyn_authorization_enabled | Should be "False"
    }

    AfterAll {
        $radius = Get-ArubaSWRadius -address 192.0.2.1
        Remove-ArubaSWRadius -id $radius.radius_server_id -noconfirm
    }
}

Describe  "Remove-ArubaSWRadius" {
    It "Remove ArubaSWRadius server" {
        Add-ArubaSWRadius -address 192.0.2.1 -shared_secret powerarubasw
        $id_server = Get-ArubaSWRadius -address 192.0.2.1
        Remove-ArubaSWRadius -id $id_server.radius_server_id -noconfirm
        $radius = Get-ArubaSWRadius -address 192.0.2.1
        $radius | Should -BeNullOrEmpty
    }
}

Disconnect-ArubaSW -noconfirm
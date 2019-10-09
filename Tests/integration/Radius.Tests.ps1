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

    It "Add-ArubaSWRadius mandatory parameters" {
        Add-ArubaSWRadius -address 192.0.2.1 -shared_secret powerarubasw
        $radius = Get-ArubaSWRadius -id 1
        $radius.address.version | Should be "IAV_IP_V4"
        $radius.address.octets | Should be "192.0.2.1"
        $radius.shared_secret | Should be "powerarubasw"
        Remove-ArubaSWRadius -id 1
    }

    It "Add-ArubaSWRadius ports" {
        Add-ArubaSWRadius -address 192.0.2.1 -shared_secret powerarubasw -authentication_port 1800 -accounting_port 1801
        $radius = Get-ArubaSWRadius -id 1
        $radius.authentication_port | Should be "1800"
        $radius.accounting_port  | Should be "1801"
        Remove-ArubaSWRadius -id 1
    }

    It "Add-ArubaSWRadius time window settings" {
        Add-ArubaSWRadius -address 192.0.2.1 -shared_secret powerarubasw -time_window_type TW_PLUS_OR_MINUS_TIME_WINDOW -time_window 0
        $radius = Get-ArubaSWRadius -id 1
        $radius.time_window_type | Should be "TW_PLUS_OR_MINUS_TIME_WINDOW"
        $radius.time_window | Should be "0"
        Remove-ArubaSWRadius -id 1
    }

    It "Add-ArubaSWRadius dynamic autorization" {
        Add-ArubaSWRadius -address 192.0.2.1 -shared_secret powerarubasw -is_dyn_authorization_enabled
        $radius = Get-ArubaSWRadius -id 1
        $radius.is_dyn_authorization_enabled | Should be "True"
        Remove-ArubaSWRadius -id 1
    }
}

Describe  "Set-ArubaSWRadius" {

    BeforeEach {
        Add-ArubaSWRadius -address 192.0.2.1 -shared_secret powerarubasw -is_dyn_autorization_enabled -time_window_type TW_PLUS_OR_MINUS_TIME_WINDOW -time_window 0 -authentication_port 1800 -accounting_port 1801
    }

    It "Set-ArubaSWRadius mandatory parameters" {
        Set-ArubaSWRadius -id 1 -address 192.0.2.2 -shared_secret radius_test
        $radius = Get-ArubaSWRadius -id 1
        $radius.radius_server_id | Should be "1"
        $radius.address | Should be "192.0.2.2"
        $radius.shared_secret | Should be "radius_test"
    }

    It "Set-ArubaSWRadius ports" {
        Set-ArubaSWRadius -id 1 -authentication_port 1812 -accounting_port 1813
        $radius = Get-ArubaSWRadius -id 1
        $radius.authentication_port | Should be "1812"
        $radius.accounting_port  | Should be "1813"
    }

    It "Set-ArubaSWRadius time window settings" {
        Set-ArubaSWRadius -id 1 -time_window_type TW_POSITIVE_TIME_WINDOW -time_window 15
        $radius = Get-ArubaSWRadius -id 1
        $radius.time_window_type | Should be "TW_POSITIVE_TIME_WINDOW"
        $radius.time_window | Should be "15"
    }

    It "Set-ArubaSWRadius dynamic autorization" {
        Set-ArubaSWRadius -id 1 -is_dyn_autorization_enabled:$false
        $radius = Get-ArubaSWRadius -id 1
        $radius.is_dyn_autorization_enabled | Should be "False"
    }

    AfterAll {
        Remove-ArubaSWRadius -id 1
    }

}

Describe  "Remove-ArubaSWRadius" {
    It "Remove ArubaSWRadius server with ID 1" {
        Add-ArubaSWRadius -address 192.0.2.1 -shared_secret powerarubasw
        Remove-ArubaSWRadius -id 1
        $radius = Get-ArubaSWRadius -id 1
        $radius | Should -BeNullOrEmpty
    }
}

Disconnect-ArubaSW -noconfirm
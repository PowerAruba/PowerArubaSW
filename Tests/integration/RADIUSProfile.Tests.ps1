#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

Describe  "Get RADIUS Profile" {
    It "Get-ArubaSWRadiusProfile Does not throw an error" {
        { Get-ArubaSWRadiusProfile } | Should Not Throw
    }
}


Describe  "Configure RADIUS Profile" {

    BeforeAll {
        #Reset RADIUS Profile by default
        Set-ArubaSWRadiusProfile -retry_interval 5 -retransmit_attempts 3 -dyn_autz_port 3799 -key "" -tracking_uname radius-tracking-user -is_tracking_enabled:$false
    }

    It "Change Retry Interval" {
        Set-ArubaSWRadiusProfile -retry_interval 3
        $radius = Get-ArubaSWRadiusProfile
        $radius.retry_interval | Should -Be "3"
    }

    It "Change Retransmit attempts" {
        Set-ArubaSWRadiusProfile -retransmit_attempts 1
        $radius = Get-ArubaSWRadiusProfile
        $radius.retransmit_attempts | Should -Be "1"
    }

    It "Change Dynamic Authorization Port" {
        Set-ArubaSWRadiusProfile -dyn_autz_port 3800
        $radius = Get-ArubaSWRadiusProfile
        $radius.dyn_autz_port | Should -Be "3800"
    }

    It "Change Key" {
        Set-ArubaSWRadiusProfile -key PowerArubaSW
        $radius = Get-ArubaSWRadiusProfile
        $radius.key | Should -Be "PowerArubaSW"
    }

    It "Change Key to Null" {
        Set-ArubaSWRadiusProfile -key ""
        $radius = Get-ArubaSWRadiusProfile
        $radius.key | Should -Be ""
    }

    It "Change Tracking uname" {
        Set-ArubaSWRadiusProfile -tracking_uname PowerArubaSW
        $radius = Get-ArubaSWRadiusProfile
        $radius.tracking_uname | Should -Be "PowerArubaSW"
    }

    It "Enabled RADIUS Tracking" {
        Set-ArubaSWRadiusProfile -is_tracking_enabled
        $radius = Get-ArubaSWRadiusProfile
        $radius.is_tracking_enabled | Should -Be "true"
    }

    It "Disabled RADIUS Tracking" {
        Set-ArubaSWRadiusProfile -is_tracking_enabled:$false
        $radius = Get-ArubaSWRadiusProfile
        $radius.is_tracking_enabled | Should -Be "false"
    }

    AfterAll {
        Set-ArubaSWRadiusProfile -retry_interval 5 -retransmit_attempts 3 -dyn_autz_port 3799 -key "" -tracking_uname radius-tracking-user -is_tracking_enabled:$false
    }
}


Disconnect-ArubaSW -noconfirm
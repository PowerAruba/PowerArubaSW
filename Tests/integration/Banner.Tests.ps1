#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

Describe  "Get Banner" {
    BeforeAll {
        $banner = Get-ArubaSWBanner
        $script:motd = $banner.motd
        $script:exec = $banner.exec
        $script:is_last_login_enabled = $banner.is_last_login_enabled
        Set-ArubaSWBanner -motd "PowerArubaSW-motd" -exec "PowerArubaSW-exec" -is_last_login_enabled:$true
    }
    It "Get Banner Does not throw an error" {
        { Get-ArubaSWBanner } | Should Not Throw
    }
    It "Get Banner Should not be null" {
        { Get-ArubaSWBanner } | Should not be $NULL
    }
    It "Get Banner and check return" {
        $banner = Get-ArubaSWBanner
        $banner.motd_base64_encoded | Should be "UG93ZXJBcnViYVNXLW1vdGQ="
        $banner.exec_base64_encoded | Should be "UG93ZXJBcnViYVNXLWV4ZWM="
        $banner.is_last_login_enabled | Should -be $true
        $banner.motd | Should be "PowerArubaSW-motd"
        $banner.exec | Should be "PowerArubaSW-exec"
    }
    AfterAll {
        Set-ArubaSWBanner -motd $script:motd -exec $script:exec -is_last_login_enabled:$script:is_last_login_enabled
    }

}

Describe  "Configure Banner" {
    BeforeAll {
        $banner = Get-ArubaSWBanner
        $script:motd = $banner.motd
        $script:exec = $banner.exec
        $script:is_last_login_enabled = $banner.is_last_login_enabled
        Set-ArubaSWBanner -motd "" -exec "" -is_last_login_enabled:$true
    }

    It "Configure Motd Banner" {
        Set-ArubaSWBanner -motd "PowerArubaSW-motd"
        $banner = Get-ArubaSWBanner
        $banner.motd_base64_encoded | Should be "UG93ZXJBcnViYVNXLW1vdGQ="
        $banner.motd | Should be "PowerArubaSW-motd"
    }

    It "Configure Exec Banner" {
        Set-ArubaSWBanner -exec "PowerArubaSW-exec"
        $banner = Get-ArubaSWBanner
        $banner.exec_base64_encoded | Should be "UG93ZXJBcnViYVNXLWV4ZWM="
        $banner.exec | Should be "PowerArubaSW-exec"
    }

    It "Configure Last login" {
        Set-ArubaSWBanner -is_last_login_enabled:$false
        $banner = Get-ArubaSWBanner
        $banner.is_last_login_enabled | Should be $false
    }

    AfterAll {
        Set-ArubaSWBanner -motd $script:motd -exec $script:exec -is_last_login_enabled:$script:is_last_login_enabled
    }
}

Disconnect-ArubaSW -noconfirm

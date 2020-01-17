#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

Describe  "Get-ArubaSWModules" {
    It "Get-ArubaSWModules Does not throw an error" {
        {
            Get-ArubaSWRestVersion
        } | Should Not Throw
    }

    It "Get-ArubaSWModules should not be null" {
        $modules = Get-ArubaSWModules
        $modules.interop_mode | Should not be $null
        $modules.module_info | Should not be $null
    }
}

Disconnect-ArubaSW -noconfirm

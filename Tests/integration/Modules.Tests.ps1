#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

BeforeAll {
    Connect-ArubaSW @invokeParams
}

Describe  "Get-ArubaSWModules" {
    It "Get-ArubaSWModules Does not throw an error" {
        {
            Get-ArubaSWModules
        } | Should -Not -Throw
    }

    It "Get-ArubaSWModules should not be null" {
        $modules = Get-ArubaSWModules
        $modules.interop_mode | Should -Not -Be $null
        $modules.module_info | Should -Not -Be $null
    }
}

AfterAll {
    Disconnect-ArubaSW -confirm:$false
}
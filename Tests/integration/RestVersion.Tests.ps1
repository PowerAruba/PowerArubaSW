#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

Describe  "Get-ArubaSWRestVersion" {
    It "Get-ArubaSWRestVersion Does not throw an error" {
        {
            Get-ArubaSWRestVersion
        } | Should Not Throw
    }

    It "Get-ArubaSWRestVersion should not be null" {
        $version = Get-ArubaSWRestVersion
        $version.version | Should not be $NULL
    }
}

Disconnect-ArubaSW -noconfirm

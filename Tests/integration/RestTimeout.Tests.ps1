#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

../common.ps1

Describe  "Get RestSessionTimeout" {
    It "Get RestSessionTimeout Does not throw an error" {
        {
            Get-ArubaSWRestSessionTimeout
        } | Should Not Throw 
    }

    It "Get RestSessionTimeout" {
        $timeout = Get-ArubaSWRestSessionTimeout
        $timeout | Should not be $NULL
    }

    It "Get RestSessionTimeout equals 600" {
        $timeout = Get-ArubaSWRestSessionTimeout
        $timeout | Should be "600"
    }
}

Describe  "Set RestSessionTimeout" {
    It "Change SessionTimeout value" {
        Set-ArubaSWRestSessionTimeout -timeout 800
        $timeout = Get-ArubaSWRestSessionTimeout
        $timeout | Should be "800"
    }

    It "Change SessionTimeout value to defaults (600)" {
        Set-ArubaSWRestSessionTimeout -timeout 600
        $timeout = Get-ArubaSWRestSessionTimeout
        $timeout | Should be "600"
    }

    It "Check range (min) of RestSessionTimeout value" {
        $change = 90
        {Set-ArubaSWRestSessionTimeout -timeout $change} | Should Throw
    }

    It "Check range (max) of RestSessionTimeout value" {
        $change = 8500
        {Set-ArubaSWRestSessionTimeout -timeout $change} | Should Throw
    }
}

Disconnect-ArubaSW -noconfirm
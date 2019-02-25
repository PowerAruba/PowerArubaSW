#
# Copyright 2019, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

Describe  "Get-ArubaSWCliBatchStatus" {
    It "Get ArubaSWCliBatchStatus Does not throw an error" {
        {
            Get-ArubaSWCliBatchStatus
        } | Should Not Throw 
    }

    It "Get ArubaSWCliBatchStatus" {
        $cli = Get-ArubaSWCliBatchStatus
        $cli | Should not be $NULL
    }
}

Describe  "Write ArubaSWCliBatch" {
    It "Write ArubaSWCliBatch" {
        Write-ArubaSWCliBatch -command "interface 4","disable"
        $cli = Get-ArubaSWCliBatchStatus
        $cli.status | Should be "CCS_SUCCESS"
        Write-ArubaSWCliBatch -command "interface 4","enable"
    }
}

Disconnect-ArubaSW -noconfirm
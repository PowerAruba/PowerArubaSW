#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

Describe  "Get-ArubaSWCli" {
    It "Get-ArubaSWCli Does not throw an error" {
        { Get-ArubaSWCli -cmd "show run" } | Should Not Throw 
    }
    It "Get-ArubaSWCli Should not be null" {
        { Get-ArubaSWCli -cmd "show run" } | Should not be $NULL
    }
    It "Value of status should be a success, sohould not be null, and should have the right command" {
        $cli = Get-ArubaSWCli -cmd "show run"
        $cli.status | Should be "CCS_SUCCESS"
        $cli.result_base64_encoded | Should not be $NULL
        $cli.cmd | Should be "show run"
    }
}

Disconnect-ArubaSW
#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

Describe  "Get (Any)CLi" {
    It "Get (Any)Cli Does not throw an error" {
        { Get-ArubaSWCli -cmd "show run" } | Should Not Throw
    }
    It "Get (Any)Cli Should not be null" {
        { Get-ArubaSWCli -cmd "show run" } | Should not be $NULL
    }
    It "Get (Any)Cli 'show run' (and return status, cmd, result...)" {
        $cli = Get-ArubaSWCli -cmd "show run"
        $cli.status | Should be "CCS_SUCCESS"
        $cli.cmd | Should be "show run"
        $cli.error_msg | Should -BeNullOrEmpty
        $cli.result_base64_encoded | Should not be $NULL
        $cli.result | Should not be $NULL
    }

    It "Get (Any)Cli 'show history' is not supported" {
        $cli = Get-ArubaSWCli -cmd "show history"
        $cli.status | Should be "CCS_FAILURE"
        $cli.cmd | Should be "show history"
        $cli.error_msg | Should -BeLike "The history commands are not supported via REST interface.*"
        $cli.result_base64_encoded | Should be "VGhlIGhpc3RvcnkgY29tbWFuZHMgYXJlIG5vdCBzdXBwb3J0ZWQgdmlhIFJFU1QgaW50ZXJmYWNlLgoA"
        $cli.result | Should -BeLike "The history commands are not supported via REST interface.*"
    }
}

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
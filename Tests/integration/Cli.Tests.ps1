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

Describe  "Send Cli Batch command" {
    It "Send Cli Batch command (disable interface $pester_cli_port and set name)" {
        $batch = Send-ArubaSWCliBatch -command "interface $pester_cli_port disable", "interface $pester_cli_port name PowerArubaSW-int"
        $batch.status | Should -be "CBS_INITIATED"
        $cliBatch = Get-ArubaSWCliBatchStatus
        if ($null -eq $cliBatch) {
            Start-Sleep 0.5
            $cliBatch = Get-ArubaSWCliBatchStatus
        }
        $cliBatch[0].status | Should -be "CCS_SUCCESS"
        $cliBatch[0].cmd | Should -Be "interface $pester_cli_port disable"
        $cliBatch[0].result | Should -BeNullOrEmpty
        $cliBatch[1].status | Should -Be "CCS_SUCCESS"
        $cliBatch[1].cmd | Should -Be "interface $pester_cli_port name PowerArubaSW-int"
        $cliBatch[1].result | Should -BeNullOrEmpty
        $port = Get-ArubaSWPort $pester_cli_port
        $port.is_port_enabled | Should -Be $false
        $port.name | Should -Be "PowerArubaSW-int"
    }

    It "Send Cli Batch command (enable interface $pester_cli_port and remove name)" {
        $batch = Send-ArubaSWCliBatch -command "interface $pester_cli_port", "enable", "no name"
        $batch.status | Should -be "CBS_INITIATED"
        $cliBatch = Get-ArubaSWCliBatchStatus
        if ($null -eq $cliBatch) {
            Start-Sleep 0.5
            $cliBatch = Get-ArubaSWCliBatchStatus
        }
        $cliBatch[0].status | Should -be "CCS_SUCCESS"
        $cliBatch[0].cmd | Should -Be "interface $pester_cli_port"
        $cliBatch[0].result | Should -BeNullOrEmpty
        $cliBatch[1].status | Should -Be "CCS_SUCCESS"
        $cliBatch[1].cmd | Should -Be "enable"
        $cliBatch[1].result | Should -BeNullOrEmpty
        $cliBatch[2].status | Should -Be "CCS_SUCCESS"
        $cliBatch[2].cmd | Should -Be "no name"
        $cliBatch[2].result | Should -BeNullOrEmpty
        $port = Get-ArubaSWPort $pester_cli_port
        $port.is_port_enabled | Should -Be $true
        $port.name | Should -BeNullOrEmpty
    }

    It "Send Cli Batch command (Wrong command)" {
        $batch = Send-ArubaSWCliBatch -command "show run"
        $batch.status | Should -be "CBS_INITIATED"
        $cliBatch = Get-ArubaSWCliBatchStatus
        $cliBatch[0].status | Should -be "CCS_FAILURE"
        $cliBatch[0].cmd | Should -Be "show run"
        $cliBatch[0].result | Should -Be "Invalid input: show"
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

Disconnect-ArubaSW -noconfirm

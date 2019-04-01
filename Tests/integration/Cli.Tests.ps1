#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

$mysecpassword = ConvertTo-SecureString $password -AsPlainText -Force
Connect-ArubaSW -Server $ipaddress -Username $login -password $mysecpassword -SkipCertificateCheck


Describe  "Get-ArubaSWCliBatchStatus" {
    It "Get-ArubaSWCliBatchStatus Does not throw an error" {
        { Get-ArubaSWCliBatchStatus } | Should Not Throw 
    }
}

Describe  "Get-ArubaSWCliBatchStatus" {
    It "Get-ArubaSWCliBatchStatus Should be a success" {
        Write-ArubaSWCliBatch "configure terminal"
        $cli = Get-ArubaSWCliBatchStatus
        $cli.status | Should be "CCS_SUCCESS"
    }
}

Describe  "Get-ArubaSWCliBatchStatus" {
    It "Get-ArubaSWCliBatchStatus Should give the command" {
        Write-ArubaSWCliBatch "configure terminal"
        $cli = Get-ArubaSWCliBatchStatus
        $cli.cmd | Should be "configure terminal"
    }
}

Describe  "Write-ArubaSWCliBatch" {
    It "Write-ArubaSWCliBatch Should not throw an error" {
        { Write-ArubaSWCliBatch "configure terminal" } | Should Not Throw
    }
}

Disconnect-ArubaSW
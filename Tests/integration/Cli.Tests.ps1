#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

$mysecpassword = ConvertTo-SecureString $password -AsPlainText -Force
Connect-ArubaSW -Server $ipaddress -Username $login -password $mysecpassword -SkipCertificateCheck


Describe  "Get-ArubaSWCli" {
    It "Get-ArubaSWCli Does not throw an error" {
        { Get-ArubaSWCli -cmd "show run" } | Should Not Throw 
    }
    It "Get-ArubaSWCli Should not be null" {
        { Get-ArubaSWCli -cmd "show run" } | Should not be $NULL
    }
    It "Value of status should be a success" {
        $cli = Get-ArubaSWCli -cmd "show run"
        $cli.status | Should be "CCS_SUCCESS"
    }
    It "Value of cmd should be the command given as parameter" {
        $cli = Get-ArubaSWCli -cmd "show run"
        $cli.cmd | Should be "show run"
    }
    It "Value of result_base64_encoded should not be null" {
        $cli = Get-ArubaSWCli -cmd "show run"
        $cli.result_base64_encoded | Should not be $NULL
    }
}

Disconnect-ArubaSW
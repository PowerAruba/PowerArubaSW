#
# Copyright 2019, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

../common.ps1

$mysecpassword = ConvertTo-SecureString $password -AsPlainText -Force
Connect-ArubaSW -Server $ipaddress -Username $login -password $mysecpassword

Describe  "Get-ArubaSWIPAddress" {
    It "Get-ArubaSWIPAddress Does not throw an error" {
        { Get-ArubaSWIPAddress } | Should Not Throw 
    }
}

Disconnect-ArubaSW -noconfirm
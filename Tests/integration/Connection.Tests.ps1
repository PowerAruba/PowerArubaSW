#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Connect to a switch (using HTTP)" {
    BeforeAll {
        #Disconnect "default connection"
        Disconnect-ArubaSW -noconfirm
    }
    It "Connect to a switch (using HTTP) and check global variable" {
        Connect-ArubaSW $ipaddress -Username $login -password $mysecpassword -httpOnly -noverbose
        $DefaultArubaSWConnection | should Not BeNullOrEmpty
        $DefaultArubaSWConnection.server | should be $ipaddress
        $DefaultArubaSWConnection.cookie | should Not BeNullOrEmpty
        $DefaultArubaSWConnection.port | should be "80"
        $DefaultArubaSWConnection.httpOnly | should be $true
        $DefaultArubaSWConnection.session | should not BeNullOrEmpty
    }
    It "Disconnect to a switch (using HTTP) and check global variable" {
        Disconnect-ArubaSW -noconfirm
        $DefaultArubaSWConnection | should be $null
    }
    #TODO: Connect using wrong login/password
}

Describe  "Connect to a switch (using HTTPS)" {
    #TODO Try change port => Need AnyCLI
    It "Connect to a switch (using HTTPS and -SkipCertificateCheck) and check global variable" -Skip:($httpOnly) {
        Connect-ArubaSW $ipaddress -Username $login -password $mysecpassword -SkipCertificateCheck -noverbose
        $DefaultArubaSWConnection | should Not BeNullOrEmpty
        $DefaultArubaSWConnection.server | should be $ipaddress
        $DefaultArubaSWConnection.cookie | should Not BeNullOrEmpty
        $DefaultArubaSWConnection.port | should be "443"
        $DefaultArubaSWConnection.httpOnly | should be $false
        $DefaultArubaSWConnection.session | should not BeNullOrEmpty
    }
    It "Disconnect to a switch (using HTTPS) and check global variable" -Skip:($httpOnly) {
        Disconnect-ArubaSW -noconfirm
        $DefaultArubaSWConnection | should be $null
    }
    #This test only work with PowerShell 6 / Core (-SkipCertificateCheck don't change global variable but only Invoke-WebRequest/RestMethod)
    #This test will be fail, if there is valid certificate...
    It "Connect to a switch (using HTTPS) and check global variable" -Skip:($httpOnly -Or "Desktop" -eq $PSEdition) {
        { Connect-ArubaSW $ipaddress -Username $login -password $mysecpassword -noverbose} | should throw "Unable to connect (certificate)"
    }
}

#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
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
        $DefaultArubaSWConnection | Should Not BeNullOrEmpty
        $DefaultArubaSWConnection.server | Should be $ipaddress
        $DefaultArubaSWConnection.cookie | Should Not BeNullOrEmpty
        $DefaultArubaSWConnection.port | Should be "80"
        $DefaultArubaSWConnection.httpOnly | Should be $true
        $DefaultArubaSWConnection.session | Should not BeNullOrEmpty
    }
    It "Disconnect to a switch (using HTTP) and check global variable" {
        Disconnect-ArubaSW -noconfirm
        $DefaultArubaSWConnection | Should be $null
    }
    #TODO: Connect using wrong login/password
}

Describe  "Connect to a switch (using HTTPS)" {
    #TODO Try change port => Need AnyCLI
    It "Connect to a switch (using HTTPS and -SkipCertificateCheck) and check global variable" -Skip:($httpOnly) {
        Connect-ArubaSW $ipaddress -Username $login -password $mysecpassword -SkipCertificateCheck -noverbose
        $DefaultArubaSWConnection | Should Not BeNullOrEmpty
        $DefaultArubaSWConnection.server | Should be $ipaddress
        $DefaultArubaSWConnection.cookie | Should Not BeNullOrEmpty
        $DefaultArubaSWConnection.port | Should be "443"
        $DefaultArubaSWConnection.httpOnly | Should be $false
        $DefaultArubaSWConnection.session | Should not BeNullOrEmpty
    }
    It "Disconnect to a switch (using HTTPS) and check global variable" -Skip:($httpOnly) {
        Disconnect-ArubaSW -noconfirm
        $DefaultArubaSWConnection | Should be $null
    }
    #This test only work with PowerShell 6 / Core (-SkipCertificateCheck don't change global variable but only Invoke-WebRequest/RestMethod)
    #This test will be fail, if there is valid certificate...
    It "Connect to a switch (using HTTPS) and check global variable" -Skip:($httpOnly -Or "Desktop" -eq $PSEdition) {
        { Connect-ArubaSW $ipaddress -Username $login -password $mysecpassword -noverbose } | Should throw "Unable to connect (certificate)"
    }
}

Describe  "Connect to a switch (using multi connection)" {
    It "Connect to a switch (using HTTP and store on sw variable)" {
        $script:sw = Connect-ArubaSW $ipaddress -Username $login -password $mysecpassword -httpOnly -noverbose -DefaultConnection:$false
        $DefaultArubaSWConnection | Should -BeNullOrEmpty
        $sw.server | Should -Be $ipaddress
        $sw.cookie | Should -Not -BeNullOrEmpty
        $sw.port | Should -Be "80"
        $sw.httpOnly | Should -Be $true
        $sw.session | Should -Not -BeNullOrEmpty
    }

    It "Throw when try to use Invoke-ArubaSWWebRequest and not connected" {
        { Invoke-ArubaSWWebRequest -uri "rest/v4/vlans" } | Should throw "Not Connected. Connect to the Switch with Connect-ArubaSW"
    }

    Context "Use Multi connection for call some (Get) cmdlet (Vlan, System...)" {
        It "Use Multi connection for call Get vlans" {
            { Get-ArubaSWVlans -connection $sw } | Should Not throw
        }
        It "Use Multi connection for call Get Vlans Ports" {
            { Get-ArubaSWVlansPorts -connection $sw } | Should Not throw
        }
        It "Use Multi connection for call Get DNS" {
            { Get-ArubaSWDNS -connection $sw } | Should Not throw
        }
        It "Use Multi connection for call Get Port" {
            { Get-ArubaSWPort -connection $sw } | Should Not throw
        }
    }

}

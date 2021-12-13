#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

Describe  "Connect to a switch (using HTTP)" {
    It "Connect to a switch (using HTTP) and check global variable" {
        Connect-ArubaSW $invokeParams.server -Username $invokeParams.Username -password $invokeParams.password -api_version 3 -httpOnly
        $DefaultArubaSWConnection.server | Should -Be $invokeParams.server
        $DefaultArubaSWConnection.cookie | Should -Not -BeNullOrEmpty
        $DefaultArubaSWConnection.port | Should -Be "80"
        $DefaultArubaSWConnection.httpOnly | Should -Be $true
        $DefaultArubaSWConnection.session | Should -Not -BeNullOrEmpty
        $DefaultArubaSWConnection.api_version.min | Should -Not -BeNullOrEmpty
        $DefaultArubaSWConnection.api_version.max | Should -Not -BeNullOrEmpty
        $DefaultArubaSWConnection.api_version.cur | Should -Be "3"
    }
    It "Disconnect to a switch (using HTTP) and check global variable" {
        Disconnect-ArubaSW -confirm:$false
        $DefaultArubaSWConnection | Should -Be $null
    }
    #TODO: Connect using wrong login/password
}

Describe  "Connect to a switch (using HTTPS)" {
    #TODO Try change port => Need AnyCLI
    It "Connect to a switch (using HTTPS and -SkipCertificateCheck) and check global variable" -Skip:($httpOnly) {
        Connect-ArubaSW $invokeParams.server -Username $invokeParams.Username -password $invokeParams.password -api_version 3 -SkipCertificateCheck
        $DefaultArubaSWConnection | Should -Not -BeNullOrEmpty
        $DefaultArubaSWConnection.server | Should -Be $invokeParams.server
        $DefaultArubaSWConnection.cookie | Should -Not -BeNullOrEmpty
        $DefaultArubaSWConnection.port | Should -Be "443"
        $DefaultArubaSWConnection.httpOnly | Should -Be $false
        $DefaultArubaSWConnection.session | Should -Not -BeNullOrEmpty
        $DefaultArubaSWConnection.api_version.min | Should -Not -BeNullOrEmpty
        $DefaultArubaSWConnection.api_version.max | Should -Not -BeNullOrEmpty
        $DefaultArubaSWConnection.api_version.cur | Should -Be "3"
    }
    It "Disconnect to a switch (using HTTPS) and check global variable" -Skip:($httpOnly) {
        Disconnect-ArubaSW -confirm:$false
        $DefaultArubaSWConnection | Should -Be $null
    }
    #This test only work with PowerShell 6 / Core (-SkipCertificateCheck don't change global variable but only Invoke-WebRequest/RestMethod)
    #This test will -Be fail, if there is valid certificate...
    It "Connect to a switch (using HTTPS) and check global variable" -Skip:($httpOnly -Or "Desktop" -eq $PSEdition) {
        { Connect-ArubaSW $invokeParams.server -Username $invokeParams.Username -password $invokeParams.password } | Should -Throw "Unable to connect (certificate)"
    }
}

Describe  "Connect to a switch (using multi connection)" {
    It "Connect to a switch (using HTTP and store on sw variable)" {
        $script:sw = Connect-ArubaSW $invokeParams.server -Username $invokeParams.Username -password $invokeParams.password -httpOnly -DefaultConnection:$false
        $DefaultArubaSWConnection | Should -BeNullOrEmpty
        $sw.server | Should -Be $invokeParams.server
        $sw.cookie | Should -Not -BeNullOrEmpty
        $sw.port | Should -Be "80"
        $sw.httpOnly | Should -Be $true
        $sw.session | Should -Not -BeNullOrEmpty
        $sw.api_version.min | Should -Not -BeNullOrEmpty
        $sw.api_version.max | Should -Not -BeNullOrEmpty
        $sw.api_version.cur | Should -Not -BeNullOrEmpty
    }

    It "Throw when try to use Invoke-ArubaSWWebRequest and not connected" {
        { Invoke-ArubaSWWebRequest -uri "rest/v4/vlans" } | Should -Throw "Not Connected. Connect to the Switch with Connect-ArubaSW"
    }

    Context "Use Multi connection for call some (Get) cmdlet (Vlan, System...)" {
        It "Use Multi connection for call Get vlans" {
            { Get-ArubaSWVlans -connection $sw } | Should -Not -Throw
        }
        It "Use Multi connection for call Get Vlans Ports" {
            { Get-ArubaSWVlansPorts -connection $sw } | Should -Not -Throw
        }
        It "Use Multi connection for call Get DNS" {
            { Get-ArubaSWDNS -connection $sw } | Should -Not -Throw
        }
        It "Use Multi connection for call Get Port" {
            { Get-ArubaSWPort -connection $sw } | Should -Not -Throw
        }
        It "Use Multi connection for call Get PoE" {
            { Get-ArubaSWPoE -connection $sw } | Should -Not -Throw
        }
        It "Use Multi connection for call Get LLDP Remote" {
            { Get-ArubaSWLLDPRemote -connection $sw } | Should -Not -Throw
        }
        It "Use Multi connection for call Get MAC Table" {
            { Get-ArubaSWMACTable -connection $sw } | Should -Not -Throw
        }
        It "Use Multi connection for call Get RADIUS Profile" {
            { Get-ArubaSWRadiusProfile -connection $sw } | Should -Not -Throw
        }
        It "Use Multi connection for call Get RADIUS Server" {
            { Get-ArubaSWRadiusServer -connection $sw } | Should -Not -Throw
        }
    }

    It "Disconnect to a switch (Multi connection)" {
        Disconnect-ArubaSW -connection $sw -confirm:$false
        $DefaultArubaSWConnection | Should -Be $null
    }

}

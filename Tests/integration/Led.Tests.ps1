#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1


Describe  "Get Led Locator" {
    BeforeAll {
        #Disable...
        Set-ArubaSWLed -status off
    }
    It "Get LedLocator Does not throw an error" {
        {
            Get-ArubaSWLed
        } | Should Not Throw
    }

    It "Get LedLocator info (first unit)" {
        $LED = Get-ArubaSWLed
        $LED[0].status | Should Be "LS_OFF"
        $LED[0].duration_in_seconds | Should BeNullOrEmpty
        $LED[0].when | Should be "LBT_NOW"
        $LED[0].remaining_seconds | Should BeNullOrEmpty
    }
}

Describe  "Configure Led Locator" {

    It "Configure Led Locator (with default duration => 30 minutes)" {
        Set-ArubaSWLed -status on
        $LED = Get-ArubaSWLed
        $LED[0].status | Should Be "LS_ON"
        $LED[0].duration_in_seconds | Should BeNullOrEmpty
        $LED[0].when | Should be "LBT_NOW"
        $LED[0].remaining_seconds | Should -BeGreaterThan 1740
    }

    It "Configure Led Locator (with duration 1 minute)" {
        Set-ArubaSWLed -status on -duration 1
        Start-Sleep 1
        $LED = Get-ArubaSWLed
        $LED[0].status | Should Be "LS_ON"
        $LED[0].duration_in_seconds | Should BeNullOrEmpty
        $LED[0].when | Should be "LBT_NOW"
        $LED[0].remaining_seconds | Should -BeGreaterThan 40
        $LED[0].remaining_seconds | Should -BeLessThan 60
    }

    It "Disable Led Locator" {
        Set-ArubaSWLed -status off
        $LED = Get-ArubaSWLed
        $LED[0].status | Should Be "LS_OFF"
        $LED[0].duration_in_seconds | Should BeNullOrEmpty
        $LED[0].when | Should be "LBT_NOW"
        $LED[0].remaining_seconds | Should BeNullOrEmpty
    }

    It "Configure Led locator for blink" {
        Set-ArubaSWLed -status blink
        $LED = Get-ArubaSWLed
        $LED[0].status | Should Be "LS_BLINK"
        $LED[0].duration_in_seconds | Should BeNullOrEmpty
        $LED[0].when | Should be "LBT_NOW"
        $LED[0].remaining_seconds | Should -BeGreaterThan 1740
    }

    It "Disable Led locator blinking" {
        Set-ArubaSWLed -status off
        $LED = Get-ArubaSWLed
        $LED[0].status | Should Be "LS_OFF"
        $LED[0].duration_in_seconds | Should BeNullOrEmpty
        $LED[0].when | Should be "LBT_NOW"
        $LED[0].remaining_seconds | Should BeNullOrEmpty
    }

    It "Configure Led locator to startup" {
        Set-ArubaSWLed -status on -when Startup
        $LED = Get-ArubaSWLed
        $LED[0].status | Should Be "LS_ON"
        $LED[0].duration_in_seconds | Should be 1800
        $LED[0].when | Should be "LBT_STARTUP"
        $LED[0].remaining_seconds | Should BeNullOrEmpty
    }

    It "Configure Led locator to startup during 1 minute" {
        Set-ArubaSWLed -status on -when Startup -duration 1
        $LED = Get-ArubaSWLed
        $LED[0].status | Should Be "LS_ON"
        $LED[0].duration_in_seconds | Should be 60
        $LED[0].when | Should be "LBT_STARTUP"
        $LED[0].remaining_seconds | Should BeNullOrEmpty
    }

    It "Disable Led locator blinking" {
        Set-ArubaSWLed -status off
        $LED = Get-ArubaSWLed
        $LED[0].status | Should Be "LS_OFF"
        $LED[0].duration_in_seconds | Should BeNullOrEmpty
        $LED[0].when | Should be "LBT_NOW"
        $LED[0].remaining_seconds | Should BeNullOrEmpty
    }
}

Disconnect-ArubaSW -noconfirm

#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-ArubaSW @invokeParams
}

Describe  "Get System" {
    It "Get System Does not throw an error" {
        {
            Get-ArubaSWSystem
        } | Should -Not -Throw
    }

    It "Get System (info)" {
        $SYSTEM = Get-ArubaSWSystem
        $SYSTEM.name | Should -Not -Be $NULL
        $SYSTEM.location | Should -Not -Be $NULL
        $SYSTEM.contact | Should -Not -Be $NULL
        $SYSTEM.device_operation_mode | Should -Not -Be $NULL
    }
}

Describe  "Configure System" {
    BeforeAll {
        $SYSTEM = Get-ArubaSWSystem
        if ($SYSTEM.location -eq $NULL) {
            Set-ArubaSWSystem -location "My Location"
        }
        if ($SYSTEM.contact -eq $NULL) {
            Set-ArubaSWSystem -location "power@aruba"
        }
    }

    It "Configure system name" {
        $name = (Get-ArubaSWSystem).name
        Set-ArubaSWSystem -name "PowerAruba-SW-Name"
        $SYSTEM = Get-ArubaSWSystem
        $SYSTEM.name | Should -Be "PowerAruba-SW-Name"
        #Set Name back
        Set-ArubaSWSystem -name $name
    }

    It "Configure system location" {
        $location = (Get-ArubaSWSystem).location
        Set-ArubaSWSystem -location "PowerAruba-SW-Location"
        $SYSTEM = Get-ArubaSWSystem
        $SYSTEM.location | Should -Be "PowerAruba-SW-Location"
        #Set Name back
        Set-ArubaSWSystem -location $location
    }

    It "Configure system contact" {
        $contact = (Get-ArubaSWSystem).contact
        Set-ArubaSWSystem -contact "PowerAruba-SW-Contact"
        $SYSTEM = Get-ArubaSWSystem
        $SYSTEM.contact | Should -Be "PowerAruba-SW-Contact"
        #Set Name back
        Set-ArubaSWSystem -contact $contact
    }
}

Describe  "Get System Status Global (Stacked)" {
    It "Get System Status Global (Stacked) Does not throw an error" -Skip:(-Not ('ST_STACKED' -eq $script:switch_type)) {
        {
            Get-ArubaSWSystemStatusGlobal
        } | Should -Not -Throw
    }

    It "Get System Status Global (Stacked)" -Skip:(-Not ('ST_STACKED' -eq $script:switch_type)) {
        $SYSTEM_STATUS = Get-ArubaSWSystemStatusGlobal
        $SYSTEM_STATUS.name | Should -Not -Be $NULL
        $SYSTEM_STATUS.firmware_version | Should -Not -Be $NULL
        $SYSTEM_STATUS.base_ethernet_address | Should -Not -Be $NULL
    }
    It "Get System Status (Stacked) Does THROW an error" -Skip:('ST_STACKED' -eq $script:switch_type) {
        {
            Get-ArubaSWSystemStatusGlobal
        } | Should -Throw "Unable to use this cmdlet, you need to use Get-ArubaSWSystemStatus"
    }
}

Describe  "Get System Status (Standalone/Chassis)" {
    It "Get System Status (Standalone/Chassis) Does not throw an error" -Skip:(-not ('ST_STANDALONE' -eq $script:switch_type) -or ('ST_CHASSIS' -eq $script:switch_type)) {
        {
            Get-ArubaSWSystemStatus
        } | Should -Not -Throw
    }

    It "Get System Status (Standalone)" -Skip:(-not ('ST_STANDALONE' -eq $script:switch_type -or 'ST_CHASSIS' -eq $script:switch_type)) {
        $SYSTEM_STATUS = Get-ArubaSWSystemStatus
        $SYSTEM_STATUS.name | Should -Not -Be $NULL
        $SYSTEM_STATUS.serial_number | Should -Not -Be $NULL
        $SYSTEM_STATUS.firmware_version | Should -Not -Be $NULL
        $SYSTEM_STATUS.hardware_revision | Should -Not -Be $NULL
        $SYSTEM_STATUS.product_model | Should -Not -Be $NULL
        $SYSTEM_STATUS.base_ethernet_address | Should -Not -Be $NULL
        $SYSTEM_STATUS.total_memory_in_bytes | Should -Not -Be $NULL
        $SYSTEM_STATUS.total_poe_consumption | Should -Not -Be $NULL
    }
    It "Get System Status (Stacked) Does THROW an error" -Skip:(('ST_STANDALONE' -eq $script:switch_type -or 'ST_CHASSIS' -eq $script:switch_type)) {
        {
            Get-ArubaSWSystemStatus
        } | Should -Throw "Unable to use this cmdlet, you need to use Get-ArubaSWSystemStatusGlobal"
    }
}


Describe  "Get System Status Switch" {
    It "Get System Status Switch Does not throw an error" {
        {
            Get-ArubaSWSystemStatusSwitch
        } | Should -Not -Throw
    }

    It "Get System Status Switch (Standalone)" -Skip:(-Not ('ST_STANDALONE' -eq $script:switch_type)) {
        $SYSTEM_STATUS_SWITCH = Get-ArubaSWSystemStatusSwitch
        $SYSTEM_STATUS_SWITCH.switch_type | Should -Be 'ST_STANDALONE'
        $SYSTEM_STATUS_SWITCH.product_name | Should -Not -Be $NULL
        $SYSTEM_STATUS_SWITCH.product_number | Should -Not -Be $NULL
        $SYSTEM_STATUS_SWITCH.hardware_info | Should -Not -Be $NULL
        $SYSTEM_STATUS_SWITCH.blades | Should -Not -Be $NULL
    }

    It "Get System Status Switch (Stacked)" -Skip:(-Not ('ST_STACKED' -eq $script:switch_type)) {
        $SYSTEM_STATUS_SWITCH = Get-ArubaSWSystemStatusSwitch
        $SYSTEM_STATUS_SWITCH.switch_type | Should -Be 'ST_STACKED'
        $SYSTEM_STATUS_SWITCH.blades | Should -Not -Be $NULL
        $SYSTEM_STATUS_SWITCH.blades.product_name | Should -Not -Be $NULL
        $SYSTEM_STATUS_SWITCH.blades.product_number | Should -Not -Be $NULL
        $SYSTEM_STATUS_SWITCH.blades.hardware_info | Should -Not -Be $NULL
        $SYSTEM_STATUS_SWITCH.blades.data_ports | Should -Not -Be $NULL
    }

    It "Get System Status Switch (Chassis)" -Skip:(-Not ('ST_CHASSIS' -eq $script:switch_type)) {
        $SYSTEM_STATUS_SWITCH = Get-ArubaSWSystemStatusSwitch
        $SYSTEM_STATUS_SWITCH.switch_type | Should -Be 'ST_CHASSIS'
        $SYSTEM_STATUS_SWITCH.blades | Should -Not -Be $NULL
        $SYSTEM_STATUS_SWITCH.blades.product_name | Should -Not -Be $NULL
        $SYSTEM_STATUS_SWITCH.blades.product_number | Should -Not -Be $NULL
        $SYSTEM_STATUS_SWITCH.blades.hardware_info | Should -Not -Be $NULL
        $SYSTEM_STATUS_SWITCH.blades.data_ports | Should -Not -Be $NULL
    }
}

AfterAll {
    Disconnect-ArubaSW -confirm:$false
}
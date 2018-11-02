#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1
#TODO: Add check if no ipaddress/login/password info...

Describe  "Get System" {
    It "Get System Does not throw an error" {
        {
            Get-ArubaSWSystem
        } | Should Not Throw 
    }

    It "Get System (info)" {
            $SYSTEM = Get-ArubaSWSystem
            $SYSTEM.name | Should not be $NULL
            $SYSTEM.location | should not be $NULL
            $SYSTEM.contact | should not be $NULL
            $SYSTEM.device_operation_mode | should not be $NULL
    }
}

Describe  "Configure System" {
        BeforeAll {
            $SYSTEM = Get-ArubaSWSystem
            if ($SYSTEM.location -eq $NULL){
                Set-ArubaSWSystem -location "My Location"
            }
            if ($SYSTEM.contact -eq $NULL){
                Set-ArubaSWSystem -location "power@aruba"
            }
        }

        It "Configure system name" {
            $name = (Get-ArubaSWSystem).name
            Set-ArubaSWSystem -name "PowerAruba-SW-Name"
            $SYSTEM = Get-ArubaSWSystem
            $SYSTEM.name | Should be "PowerAruba-SW-Name"
            #Set Name back
            Set-ArubaSWSystem -name $name
        }

        It "Configure system location" {
            $location = (Get-ArubaSWSystem).location
            Set-ArubaSWSystem -location "PowerAruba-SW-Location"
            $SYSTEM = Get-ArubaSWSystem
            $SYSTEM.location | Should be "PowerAruba-SW-Location"
            #Set Name back
            Set-ArubaSWSystem -location $location
        }

        It "Configure system contact" {
            $contact = (Get-ArubaSWSystem).contact
            Set-ArubaSWSystem -contact "PowerAruba-SW-Contact"
            $SYSTEM = Get-ArubaSWSystem
            $SYSTEM.contact | Should be "PowerAruba-SW-Contact"
            #Set Name back
            Set-ArubaSWSystem -contact $contact
        }
}

Describe  "Get System Status" {
    It "Get System Does not throw an error" {
        {
            Get-ArubaSWSystemStatus
        } | Should Not Throw 
    }

    It "Get SystemStatus (info)" {
            $SYSTEM_STATUS = Get-ArubaSWSystemStatus
            $SYSTEM_STATUS.name | Should not be $NULL
            $SYSTEM_STATUS.serial_number | should not be $NULL
            $SYSTEM_STATUS.firmware_version | should not be $NULL
            $SYSTEM_STATUS.hardware_revision | should not be $NULL
            $SYSTEM_STATUS.product_model | should not be $NULL
            $SYSTEM_STATUS.base_ethernet_address | should not be $NULL
            $SYSTEM_STATUS.total_memory_in_bytes | should not be $NULL
            $SYSTEM_STATUS.total_poe_consumption | should not be $NULL
    }
}

Disconnect-ArubaSW -noconfirm
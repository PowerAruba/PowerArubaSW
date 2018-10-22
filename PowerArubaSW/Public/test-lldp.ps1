#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
Param(
    [string]$password,
    [string]$login,
    [string]$ipaddress
)

$mysecpassword = ConvertTo-SecureString $password -AsPlainText -Force
Connect-ArubaSW -Server $ipaddress -Username $login -password $mysecpassword

Describe  "Get LLDP info about remote devices" {
    It "Get LLDPRemote does not throw an error" {
        {
            Get-ArubaSWLLDPRemote
        } | Should Not Throw 
    }

    It "Get LLDPRemote is not null" {
        $timeout = Get-ArubaSWLLDPRemote
        $timeout | Should not be $NULL
    }
}

Describe  "Get LLDP status on the switch" {
    It "Get LLDPDlobalStatus does not throw an error" {
        {
            Get-ArubaSWLLDPGlobalStatus
        } | Should Not Throw 
    }

    It "Check if LLDP is enable" {
        $lldpstatus = Get-ArubaSWLLDPGlobalStatus
        $lldpstatus.admin_status | Should be "LLAS_ENABLED" 
    }

    It "Get LLDPGlobalStatus is not null" {
        $timeout = Get-ArubaSWLLDPGlobalStatus
        $timeout | Should not be $NULL
    }
}

Describe  "Get LLDP neighbors stats" {
    It "Get LLDPNeighborStats does not throw an error" {
        {
            Get-ArubaSWLLDPNeighborStats
        } | Should Not Throw 
    }

    It "Get LLDPRemote is not null" {
        $timeout = Get-ArubaSWLLDPNeighborStats
        $timeout | Should not be $NULL
    }
}

Describe  "Get LLDP ports stats" {
    It "Get LLDPPortStats does not throw an error" {
        {
            Get-ArubaSWLLDPPortStats 
        } | Should Not Throw 
    }

    It "Get LLDPPortStats is not null" {
        $timeout = Get-ArubaSWLLDPPortStats 
        $timeout | Should not be $NULL
    }
}

Describe  "Set LLDPGlobalStatus" {
    It "Set LLDPGlobalStatus false" {
        Set-ArubaSWLLDPGlobalStatus -enable:$false 
        $lldpstatus = Get-ArubaSWLLDPGlobalStatus
        $lldpstatus.admin_status | Should be "LLAS_DISABLED" 
    }

    It "Set LLDPGlobalStatus true" {
        Set-ArubaSWLLDPGlobalStatus -enable:$true 
        $lldpstatus = Get-ArubaSWLLDPGlobalStatus
        $lldpstatus.admin_status | Should be "LLAS_ENABLED" 
    }
    
    It "Set LLDPGlobalStatus transmit" {
        Set-ArubaSWLLDPGlobalStatus -transmit 1500 
        $lldpstatus = Get-ArubaSWLLDPGlobalStatus
        $lldpstatus.transmit_interval | Should be "1500"
        Set-ArubaSWLLDPGlobalStatus -transmit 30
    }

    It "Set LLDPGlobalStatus hold time multiplier" {
        Set-ArubaSWLLDPGlobalStatus -holdtime 8 
        $lldpstatus = Get-ArubaSWLLDPGlobalStatus
        $lldpstatus.hold_time_multiplier | Should be "8"
        Set-ArubaSWLLDPGlobalStatus -holdtime 4
    }

    It "Set LLDPGlobalStatus fast start" {
        Set-ArubaSWLLDPGlobalStatus -faststart 8 
        $lldpstatus = Get-ArubaSWLLDPGlobalStatus
        $lldpstatus.fast_start_count | Should be "8"
        Set-ArubaSWLLDPGlobalStatus -faststart 5
    }

    It "Check range of LLDPGlobalStatus transmit value" {
        $change = 5
        {Set-ArubaSWLLDPGlobalStatus -transmit $change} | Should Throw
        
        $change = 35000
        {Set-ArubaSWLLDPGlobalStatus -transmit $change} | Should Throw
    }

    It "Check range of LLDPGlobalStatus holdtime value" {
        $change = 1
        {Set-ArubaSWLLDPGlobalStatus -holdtime $change} | Should Throw
        
        $change = 12
        {Set-ArubaSWLLDPGlobalStatus -holdtime $change} | Should Throw
    }

    It "Check range of LLDPGlobalStatus faststart value" {
        $change = 0
        {Set-ArubaSWLLDPGlobalStatus -faststart $change} | Should Throw
        
        $change = 12
        {Set-ArubaSWLLDPGlobalStatus -faststart $change} | Should Throw
    }
}

Disconnect-ArubaSW -noconfirm
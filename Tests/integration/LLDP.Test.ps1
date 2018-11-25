#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

../common.ps1

Describe  "Get LLDP info about remote devices" {
    It "Get LLDPRemote does not throw an error" {
        {
            Get-ArubaSWLLDPRemote
        } | Should Not Throw 
    }

    It "Get LLDPRemote is not null" {
        $lldpremote = Get-ArubaSWLLDPRemote
        $lldpremote | Should not be $NULL
    }
}

Describe  "Get LLDP status on the switch" {
    It "Get LLDPGlobalStatus does not throw an error" {
        {
            Get-ArubaSWLLDPGlobalStatus
        } | Should Not Throw 
    }

    It "Check if LLDP is enable" {
        $lldpstatus = Get-ArubaSWLLDPGlobalStatus
        $lldpstatus.admin_status | Should be "LLAS_ENABLED" 
    }

    It "Get LLDPGlobalStatus is not null" {
        $lldpremote = Get-ArubaSWLLDPGlobalStatus
        $lldpremote | Should not be $NULL
    }
}

Describe  "Get LLDP neighbors stats" {
    It "Get LLDPNeighborStats does not throw an error" {
        {
            Get-ArubaSWLLDPNeighborStats
        } | Should Not Throw 
    }

    It "Get LLDPRemote is not null" {
        $lldpstats = Get-ArubaSWLLDPNeighborStats
        $lldpstats | Should not be $NULL
    }
}

Describe  "Get LLDP ports stats" {
    It "Get LLDPPortStats does not throw an error" {
        {
            Get-ArubaSWLLDPPortStats 
        } | Should Not Throw 
    }

    It "Get LLDPPortStats is not null" {
        $lldpstats = Get-ArubaSWLLDPPortStats 
        $lldpstats | Should not be $NULL
    }
}

Describe  "Set LLDPGlobalStatus" {
    It "Disable LLDP" {
        Set-ArubaSWLLDPGlobalStatus -enable:$false 
        $lldpstatus = Get-ArubaSWLLDPGlobalStatus
        $lldpstatus.admin_status | Should be "LLAS_DISABLED" 
    }

    It "Enable LLDP" {
        Set-ArubaSWLLDPGlobalStatus -enable:$true 
        $lldpstatus = Get-ArubaSWLLDPGlobalStatus
        $lldpstatus.admin_status | Should be "LLAS_ENABLED" 
    }
    
    It "Configure LLDP transmit interval" {
        Set-ArubaSWLLDPGlobalStatus -transmit 1500 
        $lldpstatus = Get-ArubaSWLLDPGlobalStatus
        $lldpstatus.transmit_interval | Should be "1500"
        Set-ArubaSWLLDPGlobalStatus -transmit 30
    }

    It "Check range of LLDP transmit value" {
        $change = 5
        {Set-ArubaSWLLDPGlobalStatus -transmit $change} | Should Throw
        
        $change = 35000
        {Set-ArubaSWLLDPGlobalStatus -transmit $change} | Should Throw
    }

    It "Configure LLDP hold time multiplier" {
        Set-ArubaSWLLDPGlobalStatus -holdtime 8 
        $lldpstatus = Get-ArubaSWLLDPGlobalStatus
        $lldpstatus.hold_time_multiplier | Should be "8"
        Set-ArubaSWLLDPGlobalStatus -holdtime 4
    }

    It "Check range of LLDP holdtime value" {
        $change = 1
        {Set-ArubaSWLLDPGlobalStatus -holdtime $change} | Should Throw
        
        $change = 12
        {Set-ArubaSWLLDPGlobalStatus -holdtime $change} | Should Throw
    }

    It "Configure LLDP fast start" {
        Set-ArubaSWLLDPGlobalStatus -faststart 8 
        $lldpstatus = Get-ArubaSWLLDPGlobalStatus
        $lldpstatus.fast_start_count | Should be "8"
        Set-ArubaSWLLDPGlobalStatus -faststart 5
    }

    It "Check range of LLDP fast start value" {
        $change = 0
        {Set-ArubaSWLLDPGlobalStatus -faststart $change} | Should Throw
        
        $change = 12
        {Set-ArubaSWLLDPGlobalStatus -faststart $change} | Should Throw
    }
}

Disconnect-ArubaSW -noconfirm
#
# Copyright 2019, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

Describe  "Get Aruba Trunk" {
    It "Get ArubaSWTrunk Does not throw an error" {
        { Get-ArubaSWTrunk } | Should Not Throw
    }
}

Describe  "Add Aruba Trunk" {
    It "Add Trunk $pester_trunk_trk1 on port $pester_trunk_port" {
        Add-ArubaSWTrunk -trunk_group $pester_trunk_trk1 -port $pester_trunk_port
        $Trunk = Get-ArubaSWTrunk | Where-Object port_id -eq $pester_trunk_port
        $Trunk.port_id | Should be "$pester_trunk_port"
        $Trunk.trunk_group | Should be "$pester_trunk_trk1"
        Remove-ArubaSWTrunk -trunk_group $pester_trunk_trk1 -port $pester_trunk_port -noconfirm
    }

    It "Change trunk group $pester_trunk_trk1 on a port without removing it before" {
        Add-ArubaSWTrunk -trunk_group $pester_trunk_trk1 -port $pester_trunk_port
        { Add-ArubaSWTrunk -trunk_group $pester_trunk_trk2 -port $pester_trunk_port 3> $null } | Should Throw
        Remove-ArubaSWTrunk -trunk_group $pester_trunk_trk1 -port $pester_trunk_port -noconfirm
    }

    It "Change trunk group $pester_trunk_trk2 on a port after removing this port of the trunk group" {
        Add-ArubaSWTrunk -trunk_group $pester_trunk_trk1 -port $pester_trunk_port
        Remove-ArubaSWTrunk -trunk_group $pester_trunk_trk1 -port $pester_trunk_port -noconfirm
        { Add-ArubaSWTrunk -trunk_group $pester_trunk_trk2 -port $pester_trunk_port } | Should Not Throw
        Remove-ArubaSWTrunk -trunk_group $pester_trunk_trk1 -port $pester_trunk_port -noconfirm
    }
}

Describe  "Remove Aruba Trunk" {
    It "Remove ArubaSWTrunk does throw an error if trunk group doesn't exist on a port" {
        { Remove-ArubaSWTrunk -trunk_group $pester_trunk_trk1 -port $pester_trunk_port -noconfirm 3> $null } | Should Throw
    }

    It "Remove ArubaSWTrunk does not throw an error if the trunk group exist on a port" {
        Add-ArubaSWTrunk -trunk_group $pester_trunk_trk1 -port $pester_trunk_port
        { Remove-ArubaSWTrunk -trunk_group $pester_trunk_trk1 -port $pester_trunk_port -noconfirm } | Should Not Throw
    }
}


Disconnect-ArubaSW -noconfirm
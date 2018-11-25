#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

../common.ps1

#$mysecpassword = ConvertTo-SecureString $password -AsPlainText -Force
#Connect-ArubaSW -Server $ipaddress -Username $login -password $mysecpassword

Describe  "Get Aruba LACP" {
    It "Get ArubaSWLACP Does not throw an error" {
        { Get-ArubaSWLACP } | Should Not Throw 
    }
}

Describe  "Add ArubaSWLACP" {
    It "Add LACP on a port" {
        Add-ArubaSWLACP -trunk_group trk2 -port 5
        $lacp = Get-ArubaSWLACP | Where-Object port_id -eq 5
        $lacp.port_id | Should be "5"
        $lacp.trunk_group | Should be "trk2"
        Remove-ArubaSWLACP -trunk_group trk2 -port 5 -noconfirm
    }

    It "Change trunk group on a port without removing it before" {
        Add-ArubaSWLACP -trunk_group trk2 -port 5
        { Add-ArubaSWLACP -trunk_group trk6 -port 5 3> $null } | Should Throw
        Remove-ArubaSWLACP -trunk_group trk2 -port 5 -noconfirm
    }

    It "Change trunk group on a port after removing this port of the trunk group" {
        Add-ArubaSWLACP -trunk_group trk2 -port 5
        Remove-ArubaSWLACP -trunk_group trk2 -port 5 -noconfirm
        { Add-ArubaSWLACP -trunk_group trk6 -port 5 } | Should Not Throw
        Remove-ArubaSWLACP -trunk_group trk6 -port 5 -noconfirm
    }
}

Describe  "Remove Aruba LACP" {
    It "Remove ArubaSWLACP does throw an error if trunk group doesn't exist on a port" {
        { Remove-ArubaSWLACP -trunk_group trk2 -port 5 -noconfirm 3> $null } | Should Throw
    }

    It "Remove ArubaSWLACP does not throw an error if the trunk group exist on a port" {
        Add-ArubaSWLACP -trunk_group trk2 -port 5
        { Remove-ArubaSWLACP -trunk_group trk2 -port 5 -noconfirm } | Should Not Throw 
    }
}


Disconnect-ArubaSW -noconfirm
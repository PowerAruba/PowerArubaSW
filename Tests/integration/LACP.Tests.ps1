#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

BeforeAll {
    Connect-ArubaSW @invokeParams
}

Describe  "Get Aruba LACP" {
    It "Get ArubaSWLACP Does not throw an error" {
        { Get-ArubaSWLACP } | Should -Not -Throw
    }
}

Describe  "Add ArubaSWLACP" {
    It "Add LACP on a port" {
        Add-ArubaSWLACP -trunk_group $pester_lacp_trk1 -port $pester_lacp_port
        $lacp = Get-ArubaSWLACP | Where-Object port_id -eq $pester_lacp_port
        $lacp.port_id | Should -Be "$pester_lacp_port"
        $lacp.trunk_group | Should -Be "$pester_lacp_trk1"
        Remove-ArubaSWLACP -trunk_group $pester_lacp_trk1 -port $pester_lacp_port -confirm:$false
    }

    It "Change trunk group on a port without removing it before" {
        Add-ArubaSWLACP -trunk_group $pester_lacp_trk1 -port $pester_lacp_port
        { Add-ArubaSWLACP -trunk_group $pester_lacp_trk2 -port $pester_lacp_port 3> $null } | Should -Throw
        Remove-ArubaSWLACP -trunk_group $pester_lacp_trk1 -port $pester_lacp_port -confirm:$false
    }

    It "Change trunk group on a port after removing this port of the trunk group" {
        Add-ArubaSWLACP -trunk_group $pester_lacp_trk1 -port $pester_lacp_port
        Remove-ArubaSWLACP -trunk_group $pester_lacp_trk1 -port $pester_lacp_port -confirm:$false
        { Add-ArubaSWLACP -trunk_group $pester_lacp_trk2 -port $pester_lacp_port } | Should -Not -Throw
        Remove-ArubaSWLACP -trunk_group $pester_lacp_trk2 -port $pester_lacp_port -confirm:$false
    }
}

Describe  "Remove Aruba LACP" {
    It "Remove ArubaSWLACP does throw an error if trunk group doesn't exist on a port" {
        { Remove-ArubaSWLACP -trunk_group $pester_lacp_trk1 -port $pester_lacp_port -confirm:$false 3> $null } | Should -Throw
    }

    It "Remove ArubaSWLACP does not throw an error if the trunk group exist on a port" {
        Add-ArubaSWLACP -trunk_group $pester_lacp_trk1 -port $pester_lacp_port
        { Remove-ArubaSWLACP -trunk_group $pester_lacp_trk1 -port $pester_lacp_port -confirm:$false } | Should -Not -Throw
    }
}


AfterAll {
    Disconnect-ArubaSW -noconfirm
}
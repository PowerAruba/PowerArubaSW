#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2019, Cedric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

BeforeAll {
    Connect-ArubaSW @invokeParams
}

Describe  "Get RADIUS Server Group" {

    BeforeAll {
        Add-ArubaSWRadiusServer -address 192.0.2.1 -shared_secret powerarubasw
        Add-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW -server1 192.0.2.1
    }

    It "Get-ArubaSWRadiusServerGroup Does not throw an error" {
        { Get-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW } | Should -Not -Throw
    }

    AfterAll {
        Remove-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW -confirm:$false
        Get-ArubaSWRadiusServer -address 192.0.2.1 | Remove-ArubaSWRadiusServer -confirm:$false
    }

}

Describe  "Add RADIUS Server Group" {

    BeforeAll {
        Add-ArubaSWRadiusServer -address 192.0.2.1 -shared_secret powerarubasw
        Add-ArubaSWRadiusServer -address 192.0.2.2 -shared_secret powerarubasw#
    }

    It "Check name of group and IP" {
        Add-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW -server1 192.0.2.1
        $radius_group = Get-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW
        $radius_group.server_group_name | Should -Be "PowerArubaSW"
        $radius_group.server_ip.octets | Should -Be "192.0.2.1"
    }

    It "Check IP of multiple RADIUS server" {
        Add-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW -server1 192.0.2.1 -server2 192.0.2.2
        $radius_group = Get-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW
        $radius_group.server_ip.octets[0] | Should -Be "192.0.2.1"
        $radius_group.server_ip.octets[1] | Should -Be "192.0.2.2"
    }

    AfterEach {
        Remove-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW -confirm:$false
    }

    AfterAll {
        Get-ArubaSWRadiusServer -address 192.0.2.1 | Remove-ArubaSWRadiusServer -confirm:$false
        Get-ArubaSWRadiusServer -address 192.0.2.2 | Remove-ArubaSWRadiusServer -confirm:$false
    }
}

Describe  "Remove RADIUS Server Group" {

    BeforeEach {
        Add-ArubaSWRadiusServer -address 192.0.2.1 -shared_secret powerarubasw
        Add-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW -server1 192.0.2.1
    }

    Context "Remove RADIUS Server Group via id" {

        It "Remove RADIUS Server Group" {

            $radius_group = Get-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW
            Remove-ArubaSWRadiusServerGroup -server_group_name $radius_group.server_group_name -confirm:$false
            { Get-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW 3> $null } | Should -Throw
        }

    }

    Context "Remove RADIUS Server Group via pipeline" {

        It "Remove RADIUS Server Group" {
            Get-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW | Remove-ArubaSWRadiusServerGroup -confirm:$false
            { Get-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW 3> $null } | Should -Throw
        }

    }

    AfterEach {
        Get-ArubaSWRadiusServer -address 192.0.2.1 | Remove-ArubaSWRadiusServer -confirm:$false
    }
}

AfterAll {
    Disconnect-ArubaSW -confirm:$false
}

#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

Describe  "Get-ArubaSWRadiusServerGroup" {

    BeforeAll {
        Add-ArubaSWRadiusServer -address 192.0.2.1 -shared_secret powerarubasw
        Add-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW -server1 192.0.2.1
    }

    It "Get-ArubaSWRadiusServerGroup Does not throw an error" {
        { Get-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW } | Should Not Throw
    }

    AfterAll {
        Remove-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW -noconfirm
        Get-ArubaSWRadiusServer -address 192.0.2.1 | Remove-ArubaSWRadiusServer -noconfirm
    }

}

Describe  "Add-ArubaSWRadiusServerGroup" {

    BeforeEach {
        Add-ArubaSWRadiusServer -address 192.0.2.1 -shared_secret powerarubasw
    }

    It "Check name of group and IP" {
        Add-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW -server1 192.0.2.1
        $radius_group = Get-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW
        $radius_group.server_group_name | Should be "PowerArubaSW"
        $radius_group.server_ip.octets | Should be "192.0.2.1"
    }

    It "Check IP of multiple RADIUS server" {
        Add-ArubaSWRadiusServer -address 192.0.2.2 -shared_secret powerarubasw
        Add-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW -server1 192.0.2.1 -server2 192.0.2.2
        $radius_group = Get-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW
        $radius_group.server_ip.octets[0] | Should be "192.0.2.1"
        $radius_group.server_ip.octets[1] | Should be "192.0.2.2"
    }

    AfterEach {
        Remove-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW -noconfirm
        Get-ArubaSWRadiusServer -address 192.0.2.1 | Remove-ArubaSWRadiusServer -noconfirm
        Get-ArubaSWRadiusServer -address 192.0.2.2 | Remove-ArubaSWRadiusServer -noconfirm
    }
}

Describe  "Remove-ArubaSWRadiusServerGroup" {

    BeforeEach {
        Add-ArubaSWRadiusServer -address 192.0.2.1 -shared_secret powerarubasw
        Add-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW -server1 192.0.2.1
    }

    It "Remove RADIUS group server" {

        $radius_group = Get-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW
        Remove-ArubaSWRadiusServerGroup -server_group_name $radius_group.server_group_name -noconfirm
        { Get-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW } | Should Throw
    }

    It "Remove RADIUS group server" {
        Get-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW | Remove-ArubaSWRadiusServerGroup -noconfirm
        { Get-ArubaSWRadiusServerGroup -server_group_name PowerArubaSW } | Should Throw
    }

    AfterEach {
        Get-ArubaSWRadiusServer -address 192.0.2.1 | Remove-ArubaSWRadiusServer -noconfirm
    }
}

Disconnect-ArubaSW -noconfirm
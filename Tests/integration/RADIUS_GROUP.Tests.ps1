#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2019, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

. ../common.ps1

Describe  "Get-ArubaSWRadiusGroup" {
    It "Get-ArubaSWRadiusGroup Does not throw an error" {
        Add-ArubaSWRadiusServer -address 192.0.2.1 -shared_secret powerarubasw
        Add-ArubaSWRadiusGroup -server_group_name PowerArubaSW -server1 192.0.2.1
        { Get-ArubaSWRadiusGroup -server_group_name PowerArubaSW } | Should Not Throw
        Remove-ArubaSWRadiusGroup -server_group_name PowerArubaSW -noconfirm
        Remove-ArubaSWRadiusServer -address 192.0.2.1 -noconfirm
    }
}

Describe  "Add-ArubaSWRadiusGroup" {

    BeforeEach {
        Add-ArubaSWRadiusServer -address 192.0.2.1 -shared_secret powerarubasw
    }

    It "Check name of group and IP" {
        Add-ArubaSWRadiusGroup -server_group_name PowerArubaSW -server1 192.0.2.1
        $radius_group = Get-ArubaSWRadiusGroup -server_group_name PowerArubaSW
        $radius_group.server_group_name | Should be "PowerArubaSW"
        $radius_group.server_ip.octets | Should be "192.0.2.1"
    }

    It "Check IP of multiple RADIUS server" {
        Add-ArubaSWRadiusServer -address 192.0.2.2 -shared_secret powerarubasw
        Add-ArubaSWRadiusGroup -server_group_name PowerArubaSW -server1 192.0.2.1 -server2 192.0.2.2
        $radius_group = Get-ArubaSWRadiusGroup -server_group_name PowerArubaSW
        $radius_group.server_ip.octets[0] | Should be "192.0.2.1"
        $radius_group.server_ip.octets[1] | Should be "192.0.2.2"
    }

    AfterEach {
        Remove-ArubaSWRadiusGroup -server_group_name PowerArubaSW -noconfirm
        Remove-ArubaSWRadiusServer -address 192.0.2.1 -noconfirm
        Remove-ArubaSWRadiusServer -address 192.0.2.2 -noconfirm
    }
}

Describe  "Remove-ArubaSWRadiusGroup" {
    It "Remove RADIUS group server" {
        Add-ArubaSWRadiusServer -address 192.0.2.1 -shared_secret powerarubasw
        Add-ArubaSWRadiusGroup -server_group_name PowerArubaSW -server1 192.0.2.1
        $radius_group = Get-ArubaSWRadiusGroup -server_group_name PowerArubaSW
        Remove-ArubaSWRadiusGroup -server_group_name $radius_group.server_group_name -noconfirm
        { Get-ArubaSWRadiusGroup -server_group_name PowerArubaSW } | Should Throw
        Remove-ArubaSWRadiusServer -address 192.0.2.1 -noconfirm
    }
}

Disconnect-ArubaSW -noconfirm
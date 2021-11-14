#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

# Copy this file to credential.ps1 (on Tests folder) and change connection settings..

$script:ipaddress = "10.44.23.213"
$script:login = "admin"
$script:password = "enable"
$script:httpOnly = $false


#default settings use for test, can be override if needed...

#$script:pester_vlan = 85
#$script:pester_vlanport = 8
#$script:pester_lacp_port = 5
#$script:pester_lacp_trk1 = "trk2"
#$script:pester_lacp_trk2 = "trk6"
#$script:pester_port = 3
#$script:pester_stack_module = 1
#$script:pester_chassis_module = "A"
#$script:pester_trunk_port = 5
#$script:pester_trunk_trk1 = "trk3"
#$script:pester_trunk_trk2 = "trk7"
#$script:pester_stp_port = 3
#$script:pester_cli_port = 3
#$script:pester_poe_port = 4

#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

# Copy this file to credential.ps1 (on Tests folder) and change connection settings..

$ipaddress = "10.44.23.213"
$login = "admin"
$password = "enable"
$httpOnly = $false


#default settings use for test, can be override if needed...

#$pester_vlan = 85
#$pester_vlanport = 8
#$pester_lacp_port = 5
#$pester_lacp_trk1 = "trk2"
#$pester_lacp_trk2 = "trk6"
#$pester_port = 3
#$pester_stack_module = 1
#$pester_chassis_module = "A"
#$pester_trunk_port = 5
#$pester_trunk_trk1 = "trk3"
#$pester_trunk_trk2 = "trk7"
#$pester_stp_port = 3
#$pester_cli_port = 3

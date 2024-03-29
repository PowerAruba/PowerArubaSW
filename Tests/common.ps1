#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
Param()

# default settings for test...
$script:pester_vlan = 85 #vlan id for Vlan test (and Port Test)
$script:pester_vlanport = 8 #Port number of Vlan Port Test
$script:pester_lacp_port = 5 #Port number of LACP test
$script:pester_lacp_trk1 = "trk2" #Port trunk 1 name of LACP test
$script:pester_lacp_trk2 = "trk6" #Port trunk 2 name of LACP test
$script:pester_port = 3 #Port number of port test
$script:pester_stack_module = 1 #Number of stack moduele (for VSF/Stack)
$script:pester_chassis_module = "A" #Letter of chassis module (for HP54XXRzl2)
$script:pester_trunk_port = 5 #Port number of LACP test
$script:pester_trunk_trk1 = "trk3" #Port trunk 1 name of Trunk test
$script:pester_trunk_trk2 = "trk7" #Port trunk 2 name of Trunk test
$script:pester_stp_port = 3 #Port Number of STP test
$script:pester_cli_port = 3 #Port Number of CLI test
$script:pester_poe_port = 4 #Port Number of PoE test
$script:pester_dns1 = "1.1.1.1" #DNS server 1
$script:pester_dns2 = "8.8.8.8" #DNS server 2

if ("Desktop" -eq $PSVersionTable.PsEdition) {
    # -BeOfType is not same on PowerShell Core and Desktop (get int with Desktop and long with Core for number)
    $script:pester_longint = "int"
}
else {
    $script:pester_longint = "long"
}
$here = Split-Path -Parent $MyInvocation.MyCommand.Path

. ../credential.ps1
#TODO: Add check if no ipaddress/login/password info...


#Get information from the module manifest
$manifestPath = "$here\..\PowerArubaSW\PowerArubaSW.psd1"
$manifest = Test-ModuleManifest -Path $manifestPath

#Test if a PowerArubaSW module is already loaded
$Module = Get-Module -Name 'PowerArubaSW' -ErrorAction SilentlyContinue

#Load the module if needed
If ($module) {
    If ($Module.Version -ne $manifest.version) {
        Remove-Module $Module
        Import-Module "$here\..\PowerArubaSW" -Version $manifest.version -force
    }
}
else {
    Import-Module "$here\..\PowerArubaSW" -Version $manifest.version -force
}

$mysecpassword = ConvertTo-SecureString $password -AsPlainText -Force
$script:invokeParams = @{
    Server   = $ipaddress;
    Username = $login;
    password = $mysecpassword;
}
if ($httpOnly) {
    $invokeParams.add('httpOnly', $true)
}
else {
    $invokeParams.add('SkipCertificateCheck', $true)
}

Connect-ArubaSW @invokeParams
$status = Get-ArubaSWSystemStatusSwitch

if ('ST_STACKED' -eq $defaultArubaSWConnection.switch_type) {
    $product_number = $status.blades.product_number[0]
}
else {
    $product_number = $status.product_number
}

$script:switch_type = $defaultArubaSWConnection.switch_type
#Add chassis module (letter) to port number if it is a HP 5406Rzl2 (J9850A) or HP 5412Rzl2 (J9851A)
if ($product_number -eq 'J9850A' -or $product_number -eq 'J9851A') {
    $script:pester_vlanport = "$pester_chassis_module$pester_vlanport"
    $script:pester_lacp_port = "$pester_chassis_module$pester_lacp_port"
    $script:pester_port = "$pester_chassis_module$pester_$pester_port"
    $script:pester_trunk_port = "$pester_chassis_module$pester_trunk_port"
    $script:pester_stp_port = "$pester_chassis_module$pester_stp_port"
    $script:pester_cli_port = "$pester_chassis_module$pester_cli_port"
    $script:pester_poe_port = "$pester_chassis_module$pester_poe_port"
}

#Add stack module to port number (if it is a stacked switch)
if ('ST_STACKED' -eq $defaultArubaSWConnection.switch_type) {
    $script:pester_vlanport = "$pester_stack_module/$pester_vlanport"
    $script:pester_lacp_port = "$pester_stack_module/$pester_lacp_port"
    $script:pester_port = "$pester_stack_module/$pester_port"
    $script:pester_trunk_port = "$pester_stack_module/$pester_trunk_port"
    $script:pester_stp_port = "$pester_stack_module/$pester_stp_port"
    $script:pester_cli_port = "$pester_stack_module/$pester_cli_port"
    $script:pester_poe_port = "$pester_stack_module/$pester_poe_port"
}

Disconnect-ArubaSW -confirm:$false
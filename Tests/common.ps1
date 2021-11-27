#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
Param()

# default settings for test...
$pester_vlan = 85 #vlan id for Vlan test (and Port Test)
$pester_vlanport = 8 #Port number of Vlan Port Test
$pester_lacp_port = 5 #Port number of LACP test
$pester_lacp_trk1 = "trk2" #Port trunk 1 name of LACP test
$pester_lacp_trk2 = "trk6" #Port trunk 2 name of LACP test
$pester_port = 3 #Port number of port test
$pester_stack_module = 1 #Number of stack moduele (for VSF/Stack)
$pester_chassis_module = "A" #Letter of chassis module (for HP54XXRzl2)
$pester_trunk_port = 5 #Port number of LACP test
$pester_trunk_trk1 = "trk3" #Port trunk 1 name of Trunk test
$pester_trunk_trk2 = "trk7" #Port trunk 2 name of Trunk test
$pester_stp_port = 3 #Port Number of STP test
$pester_cli_port = 3 #Port Number of CLI test
$pester_poe_port = 4 #Port Number of PoE test
$pester_dns1 = "1.1.1.1" #DNS server 1
$pester_dns2 = "8.8.8.8" #DNS server 2

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
#Add chassis module (letter) to port number if it is a HP 5406Rzl2 (J9850A) or HP 5412Rzl2 (J9851A)
if ($product_number -eq 'J9850A' -or $product_number -eq 'J9851A') {
    $pester_vlanport = "$pester_chassis_module$pester_vlanport"
    $pester_lacp_port = "$pester_chassis_module$pester_lacp_port"
    $pester_port = "$pester_chassis_module$pester_$pester_port"
    $pester_trunk_port = "$pester_chassis_module$pester_trunk_port"
    $pester_stp_port = "$pester_chassis_module$pester_stp_port"
    $pester_cli_port = "$pester_chassis_module$pester_cli_port"
    $pester_poe_port = "$pester_chassis_module$pester_poe_port"
}

#Add stack module to port number (if it is a stacked switch)
if ('ST_STACKED' -eq $defaultArubaSWConnection.switch_type) {
    $pester_vlanport = "$pester_stack_module/$pester_vlanport"
    $pester_lacp_port = "$pester_stack_module/$pester_lacp_port"
    $pester_port = "$pester_stack_module/$pester_port"
    $pester_trunk_port = "$pester_stack_module/$pester_trunk_port"
    $pester_stp_port = "$pester_stack_module/$pester_stp_port"
    $pester_cli_port = "$pester_stack_module/$pester_cli_port"
    $pester_poe_port = "$pester_stack_module/$pester_poe_port"
}

Disconnect-ArubaSW -noconfirm
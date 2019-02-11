
#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

# default settings for test...
$pester_vlan = 85 #vlan id for Vlan test (and Port Test)
$pester_vlanport = 8 #Port number of Vlan Port Test
$pester_lacp_port = 5 #Port number of LACP test
$pester_lacp_trk1 = "trk2" #Port trunk 1 name of LACP test
$pester_lacp_trk2 = "trk6" #Port trunk 2 name of LACP test
$pester_port = 3 #Port number of port test
$pester_stack_module = 1 #Number of stack moduele (for VSF/Stack)

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
} else {
    Import-Module "$here\..\PowerArubaSW" -Version $manifest.version -force
}

$mysecpassword = ConvertTo-SecureString $password -AsPlainText -Force
if($httpOnly){
    Connect-ArubaSW -Server $ipaddress -Username $login -password $mysecpassword -httpOnly
} else {
    Connect-ArubaSW -Server $ipaddress -Username $login -password $mysecpassword -SkipCertificateCheck
}

#Add stack module to port number (if it is a stacked switch)
if ('ST_STACKED' -eq $defaultArubaSWConnection.switch_type){
    $pester_vlanport = "$pester_stack_module/$pester_vlanport"
    $pester_lacp_port = "$pester_stack_module/$pester_lacp_port"
    $pester_port = "$pester_stack_module/$pester_port"
}
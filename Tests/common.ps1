
#
# Copyright 2018, Alexis La Goutte <alexis.lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

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
Connect-ArubaSW -Server $ipaddress -Username $login -password $mysecpassword
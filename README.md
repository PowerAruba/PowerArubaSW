
# PowerArubaSW

This is a Powershell module for configure a ArubaOS Switch.

<p align="center">
<img src="https://raw.githubusercontent.com/PowerAruba/PowerArubaSW/master/Medias/PowerArubaSW.png" width="250" height="250" />
</p>

With this module (version 0.8.0) you can manage:

- System (Name, Location, Contact) & Switch Status (Product and Hardware info)
- Vlans (Add/Configure/Remove)
- Vlans Ports (Add/Configure/Remove a vlan (tagged/untagged/forbidden) to a interface)
- REST (Get API Version / Get|Set Rest Timeout)
- LLDP (Get|Set GlobalStatus, Get ports/neighbor stats, Get Remote)
- LACP (Add/Configure/Remove)
- Led Locator (Get|Set Led indicator)
- Ports (Information (name, status, config_mode...) and Statistics)
- DNS (Add/configure/remove IP Address and domain names)
- Trunk (Add/Configure/Remove)
- STP (Add/Configure/Remove GlobalConfig or Port)
- IP Address (Get)
- Cli (AnyCli and CliBatch for send CLI function)
- PoE (Get/Configure PoE Settings and Get Poe Stats)
- RADIUS Server (Add/Get/Set/Remove)
- RADIUS Group (Add/Get/Remove)
- MAC Table (Get)
- [Multi Connection](#MultiConnection)

More functionality will be added later.

Connection can use HTTPS (default) or HTTP
Tested with Aruba OS 2530, 2930F, 2930M, 3810, 54xxRzl (using 16.05.x firmware and later...) on Windows/Linux/macOS

# Usage

All resource management functions are available with the Powershell verbs GET, ADD, SET, REMOVE. 
For example, you can manage Vlans with the following commands:
- `Get-ArubaSWVlans`
- `Add-ArubaSWVlans`
- `Set-ArubaSWVlans`
- `Remove-ArubaSWVlans`

# Requirements

- Powershell 5 or 6 (Core) (If possible get the latest version)
- An Aruba OS Switch (with firmware 16.x), REST API enable and HTTPS enable (recommended)

# Instructions
### Install the module
```powershell
# Automated installation (Powershell 5 or later):
    Install-Module PowerArubaSW

# Import the module
    Import-Module PowerArubaSW

# Get commands in the module
    Get-Command -Module PowerArubaSW

# Get help
    Get-Help Get-ArubaSWVlans -Full
```

# Examples
### Connecting to the Aruba Switch

The first thing to do is to connect to a Aruba Switch with the command `Connect-ArubaSW` :

```powershell
# Connect to the Aruba Switch
    Connect-ArubaSW 192.0.2.1

#we get a prompt for credential
```
if you get a warning about `Unable to connect` Look [Issue](#Issue)


### Vlans Management

You can create a new Vlan `Add-ArubaSWVlans`, retrieve its information `Get-ArubaSWVlans`, modify its properties `Set-ArubaSWVLans`, or delete it `Remove-ArubaSWVlans`.

```powershell
# Create a vlan
    Add-ArubaSWVlans -id 85 -Name 'PowerArubaSW' -is_voice_enabled

    uri               : /vlans/85
    vlan_id           : 85
    name              : PowerArubaSW
    status            : VS_PORT_BASED
    type              : VT_STATIC
    is_voice_enabled  : True
    is_jumbo_enabled  : False
    is_dsnoop_enabled : False


# Get information about vlan
    Get-ArubaSWVlans -name PowerArubaSW | ft

    uri       vlan_id name         status        type      is_voice_enabled is_jumbo_enabled is_dsnoop_enabled is_management_vlan
    ---       ------- ----         ------        ----      ---------------- ---------------- ----------------- ------------------
    /vlans/85      85 PowerArubaSW VS_PORT_BASED VT_STATIC            True             False             False              False


# Remove a vlan
    Remove-ArubaSWVlans -id 85
```


### Disconnecting

```powershell
# Disconnect from the ArubaOS Switch
    Disconnect-ArubaSW
```

# Issue

## Unable to connect (certificate)
if you use `Connect-ArubaSW` and get `Unable to Connect (certificate)`

The issue coming from use Self-Signed or Expired Certificate for switch management
Try to connect using `Connect-ArubaSW -SkipCertificateCheck`

## Unable to connect
if you use `Connect-ArubaSW` and get `Unable to Connect`

Check if the HTTPS is enable on the switch

```code
PowerArubaSW# show web-management

 Web Management - Server Configuration

  HTTP Access    : Enabled
  HTTPS Access   : Enabled
  SSL Port       : 443
  Idle Timeout   : 600 seconds
  Management URL : http://h17007.www1.hpe.com/device_help
  Support URL    : http://www.arubanetworks.com/products/networking/
  User Interface : Improved
```
if it is not enabled you can enable using

```code
(config)# crypto pki enroll-self-signed certificate-name PowerArubaSW subject common-name PowerArubaSW country FR locality PowerArubaSW org PowerArubaSW org-unit PowerArubaSW
(config)# web-management ssl
```

You can use also `Connect-ArubaSW -httpOnly` for connect using HTTP (NOT RECOMMENDED !)

# MultiConnection

From release 0.8.0, it is possible to connect on same times to multi switch
You need to use -connection parameter to cmdlet

For example to get Vlan Ports of 2 switchs

```powershell
# Connect to first switch
    $sw1 = Connect-ArubaSW 192.0.2.1 -SkipCertificateCheck -DefaultConnection:$false

#DefaultConnection set to false is not mandatory but only don't set the connection info on global variable

# Connect to second switch
    $sw2 = Connect-ArubaSW 192.0.2.1 -SkipCertificateCheck -DefaultConnection:$false

# Get Vlan Ports for first switch
    Get-ArubaSWVlanPorts -connection $sw1

    uri                  vlan_id port_id port_mode
    ---                  ------- ------- ---------
    /vlans-ports/1-1/1         1 1/1     POM_UNTAGGED
    /vlans-ports/23-1/2       23 1/2     POM_UNTAGGED
    /vlans-ports/1-1/3         1 1/3     POM_UNTAGGED
    /vlans-ports/23-1/3       23 1/3     POM_TAGGED_STATIC
....
# Get Vlan Ports for second switch
    Get-ArubaSWVlanPorts -connection $sw2

    uri                  vlan_id port_id port_mode
    ---                  ------- ------- ---------
    /vlans-ports/1-1/1         1 1/1     POM_UNTAGGED
    /vlans-ports/23-1/1       23 1/1     POM_TAGGED_STATIC
    /vlans-ports/1-1/2         1 1/2     POM_UNTAGGED
    /vlans-ports/23-1/3       23 1/3     POM_UNTAGGED
...

#Each cmdlet can use -connection parameter

```

# List of available command
```powershell
Add-ArubaSWLACP
Add-ArubaSWTrunk
Add-ArubaSWVlans
Add-ArubaSWVlansPorts
Connect-ArubaSW
Disconnect-ArubaSW
Get-ArubaSWCli
Get-ArubaSWCliBatchStatus
Get-ArubaSWDns
Get-ArubaSWIpAddress
Get-ArubaSWLACP
Get-ArubaSWLed
Get-ArubaSWLLDPGlobalStatus
Get-ArubaSWLLDPNeighborStats
Get-ArubaSWLLDPPortStats
Get-ArubaSWLLDPRemote
Get-ArubaSWPoE
Get-ArubaSWPoEStats
Get-ArubaSWPort
Get-ArubaSWPortStatistics
Get-ArubaSWRestSessionTimeout
Get-ArubaSWRestVersion
Get-ArubaSWSTP
Get-ArubaSWSTPPort
Get-ArubaSWSystem
Get-ArubaSWSystemStatus
Get-ArubaSWSystemStatusGlobal
Get-ArubaSWSystemStatusSwitch
Get-ArubaSWTrunk
Get-ArubaSWVlans
Get-ArubaSWVlansPorts
Invoke-ArubaSWWebRequest
Remove-ArubaSWDns
Remove-ArubaSWLACP
Remove-ArubaSWTrunk
Remove-ArubaSWVlans
Remove-ArubaSWVlansPorts
Send-ArubaSWCliBatch
Set-ArubaSWCipherSSL
Set-ArubaSWDns
Set-ArubaSWLed
Set-ArubaSWLLDPGlobalStatus
Set-ArubaSWPoE
Set-ArubaSWPort
Set-ArubaSWRestSessionTimeout
Set-ArubaSWSTP
Set-ArubaSWSTPPort
Set-ArubaSWSystem
Set-ArubaSWuntrustedSSL
Set-ArubaSWVlans
Set-ArubaSWVlansPorts
Set-Cookie
Show-ArubaSWException
```

# Author

**Alexis La Goutte**
- <https://github.com/alagoutte>
- <https://twitter.com/alagoutte>

# Special Thanks

- Warren F. for his [blog post](http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/) 'Building a Powershell module'
- Erwan Quelin for help about Powershell

# License

Copyright 2018 Alexis La Goutte and the community.

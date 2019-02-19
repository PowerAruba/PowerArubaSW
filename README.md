
# PowerArubaSW

This is a Powershell module for configure a ArubaOS Switch.

With this module (version 0.6.0) you can manage:

- System (Name, Location, Contact) & Switch Status (Product and Hardware info)
- Vlans (Add/Configure/Remove)
- Vlans Ports (Add/Configure/Remove a vlan (tagged/untagged/forbidden) to a interface)
- REST (Get API Version / Get|Set Rest Timeout)
- LLDP (Get|Set GlobalStatus, Get ports/neighbor stats, Get Remote)
- LACP (Add/Configure/Remove)
- Led Locator (Get|Set Led indicator)
- Ports (Information (name, status, config_mode...) and Statistics)
- DNS (Add/configure/remove IP Address and domain names )

More functionality will be added later.

Connection can use HTTPS (default) or HTTP
Tested with Aruba OS 2530 and 2930F (using 16.05.x firmware) on Windows/Linux/macOS

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
# Automated installation (Powershell 5):
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

## Unable to connect
if you use `Connect-ArubaSW` and get `Unable to Connect (certificate)`

The issue coming from use Self-Signed or Expired Certificate for switch management
Try to connect using `Connect-ArubaSW -SkipCertificateCheck`

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

# List of available command
```powershell
Add-ArubaSWLACP
Add-ArubaSWVlans
Add-ArubaSWVlansPorts
Connect-ArubaSW
Disconnect-ArubaSW
Get-ArubaSWDns
Get-ArubaSWLACP
Get-ArubaSWLed
Get-ArubaSWLLDPGlobalStatus
Get-ArubaSWLLDPNeighborStats
Get-ArubaSWLLDPPortStats
Get-ArubaSWLLDPRemote
Get-ArubaSWPort
Get-ArubaSWPortStatistics
Get-ArubaSWRestSessionTimeout
Get-ArubaSWRestVersion
Get-ArubaSWSystem
Get-ArubaSWSystemStatus
Get-ArubaSWSystemStatusGlobal
Get-ArubaSWSystemStatusSwitch
Get-ArubaSWVlans
Get-ArubaSWVlansPorts
Invoke-ArubaSWWebRequest
Remove-ArubaSWDns
Remove-ArubaSWLACP
Remove-ArubaSWVlans
Remove-ArubaSWVlansPorts
Set-ArubaSWCipherSSL
Set-ArubaSWDns
Set-ArubaSWLed
Set-ArubaSWLLDPGlobalStatus
Set-ArubaSWPort
Set-ArubaSWRestSessionTimeout
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

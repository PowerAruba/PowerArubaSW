

Last release: [![GitHub version](https://badge.fury.io/gh/alagoutte%2Fpowerarubasw.svg)](https://badge.fury.io/gh/alagoutte%2Fpowerarubasw)

# PowerArubaSW

This is a Powershell module for configure a ArubaOS Switch.

With this module (version 0.3.0) you can manage:

- System (Name, Location, Contact)
- Vlans (Add/Configure/Remove)

More functionality will be added later.

Actually only support connection use (unsecure) HTTP (HTTPS support will be coming after !)
Tested with Aruba OS 2530 and 2930F (using 16.05.x firmware)

# Usage

All resource management functions are available with the Powershell verbs GET, ADD, SET, REMOVE. 
For example, you can manage Vlans with the following commands:
- `Get-ArubaSWVlans`
- `Add-ArubaSWVlans`
- `Set-ArubaSWVlans`
- `Remove-ArubaSWVlans`


# Requirements

- Powershell 5 (If possible get the latest version)
- An Aruba OS Switch (with firmware 16.x) and REST API enable

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

The first thing to do is to connect to a Aruba Switch with the command `Connect-ArubaSW`:

```powershell
# Connect to the Aruba Switch
    Connect-ArubaSW 192.0.2.1

#we get a prompt for credential
```
We can only connnect using http (for moment...)


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
    is_voice_enabled  : False
    is_jumbo_enabled  : True
    is_dsnoop_enabled : False


# Get information about vlan
    Get-ArubaSWVlans -name PowerArubaSW | ft

    uri       vlan_id name         status        type      is_voice_enabled is_jumbo_enabled is_dsnoop_enabled is_management_vlan
    ---       ------- ----         ------        ----      ---------------- ---------------- ----------------- ------------------
    /vlans/85      85 PowerArubaSW VS_PORT_BASED VT_STATIC            False             True             False              False


# Remove a vlan
    Remove-ArubaSWVlans -id 85
```


### Disconnecting

```powershell
# Disconnect from the ArubaOS Switch
    Disconnect-ArubaSW
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

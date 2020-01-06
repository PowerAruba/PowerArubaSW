# PowerArubaSW Tests

## Pre-Requisites

The tests don't be to be run on PRODUCTION switch ! there is no warning about change on switch.
It need to be use only for TESTS !

    A ArubaOS Switch with firmware >= 16.05.x
    Only need a ip address (and DEFAULT_VLAN 1)
    a user and password for admin (manager) account

These are the required modules for the tests

    Pester

## Executing Tests

Assuming you have git cloned the PowerArubaSW repository. Go on tests folder and copy credentials.example.ps1 to credentials.ps1 and edit to set information about your switch (ipaddress, login, password)

Go after on integration folder and launch all tests via

```powershell
Invoke-Pester *
```

It is possible to custom some settings when launch test (like vlan id use for vlan test or port used), you need to uncommented following line on credentials.ps1

```powershell
$pester_vlan = XX
$pester_vlanport = XX
...
```

## Executing Individual Tests

Tests are broken up according to functional area. If you are working on Vlan functionality for instance, its possible to just run Vlans related tests.

Example:

```powershell
Invoke-Pester Vlan.Tests.ps1
```

if you only launch a sub test (Describe on pester file), you can use for example to 'Add Vlans' part

```powershell
Invoke-Pester Vlan.Tests.ps1 -g 'Add Vlans'
```

The first time tests are executed, default connection details are prompted for and optionally saved to disk. These can be overridden by deleting the Test.cxn file in the tests directory if it becomes necessary to reconfigure them. Currently these credentials are stored in CLEAR TEXT. See Known Issues for details.
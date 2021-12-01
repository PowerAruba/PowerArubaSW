#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Add-ArubaSWVlansPorts {

    <#
        .SYNOPSIS
        Add a Vlan on a Port

        .DESCRIPTION
        Add vlan (Untagged, Tagged, Forbiden) on a switch Port

        .EXAMPLE
        Add-ArubaSWVlansPorts -vlan_id 85 -port_id 8 -port_mode tagged

        Add vlan id 85 on port 8 (tagged mode)

        .EXAMPLE
        Add-ArubaSWVlansPorts 85 8 untagged

        Add vlan id 23 on port 8 (untagged mode)

    #>

    Param(
        [Parameter (Mandatory = $true, Position = 1)]
        [int]$vlan_id,
        [Parameter (Mandatory = $true, Position = 2)]
        [string]$port_id,
        [Parameter (Mandatory = $true, Position = 3)]
        [ValidateSet("Untagged", "tagged", "Forbidden")]
        [string]$port_mode,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/vlans-ports"

        $vlanports = New-Object -TypeName PSObject

        $vlanports | Add-Member -name "vlan_id" -membertype NoteProperty -Value $vlan_id

        $vlanports | Add-Member -name "port_id" -membertype NoteProperty -Value $port_id

        switch ($port_mode) {
            { $_ -eq "Untagged" } { $vlanports | Add-Member -name "port_mode" -membertype NoteProperty -Value "POM_UNTAGGED" }
            { $_ -eq "tagged" } { $vlanports | Add-Member -name "port_mode" -membertype NoteProperty -Value "POM_TAGGED_STATIC" }
            { $_ -eq "Forbidden" } { $vlanports | Add-Member -name "port_mode" -membertype NoteProperty -Value "POM_FORBIDDEN" }
        }

        $response = Invoke-ArubaSWWebRequest -method "POST" -body $vlanports -uri $uri -connection $connection
        $rep_vlansports = ($response.Content | ConvertFrom-Json)

        $rep_vlansports
    }

    End {
    }
}
function Get-ArubaSWVlansPorts {

    <#
        .SYNOPSIS
        Get Vlans Ports about ArubaOS Switch (Provision)

        .DESCRIPTION
        Get Vlans Ports (id, interface and mode)

        .EXAMPLE
        Get-ArubaSWVlansPorts

        Get ALL vlans Ports on the switch

        .EXAMPLE
        Get-ArubaSWVlansPorts -vlan_id 85

        Get All Port on vlan 85

        .EXAMPLE
        Get-ArubaSWVlansPorts -port_id 10

        Get vlan port info about port 10

    #>

    #[CmdLetBinding(DefaultParameterSetName="Default")]

    Param(
        [Parameter (Mandatory = $false)]
        [int]$vlan_id,
        [Parameter (Mandatory = $false)]
        [string]$port_id,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/vlans-ports"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection
        $vlansports = ($response.Content | ConvertFrom-Json).vlan_port_element

        if ($PsBoundParameters.ContainsKey('vlan_id')) {
            $vlansports = $vlansports | Where-Object { $_.vlan_id -eq $vlan_id }
        }
        if ($PsBoundParameters.ContainsKey('port_id')) {
            $vlansports = $vlansports | Where-Object { $_.port_id -eq $port_id }
        }
        $vlansports
    }

    End {
    }
}
function Set-ArubaSWVlansPorts {

    <#
        .SYNOPSIS
        Configure Vlan Ports on ArubaOS Switch (Provision)

        .DESCRIPTION
        Configure vlan Ports Mode (Tagged, Untagged, Forbidden)

        .EXAMPLE
        $vlanport = Get-ArubaSWVlansPorts -vlan_id 85 -port_id 8
        PS C:\>$vlanport | Set-ArubaSWVlansPorts -port_mode untagged

        (Re)configure vlan id 85 on port id 8 with mode untagged

        .EXAMPLE
        Set-ArubaSWVlansPorts -vlan_id 23 -port_id 8 -port_mode tagged

        (Re)configure vlan id 23 on port id 8 with mode tagged
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'medium')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$vlan_id,
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [string]$port_id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "vlan")]
        #ValidateScript({ ValidateVlan $_ })]
        [psobject]$vlanports,
        [Parameter (Mandatory = $true, Position = 3)]
        [ValidateSet("Untagged", "Tagged", "Forbidden")]
        [string]$port_mode,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        #get vlan id and port id from vlanports ps object
        if ($vlanports) {
            $vlan_id = $vlanports.vlan_id
            $port_id = $vlanports.port_id
        }
        $uri = "rest/v4/vlans-ports/${vlan_id}-${port_id}"

        $_vlanport = New-Object -TypeName PSObject

        $_vlanport | Add-Member -name "vlan_id" -membertype NoteProperty -Value $vlan_id
        $_vlanport | Add-Member -name "port_id" -membertype NoteProperty -Value $port_id

        switch ($port_mode) {
            { $_ -eq "Untagged" } { $_vlanport | Add-Member -name "port_mode" -membertype NoteProperty -Value "POM_UNTAGGED" }
            { $_ -eq "tagged" } { $_vlanport | Add-Member -name "port_mode" -membertype NoteProperty -Value "POM_TAGGED_STATIC" }
            { $_ -eq "Forbidden" } { $_vlanport | Add-Member -name "port_mode" -membertype NoteProperty -Value "POM_FORBIDDEN" }
        }

        if ($PSCmdlet.ShouldProcess("${vlan_id}-${port_id}", 'Configure Vlans Ports')) {
            $response = Invoke-ArubaSWWebRequest -method "PUT" -body $_vlanport -uri $uri -connection $connection
            $rep_vlanport = ($response.Content | ConvertFrom-Json)

            $rep_vlanport
        }
    }

    End {
    }
}

function Remove-ArubaSWVlansPorts {

    <#
        .SYNOPSIS
        Remove a Vlan Ports on ArubaOS Switch (Provision)

        .DESCRIPTION
        Remove vlan ports on the switch

        .EXAMPLE
        $vlanport = Get-ArubaSWVlansPorts -vlan_id 85 -port_id 8
        PS C:\>$vlanport | Remove-ArubaSWVlansPorts

        Remove vlan 85 on port 8

        .EXAMPLE
        Remove-ArubaSWVlansPorts -vlan_id 85 -port_id 8 -confirm:$false

        Remove vlan id 85 on port 8 with no confirmation
    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'high')]
    Param(
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [int]$vlan_id,
        [Parameter (Mandatory = $true, ParameterSetName = "id")]
        [string]$port_id,
        [Parameter (Mandatory = $true, ValueFromPipeline = $true, Position = 1, ParameterSetName = "vlan")]
        #ValidateScript({ ValidateVlan $_ })]
        [psobject]$vlanport,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin {
    }

    Process {

        #get vlan id and port id from vlan ports ps object
        if ($vlanport) {
            $vlan_id = $vlanport.vlan_id
            $port_id = $vlanport.port_id
        }

        $uri = "rest/v4/vlans-ports/${vlan_id}-${port_id}"

        if ($PSCmdlet.ShouldProcess("${vlan_id}-${port_id}", 'Configure Vlans Ports')) {
            $null = Invoke-ArubaSWWebRequest -method "DELETE" -uri $uri -connection $connection
        }
    }

    End {
    }
}

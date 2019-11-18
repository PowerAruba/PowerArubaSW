#
# Copyright 2019, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWBanner
{

    <#
        .SYNOPSIS
        Get Banner (motd and exec) of ArubaOS Switch

        .DESCRIPTION
        Get Banner (motd, exec and last login) of ArubaOS Switch


        .EXAMPLE
        Get-ArubaSWBanner

        Get Banner (motd, exec and last login)
        the cmdlet decode base64 for easy use

        .EXAMPLE
    #>

    Param(
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin
    {
    }

    Process
    {

        $uri = "rest/v4/banner"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri -connection $connection

        $banner = ($response | ConvertFrom-Json)

        #Decode (base64) motd
        $motd_base64_encoded = $banner.motd_base64_encoded

        $motd_base64_encoded = [System.Convert]::FromBase64String($motd_base64_encoded)

        $motd = [System.Text.Encoding]::UTF8.GetString($motd_base64_encoded)

        $banner | Add-Member -name "motd" -membertype NoteProperty -value $motd

        #Decode (base64) exec
        $exec_base64_encoded = $banner.exec_base64_encoded

        $exec_base64_encoded = [System.Convert]::FromBase64String($exec_base64_encoded)

        $exec = [System.Text.Encoding]::UTF8.GetString($exec_base64_encoded)

        $banner | Add-Member -name "exec" -membertype NoteProperty -value $exec

        $banner
    }

    End
    {
    }
}

function Set-ArubaSWBanner
{

    <#
        .SYNOPSIS
        Configure Banner (motd, exec)

        .DESCRIPTION
        Configure Banner (motd, exec and last login)

        .EXAMPLE
        Set-ArubaSWBanner -motd "Welcome on motd PowerArubaSW "

        Set motd welcome message to Welcome on motd PowerArubaSW

        .EXAMPLE
        Set-ArubaSWBanner -exec "Welcome on exec PowerArubaSW "

        Set exec welcome message to Welcome on exec PowerArubaSW

        .EXAMPLE
        Set-ArubaSWBanner -is_last_login_enabled:$false

        Disable is_last_login message
        #>

    Param(
        [Parameter (Mandatory = $false)]
        [string]$motd,
        [Parameter (Mandatory = $false)]
        [string]$exec,
        [Parameter (Mandatory = $false)]
        [switch]$is_last_login_enabled,
        [Parameter (Mandatory = $False)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$connection = $DefaultArubaSWConnection
    )

    Begin
    {
    }

    Process
    {
        $uri = "rest/v4/banner"

        $banner = New-Object -TypeName PSObject

        if ($PsBoundParameters.ContainsKey('motd'))
        {
            $encode = [System.Text.Encoding]::UTF8.GetBytes($motd)

            $EncodedText = [Convert]::ToBase64String($encode)

            $banner | Add-Member -name "motd_base64_encoded" -membertype NoteProperty -Value $EncodedText

        }

        if ($PsBoundParameters.ContainsKey('exec'))
        {
            $encode = [System.Text.Encoding]::UTF8.GetBytes($exec)

            $EncodedText = [Convert]::ToBase64String($encode)

            $banner | Add-Member -name "exec_base64_encoded" -membertype NoteProperty -Value $EncodedText

        }

        if ( $PsBoundParameters.ContainsKey('is_last_login_enabled') )
        {
            if ( $is_last_login_enabled )
            {
                $banner | Add-Member -name "is_last_login_enabled" -membertype NoteProperty -Value $true
            }
            else
            {
                $banner | Add-Member -name "is_last_login_enabled" -membertype NoteProperty -Value $false
            }
        }

        $response = Invoke-ArubaSWWebRequest -method "PUT" -body $banner -uri $uri -connection $connection

        $run = $response | ConvertFrom-Json

        $run
    }

    End
    {
    }
}

#
# Copyright 2018, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
# Copyright 2018, Cédric Moreau <moreaucedric0 at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#

function Get-ArubaSWCli {

    <#
        .SYNOPSIS
        Get the result of a cli command on ArubaOS Switch.

        .DESCRIPTION
        Get the result of a cli command.

        All configuration and execution commands in non-interactive mode are supported.
        crypto, copy, process-tracking, recopy, redo, repeat, session, end, print, terminal,
        logout, menu, page, restore, update, upgrade-software, return, setup, screen-length,
        vlan range and help commands are not supported.
        Testmode commands are not supported.
        All show commands are supported except show tech and show history

        .EXAMPLE
        Get-ArubaSWCli -cmd "Show running-config"

        This function give you the result (cmd, status, result, error_mesg...) of a cli command on the switch.

        .EXAMPLE
        Get-ArubaSWCli -cmd "Show running-config" -display_result

        This function give only ther esult of a cli command on the switch.
    #>

    Param(
        [Parameter (Mandatory = $true, Position = 1)]
        [string]$cmd,
        [Parameter (Mandatory = $false)]
        [switch]$display_result
    )

    Begin {
    }

    Process {

        $uri = "rest/v4/cli"

        $run = New-Object -TypeName PSObject

        $run | Add-Member -name "cmd" -membertype NoteProperty -Value "$cmd"

        $response = Invoke-ArubaSWWebRequest -method "POST" -body $run -uri $uri

        $conf = ($response | ConvertFrom-Json)

        $result_base64_encoded = $conf.result_base64_encoded

        $result = [System.Convert]::FromBase64String($result_base64_encoded)

        $result = [System.Text.Encoding]::UTF8.GetString($result)

        $conf | Add-Member -name "result" -membertype NoteProperty -value $result

        if ($display_result) {
            #only display CLI output
            $conf.result
        }
        else {
            $conf
        }
    }

    End {
    }
}

function Send-ArubaSWCliBatch {

    <#
        .SYNOPSIS
        Send a cli batch command.

        .DESCRIPTION
        Send a cli batch command on Aruba OS Switch.
        All configuration commands in non-interactive mode  are supported. Exit, configure, erase, startup-config commands are supported.
        Crypto, show, execution and testmode commands are NOT supported.

        .EXAMPLE
        Send-ArubaSWCliBatch -command "interface 4 disable"

        Send a cli batch command (disable interface 4) on the switch, use Get-ArubaSWCliBatchStatus for get result

        .EXAMPLE
        Send-ArubaSWCliBatch -command "interface 4", "enable", "name PowerArubaSW-int"

        Send a cli batch command (disable interface 4) on the switch, use Get-ArubaSWCliBatchStatus for get result
        #>

    Param(
        [Parameter (Mandatory = $true)]
        [string[]]$command
    )

    Begin {
    }

    Process {

        $nb = 0

        foreach ($line in $command) {
            $result = $result + $command[$nb] + "`n"
            $nb = $nb + 1
        }

        $uri = "rest/v4/cli_batch"

        $conf = New-Object -TypeName PSObject

        $encode = [System.Text.Encoding]::UTF8.GetBytes($result)

        $EncodedText = [Convert]::ToBase64String($encode)

        $conf | Add-Member -name "cli_batch_base64_encoded" -membertype NoteProperty -Value $EncodedText

        $response = Invoke-ArubaSWWebRequest -method "POST" -body $conf -uri $uri

        $run = $response | ConvertFrom-Json

        $run
    }

    End {
    }
}

function Get-ArubaSWCliBatchStatus {

    <#
        .SYNOPSIS
        Get a cli batch command status.

        .DESCRIPTION
        Get a cli batch command status on Aruba OS Switch.

        .EXAMPLE
        Get-ArubaSWCliBatchStatus

        Get a cli batch command status on the switch.
    #>

    Begin {
    }

    Process {

        $uri = "rest/v4/cli_batch/status"

        $response = Invoke-ArubaSWWebRequest -method "GET" -uri $uri

        $run = ($response | ConvertFrom-Json).cmd_exec_logs

        $run
    }

    End {
    }
}

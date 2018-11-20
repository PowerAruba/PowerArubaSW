
 <#
  .SYNOPSIS
This script is used to extract data from an Aruba switch and to classify this information in an Excel sheet.
  .DESCRIPTION

The Excel file contains :       -Name of the switch
                                -Serial Number
                                -Firmware
                                -Hardware Revision
                                -Product Model


                                -Name of the port
                                -ID of the port
                                -Tagged ports vlan
                                -Untagged ports vlan
                                -LACP Status
                                -Is port UP
                                -LLDP Port ID
                                -LLDP PORT Description


This script requires the PowerArubaSW module to be installed. More information at https://github.com/PowerAruba/PowerArubaSW
This script uses Microsoft Excel, the software will need to be installed on the computer on which the script is running.

  .EXAMPLE

The script can be executed with the following argument list

Extract-Port-ArubaSW.ps1 -CompanyName <company name> -IPSwitch <switch ip> -LoginSwitch <switch login> -PassSwitch <switch password>
  
  .EXAMPLE
The script can be executed without specifying the type of argument as long as the order of the arguments <company name> <switch ip> <switch login> <switch password> is respected

Extract-Port-ArubaSW.ps1 <company name> <switch ip> <switch login> <switch password>

  .EXAMPLE

The script can be executed without arguments, questions will be asked to the user during this one.

Extract-Port-ArubaSW.ps1 

  .NOTES

  Version:        1.5
  Author:         <Benjamin PERRIER>
  Creation Date:  <21/09/2018>
  Script Name: Extract-Port-ArubaSW

  #>
  
# Parameters :
Param(
  [string]$CompanyName,
  [string]$IPSwitch,
  [string]$LoginSwitch,
  [string]$PassSwitch,
  [String]$Targets = "Help" )

# Functions :
 function Add-ExcelFormatArray {
 Param ([string]$name,
        [string]$letter1,
        [string]$letter2,
        [string]$emplacementtxt,
        [string]$fontcolorindex,
        [string]$fontsize,
        [string]$interiorcolorindex)

                        $sheet.Cells.Item($row,$column)= $name
                        $MergeCells = $sheet.Range("$letter1$($anum):$letter2$($bnum)")
                        $MergeCells.MergeCells = $true
                        $xlConstants = "microsoft.office.interop.excel.Constants" -as [type]
                        $sheet.Cells($row,$column).HorizontalAlignment = $xlConstants::$emplacementtxt
                        $sheet.Cells.Item($row,$column).Font.Size = $fontsize
                        $sheet.Cells.Item($row,$column).Font.Bold=$True
                        $sheet.Cells.Item($row,$column).Font.Name = "Cambria"
                        $sheet.Cells.Item($row,$column).Font.ThemeFont = 1
                        $sheet.Cells.Item($row,$column).Font.ThemeColor = 4
                        $sheet.Cells.Item($row,$column).Font.ColorIndex = $fontcolorindex
                        $sheet.Cells.Item($row,$column).Interior.ColorIndex = $interiorcolorindex
                        $sheet.Cells.Range("$letter1$($anum):$letter2$($bnum)").Borders.LineStyle = [Microsoft.Office.Interop.Excel.XlLineStyle]::xlContinuous
                        $sheet.Cells.Range("$letter1$($anum):$letter2$($bnum)").Borders.Weight = 3

                     }

#TESTING THE PRESENCE OF THE POWERARUBASW MODULE
if (Get-Module -ListAvailable -Name PowerArubaSW) {

        Import-Module PowerArubaSW
        Clear-Host

} else {

        Clear-Host
        Write-Host ""
        Write-Host "############################################################"
        Write-Host ""
        Write-Host ""
        Write-Host ""
        Write-Host "    !!! THE POWERARUBASW MODULE IS NOT INSTALLING !!!"
        Write-Host ""
        Write-Host "         In order to install this module type the command"
        Write-Host "                Install-Module PowerArubaSW"
        Write-Host ""
        Write-Host "            Then restart that script again."
        Write-Host ""
        Write-Host ""
        Write-Host ""
        Write-Host "############################################################"
        Write-Host ""
        Write-Host ""
        $exitquit = Read-Host "Press any key to exit"
        break
       
        }

# Company name request if not given as an argument
if ([string]::IsNullOrEmpty($CompanyName)) {


        Clear-Host
        Write-Host ""
        Write-Host "############################################################"
        Write-Host ""
        Write-Host ""
        Write-Host ""
        Write-Host "                What is the name of the company?"
        Write-Host ""
        Write-Host ""
        Write-Host ""
        Write-Host "############################################################"
        Write-Host ""
        Write-Host ""
        $CompanyName = Read-Host "Please enter the name of the company"
        Clear-Host

        }

#Save the date as day / month / year in the date variable
$date = Get-Date -format "dd-MM-yyyy"

#Request ip switch if not specified in argument
if ([string]::IsNullOrEmpty($ipswitch)) {

    Clear-Host
    Write-Host ""
    Write-Host "############################################################"
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "             What is the IP address of the switch?"
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "############################################################"
    Write-Host ""
    Write-Host ""
    $ipswitch = Read-Host "Please enter the IP address of the switch?"
    Clear-Host

    }

# View the name of the generated file and its location
Clear-Host
Write-Host ""
Write-Host "#######################################################################"
Write-Host ""
Write-Host "       An excel file will be automatically created"
Write-Host ""
Write-Host "        It will be stored in $env:USERPROFILE\Desktop\"
Write-Host ""
Write-Host "       and will be named $($date)_$($CompanyName)_$($ipswitch).xlsx"
Write-Host ""
Write-Host "#######################################################################"
Write-Host ""
Write-Host ""

#Verification of loginswitch and passswitch variables
if ((-not [string]::IsNullOrEmpty($loginswitch)) -and (-not [string]::IsNullOrEmpty($PassSwitch))) { 

        $mysecpassword = ConvertTo-SecureString $PassSwitch -AsPlainText -Force

        try {

                Connect-ArubaSW -Server $ipswitch -Username $loginswitch -Password $mysecpassword
                
                }

        Catch { 

                Clear-Host
                Write-Host ""
                Write-Host "############################################################"
                Write-Host ""
                Write-Host ""
                Write-Host ""
                Write-Host "              !!! CAN NOT CONNECT TO SWITCH !!!"
                Write-Host ""
                Write-Host "       Check that the IP or login and password is valid."
                Write-Host ""
                Write-Host ""
                Write-Host "              Then restart that script again."
                Write-Host ""
                Write-Host ""
                Write-Host ""
                Write-Host "############################################################"
                Write-Host ""
                Write-Host ""
                $exitquit = Read-Host "Press any key to exit"
                break

                }        
       
} else {

        try {

                Connect-ArubaSW -Server $ipswitch 
                
                }

        Catch { 

                Clear-Host
                Write-Host ""
                Write-Host "############################################################"
                Write-Host ""
                Write-Host ""
                Write-Host ""
                Write-Host "              !!! CAN NOT CONNECT TO SWITCH !!!"
                Write-Host ""
                Write-Host "       Check that the IP or login and password is valid."
                Write-Host ""
                Write-Host ""
                Write-Host "              Then restart that script again."
                Write-Host ""
                Write-Host ""
                Write-Host ""
                Write-Host "############################################################"
                Write-Host ""
                Write-Host ""
                $exitquit = Read-Host "Press any key to exit"
                break

                }
        
        }

# Creation of the run variable

$url = "rest/v4/ports"
$response = invoke-ArubaSWWebRequest -method "GET" -url $url
$run = ($response | convertfrom-json).port_element

# Creation of the vlanports variable
$vlanports = Get-ArubaSWVlansPorts
$lldpremote = get-arubaswlldpremote

$resultarray=@()

# Crossing the information of the run variable against the vlanports variable
foreach ($port in $run) {
 
    $v = $vlanports | Where-Object {$_.port_id -eq $port.id}
    $tagged=$null
    $w = $lldpremote | Where-Object {$lldpremote.local_port -eq $port.id} 

    $countvlan = -1
        
        foreach ($vlanp in $v) {
            
                $countvlan ++
                
                }

        $comacountvlan = 0
      
        foreach ($vlanp in $v) {
            
            if ($comacountvlan -eq $countvlan) {

                                                $coma = ''
                                            
                                                } else {
                                            
                                                $coma = ', '
                                            
                                                }
            
            if ($vlanp.port_mode -eq "POM_UNTAGGED") {
            
                    $untagged = $vlanp.vlan_id
                    
                    }

            if ($vlanp.port_mode -eq "POM_TAGGED_STATIC") {

                    $tagged += "$($vlanp.vlan_id)$coma"
                    
                    }

            $comacountvlan++
      
        } 

    $item = New-Object PSObject
    $item | Add-Member -type NoteProperty -Name 'name' -Value $($port.name)
    $item | Add-Member -type NoteProperty -Name 'port_id' -Value $($port.id)
    $item | Add-Member -type NoteProperty -Name 'port_tagged' -Value $($tagged)
    $item | Add-Member -type NoteProperty -Name 'port_untagged' -Value $($untagged)
    $item | Add-Member -type NoteProperty -Name 'lacp_status' -Value $($port.lacp_status)
    $item | Add-Member -type NoteProperty -Name 'is_port_up' -Value $($port.is_port_up)
    $item | Add-Member -type NoteProperty -Name 'lldp_port_id' -Value $($w.port_id)
    $item | Add-Member -type NoteProperty -Name 'lldp_port_description' -Value $($w.port_description)
     
    $resultarray += $item
}

# Creation of Excel file
$infoswitch = Get-ArubaSWSystemStatus

# Launching an instance of MS Excel
$excel = New-Object -ComObject "Excel.Application"            
$excel.Visible = $True
$excel.DisplayAlerts = $False

# Creating an Excel sheet + activating the current sheet   
$workbook = $excel.Workbooks.Add()
$sheet = $workbook.Worksheets.Item(1)
$sheet.Activate() | Out-Null

# We position ourselves in A1 on Excel (line = 1 / column = 1)
$row = 1
$Column = 1
$anum = 1
$bnum = 1

# Entering data in Excel
Add-ExcelFormatArray -name 'Name :' -letter1 A -letter2 B -emplacementtxt xlRight -fontcolorindex 55 -fontsize 10 -interiorcolorindex 15

$row++
$anum++
$bnum++ 

Add-ExcelFormatArray -name 'Serial Number :' -letter1 A -letter2 B -emplacementtxt xlRight -fontcolorindex 55 -fontsize 10 -interiorcolorindex 15

$row++
$anum++
$bnum++ 

Add-ExcelFormatArray -name 'Firmware Version :' -letter1 A -letter2 B -emplacementtxt xlRight -fontcolorindex 55 -fontsize 10 -interiorcolorindex 15

$row++
$anum++
$bnum++ 

Add-ExcelFormatArray -name 'Hardware Revision :' -letter1 A -letter2 B -emplacementtxt xlRight -fontcolorindex 55 -fontsize 10 -interiorcolorindex 15

$row++
$anum++
$bnum++ 

Add-ExcelFormatArray -name 'Product Model :' -letter1 A -letter2 B -emplacementtxt xlRight -fontcolorindex 55 -fontsize 10 -interiorcolorindex 15

$row = 1
$Column = 3
$anum = 1
$bnum = 1

    Add-ExcelFormatArray -name $infoswitch.name -letter1 C -letter2 G -emplacementtxt xlLeft -fontcolorindex 1 -fontsize 10 -interiorcolorindex 19

    $row++
    $anum++
    $bnum++ 
        
    Add-ExcelFormatArray -name $infoswitch.serial_number -letter1 C -letter2 G -emplacementtxt xlLeft -fontcolorindex 1 -fontsize 10 -interiorcolorindex 19

    $row++
    $anum++
    $bnum++ 

    Add-ExcelFormatArray -name $infoswitch.firmware_version -letter1 C -letter2 G -emplacementtxt xlLeft -fontcolorindex 1 -fontsize 10 -interiorcolorindex 19

    $row++
    $anum++
    $bnum++

    Add-ExcelFormatArray -name $infoswitch.hardware_revision -letter1 C -letter2 G -emplacementtxt xlLeft -fontcolorindex 1 -fontsize 10 -interiorcolorindex 19

    $row++
    $anum++
    $bnum++

    Add-ExcelFormatArray -name $infoswitch.product_model -letter1 C -letter2 G -emplacementtxt xlLeft -fontcolorindex 1 -fontsize 10 -interiorcolorindex 19
    
$row = 10
$Column = 1
$anum = 10
$bnum = 10

Add-ExcelFormatArray -name 'Name' -letter1 A -letter2 B -emplacementtxt xlCenter -fontcolorindex 55 -fontsize 10 -interiorcolorindex 15

$Column++
$Column++  

Add-ExcelFormatArray -name 'Port ID' -letter1 C -letter2 D -emplacementtxt xlCenter -fontcolorindex 55 -fontsize 10 -interiorcolorindex 15

$Column++ 
$Column++ 

Add-ExcelFormatArray -name 'Port Tagged' -letter1 E -letter2 F -emplacementtxt xlCenter -fontcolorindex 55 -fontsize 10 -interiorcolorindex 15

$Column++ 
$Column++ 

Add-ExcelFormatArray -name 'Port Untagged' -letter1 G -letter2 H -emplacementtxt xlCenter -fontcolorindex 55 -fontsize 10 -interiorcolorindex 15

$Column++ 
$Column++ 

Add-ExcelFormatArray -name 'LACP Status' -letter1 I -letter2 J -emplacementtxt xlCenter -fontcolorindex 55 -fontsize 10 -interiorcolorindex 15

$Column++ 
$Column++ 

Add-ExcelFormatArray -name 'Is Port UP' -letter1 K -letter2 L -emplacementtxt xlCenter -fontcolorindex 55 -fontsize 10 -interiorcolorindex 15

$Column++ 
$Column++ 

Add-ExcelFormatArray -name 'LLDP Port ID' -letter1 M -letter2 N -emplacementtxt xlCenter -fontcolorindex 55 -fontsize 10 -interiorcolorindex 15

$Column++ 
$Column++ 

Add-ExcelFormatArray -name 'LLDP Port Description' -letter1 O -letter2 P -emplacementtxt xlCenter -fontcolorindex 55 -fontsize 10 -interiorcolorindex 15

$row = 11
$Column = 1
$anum = 11
$bnum = 11

# Data recovery
$entries = $resultarray

foreach ($entry in $entries)  {

    Add-ExcelFormatArray -name $entry.name -letter1 A -letter2 B -emplacementtxt xlCenter -fontcolorindex 1 -fontsize 10 -interiorcolorindex 19

    $Column++ 
    $Column++

    Add-ExcelFormatArray -name $entry.port_id -letter1 C -letter2 D -emplacementtxt xlCenter -fontcolorindex 1 -fontsize 10 -interiorcolorindex 19

    $Column++ 
    $Column++

    Add-ExcelFormatArray -name $entry.port_tagged -letter1 E -letter2 F -emplacementtxt xlCenter -fontcolorindex 1 -fontsize 10 -interiorcolorindex 19

    $Column++ 
    $Column++

    Add-ExcelFormatArray -name $entry.port_untagged -letter1 G -letter2 H -emplacementtxt xlCenter -fontcolorindex 1 -fontsize 10 -interiorcolorindex 19

    $Column++ 
    $Column++

    Add-ExcelFormatArray -name $entry.lacp_status -letter1 I -letter2 J -emplacementtxt xlCenter -fontcolorindex 1 -fontsize 10 -interiorcolorindex 19

    $Column++ 
    $Column++

    Add-ExcelFormatArray -name $entry.is_port_up -letter1 K -letter2 L -emplacementtxt xlCenter -fontcolorindex 1 -fontsize 10 -interiorcolorindex 19

    $Column++ 
    $Column++    

    Add-ExcelFormatArray -name $entry.lldp_port_id -letter1 M -letter2 N -emplacementtxt xlCenter -fontcolorindex 1 -fontsize 10 -interiorcolorindex 19

    $Column++ 
    $Column++  

    Add-ExcelFormatArray -name $entry.lldp_port_description -letter1 O -letter2 P -emplacementtxt xlCenter -fontcolorindex 1 -fontsize 10 -interiorcolorindex 19

    $row++
    $column=1
    $anum ++
    $bnum ++
    
    }

# Saving the excel file:
$workbook.SaveAs("$env:USERPROFILE\Desktop\$($date)_$($CompanyName)_$($ipswitch).xlsx")

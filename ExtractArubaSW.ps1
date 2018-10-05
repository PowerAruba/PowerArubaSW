
 <#
  .SYNOPSIS
  Ce script permet d'extraire des données d'un switch Aruba et de classer ces informations d'un tableau Excel
  .DESCRIPTION
  Le fichier Excel comportera : -Nom du switch
                                -Numéro de série
                                -Firmware
                                -Revision matérielle
                                -Modèle du switch

                                -Nom du port
                                -Identifiant du port
                                -Vlan ports taguer
                                -Vlan ports non taguer
                                -Statut LACP

Ce script nécessite au le module PowerArubaSW soit installé. Plus d'information sur https://github.com/alagoutte/PowerArubaSW
Ce script utilise Microsoft Excel, le logiciel devra être installer sur l'ordinateur sur lequel le script s'exécute.

  .EXAMPLE
Le script peut être exécuté avec la liste d'arguments suivant 

ExtractArubaSW.ps1 -ClientName <nom du client> -IpSwitch <ip du switch> -LoginSwitch <login du switch> -MdpSwitch <mot de passe switch>
  
  .EXAMPLE
Le script peut être exécuté sans préciser le type d'argument du moment que l'ordre des arguments <nom du client> <ip du switch> <login du switch> <mot de passe switch> est respecté

ExtractArubaSW.ps1 <nom du client> <ip du switch> <login du switch> <mot de passe switch>

  .EXAMPLE
Le script peut être exécuté sans argument, des questions seront posées à l'utilisateur au cours de celui-ci.

ExtractArubaSW.ps1 

  .NOTES

  Version:        1.2
  Author:         <Benjamin PERRIER>
  Creation Date:  <21/09/2018>
  Script Name: ExtractArubaSW

  #>


Param(
  [string]$ClientName,
  [string]$IPSwitch,
  [string]$LoginSwitch,
  [string]$MDPSwitch,
  [String]$Targets = "Help" )



#TEST DE LA PRESENCE DU MODULE POWERARUBASW

if (Get-Module -ListAvailable -Name PowerArubaSW) {

        Import-Module PowerArubaSW
        cls

} else {

        cls
        echo ""
        echo "############################################################"
        echo ""
        echo ""
        echo ""
        echo "    !!! LE MODULE POWERARUBASW N'EST PAS INSTALLER !!!"
        echo ""
        echo "         Afin d'installer ce module tapez la commande"
        echo "                Install-Module PowerArubaSW"
        echo ""
        echo "            Puis relancez de nouveau ce script."
        echo ""
        echo ""
        echo ""
        echo "############################################################"
        echo ""
        echo ""
        $exitquit = Read-Host "Appuyez sur n'importe quelle touche pour quitter."
        break
       
        }

	



# Demande du nom client si pas renseigné en argument

if ([string]::IsNullOrEmpty($clientname)) {

        #Information nom client
        cls
        echo ""
        echo "############################################################"
        echo ""
        echo ""
        echo ""
        echo "                 Quel est le nom du client ?"
        echo ""
        echo ""
        echo ""
        echo "############################################################"
        echo ""
        echo ""
        $clientname = Read-Host "Veuillez saisir le nom du client"
        cls

        }


#Enregistrement de la date au format day/month/year dans la variable date
$date = Get-Date -format "dd-MM-yyyy"




#Demande ip switch si pas renseigné en argument

if ([string]::IsNullOrEmpty($ipswitch)) {

    cls
    echo ""
    echo "############################################################"
    echo ""
    echo ""
    echo ""
    echo "             Quelle est l'adresse IP du switch ?"
    echo ""
    echo ""
    echo ""
    echo "############################################################"
    echo ""
    echo ""
    $ipswitch = Read-Host "Veuillez saisir l'addresse IP du switch ?"
    cls

    }


# Affichage du nom du fichier généré et de son emplacement

cls
echo ""
echo "#######################################################################"
echo ""
echo "       Un fichier excel sera automatiquement créé"
echo ""
echo "       Il sera stocké dans $env:USERPROFILE\Desktop\"
echo ""
echo "       et sera nommé $($date)_$($clientname)_$($ipswitch).xlsx"
echo ""
echo "#######################################################################"
echo ""
echo ""



# Verification des variables loginswitch et mdpswitch

if ((-not [string]::IsNullOrEmpty($loginswitch)) -and (-not [string]::IsNullOrEmpty($mdpswitch))) { 




        $mysecpassword = ConvertTo-SecureString $mdpswitch -AsPlainText -Force



        try {

                Connect-ArubaSW -Server $ipswitch -Username $loginswitch -Password $mysecpassword
                
                }

        Catch { 

                cls
                echo ""
                echo "############################################################"
                echo ""
                echo ""
                echo ""
                echo "       !!! IMPOSSIBLE DE SE CONNECTER AU SWITCH !!!"
                echo ""
                echo "         Verrifier que le login et le mot de passe"
                echo "                      soit valide"
                echo ""
                echo "           Puis relancez de nouveau ce script."
                echo ""
                echo ""
                echo ""
                echo "############################################################"
                echo ""
                echo ""
                $exitquit = Read-Host "Appuyez sur n'importe quelle touche pour quitter."
                break

                }
        
        

} else {

        try {

                Connect-ArubaSW -Server $ipswitch 
                
                }

        Catch { 

                cls
                echo ""
                echo "############################################################"
                echo ""
                echo ""
                echo ""
                echo "       !!! IMPOSSIBLE DE SE CONNECTER AU SWITCH !!!"
                echo ""
                echo "         Verrifier que le login et le mot de passe"
                echo "                      soit valide"
                echo ""
                echo "           Puis relancez de nouveau ce script."
                echo ""
                echo ""
                echo ""
                echo "############################################################"
                echo ""
                echo ""
                $exitquit = Read-Host "Appuyez sur n'importe quelle touche pour quitter."
                break

                }
        
        }






# Creation de la variable run

$url = "rest/v4/ports"
$response = invoke-ArubaSWWebRequest -method "GET" -url $url
$run = ($response | convertfrom-json).port_element

# Creation de la variable vlanports
$vlanports = Get-ArubaSWVlansPorts

$resultarray=@()

# Croisement des informations de la variable run par rapport à la variable vlanports

foreach ($port in $run) {
 
    $v = $vlanports | Where-Object {$_.port_id -eq $port.id}
    $tagged=$null 

        foreach ($vlanp in $v) {
            
            if ($vlanp.port_mode -eq "POM_UNTAGGED") {
            
                    $untagged = $vlanp.vlan_id
                    
                    }

            if ($vlanp.port_mode -eq "POM_TAGGED_STATIC") {

                    $tagged += "$($vlanp.vlan_id), "
                    
                    }

        } 

  
    $item = New-Object PSObject
    $item | Add-Member -type NoteProperty -Name 'name' -Value $($port.name)
    $item | Add-Member -type NoteProperty -Name 'port_id' -Value $($port.id)
    $item | Add-Member -type NoteProperty -Name 'port_tagged' -Value $($tagged)
    $item | Add-Member -type NoteProperty -Name 'port_untagged' -Value $($untagged)
    $item | Add-Member -type NoteProperty -Name 'lacp_status' -Value $($port.lacp_status)
    $item | Add-Member -type NoteProperty -Name 'is_port_up' -Value $($port.is_port_up)
     
    $resultarray += $item

}


$lldpremote = get-arubaswlldpremote

$resultarray2=@()

foreach ($resultarra in $resultarray) {

$w = $lldpremote | Where-Object {$lldpremote.local_port -eq $resultarra.port_id}


#Write-Host "port_id $($resultarra.port_id) port_id $($w.port_id)"

    $item = New-Object PSObject
    $item | Add-Member -type NoteProperty -Name 'name' -Value $($resultarra.name)
    $item | Add-Member -type NoteProperty -Name 'port_id' -Value $($resultarra.port_id)
    $item | Add-Member -type NoteProperty -Name 'port_tagged' -Value $($resultarra.port_tagged)
    $item | Add-Member -type NoteProperty -Name 'port_untagged' -Value $($resultarra.port_untagged)
    $item | Add-Member -type NoteProperty -Name 'lacp_status' -Value $($resultarra.lacp_status)
    $item | Add-Member -type NoteProperty -Name 'is_port_up' -Value $($resultarra.is_port_up)
    $item | Add-Member -type NoteProperty -Name 'lldp_port_id' -Value $($w.port_id)
    $item | Add-Member -type NoteProperty -Name 'lldp_port_description' -Value $($w.port_description)
     
    $resultarray2 += $item

}

# Creation du fichier Excel


$infoswitch = Get-ArubaSWSystemStatus | Select -Property name,serial_number,firmware_version,hardware_revision,product_model




# Lancement d'une instance de MS Excel
$excel = New-Object -ComObject "Excel.Application"            
$excel.Visible = $True
$excel.DisplayAlerts = $False

# Création d'une feuille Excel + activation de la feuille en cours   
$workbook = $excel.Workbooks.Add()
$sheet = $workbook.Worksheets.Item(1)
$sheet.Activate() | Out-Null



# On se positionne en A1 sur Excel (ligne=1/colonne=1)
$row = 1
$Column = 1
$anum = 1
$bnum = 1




# Saisie des données dans Excel

 function excelparamarray1  {
                        $MergeCells = $sheet.Range("A$($anum):B$($bnum)")
                        $MergeCells.Select() 
                        $MergeCells.MergeCells = $true
                        $xlConstants = "microsoft.office.interop.excel.Constants" -as [type]
                        $sheet.Cells($row,$column).HorizontalAlignment = $xlConstants::xlRight
                        $sheet.Cells.Item($row,$column).Font.Size = 10
                        $sheet.Cells.Item($row,$column).Font.Bold=$True
                        $sheet.Cells.Item($row,$column).Font.Name = "Cambria"
                        $sheet.Cells.Item($row,$column).Font.ThemeFont = 1
                        $sheet.Cells.Item($row,$column).Font.ThemeColor = 4
                        $sheet.Cells.Item($row,$column).Font.ColorIndex = 55
                        $sheet.Cells.Item($row,$column).Font.Color = 8210719
                        $sheet.Cells.Item($row,$column).Interior.ColorIndex = 15
                     }



$sheet.Cells.Item($row,$column)= 'Name :'
excelparamarray1

$row++
$anum++
$bnum++ 

$sheet.Cells.Item($row,$column)= 'Serial Number :'
excelparamarray1

$row++
$anum++
$bnum++ 

$sheet.Cells.Item($row,$column)= 'Firmware Version :'
excelparamarray1

$row++
$anum++
$bnum++ 

$sheet.Cells.Item($row,$column)= 'Hardware Revision :'
excelparamarray1

$row++
$anum++
$bnum++ 

$sheet.Cells.Item($row,$column)= 'Product Model :'
excelparamarray1

$row++
$anum++
$bnum++ 


$row = 1
$Column = 3
$anum = 1
$bnum = 1

# Récupération des données
$entries = $infoswitch | Select -Property name,serial_number,firmware_version,hardware_revision,product_model

#
function excelparam2array1 {
                                $MergeCells = $sheet.Range("C$($anum):G$($bnum)")
                                $MergeCells.Select() 
                                $MergeCells.MergeCells = $true
                                $xlConstants = "microsoft.office.interop.excel.Constants" -as [type]
                                $sheet.Cells($row,$column).HorizontalAlignment = $xlConstants::xlLeft
                                $sheet.Cells.Item($row,$column).Font.Size = 10
                                $sheet.Cells.Item($row,$column).Font.Bold=$True
                                $sheet.Cells.Item($row,$column).Font.Name = "Cambria"
                            }



foreach ($entry in $entries)  {

    $sheet.Cells.Item($row,$column)= $entry.name
    excelparam2array1

    $row++
    $anum++
    $bnum++ 
        
    $sheet.Cells.Item($row,$column)= $entry.serial_number
    excelparam2array1

    $row++
    $anum++
    $bnum++ 

    $sheet.Cells.Item($row,$column)= $entry.firmware_version
    excelparam2array1

    $row++
    $anum++
    $bnum++

    $sheet.Cells.Item($row,$column)= $entry.hardware_revision
    excelparam2array1

    $row++
    $anum++
    $bnum++

    $sheet.Cells.Item($row,$column)= $entry.product_model
    excelparam2array1
    
}



$row = 10
$Column = 1
$anum = 10
$bnum = 10

function excelparam1array2 {
            $MergeCells.Select() 
            $MergeCells.MergeCells = $true
            $xlConstants = "microsoft.office.interop.excel.Constants" -as [type]
            $sheet.Cells($row,$column).HorizontalAlignment = $xlConstants::xlCenter
            $sheet.Cells.Item($row,$column).Font.Size = 10
            $sheet.Cells.Item($row,$column).Font.Bold=$True
            $sheet.Cells.Item($row,$column).Font.Name = "Cambria"
            $sheet.Cells.Item($row,$column).Font.ThemeFont = 1
            $sheet.Cells.Item($row,$column).Font.ThemeColor = 4
            $sheet.Cells.Item($row,$column).Font.ColorIndex = 55
            $sheet.Cells.Item($row,$column).Font.Color = 8210719
            $sheet.Cells.Item($row,$column).Interior.ColorIndex = 15
         }

# Saisie des données dans Excel

$sheet.Cells.Item($row,$column)= 'Name'
$MergeCells = $sheet.Range("A$($anum):B$($bnum)")
excelparam1array2

$Column++
$Column++  

$sheet.Cells.Item($row,$column)= 'Port ID'
$MergeCells = $sheet.Range("C$($anum):D$($bnum)")
excelparam1array2

$Column++ 
$Column++ 

$sheet.Cells.Item($row,$column)= 'Port Tagged'
$MergeCells = $sheet.Range("E$($anum):F$($bnum)")
excelparam1array2

$Column++ 
$Column++ 

$sheet.Cells.Item($row,$column)= 'Port Untagged'
$MergeCells = $sheet.Range("G$($anum):H$($bnum)")
excelparam1array2

$Column++ 
$Column++ 

$sheet.Cells.Item($row,$column)= 'LACP Status'
$MergeCells = $sheet.Range("I$($anum):J$($bnum)")
excelparam1array2

$Column++ 
$Column++ 

$sheet.Cells.Item($row,$column)= 'Is Port UP'
$MergeCells = $sheet.Range("K$($anum):L$($bnum)")
excelparam1array2

$Column++ 
$Column++ 

$sheet.Cells.Item($row,$column)= 'LLDP Port ID'
$MergeCells = $sheet.Range("M$($anum):N$($bnum)")
excelparam1array2

$Column++ 
$Column++ 

$sheet.Cells.Item($row,$column)= 'LLDP Port Description'
$MergeCells = $sheet.Range("O$($anum):P$($bnum)")
excelparam1array2



$row = 11
$Column = 1
$anum = 11
$bnum = 11

# Récupération des données
$entries = $resultarray2


function excelparam2array2 {
    $MergeCells.Select() 
    $MergeCells.MergeCells = $true
    $xlConstants = "microsoft.office.interop.excel.Constants" -as [type]
    $sheet.Cells($row,$column).HorizontalAlignment = $xlConstants::xlCenter
    $sheet.Cells.Item($row,$column).Font.Size = 10
    $sheet.Cells.Item($row,$column).Font.Bold=$True
    $sheet.Cells.Item($row,$column).Font.Name = "Cambria"
         }


foreach ($entry in $entries)  {

    $sheet.Cells.Item($row,$column)= $entry.name
    $MergeCells = $sheet.Range("A$($anum):B$($bnum)")
    excelparam2array2

    $Column++ 
    $Column++

    $sheet.Cells.Item($row,$column)= $entry.port_id
    $MergeCells = $sheet.Range("C$($anum):D$($bnum)")
    excelparam2array2

    $Column++ 
    $Column++

    $sheet.Cells.Item($row,$column)= $entry.port_tagged
    $MergeCells = $sheet.Range("E$($anum):F$($bnum)")
    excelparam2array2

    $Column++ 
    $Column++
    
    $sheet.Cells.Item($row,$column)= $entry.port_untagged
    $MergeCells = $sheet.Range("G$($anum):H$($bnum)")
    excelparam2array2

    $Column++ 
    $Column++

    $sheet.Cells.Item($row,$column)= $entry.lacp_status
    $MergeCells = $sheet.Range("I$($anum):J$($bnum)")
    excelparam2array2

    $Column++ 
    $Column++
    
    $sheet.Cells.Item($row,$column)= $entry.is_port_up
    $MergeCells = $sheet.Range("K$($anum):L$($bnum)")
    excelparam2array2

    $Column++ 
    $Column++    

    $sheet.Cells.Item($row,$column)= $entry.lldp_port_id
    $MergeCells = $sheet.Range("M$($anum):N$($bnum)")
    excelparam2array2

    $Column++ 
    $Column++  

    $sheet.Cells.Item($row,$column)= $entry.lldp_port_description
    $MergeCells = $sheet.Range("O$($anum):P$($bnum)")
    excelparam2array2

    $row++
    $column=1
    $anum ++
    $bnum ++
    
    }




# Sauvegarde du fichier excel:
$workbook.SaveAs("$env:USERPROFILE\Desktop\$($date)_$($clientname)_$($ipswitch).xlsx")

break


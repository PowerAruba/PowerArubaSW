
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

  Version:        1.1
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


# Saisie des données dans Excel
$sheet.Cells.Item($row,$column)= 'name'
$sheet.Cells.Item($row,$column).Font.Bold=$True

$row++ 

$sheet.Cells.Item($row,$column)= 'serial_number'
$sheet.Cells.Item($row,$column).Font.Bold=$True
$row++ 

$sheet.Cells.Item($row,$column)= 'firmware_version'
$sheet.Cells.Item($row,$column).Font.Bold=$True
$row++ 

$sheet.Cells.Item($row,$column)= 'hardware_revision'
$sheet.Cells.Item($row,$column).Font.Bold=$True
$row++ # On passe à la colonne suivante

$sheet.Cells.Item($row,$column)= 'product_model'
$sheet.Cells.Item($row,$column).Font.Bold=$True
$row++ # On passe à la colonne suivante


$row = 1
$Column = 2

# Récupération des données
$entries = $infoswitch | Select -Property name,serial_number,firmware_version,hardware_revision,product_model

#
foreach ($entry in $entries)  {

    $sheet.Cells.Item($row,$column) = $entry.name
    $row++

    $sheet.Cells.Item($row,$column) = $entry.serial_number
    $row++
    
    $sheet.Cells.Item($row,$column) = $entry.firmware_version
    $row++

    $sheet.Cells.Item($row,$column) = $entry.hardware_revision
    $row++

    $sheet.Cells.Item($row,$column) = $entry.product_model
    $rown++
    
    
    $row=1
    $column++
}



$row = 8
$Column = 1

# Saisie des données dans Excel
$sheet.Cells.Item($row,$column)= 'name'
$sheet.Cells.Item($row,$column).Font.Bold=$True
$Column++ # On passe à la colonne suivante

$sheet.Cells.Item($row,$column)= 'port_id'
$sheet.Cells.Item($row,$column).Font.Bold=$True
$Column++ 

$sheet.Cells.Item($row,$column)= 'port_tagged'
$sheet.Cells.Item($row,$column).Font.Bold=$True
$Column++ 

$sheet.Cells.Item($row,$column)= 'port_untagged'
$sheet.Cells.Item($row,$column).Font.Bold=$True
$Column++ 

$sheet.Cells.Item($row,$column)= 'lacp_status'
$sheet.Cells.Item($row,$column).Font.Bold=$True
$Column++ 

$sheet.Cells.Item($row,$column)= 'is_port_up'
$sheet.Cells.Item($row,$column).Font.Bold=$True
$Column++ 


$row = 9
$Column = 1

# Récupération des données
$entries = $resultarray


foreach ($entry in $entries)  {

    $sheet.Cells.Item($row,$column) = $entry.name
    $column++

    $sheet.Cells.Item($row,$column) = $entry.port_id
    $column++
    
    $sheet.Cells.Item($row,$column) = $entry.port_tagged
    $column++

    $sheet.Cells.Item($row,$column) = $entry.port_untagged
    $column++

    $sheet.Cells.Item($row,$column) = $entry.lacp_status
    $column++
    
    $sheet.Cells.Item($row,$column) = $entry.is_port_up
    $column++
    
    $row++
    $column=1
    
    }




# Sauvegarde du fichier excel:
$workbook.SaveAs("$env:USERPROFILE\Desktop\$($date)_$($clientname)_$($ipswitch).xlsx")

break
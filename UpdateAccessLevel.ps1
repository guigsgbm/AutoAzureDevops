$env:AZURE_DEVOPS_EXT_PAT = 'PAT da org'

$users = "Lista de usuários"

$license = "stakeholder"
$org = "Link da Organização"

$users.Length

for($i = 0; $i -ne $users.Length; $i++){
    $env:AZURE_DEVOPS_EXT_PAT | az devops login --org $org
    az devops user update --license-type $license --user $users[$i] --org $org --output table
    echo ""
}
az devops logout

#Comando no excel para gerar a matriz no "formato certo"
#=CARACT(34)&B2&CARACT(34)&","
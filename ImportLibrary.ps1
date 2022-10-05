#Algumas observações: 
#Pode haver alguns problemas na criação da Library, por exemplo:
#O script deve rodar até o final, sem interrupções
#Algumas palavras reservadas ou caracteres especiais contidos nas "Libraries" podem conflitar com os comandos ($System, Rooping, Aspas Duplas, \\ etc...)

$sourceProj = "NOME Team project ORIGEM"
$sourceOrg = "LINK organization ORIGEM"

$destinationProj = "NOME team project DESTINO"
$destinationOrg = "LINK organization DESTINO"

#Pat e chamada na organização de origem
$env:AZURE_DEVOPS_EXT_PAT = "PAT ORIGEM"

$variableGroup = az pipelines variable-group list  --project $sourceProj --org $sourceOrg | ConvertFrom-Json
$variableGroup | ConvertTo-Json | Out-File .\variableGroup.json

#Pat organização de destino
$env:AZURE_DEVOPS_EXT_PAT = "PAT DESTINO"

#Importar a Library caso tenha somente 1 Variable Group.
if ($variableGroup.name[0].Length -eq 1){

    #Cria a Library
    az pipelines variable-group create --name $variableGroup.name --variables 1=1 --org $destinationOrg --project $destinationProj

    $variableGroupTemp = az pipelines variable-group list --project $destinationProj --org $destinationOrg | ConvertFrom-Json
    $variableGroupTemp | ConvertTo-Json | Out-File -FilePath .\variableGroupTemp.json

    foreach($a in ($variableGroup.variables | Get-Member -MemberType Properties))
    {
        #Caso a variável não contenha valor..
        if ($variableGroup.variables.($a.Name).value -eq $null){
            $variableGroup.variables.($a.Name).value = "Isso eh um KV ou Secret"
            az pipelines variable-gro   up variable create --group-id $variableGroupTemp.id[0] --name $a.Name --org $destinationOrg --project $destinationProj --value $variableGroup.variables.($a.Name).value
        }
        #Cria a variável
        az pipelines variable-group variable create --group-id $variableGroupTemp.id[0] --name $a.Name --org $destinationOrg --project $destinationProj --value $variableGroup.variables.($a.Name).value
    }
    #Deleta a variável de criação temporária "1=1"
    az pipelines variable-group variable delete --group-id $variableGroupTemp.id[0] --name 1 --org $destinationOrg --project $destinationProj --yes
}

#Importar a Library caso tenha 2 Variable Group ou mais.
else{
    for($i = 0; $i -ne $variableGroup.variables.Length; $i++){
        foreach($object in $variableGroup.variables[$i]){

            az pipelines variable-group create --name $variableGroup.name[$i] --variables 1=1 --org $destinationOrg --project $destinationProj

            $variableGroupTemp = az pipelines variable-group list --project $destinationProj --org $destinationOrg | ConvertFrom-Json
            $variableGroupTemp | ConvertTo-Json | Out-File -FilePath .\variableGroupTemp.json

            foreach($key in ($object | Get-Member -MemberType Properties)){
                
                $values = $key.Definition
                $values = $values  -replace "System.Management.Automation.PSCustomObject $($key.Name)(=@{isSecret=; value=|=@{isSecret=True; value=)",''
                $values = $values  -replace '}'

                if ($values -eq ''){
                    $values = "Isso eh um KV ou Secret"
                }

                az pipelines variable-group variable create --group-id $variableGroupTemp.id[0] --name $key.Name --org $destinationOrg --project $destinationProj --value $values
            }
            az pipelines variable-group variable delete --group-id $variableGroupTemp.id[0] --name 1 --org $destinationOrg --project $destinationProj --yes
        }
    }
}

#Liberar recursos.
remove-item -path .\variableGroup.json 
remove-item -path .\variableGroupTemp.json
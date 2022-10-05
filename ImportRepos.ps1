#Autenticação API
function Create-BasicAuthHeader {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(Mandatory=$true)]
        [string]$PAT
    )

    $Auth = '{0}:{1}' -f $Name, $PAT
    $Auth = [System.Text.Encoding]::UTF8.GetBytes($Auth)
    $Auth = [System.Convert]::ToBase64String($Auth)
    $Header = @{Authorization=("Basic {0}" -f $Auth)} 

    $Header
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Autenticações API, Repos privado e setar variáveis.

$sourceProject = "NOME Team Project ORIGEM"
$sourceOrg = "NOME organization ORIGEM"
$destinationOrg = "LINK organization DESTINO"
$userName = "MigracaoDevOps"

$env:AZURE_DEVOPS_EXT_GIT_SOURCE_PASSWORD_OR_PAT = 'PAT ORIGEM'
$headerdata = Create-BasicAuthHeader 'Apis' 'PAT ORIGEM'
echo  "PAT ORIGEM" | az devops login --organization 'LINK organization ORIGEM' #"EX:(https://vstscs.visualstudio.com/)"
echo  "PAT DESTINO" | az devops login --organization $destinationOrg

#Chamada na API (pode conter filtros no link)
$repos = (Invoke-WebRequest -Uri (-Join('https://dev.azure.com/', $sourceOrg, '/', $sourceProject, '/_apis/git/repositories?api-version=6.0')) -UseBasicParsing -Headers $headerdata -Method Get).Content | ConvertFrom-Json
$repos | ConvertTo-Json | Out-File -FilePath .\repos.json

#Para cada repositório dentro do JSON gerado pela API, o foreach vai criar um repositório zerado na organização de destino e depois clonar da origem.
foreach ($repo in $repos.value) 
{
    $sourceRepoName = $repo.webUrl
    $destinationRepo = $repo.name
    $destinationProject = $repo.project.name
    #$destinationProject = EX "FrontProjects"

    #Se os nomes dos projetos e repositórios de origem e destino forem diferentes um do outro, terá que chumbar o valor das variáveis no script antes de executa-lo.
    az repos create --name $destinationRepo -p $destinationProject --org $destinationOrg
    az repos import create --git-source-url $sourceRepoName --org $destinationOrg -p $destinationProject -r $destinationRepo --requires-authorization --user-name $userName
}

#Liberar recursos.
remove-item -path .\repos.json
az devops logout
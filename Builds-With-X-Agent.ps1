function BasicAuthHeader {
    Param(
        [Parameter(Mandatory=$true)]
        [string]$PAT
    )

    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($PAT)"))

    $headers = @{
    Authorization = "Basic $base64AuthInfo"
    }

    $headers
}

$PAT = "Personal Access Token"
$orgName = "Organization Name"
$agentPoolID = "Agent Pool ID"

$headerdata = BasicAuthHeader "$PAT"
$buildPipes = @()

$runs = (Invoke-WebRequest `
-Uri ("https://dev.azure.com/$orgName/_apis/distributedtask/pools/$agentPoolID/jobrequests?api-version=6.0") `
-UseBasicParsing `
-Headers $headerdata `
-Method Get).Content | ConvertFrom-Json

foreach ($run in $runs.value){

    $buildPipe = [PSCustomObject]@{
        Name = $run.definition.name
        Url = $run.definition._links.web.href
    }

    if ($null -eq ($buildPipes | Where-Object { $_.Name -eq $buildPipe.Name -and $_.Url -eq $buildPipe.Url })) {
            $buildPipes += $buildPipe
    }
}

$json = $buildPipes | ConvertTo-Json | Out-File -FilePath "Builds-With-X-Agent.json"

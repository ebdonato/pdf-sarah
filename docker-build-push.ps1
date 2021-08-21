# Set-ExecutionPolicy Bypass -Scope Process -Force; .\docker-build-push.ps1

param
(
    $dockeruser = "ebdonato"
)

$version = (Get-Content package.json) -join "`n" | ConvertFrom-Json | Select -ExpandProperty "version"

$repository = (Get-Content package.json) -join "`n" | ConvertFrom-Json | Select -ExpandProperty "name"

Write-Host $repository $version

Write-Host "Building Image"

docker build . -t ${dockeruser}/${repository}:${version}

Write-Host "Creating latest tag"

docker tag ${dockeruser}/${repository}:${version} ${dockeruser}/${repository}:latest

Write-Host "Pushing tag " $version

docker push ${dockeruser}/${repository}:${version}

Write-Host "Pushing tag latest"

docker push ${dockeruser}/${repository}:latest

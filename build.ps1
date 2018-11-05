$REPOSITORY_URI = "322767926738.dkr.ecr.ap-southeast-2.amazonaws.com/bookystuff"

function PackageIntegration
{
    param([string]$Command)

    Write-Output "Building Integration Image"
    docker build -t ${REPOSITORY_URI}:bookystuff-blazor -t ${REPOSITORY_URI}:latest . .\bookystuff.Server
    Write-Output "Finished Building Integration Image"
    if ($command -eq "apply")
    {
        Write-Output "Pushing Integration Image"
        $dockerlogin = aws ecr get-login --no-include-email --region ap-southeast-2
        Invoke-Expression $dockerlogin
        docker push ${REPOSITORY_URI}:latest
        docker push ${REPOSITORY_URI}:bookystuff-blazor
        Write-Output "Finished Pushing Integration Image"
    }
}

function TerraformCommand
{
    param([string]$Command)

    Write-Host "Executing Terraform Command: $Command"
    Push-Location bookystuff.Terraform
    switch ($Command)
    {
        "init" {
            terraform init | Tee-Object -a ..\terraform.txt 2>&1
            Write-Host "Finished initing"
        }
        "plan" {
            terraform plan | Tee-Object -a ..\terraform.txt 2>&1
            Write-Host "Finished planning terraform"
        }
        "apply" {
            terraform apply -auto-approve | Tee-Object -a ..\terraform.txt 2>&1
            Write-Host "Finished applying terraform"
        }
    }
    Pop-Location    
    Write-Host "Finished Executing Terraform Command: $Command"
}

# Main Script

if ($env:APPVEYOR_REPO_TAG -eq "false")
{
    Write-Host "Unable to acertain action, commit has no tags. Exiting." 
    Exit 
}

$Command = $env:APPVEYOR_REPO_TAG_NAME
if ($Command -ne "plan" -and $Command -ne "apply") 
{
    Write-Host "Action $Command is invalid, options arre 'plan' or 'apply'. Exiting." 
    Exit 
}

$ErrorActionPreference = "Stop"
Write-Host "Processing Command: $Command"


PackageIntegration $Command
TerraformCommand -Command "init"
TerraformCommand -Command $Command

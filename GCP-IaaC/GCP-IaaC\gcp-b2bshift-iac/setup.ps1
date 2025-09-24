# ================================================
# SETUP.PS1 - B2BSHIFT PLATFORM
# Script de configuração inicial
# Projeto: b2bshift (849881353097) - Produção
# ================================================

# Cores para output
$RED = "Red"
$GREEN = "Green"
$YELLOW = "Yellow"
$BLUE = "Blue"

function Write-Log {
    param($Message, $Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Write-Success {
    param($Message)
    Write-Log "✅ $Message" -Color $GREEN
}

function Write-Error-Custom {
    param($Message)
    Write-Log "❌ $Message" -Color $RED
}

function Write-Warning-Custom {
    param($Message)
    Write-Log "⚠️  $Message" -Color $YELLOW
}

# Banner
Write-Host ""
Write-Host "================================================" -ForegroundColor $BLUE
Write-Host "🚀 B2BSHIFT PLATFORM - CONFIGURAÇÃO INICIAL" -ForegroundColor $BLUE
Write-Host "================================================" -ForegroundColor $BLUE
Write-Host ""

# Verificar pré-requisitos
Write-Log "🔍 Verificando pré-requisitos..." -Color $BLUE

# Verificar Terraform
if (!(Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Error-Custom "Terraform não encontrado. Instale o Terraform primeiro."
    Write-Host "Download: https://www.terraform.io/downloads" -ForegroundColor $YELLOW
    exit 1
}
Write-Success "Terraform encontrado: $(terraform version -json | ConvertFrom-Json | Select-Object -ExpandProperty terraform_version)"

# Verificar gcloud
if (!(Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Error-Custom "Google Cloud SDK não encontrado. Instale o gcloud primeiro."
    Write-Host "Download: https://cloud.google.com/sdk/docs/install" -ForegroundColor $YELLOW
    exit 1
}
Write-Success "Google Cloud SDK encontrado"

Write-Host ""
Write-Log "🔐 Configurando autenticação..." -Color $BLUE

# Login no GCP
Write-Host "Fazendo login no GCP..." -ForegroundColor $YELLOW
gcloud auth login

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Falha no login do GCP"
    exit 1
}

# Configurar projeto
Write-Host "Configurando projeto composite-rune-470721-n2..." -ForegroundColor $YELLOW
gcloud config set project composite-rune-470721-n2

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Falha ao configurar projeto. Verifique se o projeto 'composite-rune-470721-n2' existe."
    exit 1
}

# Verificar projeto ativo
$activeProject = gcloud config get-value project 2>$null
if ($activeProject -eq "composite-rune-470721-n2") {
    Write-Success "Projeto ativo: $activeProject"
} else {
    Write-Error-Custom "Projeto ativo incorreto: $activeProject"
    exit 1
}

# Configurar credenciais para Terraform
Write-Host "Configurando credenciais para Terraform..." -ForegroundColor $YELLOW
gcloud auth application-default login

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Falha na configuração de credenciais para Terraform"
    exit 1
}

Write-Host ""
Write-Log "📋 Verificando billing e permissões..." -Color $BLUE

# Verificar billing
$billingInfo = gcloud beta billing projects describe composite-rune-470721-n2 --format="value(billingEnabled)" 2>$null
if ($billingInfo -eq "True") {
    Write-Success "Billing habilitado no projeto"
} else {
    Write-Warning-Custom "Billing não habilitado ou não verificável"
    Write-Host "Acesse: https://console.cloud.google.com/billing" -ForegroundColor $YELLOW
}

# Verificar permissões básicas
Write-Log "Verificando permissões básicas..." -Color $BLUE
$permissions = gcloud projects get-iam-policy composite-rune-470721-n2 --format="value(bindings.members)" 2>$null
$userEmail = gcloud config get-value account 2>$null

if ($permissions -match $userEmail) {
    Write-Success "Usuário encontrado nas permissões do projeto"
} else {
    Write-Warning-Custom "Não foi possível verificar permissões automaticamente"
}

Write-Host ""
Write-Log "🔧 Habilitando APIs necessárias..." -Color $BLUE

$apis = @(
    "compute.googleapis.com",
    "storage-api.googleapis.com", 
    "bigquery.googleapis.com",
    "dataflow.googleapis.com",
    "dataproc.googleapis.com",
    "composer.googleapis.com",
    "aiplatform.googleapis.com",
    "dataplex.googleapis.com",
    "cloudbuild.googleapis.com",
    "iam.googleapis.com"
)

foreach ($api in $apis) {
    Write-Host "Habilitando $api..." -ForegroundColor $YELLOW
    gcloud services enable $api --quiet
    if ($LASTEXITCODE -eq 0) {
        Write-Success "API $api habilitada"
    } else {
        Write-Warning-Custom "Falha ao habilitar $api (pode já estar habilitada)"
    }
}

Write-Host ""
Write-Log "📁 Verificando arquivos de configuração..." -Color $BLUE

# Verificar terraform.tfvars
if (Test-Path "terraform.tfvars") {
    Write-Success "Arquivo terraform.tfvars encontrado"
    
    # Mostrar configurações
    $projectId = (Get-Content "terraform.tfvars" | Select-String 'project_id.*=.*"([^"]+)"').Matches[0].Groups[1].Value
    $region = (Get-Content "terraform.tfvars" | Select-String 'region.*=.*"([^"]+)"').Matches[0].Groups[1].Value
    
    Write-Host "  - Project ID: $projectId" -ForegroundColor $BLUE
    Write-Host "  - Region: $region" -ForegroundColor $BLUE
} else {
    Write-Warning-Custom "Arquivo terraform.tfvars não encontrado"
    Write-Host "Criando terraform.tfvars básico..." -ForegroundColor $YELLOW
    
    $tfvarsContent = @"
project_id     = "composite-rune-470721-n2"
project_number = "565386878204"
region         = "us-central1"  
zone           = "us-central1-a"
environment    = "prod"
"@
    $tfvarsContent | Out-File -FilePath "terraform.tfvars" -Encoding UTF8
    Write-Success "Arquivo terraform.tfvars criado"
}

Write-Host ""
Write-Log "🚀 Inicializando Terraform..." -Color $BLUE

# Terraform init
Write-Host "Executando terraform init..." -ForegroundColor $YELLOW
terraform init

if ($LASTEXITCODE -eq 0) {
    Write-Success "Terraform inicializado com sucesso"
} else {
    Write-Error-Custom "Falha na inicialização do Terraform"
    exit 1
}

# Terraform validate
Write-Host "Validando configuração..." -ForegroundColor $YELLOW
terraform validate

if ($LASTEXITCODE -eq 0) {
    Write-Success "Configuração válida"
} else {
    Write-Error-Custom "Configuração inválida"
    exit 1
}

# Resumo final
Write-Host ""
Write-Host "================================================" -ForegroundColor $GREEN
Write-Host "✅ CONFIGURAÇÃO INICIAL CONCLUÍDA!" -ForegroundColor $GREEN
Write-Host "================================================" -ForegroundColor $GREEN
Write-Host ""

Write-Host "📋 PRÓXIMOS PASSOS:" -ForegroundColor $BLUE
Write-Host ""
Write-Host "1. 📧 Edite o arquivo bigquery.tf e descomente/configure os emails:" -ForegroundColor $YELLOW
Write-Host "   - Procure por 'SEU-EMAIL@GMAIL.COM'" -ForegroundColor $YELLOW
Write-Host "   - Substitua pelo seu email real" -ForegroundColor $YELLOW
Write-Host ""
Write-Host "2. 🔍 Visualize o plano:" -ForegroundColor $YELLOW  
Write-Host "   terraform plan" -ForegroundColor $BLUE
Write-Host ""
Write-Host "3. 🚀 Execute o deploy:" -ForegroundColor $YELLOW
Write-Host "   terraform apply" -ForegroundColor $BLUE
Write-Host ""
Write-Host "4. ✅ Valide a infraestrutura:" -ForegroundColor $YELLOW
Write-Host "   .\validate.ps1" -ForegroundColor $BLUE
Write-Host ""

Write-Warning-Custom "IMPORTANTE: O deploy criará recursos que custam dinheiro (~$17-28/dia)"
Write-Warning-Custom "Execute 'terraform destroy' após os testes para evitar custos!"

Write-Host ""
Write-Host "🔗 LINKS ÚTEIS:" -ForegroundColor $BLUE
Write-Host "- Console GCP: https://console.cloud.google.com/home/dashboard?project=composite-rune-470721-n2"
Write-Host "- Billing: https://console.cloud.google.com/billing"
Write-Host "- BigQuery: https://console.cloud.google.com/bigquery?project=composite-rune-470721-n2"
Write-Host ""
Write-Success "Setup concluído! Você está pronto para executar o Terraform."

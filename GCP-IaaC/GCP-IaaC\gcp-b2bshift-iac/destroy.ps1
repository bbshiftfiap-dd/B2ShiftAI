# ================================================
# DESTROY.SH - B2BSHIFT PLATFORM  
# Script para destruir a infraestrutura
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

function Write-Error-Custom {
    param($Message)
    Write-Log "ERROR: $Message" -Color $RED
    exit 1
}

function Write-Success {
    param($Message)
    Write-Log "SUCCESS: $Message" -Color $GREEN
}

function Write-Warning-Custom {
    param($Message)
    Write-Log "WARNING: $Message" -Color $YELLOW
}

# Banner
Write-Host ""
Write-Host "================================================" -ForegroundColor $RED
Write-Host "🗑️  B2BSHIFT PLATFORM DESTRUCTION" -ForegroundColor $RED
Write-Host "================================================" -ForegroundColor $RED
Write-Host ""

# Verificar pré-requisitos
Write-Log "Verificando pré-requisitos..." -Color $BLUE

# Verificar Terraform
if (!(Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Error-Custom "Terraform não encontrado. Instale o Terraform primeiro."
}

# Verificar se existe terraform.tfstate
if (!(Test-Path "terraform.tfstate")) {
    Write-Error-Custom "Arquivo terraform.tfstate não encontrado. Não há infraestrutura para destruir."
}

Write-Success "Pré-requisitos verificados!"

# Obter PROJECT_ID
$projectId = ""
if (Test-Path "terraform.tfvars") {
    $content = Get-Content "terraform.tfvars"
    foreach ($line in $content) {
        if ($line -match '^project_id\s*=\s*"([^"]+)"') {
            $projectId = $matches[1]
            break
        }
    }
}

if ($projectId) {
    Write-Log "Projeto identificado: $projectId" -Color $BLUE
} else {
    Write-Warning-Custom "Não foi possível identificar o project_id"
}

# AVISO CRÍTICO
Write-Host ""
Write-Host "⚠️  ATENÇÃO: OPERAÇÃO DESTRUTIVA ⚠️" -ForegroundColor $RED -BackgroundColor Yellow
Write-Host ""
Write-Host "Esta operação irá DELETAR PERMANENTEMENTE:" -ForegroundColor $RED
Write-Host "- Todos os buckets do Cloud Storage e seus dados"
Write-Host "- Todos os datasets do BigQuery e tabelas"
Write-Host "- Clusters Dataproc"
Write-Host "- Jobs do Dataflow"
Write-Host "- Ambiente do Composer/Airflow"
Write-Host "- Modelos do Vertex AI"
Write-Host "- DataPlex Lakes e configurações"
Write-Host "- Service Accounts"
Write-Host ""
Write-Host "💀 ESTA AÇÃO NÃO PODE SER DESFEITA! 💀" -ForegroundColor $RED -BackgroundColor Yellow
Write-Host ""

# Confirmação tripla
$confirmation1 = Read-Host "Digite 'DESTRUIR' para continuar (case-sensitive)"
if ($confirmation1 -ne "DESTRUIR") {
    Write-Log "Operação cancelada pelo usuário." -Color $YELLOW
    exit 0
}

$confirmation2 = Read-Host "Tem CERTEZA ABSOLUTA? Digite 'SIM' para continuar"
if ($confirmation2 -ne "SIM") {
    Write-Log "Operação cancelada pelo usuário." -Color $YELLOW
    exit 0
}

# Fazer backup do estado
Write-Log "Fazendo backup do terraform.tfstate..." -Color $BLUE
$backupName = "terraform.tfstate.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Copy-Item "terraform.tfstate" $backupName
Write-Success "Backup salvo como: $backupName"

# Inicializar Terraform
Write-Log "Inicializando Terraform..." -Color $BLUE
terraform init
if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Inicialização do Terraform falhou!"
}

# Plano de destruição
Write-Log "Criando plano de destruição..." -Color $BLUE
terraform plan -destroy
if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Criação do plano de destruição falhou!"
}

# Aplicar destruição
Write-Log "Iniciando destruição da infraestrutura..." -Color $RED
terraform destroy -auto-approve
if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Destruição falhou!"
}

# Limpeza de arquivos
Write-Log "Limpando arquivos temporários..." -Color $BLUE
if (Test-Path "tfplan") { Remove-Item "tfplan" }
if (Test-Path ".terraform.lock.hcl") { Remove-Item ".terraform.lock.hcl" }

Write-Host ""
Write-Host "================================================" -ForegroundColor $GREEN
Write-Host "🗑️  INFRAESTRUTURA DESTRUÍDA" -ForegroundColor $GREEN  
Write-Host "================================================" -ForegroundColor $GREEN
Write-Host ""
Write-Success "Todas as operações concluídas!"
Write-Host ""
Write-Host "📋 O que foi feito:"
Write-Host "- Backup do state salvo como: $backupName"
Write-Host "- Todos os recursos GCP foram deletados"
Write-Host "- Arquivos temporários removidos"
Write-Host ""
Write-Warning-Custom "O backup do terraform.tfstate foi mantido por segurança."

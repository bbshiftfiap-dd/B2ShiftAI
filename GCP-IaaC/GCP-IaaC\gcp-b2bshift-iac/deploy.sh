#!/bin/bash

# ================================================
# DEPLOY.SH - B2BSHIFT PLATFORM
# Script de deploy automatizado da infraestrutura
# ================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para logs
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Banner
echo -e "${BLUE}"
echo "================================================"
echo "🚀 B2BSHIFT PLATFORM DEPLOYMENT"
echo "================================================"
echo -e "${NC}"

# Verificar pré-requisitos
log "Verificando pré-requisitos..."

# Verificar Terraform
if ! command -v terraform &> /dev/null; then
    error "Terraform não encontrado. Instale o Terraform primeiro."
fi

# Verificar gcloud
if ! command -v gcloud &> /dev/null; then
    error "Google Cloud SDK não encontrado. Instale o gcloud primeiro."
fi

# Verificar autenticação
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "."; then
    error "Não autenticado no GCP. Execute: gcloud auth login"
fi

# Verificar arquivo terraform.tfvars
if [ ! -f "terraform.tfvars" ]; then
    warning "Arquivo terraform.tfvars não encontrado."
    log "Copiando terraform.tfvars.example..."
    cp terraform.tfvars.example terraform.tfvars
    error "Configure o arquivo terraform.tfvars com seus valores e execute novamente."
fi

success "Pré-requisitos verificados!"

# Obter PROJECT_ID do terraform.tfvars
PROJECT_ID=$(grep '^project_id' terraform.tfvars | cut -d'"' -f2)
if [ -z "$PROJECT_ID" ]; then
    error "project_id não encontrado em terraform.tfvars"
fi

log "Projeto: $PROJECT_ID"

# Confirmar deploy
echo ""
read -p "Deseja continuar com o deploy? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log "Deploy cancelado pelo usuário."
    exit 0
fi

# Configurar projeto no gcloud
log "Configurando projeto no gcloud..."
gcloud config set project "$PROJECT_ID"

# Inicializar Terraform
log "Inicializando Terraform..."
terraform init

# Validar configuração
log "Validando configuração..."
terraform validate
if [ $? -ne 0 ]; then
    error "Validação do Terraform falhou!"
fi

# Criar plano
log "Criando plano de execução..."
terraform plan -out=tfplan
if [ $? -ne 0 ]; then
    error "Criação do plano falhou!"
fi

# Confirmar aplicação
echo ""
read -p "Plano criado. Deseja aplicar? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log "Deploy cancelado pelo usuário."
    exit 0
fi

# Aplicar infraestrutura
log "Aplicando infraestrutura..."
terraform apply tfplan
if [ $? -ne 0 ]; then
    error "Deploy falhou!"
fi

# Gerar outputs
log "Coletando informações da infraestrutura..."
terraform output > deploy_outputs.txt

success "Deploy concluído com sucesso!"

# Exibir informações importantes
echo ""
echo -e "${GREEN}================================================"
echo "🎉 DEPLOY CONCLUÍDO!"
echo "================================================${NC}"
echo ""
echo "📋 Próximos passos:"
echo "1. Verifique os outputs em: deploy_outputs.txt"
echo "2. Acesse o BigQuery Console para configurar queries"
echo "3. Configure DAGs no Airflow"
echo "4. Teste os pipelines de dados"
echo ""
echo "🔗 Links úteis:"
terraform output -json quick_access_urls | jq -r 'to_entries[] | "- \(.key): \(.value)"'
echo ""
echo -e "${YELLOW}⚠️  Importante: Guarde o arquivo terraform.tfstate em local seguro!${NC}"

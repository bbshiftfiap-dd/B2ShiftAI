# ================================================
# INSTRUÇÕES DE EXECUÇÃO - B2BSHIFT PLATFORM
# Passo a passo para executar os scripts IaC
# ================================================

## 🚀 INSTRUÇÕES PARA EXECUÇÃO NO WINDOWS (PowerShell)

### PRÉ-REQUISITOS

1. **Instalar Terraform**
   - Baixe de: https://www.terraform.io/downloads
   - Adicione ao PATH do Windows
   - Verifique: `terraform version`

2. **Instalar Google Cloud SDK**
   - Baixe de: https://cloud.google.com/sdk/docs/install
   - Execute: `gcloud init`
   - Autentique: `gcloud auth login`

3. **Ter um Projeto GCP**
   - Crie no console: https://console.cloud.google.com
   - Habilite billing
   - Anote o Project ID

### PASSO A PASSO

#### 1. Configuração Inicial
```powershell
# Navegue até o diretório
cd "c:\Users\ssitta\OneDrive - azureford\Documents\FIAP\2025\B2Shift - 3Sprint\3Sprint - Cloud Solutions\gcp-b2bshift-iac"

# Copie o arquivo de exemplo
Copy-Item terraform.tfvars.example terraform.tfvars

# Edite o terraform.tfvars com seus valores
notepad terraform.tfvars
```

#### 2. Configurar terraform.tfvars
Edite o arquivo com seus valores reais:
```hcl
project_id  = "seu-projeto-gcp-real"
region      = "us-central1"
zone        = "us-central1-a"
environment = "dev"
```

#### 3. Autenticação no GCP
```powershell
# Login no GCP
gcloud auth login

# Configure o projeto padrão
gcloud config set project SEU-PROJECT-ID

# Configure credenciais para Terraform
gcloud auth application-default login
```

#### 4. Inicialização do Terraform
```powershell
# Inicialize o Terraform
terraform init

# Valide a configuração
terraform validate

# Visualize o plano
terraform plan
```

#### 5. Deploy da Infraestrutura
```powershell
# Opção 1: Deploy automatizado (RECOMENDADO)
.\deploy.sh

# Opção 2: Deploy manual
terraform apply
# Digite 'yes' quando solicitado
```

#### 6. Validação (Após o Deploy)
```powershell
# Execute o script de validação
.\validate.ps1
```

#### 7. Acessar os Serviços
```powershell
# Ver URLs de acesso
terraform output quick_access_urls
```

### EVIDÊNCIAS PARA ENTREGA

#### 1. Prints da Execução
Tire prints das seguintes telas:

**A. Durante a execução:**
- `terraform plan` (mostrando recursos a serem criados)
- `terraform apply` (mostrando criação dos recursos)
- Output final com as URLs

**B. No Console GCP:**
- Cloud Storage: Lista dos buckets criados
- BigQuery: Datasets e tabelas criadas
- Dataflow: Jobs configurados
- Dataproc: Cluster criado
- Vertex AI: Datasets e endpoints
- Composer: Ambiente Airflow
- DataPlex: Lake e zonas

#### 2. Arquivo de Outputs
```powershell
# Salvar outputs em arquivo
terraform output > evidencias_outputs.txt
```

### COMANDOS ÚTEIS

#### Verificar Status dos Recursos
```powershell
# Ver todos os recursos criados
terraform show

# Ver outputs específicos
terraform output storage_buckets
terraform output bigquery_datasets
terraform output quick_access_urls
```

#### Monitoramento
```powershell
# Status do cluster Dataproc
gcloud dataproc clusters list

# Status dos jobs Dataflow
gcloud dataflow jobs list

# Buckets criados
gcloud storage buckets list

# Datasets BigQuery
bq ls
```

### LIMPEZA (QUANDO NECESSÁRIO)

⚠️ **ATENÇÃO: Isso apagará TODOS os dados e recursos!**

```powershell
# Para destruir toda a infraestrutura
.\destroy.ps1

# Ou manualmente:
terraform destroy
```

### TROUBLESHOOTING

#### Problemas Comuns:

1. **Erro de permissões:**
   ```powershell
   # Verifique se tem as permissões necessárias
   gcloud projects get-iam-policy SEU-PROJECT-ID
   ```

2. **Erro de APIs não habilitadas:**
   ```powershell
   # Os scripts habilitam automaticamente, mas se der erro:
   gcloud services enable compute.googleapis.com
   gcloud services enable storage-api.googleapis.com
   gcloud services enable bigquery.googleapis.com
   ```

3. **Erro de quota:**
   - Verifique quotas no console GCP
   - Solicite aumento se necessário

4. **Erro de autenticação:**
   ```powershell
   # Re-autentique
   gcloud auth revoke --all
   gcloud auth login
   gcloud auth application-default login
   ```

### ESTRUTURA DE ENTREGA

Organize assim para entrega:
```
b2bshift-iac-entrega.zip
├── scripts/
│   ├── provider.tf
│   ├── variables.tf  
│   ├── storage.tf
│   ├── bigquery.tf
│   ├── dataflow.tf
│   ├── dataproc.tf
│   ├── vertex_ai.tf
│   ├── composer.tf
│   ├── dataplex.tf
│   ├── outputs.tf
│   └── README.md
├── evidencias/
│   ├── 01-terraform-plan.png
│   ├── 02-terraform-apply.png
│   ├── 03-bigquery-console.png
│   ├── 04-storage-console.png
│   ├── 05-dataflow-console.png
│   ├── 06-dataproc-console.png
│   ├── 07-vertex-ai-console.png
│   ├── 08-composer-console.png
│   ├── 09-dataplex-console.png
│   └── 10-outputs.txt
└── documentacao/
    ├── INSTRUCOES-EXECUCAO.md (este arquivo)
    ├── ARQUITETURA.md
    └── terraform.tfvars.example
```

### ESTIMATIVA DE TEMPO

- **Configuração inicial:** 15-30 minutos
- **Deploy da infraestrutura:** 30-60 minutos
- **Validação e testes:** 15-30 minutos
- **Documentação e prints:** 30 minutos
- **Total:** ~2-3 horas

### CUSTOS ESTIMADOS

| Serviço | Custo/Hora | Custo/Dia |
|---------|------------|-----------|
| Dataproc | $0.50 | $12 |
| Composer | $0.25 | $6 |
| BigQuery | $0.02 | $0.50 |
| Storage | $0.01 | $0.25 |
| **Total** | **~$0.78** | **~$19** |

⚠️ **Lembre-se de destruir os recursos após os testes para evitar custos!**

---

📞 **Precisa de ajuda?** 
- Consulte o README.md
- Verifique logs em caso de erro
- Use `terraform plan` antes de `apply`

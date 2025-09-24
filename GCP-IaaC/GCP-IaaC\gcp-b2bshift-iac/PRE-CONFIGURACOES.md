# ================================================
# PRÉ-CONFIGURAÇÕES NECESSÁRIAS - B2BSHIFT
# O que configurar ANTES de executar o Terraform
# ================================================

## 🚨 CONFIGURAÇÕES OBRIGATÓRIAS NO CONSOLE GCP

### 1. 🔐 AUTENTICAÇÃO E PERMISSÕES

#### A. Configure suas credenciais:
```powershell
# Login no GCP
gcloud auth login

# Configure o projeto
gcloud config set project b2bshift

# Configure credenciais para o Terraform
gcloud auth application-default login
```

#### B. Verifique se sua conta tem as seguintes permissões no projeto `b2bshift`:
- ✅ **Project Editor** OU **Owner**
- ✅ **Service Account Admin**
- ✅ **Security Admin** 
- ✅ **BigQuery Admin**
- ✅ **Storage Admin**
- ✅ **Compute Admin**

### 2. 🔧 BILLING E APIS

#### A. Habilite o Billing:
- Acesse: https://console.cloud.google.com/billing
- Associe uma conta de billing ao projeto `b2bshift`

#### B. As APIs serão habilitadas automaticamente pelo Terraform, mas você pode habilitar manualmente se preferir:
```powershell
gcloud services enable compute.googleapis.com
gcloud services enable storage-api.googleapis.com
gcloud services enable bigquery.googleapis.com
gcloud services enable dataflow.googleapis.com
gcloud services enable dataproc.googleapis.com
gcloud services enable composer.googleapis.com
gcloud services enable aiplatform.googleapis.com
gcloud services enable dataplex.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable iam.googleapis.com
```

## 🤖 SERVICE ACCOUNTS CRIADAS AUTOMATICAMENTE

O Terraform criará automaticamente os seguintes Service Accounts:

### 1. **Dataflow Service Account**
- **Nome**: `b2bshift-dataflow-sa@b2bshift.iam.gserviceaccount.com`
- **Permissões**: dataflow.worker, bigquery.dataEditor, storage.objectAdmin
- **Uso**: Jobs de ETL/ELT no Dataflow

### 2. **Dataproc Service Account**  
- **Nome**: `b2bshift-dataproc-sa@b2bshift.iam.gserviceaccount.com`
- **Permissões**: dataproc.worker, bigquery.dataEditor, storage.objectAdmin
- **Uso**: Cluster Spark/Hadoop

### 3. **Vertex AI Service Account**
- **Nome**: `b2bshift-vertex-ai-sa@b2bshift.iam.gserviceaccount.com`
- **Permissões**: aiplatform.user, bigquery.dataViewer, ml.admin
- **Uso**: Machine Learning pipelines

### 4. **Composer Service Account**
- **Nome**: `b2bshift-composer-sa@b2bshift.iam.gserviceaccount.com`
- **Permissões**: composer.worker, bigquery.dataEditor, dataflow.admin
- **Uso**: Orquestração Airflow

### 5. **DataPlex Service Account**
- **Nome**: `b2bshift-dataplex-sa@b2bshift.iam.gserviceaccount.com`
- **Permissões**: dataplex.editor, bigquery.dataViewer
- **Uso**: Governança de dados

## ⚠️ CONFIGURAÇÕES MANUAIS NECESSÁRIAS

### 1. 📧 EMAILS NAS TABELAS BIGQUERY
**⚠️ IMPORTANTE**: Você precisa alterar os emails nos arquivos Terraform:

No arquivo `bigquery.tf`, procure e substitua:

```hcl
# ENCONTRE estas linhas (aproximadamente linha 45-55):
access {
  role          = "OWNER"
  user_by_email = "data-team@b2bshift.com" # ⚠️ SUBSTITUA pelo seu email
}

access {
  role   = "READER"
  group_by_email = "analytics-team@b2bshift.com" # ⚠️ SUBSTITUA pelo grupo/email
}
```

**SUBSTITUA POR:**
```hcl
access {
  role          = "OWNER"
  user_by_email = "SEU-EMAIL@GMAIL.COM" # ⚠️ Coloque seu email real
}

# Remova ou substitua o group_by_email se não tiver um grupo
```

### 2. 📁 STORAGE BUCKETS - Scripts e Templates
Você precisará fazer upload de alguns arquivos posteriormente:

#### Bucket: `b2bshift-scripts-b2bshift-dev`
- 📂 `transforms/csv_transform.js` (função JavaScript para Dataflow)
- 📂 `dataplex/data_quality_check.py` (script Python qualidade)
- 📂 `dataplex/schema_discovery.py` (script descoberta)
- 📂 `python/customer_analytics.py` (PySpark analytics)
- 📂 `jars/b2bshift-etl.jar` (JAR Spark/Scala)

### 3. 🔧 CLOUD FUNCTION ZIP
Para o trigger de DAGs:
- 📂 `cloud-functions/dag-trigger.zip` (código da Cloud Function)

## 🚀 ORDEM DE EXECUÇÃO RECOMENDADA

### Passo 1: Configuração Inicial
```powershell
# 1. Autenticação
gcloud auth login
gcloud config set project b2bshift
gcloud auth application-default login

# 2. Verificar projeto ativo
gcloud config get-value project
# Deve retornar: b2bshift
```

### Passo 2: Terraform
```powershell
# 1. Inicializar
terraform init

# 2. Validar
terraform validate

# 3. Planejar
terraform plan

# 4. Aplicar (CUIDADO: Vai criar recursos que custam dinheiro!)
terraform apply
```

### Passo 3: Validação
```powershell
# Executar script de validação
.\validate.ps1
```

## 💰 CUSTOS ESTIMADOS

| Serviço | Custo/Dia (USD) | Observações |
|---------|-----------------|-------------|
| Dataproc Cluster | $8-12 | Cluster sempre ativo |
| Composer Environment | $6-8 | Ambiente gerenciado |
| BigQuery | $1-3 | Depende do volume |
| Cloud Storage | $0.50 | Buckets vazios inicialmente |
| Vertex AI | $2-5 | Notebooks + feature store |
| **TOTAL** | **$17-28/dia** | **≈ $500-850/mês** |

⚠️ **IMPORTANTE**: Execute `terraform destroy` após os testes para evitar custos!

## 🔍 VERIFICAÇÕES PRÉ-EXECUÇÃO

Antes de executar `terraform apply`, verifique:

- [ ] ✅ Projeto `b2bshift` existe e tem billing ativo
- [ ] ✅ Você tem permissões de Owner/Editor no projeto
- [ ] ✅ gcloud está autenticado e configurado
- [ ] ✅ Emails atualizados no `bigquery.tf`
- [ ] ✅ terraform.tfvars configurado
- [ ] ✅ Terraform instalado e funcionando

## 🆘 TROUBLESHOOTING

### Erro: "Permission denied"
```powershell
# Re-autentique
gcloud auth revoke --all
gcloud auth login
gcloud auth application-default login
```

### Erro: "Billing account not found"
- Acesse: https://console.cloud.google.com/billing
- Associe uma conta de billing ao projeto

### Erro: "API not enabled"
- O Terraform habilitará automaticamente
- Ou execute manualmente os comandos de habilitação acima

---

📞 **Dúvidas?** Consulte os logs detalhados e a documentação nos arquivos README.md

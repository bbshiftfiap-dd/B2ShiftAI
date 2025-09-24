# ================================================
# VALIDATE.PS1 - B2BSHIFT PLATFORM
# Script para validar a infraestrutura criada
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
Write-Host "🔍 B2BSHIFT PLATFORM VALIDATION" -ForegroundColor $BLUE
Write-Host "================================================" -ForegroundColor $BLUE
Write-Host ""

# Verificar se a infraestrutura foi deployada
if (!(Test-Path "terraform.tfstate")) {
    Write-Error-Custom "terraform.tfstate não encontrado. Execute o deploy primeiro."
    exit 1
}

# Obter outputs do Terraform
Write-Log "Coletando informações da infraestrutura..." -Color $BLUE
$outputs = terraform output -json | ConvertFrom-Json

if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Falha ao obter outputs do Terraform"
    exit 1
}

$projectId = $outputs.project_info.value.project_id
$region = $outputs.project_info.value.region

Write-Log "Projeto: $projectId" -Color $BLUE
Write-Log "Região: $region" -Color $BLUE
Write-Host ""

# Configurar projeto no gcloud
Write-Log "Configurando projeto no gcloud..." -Color $BLUE
gcloud config set project $projectId

# Validações

Write-Host "🗄️  VALIDANDO CLOUD STORAGE..." -ForegroundColor $YELLOW
Write-Host "----------------------------------------"

# Verificar buckets
$buckets = $outputs.storage_buckets.value
foreach ($bucket in $buckets.PSObject.Properties) {
    $bucketName = $bucket.Name
    $result = gcloud storage buckets describe "gs://$bucketName" --format="value(name)" 2>$null
    if ($result) {
        Write-Success "Bucket $bucketName existe"
    } else {
        Write-Error-Custom "Bucket $bucketName não encontrado"
    }
}

Write-Host ""
Write-Host "🏢 VALIDANDO BIGQUERY..." -ForegroundColor $YELLOW
Write-Host "----------------------------------------"

# Verificar datasets
$datasets = $outputs.bigquery_datasets.value
foreach ($dataset in $datasets.PSObject.Properties) {
    $datasetId = $dataset.Name
    $result = bq show --dataset=true "$projectId`:$datasetId" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Dataset $datasetId existe"
    } else {
        Write-Error-Custom "Dataset $datasetId não encontrado"
    }
}

# Verificar tabelas específicas
$tables = $outputs.bigquery_tables.value
foreach ($table in $tables.PSObject.Properties) {
    $tableName = $table.Name
    $tableInfo = $table.Value
    $fullTableId = "$projectId`:$($tableInfo.dataset).$($tableInfo.table_id)"
    $result = bq show $fullTableId 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Tabela $($tableInfo.table_id) existe"
    } else {
        Write-Error-Custom "Tabela $($tableInfo.table_id) não encontrada"
    }
}

Write-Host ""
Write-Host "⚡ VALIDANDO DATAFLOW..." -ForegroundColor $YELLOW
Write-Host "----------------------------------------"

# Verificar jobs do Dataflow
$dataflowJobs = $outputs.dataflow_jobs.value
foreach ($job in $dataflowJobs.PSObject.Properties) {
    $jobName = $job.Name
    $jobInfo = $job.Value
    $result = gcloud dataflow jobs list --filter="name:$($jobInfo.name)" --format="value(id)" --region=$region 2>$null
    if ($result) {
        Write-Success "Job Dataflow $jobName encontrado"
    } else {
        Write-Warning-Custom "Job Dataflow $jobName não está rodando (pode estar parado)"
    }
}

Write-Host ""
Write-Host "🔧 VALIDANDO DATAPROC..." -ForegroundColor $YELLOW
Write-Host "----------------------------------------"

# Verificar cluster Dataproc
$dataprocCluster = $outputs.dataproc_cluster.value
$result = gcloud dataproc clusters describe $dataprocCluster.name --region=$region --format="value(status.state)" 2>$null
if ($result) {
    Write-Success "Cluster Dataproc $($dataprocCluster.name) existe - Status: $result"
} else {
    Write-Error-Custom "Cluster Dataproc $($dataprocCluster.name) não encontrado"
}

Write-Host ""
Write-Host "🤖 VALIDANDO VERTEX AI..." -ForegroundColor $YELLOW
Write-Host "----------------------------------------"

# Verificar datasets do Vertex AI
$vertexDatasets = $outputs.vertex_ai_datasets.value
foreach ($dataset in $vertexDatasets.PSObject.Properties) {
    $datasetName = $dataset.Name
    $datasetInfo = $dataset.Value
    $result = gcloud ai datasets describe $datasetInfo.name --region=$region --format="value(name)" 2>$null
    if ($result) {
        Write-Success "Dataset Vertex AI $datasetName existe"
    } else {
        Write-Warning-Custom "Dataset Vertex AI $datasetName não encontrado"
    }
}

# Verificar endpoint
$vertexEndpoint = $outputs.vertex_ai_endpoint.value
$result = gcloud ai endpoints describe $vertexEndpoint.name --region=$region --format="value(name)" 2>$null
if ($result) {
    Write-Success "Endpoint Vertex AI existe"
} else {
    Write-Warning-Custom "Endpoint Vertex AI não encontrado"
}

# Verificar notebook
$notebook = $outputs.ml_notebook.value
$result = gcloud notebooks instances describe $notebook.name --location=$region --format="value(name)" 2>$null
if ($result) {
    Write-Success "Notebook Jupyter existe"
} else {
    Write-Warning-Custom "Notebook Jupyter não encontrado"
}

Write-Host ""
Write-Host "🔄 VALIDANDO COMPOSER (AIRFLOW)..." -ForegroundColor $YELLOW
Write-Host "----------------------------------------"

# Verificar ambiente Composer
$composerEnv = $outputs.composer_environment.value
$result = gcloud composer environments describe $composerEnv.name --location=$region --format="value(name)" 2>$null
if ($result) {
    Write-Success "Ambiente Composer existe"
    Write-Log "Airflow UI: $($composerEnv.airflow_uri)" -Color $BLUE
} else {
    Write-Error-Custom "Ambiente Composer não encontrado"
}

Write-Host ""
Write-Host "📊 VALIDANDO DATAPLEX..." -ForegroundColor $YELLOW
Write-Host "----------------------------------------"

# Verificar DataPlex Lake
$dataplexLake = $outputs.dataplex_lake.value
$result = gcloud dataplex lakes describe $dataplexLake.name --location=$region --format="value(name)" 2>$null
if ($result) {
    Write-Success "DataPlex Lake existe"
} else {
    Write-Error-Custom "DataPlex Lake não encontrado"
}

# Verificar zonas
$dataplexZones = $outputs.dataplex_zones.value
foreach ($zone in $dataplexZones.PSObject.Properties) {
    $zoneName = $zone.Name
    $zoneInfo = $zone.Value
    $result = gcloud dataplex zones describe $zoneInfo.name --location=$region --lake=$dataplexLake.name --format="value(name)" 2>$null
    if ($result) {
        Write-Success "DataPlex Zone $zoneName existe"
    } else {
        Write-Error-Custom "DataPlex Zone $zoneName não encontrada"
    }
}

Write-Host ""
Write-Host "👤 VALIDANDO SERVICE ACCOUNTS..." -ForegroundColor $YELLOW
Write-Host "----------------------------------------"

# Verificar service accounts
$serviceAccounts = $outputs.service_accounts.value
foreach ($sa in $serviceAccounts.PSObject.Properties) {
    $saName = $sa.Name
    $saEmail = $sa.Value
    $result = gcloud iam service-accounts describe $saEmail --format="value(email)" 2>$null
    if ($result) {
        Write-Success "Service Account $saName existe"
    } else {
        Write-Error-Custom "Service Account $saName não encontrado"
    }
}

# Resumo final
Write-Host ""
Write-Host "================================================" -ForegroundColor $GREEN
Write-Host "📋 RESUMO DA VALIDAÇÃO" -ForegroundColor $GREEN
Write-Host "================================================" -ForegroundColor $GREEN
Write-Host ""

Write-Host "🔗 LINKS DE ACESSO RÁPIDO:" -ForegroundColor $BLUE
$quickAccess = $outputs.quick_access_urls.value
foreach ($link in $quickAccess.PSObject.Properties) {
    $linkName = $link.Name
    $linkUrl = $link.Value
    if ($linkUrl) {
        Write-Host "- $linkName`: $linkUrl" -ForegroundColor $BLUE
    }
}

Write-Host ""
Write-Success "Validação concluída!"
Write-Host ""
Write-Host "📝 PRÓXIMOS PASSOS:"
Write-Host "1. Acesse o BigQuery e execute algumas queries de teste"
Write-Host "2. Verifique o Airflow UI e configure DAGs"
Write-Host "3. Teste o upload de dados no bucket landing-zone"
Write-Host "4. Configure modelos no Vertex AI"
Write-Host "5. Monitore os jobs no Dataflow Console"

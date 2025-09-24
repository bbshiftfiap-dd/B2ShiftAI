# ================================================
# TERRAFORM.TFVARS - B2BSHIFT PLATFORM
# Configurações reais do projeto
# ================================================

# === CONFIGURAÇÕES BÁSICAS ===
project_id     = "composite-rune-470721-n2"
project_number = "565386878204"
region         = "us-central1"
zone           = "us-central1-a"
environment    = "prod"

# === CONFIGURAÇÕES DE BUCKETS ===
buckets = [
  "landing-zone",
  "raw-zone",
  "trusted-zone", 
  "refined-zone",
  "archive-zone"
]

# === CONFIGURAÇÕES DE DATASETS ===
dataset_names = [
  "b2bshift_raw",
  "b2bshift_trusted",
  "b2bshift_refined", 
  "b2bshift_analytics"
]

# === CONFIGURAÇÕES DE MÁQUINAS ===
machine_types = {
  dataproc_master = "n1-standard-4"
  dataproc_worker = "n1-standard-2" 
  composer_node   = "n1-standard-2"
}

# === LABELS PADRÃO ===
labels = {
  project     = "b2bshift"
  team        = "data-engineering"
  managed-by  = "terraform"
  environment = "prod"
  cost-center = "data-platform"
}

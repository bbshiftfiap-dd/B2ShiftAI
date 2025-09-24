# ================================================
# VARIABLES.TF - B2BSHIFT PLATFORM
# Definição de todas as variáveis globais do projeto
# ================================================

variable "project_id" {
  description = "ID do projeto GCP para B2BShift"
  type        = string
  default     = "composite-rune-470721-n2"
}

variable "project_number" {
  description = "Número do projeto GCP para B2BShift"
  type        = string
  default     = "565386878204"
}

variable "region" {
  description = "Região principal do GCP"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zona específica do GCP"
  type        = string
  default     = "us-central1-a"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "buckets" {
  description = "Buckets para as camadas do Data Lake"
  type        = list(string)
  default     = [
    "landing-zone",
    "raw-zone", 
    "trusted-zone",
    "refined-zone",
    "archive-zone"
  ]
}

variable "dataset_names" {
  description = "Datasets do BigQuery"
  type        = list(string)
  default     = [
    "b2bshift_raw",
    "b2bshift_trusted", 
    "b2bshift_refined",
    "b2bshift_analytics"
  ]
}

variable "machine_types" {
  description = "Tipos de máquina para diferentes componentes"
  type = object({
    dataproc_master = string
    dataproc_worker = string
    composer_node   = string
  })
  default = {
    dataproc_master = "n1-standard-2"
    dataproc_worker = "n1-standard-2"
    composer_node   = "n1-standard-2"
  }
}

variable "labels" {
  description = "Labels padrão para recursos"
  type        = map(string)
  default = {
    project     = "b2bshift"
    team        = "data-engineering"
    managed-by  = "terraform"
  }
}

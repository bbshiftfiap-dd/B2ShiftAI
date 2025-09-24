# ================================================
# PROVIDER.TF - B2BSHIFT PLATFORM
# Configuração do provider GCP e recursos básicos
# ================================================

terraform {
  required_version = ">= 1.3.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }

  # Configuração do backend remoto (opcional)
  # backend "gcs" {
  #   bucket = "b2bshift-terraform-state"
  #   prefix = "terraform/state"
  # }
}

# Provider principal do GCP
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Provider beta para recursos em preview
provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Habilitação de APIs necessárias
resource "google_project_service" "required_apis" {
  for_each = toset([
    "storage-api.googleapis.com",
    "bigquery.googleapis.com", 
    "dataflow.googleapis.com",
    "dataproc.googleapis.com",
    "composer.googleapis.com",
    "aiplatform.googleapis.com",
    "dataplex.googleapis.com",
    "cloudbuild.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "notebooks.googleapis.com"
  ])

  project = var.project_id
  service = each.value

  disable_dependent_services = true
  disable_on_destroy         = false
}

# ================================================
# STORAGE.TF - B2BSHIFT PLATFORM
# Cloud Storage buckets para Data Lake
# Landing > Raw > Trusted > Refined > Archive
# ================================================

# Bucket para Landing Zone (dados brutos recém-chegados)
resource "google_storage_bucket" "data_lake_buckets" {
  for_each = toset(var.buckets)

  name          = "${each.key}-${var.project_id}-${var.environment}"
  location      = var.region
  force_destroy = true

  # Configurações de segurança
  uniform_bucket_level_access = true
  
  # Versionamento para auditoria
  versioning {
    enabled = true
  }

  # Lifecycle para otimizar custos
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type          = "SetStorageClass"
      storage_class = "ARCHIVE"
    }
  }

  labels = merge(var.labels, {
    zone = each.key
  })
}

# Bucket específico para scripts e templates
resource "google_storage_bucket" "scripts_bucket" {
  name          = "b2bshift-scripts-${var.project_id}-${var.environment}"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
  
  labels = merge(var.labels, {
    purpose = "scripts-templates"
  })
}

# Buckets para Dataflow são definidos em dataflow.tf
# Para evitar duplicação, removido daqui

# IAM para buckets - Service Account do Dataflow
resource "google_storage_bucket_iam_member" "dataflow_bucket_access" {
  for_each = google_storage_bucket.data_lake_buckets

  bucket = each.value.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.dataflow_sa.email}"

  depends_on = [google_service_account.dataflow_sa]
}

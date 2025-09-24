# ================================================
# DATAPLEX.TF - B2BSHIFT PLATFORM
# Governança e descoberta de dados com DataPlex
# ================================================

# Lake principal para governança de dados
resource "google_dataplex_lake" "b2bshift_lake" {
  name         = "b2bshift-data-lake-${var.environment}"
  location     = var.region
  display_name = "B2BShift Data Governance Lake"
  description  = "Lake principal para governança e catalogação de dados B2BShift"

  labels = merge(var.labels, {
    governance = "dataplex"
  })
}

# Zone para dados brutos (Raw)
resource "google_dataplex_zone" "raw_zone" {
  name         = "raw-data-zone"
  location     = var.region
  lake         = google_dataplex_lake.b2bshift_lake.name
  display_name = "Raw Data Zone"
  description  = "Zona para dados brutos não processados"

  type = "RAW"

  discovery_spec {
    enabled = true
    schedule = "0 2 * * *"  # Descoberta diária às 2:00 AM

    csv_options {
      header_rows      = 1
      delimiter        = ","
      encoding         = "UTF-8"
      disable_type_inference = false
    }

    json_options {
      encoding         = "UTF-8"
      disable_type_inference = false
    }
  }

  resource_spec {
    location_type = "SINGLE_REGION"
  }

  labels = var.labels
}

# Zone para dados curados (Curated)
resource "google_dataplex_zone" "curated_zone" {
  name         = "curated-data-zone"
  location     = var.region
  lake         = google_dataplex_lake.b2bshift_lake.name
  display_name = "Curated Data Zone"
  description  = "Zona para dados curados e processados"

  type = "CURATED"

  discovery_spec {
    enabled = true
    schedule = "0 3 * * *"  # Descoberta diária às 3:00 AM
  }

  resource_spec {
    location_type = "SINGLE_REGION"
  }

  labels = var.labels
}

# Asset para buckets de Storage
resource "google_dataplex_asset" "storage_assets" {
  for_each = toset([
    "raw-zone",
    "trusted-zone", 
    "refined-zone"
  ])

  name         = "${each.key}-storage-asset"
  location     = var.region
  lake         = google_dataplex_lake.b2bshift_lake.name
  dataplex_zone = each.key == "raw-zone" ? google_dataplex_zone.raw_zone.name : google_dataplex_zone.curated_zone.name
  display_name = "${title(each.key)} Storage Asset"
  description  = "Asset para bucket ${each.key}"

  resource_spec {
    name = "projects/${var.project_id}/buckets/${each.key}-${var.project_id}-${var.environment}"
    type = "STORAGE_BUCKET"
  }

  discovery_spec {
    enabled = true
    schedule = "0 4 * * *"  # Descoberta às 4:00 AM

    csv_options {
      header_rows      = 1
      delimiter        = ","
      encoding         = "UTF-8"
      disable_type_inference = false
    }
  }

  labels = merge(var.labels, {
    asset-type = "storage"
    zone       = each.key
  })

  depends_on = [
    google_storage_bucket.data_lake_buckets,
    google_dataplex_zone.raw_zone,
    google_dataplex_zone.curated_zone
  ]
}

# Asset para datasets do BigQuery
resource "google_dataplex_asset" "bigquery_assets" {
  for_each = toset([
    "b2bshift_raw",
    "b2bshift_trusted",
    "b2bshift_analytics"
  ])

  name         = "${replace(each.key, "_", "-")}-bq-asset"
  location     = var.region
  lake         = google_dataplex_lake.b2bshift_lake.name
  dataplex_zone = each.key == "b2bshift_raw" ? google_dataplex_zone.raw_zone.name : google_dataplex_zone.curated_zone.name
  display_name = "${title(replace(each.key, "_", " "))} BigQuery Asset"
  description  = "Asset para dataset BigQuery ${each.key}"

  resource_spec {
    name = "projects/${var.project_id}/datasets/${each.key}"
    type = "BIGQUERY_DATASET"
  }

  discovery_spec {
    enabled = true
    schedule = "0 5 * * *"  # Descoberta às 5:00 AM
  }

  labels = merge(var.labels, {
    asset-type = "bigquery"
    dataset    = each.key
  })

  depends_on = [
    google_bigquery_dataset.datasets,
    google_dataplex_zone.raw_zone,
    google_dataplex_zone.curated_zone
  ]
}

# Task para qualidade de dados
resource "google_dataplex_task" "data_quality_check" {
  task_id      = "data-quality-check"
  location     = var.region
  lake         = google_dataplex_lake.b2bshift_lake.name
  display_name = "Data Quality Check Task"
  description  = "Task para verificação de qualidade dos dados"

  trigger_spec {
    type = "RECURRING"
    schedule = "0 6 * * *"  # Execução às 6:00 AM
  }

  execution_spec {
    service_account = google_service_account.dataplex_sa.email
    max_job_execution_lifetime = "3600s"
  }

  spark {
    python_script_file = "gs://b2bshift-scripts-${var.project_id}-${var.environment}/dataplex/data_quality_check.py"
    
    archive_uris = [
      "gs://b2bshift-scripts-${var.project_id}-${var.environment}/dataplex/quality_utils.zip"
    ]
  }

  labels = merge(var.labels, {
    task-type = "data-quality"
  })

  depends_on = [google_service_account.dataplex_sa]
}

# Task para descoberta de esquemas
resource "google_dataplex_task" "schema_discovery" {
  task_id      = "schema-discovery"
  location     = var.region
  lake         = google_dataplex_lake.b2bshift_lake.name
  display_name = "Schema Discovery Task"
  description  = "Task para descoberta automática de esquemas"

  trigger_spec {
    type = "ON_DEMAND"
  }

  execution_spec {
    service_account = google_service_account.dataplex_sa.email
    max_job_execution_lifetime = "1800s"
  }

  spark {
    python_script_file = "gs://b2bshift-scripts-${var.project_id}-${var.environment}/dataplex/schema_discovery.py"
  }

  labels = merge(var.labels, {
    task-type = "schema-discovery"
  })
}

# Service Account para DataPlex
resource "google_service_account" "dataplex_sa" {
  account_id   = "b2bshift-dataplex-sa"
  display_name = "B2BShift DataPlex Service Account"
  description  = "Service Account para operações do DataPlex"
}

# IAM roles para DataPlex
resource "google_project_iam_member" "dataplex_roles" {
  for_each = toset([
    "roles/dataplex.editor",
    "roles/bigquery.dataViewer", 
    "roles/storage.objectViewer",
    "roles/dataproc.editor",
    "roles/logging.logWriter"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.dataplex_sa.email}"
}

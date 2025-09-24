# ================================================
# COMPOSER.TF - B2BSHIFT PLATFORM
# Orquestração de workflows com Cloud Composer (Airflow)
# ================================================

# Ambiente do Cloud Composer para orquestração
resource "google_composer_environment" "b2bshift_airflow" {
  name   = "b2bshift-composer-${var.environment}"
  region = var.region

  config {
    # Service account obrigatório no Composer 3
    node_config {
      service_account = google_service_account.composer_sa.email
    }

    # Configuração do software
    software_config {
      image_version = "composer-3-airflow-2"
      
      # Variáveis de ambiente (apenas as permitidas)
      env_variables = {
        ENVIRONMENT    = var.environment
        BQ_DATASET_RAW = "b2bshift_raw"
        BQ_DATASET_TRUSTED = "b2bshift_trusted"
        BQ_DATASET_ANALYTICS = "b2bshift_analytics"
        LANDING_BUCKET = "landing-zone-${var.project_id}-${var.environment}"
        RAW_BUCKET     = "raw-zone-${var.project_id}-${var.environment}"
      }

      # Configurações básicas do Airflow
      airflow_config_overrides = {
        "core-dags_are_paused_at_creation" = "True"
        "core-max_active_runs_per_dag"     = "1"
        "webserver-expose_config"          = "True"
      }
    }
  }

  labels = merge(var.labels, {
    orchestration = "airflow"
  })

  depends_on = [google_service_account.composer_sa]
}

# Service Account para Composer
resource "google_service_account" "composer_sa" {
  account_id   = "b2bshift-composer-sa"
  display_name = "B2BShift Composer Service Account"
  description  = "Service Account para Cloud Composer/Airflow"
}

# IAM roles para Composer
resource "google_project_iam_member" "composer_roles" {
  for_each = toset([
    "roles/composer.worker",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/storage.objectAdmin",
    "roles/dataflow.admin",
    "roles/dataproc.editor",
    "roles/aiplatform.user",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.composer_sa.email}"
}

# Cloud Function para trigger de DAGs (comentado para simplificar deploy inicial)
# resource "google_cloudfunctions_function" "dag_trigger" {
#   name        = "b2bshift-dag-trigger-${var.environment}"
#   runtime     = "python39"
#   region      = var.region
#   # ... configurações ...
# }

# Scheduler para execução automática (comentado para simplificar deploy inicial)
# resource "google_cloud_scheduler_job" "daily_pipeline" {
#   name      = "b2bshift-daily-pipeline-${var.environment}"
#   region    = var.region
#   schedule  = "0 2 * * *"
#   # ... configurações ...
# }

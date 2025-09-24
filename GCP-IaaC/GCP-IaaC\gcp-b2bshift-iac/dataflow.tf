# ================================================
# DATAFLOW.TF - B2BSHIFT PLATFORM
# Jobs de ETL/ELT para processamento de dados
# ================================================

# Service Account para Dataflow
resource "google_service_account" "dataflow_sa" {
  account_id   = "b2bshift-dataflow-sa"
  display_name = "B2BShift Dataflow Service Account"
  description  = "Service Account para jobs Dataflow"
}

# IAM roles para o Dataflow SA
resource "google_project_iam_member" "dataflow_worker" {
  project = var.project_id
  role    = "roles/dataflow.worker"
  member  = "serviceAccount:${google_service_account.dataflow_sa.email}"
}

resource "google_project_iam_member" "dataflow_developer" {
  project = var.project_id
  role    = "roles/dataflow.developer"
  member  = "serviceAccount:${google_service_account.dataflow_sa.email}"
}

# Pub/Sub Topic para streaming data
resource "google_pubsub_topic" "data_ingestion" {
  name = "b2bshift-data-ingestion"
  
  labels = {
    environment = var.environment
    project     = "b2bshift"
  }
}

# Pub/Sub Subscription
resource "google_pubsub_subscription" "data_ingestion_sub" {
  name  = "b2bshift-data-ingestion-sub"
  topic = google_pubsub_topic.data_ingestion.name

  # Configurações de retry
  retry_policy {
    minimum_backoff = "10s"
    maximum_backoff = "600s"
  }

  # Dead letter policy
  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.dead_letter.id
    max_delivery_attempts = 5
  }
}

# Dead Letter Topic
resource "google_pubsub_topic" "dead_letter" {
  name = "b2bshift-dead-letter"
}

# Template bucket for Dataflow templates
resource "google_storage_bucket" "dataflow_templates" {
  name          = "dataflow-templates-${var.project_id}"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
  
  labels = {
    environment = var.environment
    purpose     = "dataflow-templates"
  }
}

# Staging bucket for Dataflow
resource "google_storage_bucket" "dataflow_staging" {
  name          = "dataflow-staging-${var.project_id}"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
  
  labels = {
    environment = var.environment
    purpose     = "dataflow-staging"
  }
}

# Temporary bucket for Dataflow
resource "google_storage_bucket" "dataflow_temp" {
  name          = "dataflow-temp-${var.project_id}"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true
  
  # Auto-delete temp files after 1 day
  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "Delete"
    }
  }
  
  labels = {
    environment = var.environment
    purpose     = "dataflow-temp"
  }
}

# Job 1: Batch Processing - CSV to BigQuery (usando template padrão)
resource "google_dataflow_job" "csv_to_bigquery" {
  name              = "b2bshift-csv-to-bigquery"
  template_gcs_path = "gs://dataflow-templates/latest/GCS_Text_to_BigQuery"
  temp_gcs_location = "gs://${google_storage_bucket.dataflow_temp.name}/temp/"
  
  parameters = {
    inputFilePattern     = "gs://${google_storage_bucket.data_lake_buckets["raw-zone"].name}/*.csv"
    outputTable          = "${var.project_id}:${google_bigquery_dataset.datasets["b2bshift_raw"].dataset_id}.sales_proposals"
    bigQueryLoadingTemporaryDirectory = "gs://${google_storage_bucket.dataflow_temp.name}/bq-loading/"
    javascriptTextTransformGcsPath = "gs://${google_storage_bucket.dataflow_templates.name}/transform.js"
    JSONPath             = "gs://${google_storage_bucket.dataflow_templates.name}/schema.json"
  }

  zone                = var.zone
  service_account_email = google_service_account.dataflow_sa.email
  
  labels = {
    environment = var.environment
    job_type    = "batch"
  }

  depends_on = [
    google_bigquery_dataset.datasets,
    google_storage_bucket.data_lake_buckets
  ]
}

# Job 2: Streaming Processing - Pub/Sub to BigQuery
resource "google_dataflow_job" "streaming_processor" {
  name              = "b2bshift-streaming-processor"
  template_gcs_path = "gs://dataflow-templates/latest/PubSub_to_BigQuery"
  temp_gcs_location = "gs://${google_storage_bucket.dataflow_temp.name}/temp/"
  
  parameters = {
    inputTopic      = google_pubsub_topic.data_ingestion.id
    outputTableSpec = "${var.project_id}:${google_bigquery_dataset.datasets["b2bshift_raw"].dataset_id}.streaming_data"
  }

  zone                = var.zone
  service_account_email = google_service_account.dataflow_sa.email
  
  labels = {
    environment = var.environment
    job_type    = "streaming"
  }
}

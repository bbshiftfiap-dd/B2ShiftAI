# ================================================
# VERTEX_AI.TF - B2BSHIFT PLATFORM
# Machine Learning e AI com Vertex AI
# ================================================

# Dataset para treinamento de modelos
resource "google_vertex_ai_dataset" "customer_segmentation" {
  display_name          = "b2bshift-customer-segmentation"
  metadata_schema_uri   = "gs://google-cloud-aiplatform/schema/dataset/metadata/tabular_1.0.0.yaml"
  region               = var.region

  labels = merge(var.labels, {
    use-case = "customer-segmentation"
  })
}

# Dataset para previsão de churn
resource "google_vertex_ai_dataset" "churn_prediction" {
  display_name          = "b2bshift-churn-prediction"
  metadata_schema_uri   = "gs://google-cloud-aiplatform/schema/dataset/metadata/tabular_1.0.0.yaml"
  region               = var.region

  labels = merge(var.labels, {
    use-case = "churn-prediction"
  })
}

# Endpoint para deploy de modelos
resource "google_vertex_ai_endpoint" "customer_insights" {
  name         = "b2bshift-customer-insights-endpoint"
  display_name = "B2BShift Customer Insights Endpoint"
  description  = "Endpoint para modelos de insights de clientes"
  location     = var.region

  labels = merge(var.labels, {
    endpoint-type = "customer-insights"
  })
}

# Workbench Instance - TEMPORARIAMENTE COMENTADO devido a problemas de imagem
# Será criado manualmente após o deploy principal ou com imagem diferente
# 
# resource "google_workbench_instance" "ml_workbench" {
#   name     = "b2bshift-ml-workbench-${var.environment}"
#   location = var.zone
#
#   gce_setup {
#     machine_type = "n1-standard-2"
#     
#     vm_image {
#       project      = "deeplearning-platform-release"
#       family       = "tf-latest-cpu"
#     }
#     
#     boot_disk {
#       disk_size_gb = 100
#       disk_type    = "PD_SSD"
#     }
#     
#     data_disks {
#       disk_size_gb = 200
#       disk_type    = "PD_STANDARD"
#     }
#     
#     service_accounts {
#       email  = google_service_account.vertex_ai_sa.email
#     }
#     
#     metadata = {
#       environment = var.environment
#       purpose     = "ml-development"
#     }
#   }
#
#   labels = merge(var.labels, {
#     purpose = "ml-development"
#   })
#
#   depends_on = [
#     google_service_account.vertex_ai_sa,
#     google_project_service.required_apis
#   ]
# }

# Service Account para Vertex AI
resource "google_service_account" "vertex_ai_sa" {
  account_id   = "b2bshift-vertex-ai-sa"
  display_name = "B2BShift Vertex AI Service Account"
  description  = "Service Account para operações do Vertex AI"
}

# IAM roles para Vertex AI
resource "google_project_iam_member" "vertex_ai_roles" {
  for_each = toset([
    "roles/aiplatform.user",
    "roles/bigquery.dataViewer",
    "roles/storage.objectViewer",
    "roles/notebooks.admin",
    "roles/ml.admin"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.vertex_ai_sa.email}"
}

# Feature Store para ML features
resource "google_vertex_ai_featurestore" "customer_features" {
  name     = "customer_features_store"
  region   = var.region
  
  online_serving_config {
    fixed_node_count = 1
  }

  labels = merge(var.labels, {
    store-type = "customer-features"
  })
}

# Entity Type para features de clientes
resource "google_vertex_ai_featurestore_entitytype" "customer_entity" {
  name         = "customer"
  featurestore = google_vertex_ai_featurestore.customer_features.id
  
  monitoring_config {
    snapshot_analysis {
      disabled = false
    }
  }

  labels = var.labels
}

# Features específicas
resource "google_vertex_ai_featurestore_entitytype_feature" "customer_features" {
  for_each = toset([
    "total_transactions",
    "avg_transaction_value",
    "days_since_last_transaction",
    "customer_lifetime_value",
    "churn_probability"
  ])

  name       = each.value
  entitytype = google_vertex_ai_featurestore_entitytype.customer_entity.id
  
  value_type = "DOUBLE"

  labels = var.labels
}

# Placeholders para pipelines futuras - comentados para evitar erros
# Nota: Estes recursos serão implementados quando disponíveis na versão do provider

# Training Pipeline placeholder
# resource "google_vertex_ai_training_pipeline" "customer_segmentation_pipeline" {
#   display_name = "customer-segmentation-training"
#   location     = var.region
#   labels = merge(var.labels, {
#     model-type = "customer-segmentation"
#   })
# }

# Batch Prediction Job placeholder  
# resource "google_vertex_ai_batch_prediction_job" "customer_insights_batch" {
#   display_name = "customer-insights-batch-prediction"
#   location     = var.region
#   labels = merge(var.labels, {
#     job-type = "batch-prediction"
#   })
# }

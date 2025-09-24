# ================================================
# OUTPUTS.TF - B2BSHIFT PLATFORM
# Outputs importantes dos recursos criados
# ================================================

# === STORAGE OUTPUTS ===
output "storage_buckets" {
  description = "URLs dos buckets do Data Lake"
  value = {
    for bucket in google_storage_bucket.data_lake_buckets :
    bucket.name => bucket.url
  }
}

output "scripts_bucket" {
  description = "URL do bucket de scripts"
  value       = google_storage_bucket.scripts_bucket.url
}

output "dataflow_temp_bucket" {
  description = "URL do bucket temporário do Dataflow"
  value       = google_storage_bucket.dataflow_temp.url
}

# === BIGQUERY OUTPUTS ===
output "bigquery_datasets" {
  description = "IDs dos datasets criados no BigQuery"
  value = {
    for dataset in google_bigquery_dataset.datasets :
    dataset.dataset_id => {
      id       = dataset.id
      location = dataset.location
      self_link = dataset.self_link
    }
  }
}

output "bigquery_tables" {
  description = "Informações das tabelas criadas"
  value = {
    sales_proposals = {
      dataset   = google_bigquery_dataset.datasets["b2bshift_raw"].dataset_id
      table_id  = "sales_proposals"
      full_id   = "${var.project_id}.${google_bigquery_dataset.datasets["b2bshift_raw"].dataset_id}.sales_proposals"
    }
    customer_master = {
      dataset   = google_bigquery_dataset.datasets["b2bshift_raw"].dataset_id
      table_id  = "customer_master"
      full_id   = "${var.project_id}.${google_bigquery_dataset.datasets["b2bshift_raw"].dataset_id}.customer_master"
    }
    dim_customer = {
      dataset   = google_bigquery_dataset.datasets["b2bshift_refined"].dataset_id
      table_id  = "dim_customer"
      full_id   = "${var.project_id}.${google_bigquery_dataset.datasets["b2bshift_refined"].dataset_id}.dim_customer"
    }
  }
}

# === DATAFLOW OUTPUTS ===
output "dataflow_jobs" {
  description = "Informações dos jobs do Dataflow"
  value = {
    csv_to_bigquery = {
      name         = google_dataflow_job.csv_to_bigquery.name
      job_id       = google_dataflow_job.csv_to_bigquery.job_id
      state        = google_dataflow_job.csv_to_bigquery.state
    }
    streaming_processor = {
      name         = google_dataflow_job.streaming_processor.name
      job_id       = google_dataflow_job.streaming_processor.job_id
      state        = google_dataflow_job.streaming_processor.state
    }
  }
}

output "pubsub_topics" {
  description = "Informações dos tópicos Pub/Sub"
  value = {
    data_ingestion = {
      name = google_pubsub_topic.data_ingestion.name
      id   = google_pubsub_topic.data_ingestion.id
    }
    dead_letter = {
      name = google_pubsub_topic.dead_letter.name
      id   = google_pubsub_topic.dead_letter.id
    }
  }
}

# === DATAPROC OUTPUTS ===
output "dataproc_cluster" {
  description = "Informações do cluster Dataproc"
  value = {
    name           = google_dataproc_cluster.b2bshift_cluster.name
    region         = google_dataproc_cluster.b2bshift_cluster.region
    master_instance_names = google_dataproc_cluster.b2bshift_cluster.cluster_config[0].master_config[0].instance_names
    worker_instance_names = google_dataproc_cluster.b2bshift_cluster.cluster_config[0].worker_config[0].instance_names
  }
}

output "dataproc_autoscaling_policy" {
  description = "Política de autoscaling do Dataproc"
  value = {
    id   = google_dataproc_autoscaling_policy.b2bshift_autoscaling.id
    name = google_dataproc_autoscaling_policy.b2bshift_autoscaling.name
  }
}

# === VERTEX AI OUTPUTS ===
output "vertex_ai_datasets" {
  description = "Datasets do Vertex AI"
  value = {
    customer_segmentation = {
      id   = google_vertex_ai_dataset.customer_segmentation.id
      name = google_vertex_ai_dataset.customer_segmentation.name
    }
    churn_prediction = {
      id   = google_vertex_ai_dataset.churn_prediction.id
      name = google_vertex_ai_dataset.churn_prediction.name
    }
  }
}

output "vertex_ai_endpoint" {
  description = "Endpoint do Vertex AI"
  value = {
    id   = google_vertex_ai_endpoint.customer_insights.id
    name = google_vertex_ai_endpoint.customer_insights.name
  }
}

# output "ml_notebook" {
#   description = "Instância do Jupyter Notebook"
#   value = {
#     name      = google_workbench_instance.ml_workbench.name
#     location  = google_workbench_instance.ml_workbench.location
#   }
# }

output "featurestore" {
  description = "Feature Store do Vertex AI"
  value = {
    id   = google_vertex_ai_featurestore.customer_features.id
    name = google_vertex_ai_featurestore.customer_features.name
  }
}

# === COMPOSER OUTPUTS ===
output "composer_environment" {
  description = "Ambiente do Cloud Composer"
  value = {
    name       = google_composer_environment.b2bshift_airflow.name
    airflow_uri = google_composer_environment.b2bshift_airflow.config[0].airflow_uri
    gcs_bucket  = google_composer_environment.b2bshift_airflow.config[0].dag_gcs_prefix
  }
}

# Cloud Function output - comentado pois o recurso foi comentado temporariamente
# output "dag_trigger_function" {
#   description = "Cloud Function para trigger de DAGs"
#   value = {
#     name         = google_cloudfunctions_function.dag_trigger.name
#     https_trigger_url = google_cloudfunctions_function.dag_trigger.https_trigger_url
#   }
# }

# === DATAPLEX OUTPUTS ===
output "dataplex_lake" {
  description = "DataPlex Lake principal"
  value = {
    id   = google_dataplex_lake.b2bshift_lake.id
    name = google_dataplex_lake.b2bshift_lake.name
    uid  = google_dataplex_lake.b2bshift_lake.uid
  }
}

output "dataplex_zones" {
  description = "Zonas do DataPlex"
  value = {
    raw_zone = {
      id   = google_dataplex_zone.raw_zone.id
      name = google_dataplex_zone.raw_zone.name
    }
    curated_zone = {
      id   = google_dataplex_zone.curated_zone.id
      name = google_dataplex_zone.curated_zone.name
    }
  }
}

# === SERVICE ACCOUNTS ===
output "service_accounts" {
  description = "Service Accounts criados"
  value = {
    dataflow  = google_service_account.dataflow_sa.email
    dataproc  = google_service_account.dataproc_sa.email
    vertex_ai = google_service_account.vertex_ai_sa.email
    composer  = google_service_account.composer_sa.email
    dataplex  = google_service_account.dataplex_sa.email
  }
}

# === PROJECT INFO ===
output "project_info" {
  description = "Informações do projeto"
  value = {
    project_id     = var.project_id
    project_number = var.project_number
    region         = var.region
    zone           = var.zone
    environment    = var.environment
  }
}

# === APIS ENABLED ===
output "enabled_apis" {
  description = "APIs habilitadas no projeto"
  value = [for api in google_project_service.required_apis : api.service]
}

# === QUICK ACCESS URLS ===
output "quick_access_urls" {
  description = "URLs de acesso rápido aos serviços"
  value = {
    bigquery_console    = "https://console.cloud.google.com/bigquery?project=${var.project_id}"
    storage_console     = "https://console.cloud.google.com/storage/browser?project=${var.project_id}"
    dataflow_console    = "https://console.cloud.google.com/dataflow/jobs?project=${var.project_id}"
    dataproc_console    = "https://console.cloud.google.com/dataproc/clusters?project=${var.project_id}"
    vertex_ai_console   = "https://console.cloud.google.com/vertex-ai?project=${var.project_id}"
    composer_console    = "https://console.cloud.google.com/composer/environments?project=${var.project_id}"
    dataplex_console    = "https://console.cloud.google.com/dataplex?project=${var.project_id}"
    airflow_ui          = try(google_composer_environment.b2bshift_airflow.config[0].airflow_uri, "")
    jupyter_notebook    = "Workbench instance temporarily disabled - create manually in console"
  }
}

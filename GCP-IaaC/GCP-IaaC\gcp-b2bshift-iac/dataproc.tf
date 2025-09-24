# ================================================
# DATAPROC.TF - B2BSHIFT PLATFORM
# Cluster Hadoop/Spark para processamento big data
# ================================================

# Service Account para Dataproc
resource "google_service_account" "dataproc_sa" {
  account_id   = "b2bshift-dataproc-sa"
  display_name = "B2BShift Dataproc Service Account"
  description  = "Service Account para cluster Dataproc no projeto B2BShift"
}

# IAM roles para o Service Account do Dataproc
resource "google_project_iam_member" "dataproc_roles" {
  for_each = toset([
    "roles/dataproc.worker",
    "roles/bigquery.dataEditor",
    "roles/storage.objectAdmin",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.dataproc_sa.email}"
}

# Política de Auto-scaling
resource "google_dataproc_autoscaling_policy" "b2bshift_autoscaling" {
  policy_id = "b2bshift-autoscaling-policy"
  location  = var.region

  worker_config {
    max_instances = 10
    min_instances = 2
    weight        = 1
  }

  secondary_worker_config {
    max_instances = 5
    min_instances = 0
    weight        = 1
  }

  basic_algorithm {
    cooldown_period = "120s"
    yarn_config {
      graceful_decommission_timeout = "300s"
      scale_up_factor               = 0.05
      scale_down_factor             = 1.0
    }
  }
}

# Cluster Dataproc principal
resource "google_dataproc_cluster" "b2bshift_cluster" {
  name   = "b2bshift-spark-cluster-${var.environment}"
  region = var.region

  cluster_config {
    # Configuração do Master Node (reduzido para quota)
    master_config {
      num_instances = 1
      machine_type  = "n1-standard-2"  # Reduzido para economizar quota
      disk_config {
        boot_disk_type    = "pd-standard"  # Mudado para standard para economizar
        boot_disk_size_gb = 30
        num_local_ssds    = 0  # Removido SSD para economizar quota
      }
    }

    # Configuração dos Worker Nodes (reduzido para quota)
    worker_config {
      num_instances = 2  # Reduzido de 3 para 2
      machine_type  = "n1-standard-2"  # Reduzido para economizar quota
      disk_config {
        boot_disk_type    = "pd-standard"
        boot_disk_size_gb = 30
        num_local_ssds    = 0  # Removido SSD para economizar quota
      }
    }

    # Configuração dos Preemptible Workers removida temporariamente
    # preemptible_worker_config {
    #   num_instances = 2
    # }

    # Configurações de software
    software_config {
      image_version = "2.1-debian11"
      override_properties = {
        "dataproc:dataproc.allow.zero.workers" = "true"
        "spark:spark.sql.adaptive.enabled"     = "true"
        "spark:spark.sql.adaptive.coalescePartitions.enabled" = "true"
      }
      
      # Componentes opcionais
      optional_components = ["JUPYTER"]  # Removido ZEPPELIN para economizar recursos
    }

    # Configurações de inicialização removidas temporariamente
    # initialization_action {
    #   script      = "gs://b2bshift-scripts-${var.project_id}-${var.environment}/init/install-dependencies.sh"
    #   timeout_sec = 500
    # }

    # Configurações de rede e segurança
    gce_cluster_config {
      network         = "default"
      zone           = var.zone
      service_account = google_service_account.dataproc_sa.email
      service_account_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
      
      # Tags para firewall
      tags = ["dataproc", "b2bshift", var.environment]
    }

    # Auto-scaling policy
    autoscaling_config {
      policy_uri = google_dataproc_autoscaling_policy.b2bshift_autoscaling.name
    }
  }

  labels = merge(var.labels, {
    cluster-type = "spark-processing"
  })

  depends_on = [
    google_service_account.dataproc_sa,
    google_storage_bucket.scripts_bucket
  ]
}

# Job Spark para processamento de dados grandes
resource "google_dataproc_job" "spark_etl" {
  region       = var.region
  force_delete = true

  placement {
    cluster_name = google_dataproc_cluster.b2bshift_cluster.name
  }

  spark_config {
    main_class    = "com.b2bshift.etl.DataProcessor"
    jar_file_uris = ["gs://b2bshift-scripts-${var.project_id}-${var.environment}/jars/b2bshift-etl.jar"]
    
    args = [
      "--input=gs://raw-zone-${var.project_id}-${var.environment}/",
      "--output=${var.project_id}:b2bshift_trusted.processed_data",
      "--temp-location=gs://b2bshift-dataflow-temp-${var.project_id}-${var.environment}/spark-temp/"
    ]

    properties = {
      "spark.executor.memory" = "2g"
      "spark.driver.memory"   = "1g"
      "spark.executor.cores"  = "2"
    }
  }

  labels = merge(var.labels, {
    job-type = "spark-etl"
  })
}

# Job PySpark para análise de dados
resource "google_dataproc_job" "pyspark_analytics" {
  region       = var.region
  force_delete = true

  placement {
    cluster_name = google_dataproc_cluster.b2bshift_cluster.name
  }

  pyspark_config {
    main_python_file_uri = "gs://b2bshift-scripts-${var.project_id}-${var.environment}/python/customer_analytics.py"
    
    args = [
      "--project=${var.project_id}",
      "--dataset=b2bshift_trusted",
      "--output-dataset=b2bshift_analytics"
    ]

    python_file_uris = [
      "gs://b2bshift-scripts-${var.project_id}-${var.environment}/python/utils.py"
    ]

    properties = {
      "spark.executor.memory" = "2g"
      "spark.driver.memory"   = "1g"
    }
  }

  labels = merge(var.labels, {
    job-type = "pyspark-analytics"
  })
}

# Workflow template para automação
resource "google_dataproc_workflow_template" "b2bshift_workflow" {
  name     = "b2bshift-daily-processing"
  location = var.region

  placement {
    managed_cluster {
      cluster_name = "ephemeral-cluster-${var.environment}"
      config {
        master_config {
          num_instances = 1
          machine_type  = "n1-standard-2"
        }
        worker_config {
          num_instances = 2
          machine_type  = "n1-standard-2"
        }
        software_config {
          image_version = "2.1-debian11"
        }
      }
    }
  }

  jobs {
    step_id = "extract-data"
    spark_job {
      main_class    = "com.b2bshift.extract.DataExtractor"
      jar_file_uris = ["gs://b2bshift-scripts-${var.project_id}-${var.environment}/jars/b2bshift-etl.jar"]
    }
  }

  jobs {
    step_id = "transform-data"
    prerequisite_step_ids = ["extract-data"]
    pyspark_job {
      main_python_file_uri = "gs://b2bshift-scripts-${var.project_id}-${var.environment}/python/transform.py"
    }
  }

  jobs {
    step_id = "load-analytics"
    prerequisite_step_ids = ["transform-data"]
    spark_sql_job {
      query_file_uri = "gs://b2bshift-scripts-${var.project_id}-${var.environment}/sql/analytics_load.sql"
    }
  }

  labels = merge(var.labels, {
    workflow-type = "daily-etl"
  })
}

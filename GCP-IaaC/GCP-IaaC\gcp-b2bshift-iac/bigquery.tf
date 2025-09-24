# ================================================
# BIGQUERY.TF - B2BSHIFT PLATFORM  
# Data Warehouse e Analytics com BigQuery
# ================================================

# Datasets principais do Data Warehouse
resource "google_bigquery_dataset" "datasets" {
  for_each = toset(var.dataset_names)

  dataset_id    = each.value
  friendly_name = "B2BShift ${title(replace(each.value, "_", " "))}"
  description   = "Dataset ${each.value} para o projeto B2BShift"
  location      = var.region

  delete_contents_on_destroy = true

  # Configurações de acesso
  # IMPORTANTE: Substitua pelos seus emails reais antes de executar
  # access {
  #   role          = "OWNER"
  #   user_by_email = "SEU-EMAIL@GMAIL.COM" # Substitua pelo seu email real
  # }

  # access {
  #   role   = "READER"
  #   group_by_email = "SEU-GRUPO@GMAIL.COM" # Substitua pelo grupo real ou remova
  # }

  labels = merge(var.labels, {
    dataset = each.value
  })
}

# ================================================
# RAW LAYER TABLES - Dados brutos da Landing Zone
# ================================================

# Sales Proposals History
resource "google_bigquery_table" "sales_proposals_raw" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_raw"].dataset_id
  table_id            = "sales_proposals"
  description         = "Histórico de propostas de vendas (dados brutos)"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "proposal_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "customer_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "proposal_date"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "proposal_value"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "status"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "products_json"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "sales_rep_id"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "updated_at"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    }
  ])

  labels = var.labels
}

# Customer Stats
resource "google_bigquery_table" "customer_stats_raw" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_raw"].dataset_id
  table_id            = "customer_stats"
  description         = "Estatísticas de clientes (dados brutos)"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "customer_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "company_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "industry"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "company_size"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "annual_revenue"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "contact_email"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "contact_phone"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "address_json"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "updated_at"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    }
  ])

  labels = var.labels
}

# Recent Contracts
resource "google_bigquery_table" "recent_contracts_raw" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_raw"].dataset_id
  table_id            = "recent_contracts"
  description         = "Contratos recentes (dados brutos)"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "contract_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "customer_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "contract_date"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "contract_value"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "contract_duration_months"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "contract_type"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "products_json"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "status"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "updated_at"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    }
  ])

  labels = var.labels
}

# Customer Master Data
resource "google_bigquery_table" "customer_master_raw" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_raw"].dataset_id
  table_id            = "customer_master"
  description         = "Dados mestres de clientes (dados brutos)"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "customer_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "master_data_json"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "data_source"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "last_sync"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "updated_at"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    }
  ])

  labels = var.labels
}

# Customer MRR (Monthly Recurring Revenue)
resource "google_bigquery_table" "customer_mrr_raw" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_raw"].dataset_id
  table_id            = "customer_mrr"
  description         = "Revenue mensal recorrente por cliente (dados brutos)"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "customer_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "month_year"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "mrr_value"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "currency"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "products_json"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "calculated_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])

  labels = var.labels
}

# NPS Relational Data
resource "google_bigquery_table" "nps_relational_raw" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_raw"].dataset_id
  table_id            = "nps_relational"
  description         = "Dados relacionais de NPS (dados brutos)"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "nps_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "customer_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "survey_date"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "nps_score"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "feedback_text"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "respondent_email"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "survey_type"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])

  labels = var.labels
}

# Support Tickets
resource "google_bigquery_table" "support_tickets_raw" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_raw"].dataset_id
  table_id            = "support_tickets"
  description         = "Tickets de suporte (dados brutos)"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "ticket_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "customer_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "created_date"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "resolved_date"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    },
    {
      name = "priority"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "category"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "status"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "description"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "assigned_to"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "updated_at"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    }
  ])

  labels = var.labels
}

# External Data - Brazilian Market Data
resource "google_bigquery_table" "brazilian_market_data_raw" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_raw"].dataset_id
  table_id            = "brazilian_market_data"
  description         = "Dados do mercado brasileiro (dados externos)"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "data_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "industry_sector"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "market_size_brl"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "growth_rate_percent"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "economic_indicators_json"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "data_date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "source"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])

  labels = var.labels
}

# External Data - Demographic Data
resource "google_bigquery_table" "demographic_data_raw" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_raw"].dataset_id
  table_id            = "demographic_data"
  description         = "Dados demográficos (dados externos)"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "demographic_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "region_code"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "region_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "population"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "business_density"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "avg_income_brl"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "education_level_json"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "data_year"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "source"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])

  labels = var.labels
}

# ================================================
# TRUSTED LAYER TABLES - Dados limpos e estruturados
# ================================================

# Customer Dimension (limpo e estruturado)
resource "google_bigquery_table" "customers_trusted" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_trusted"].dataset_id
  table_id            = "customers"
  description         = "Dados de clientes limpos e estruturados"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "customer_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "company_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "industry"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "company_size"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "annual_revenue"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "contact_email"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "contact_phone"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "address_street"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "address_city"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "address_state"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "address_zipcode"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "region_code"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "updated_at"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    },
    {
      name = "is_active"
      type = "BOOLEAN"
      mode = "REQUIRED"
    }
  ])

  labels = var.labels
}

# Products Dimension (extraído das propostas e contratos)
resource "google_bigquery_table" "products_trusted" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_trusted"].dataset_id
  table_id            = "products"
  description         = "Catálogo de produtos estruturado"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "product_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "product_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "product_category"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "product_description"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "unit_price"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "currency"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "is_active"
      type = "BOOLEAN"
      mode = "REQUIRED"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "updated_at"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    }
  ])

  labels = var.labels
}

# Sales Proposals (estruturado)
resource "google_bigquery_table" "sales_proposals_trusted" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_trusted"].dataset_id
  table_id            = "sales_proposals"
  description         = "Propostas de vendas estruturadas"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "proposal_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "customer_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "proposal_date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "proposal_value"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "currency"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "status"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "sales_rep_id"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "proposal_quarter"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "proposal_year"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "updated_at"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    }
  ])

  labels = var.labels
}

# Proposal Products (relationship table)
resource "google_bigquery_table" "proposal_products_trusted" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_trusted"].dataset_id
  table_id            = "proposal_products"
  description         = "Relacionamento entre propostas e produtos"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "proposal_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "product_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "quantity"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "unit_price"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "total_price"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "currency"
      type = "STRING"
      mode = "REQUIRED"
    }
  ])

  labels = var.labels
}

# Contracts (estruturado)
resource "google_bigquery_table" "contracts_trusted" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_trusted"].dataset_id
  table_id            = "contracts"
  description         = "Contratos estruturados"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "contract_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "customer_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "contract_date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "contract_value"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "currency"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "contract_duration_months"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "contract_type"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "status"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "start_date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "end_date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "contract_quarter"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "contract_year"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "updated_at"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    }
  ])

  labels = var.labels
}

# Contract Products (relationship table)
resource "google_bigquery_table" "contract_products_trusted" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_trusted"].dataset_id
  table_id            = "contract_products"
  description         = "Relacionamento entre contratos e produtos"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "contract_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "product_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "quantity"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "unit_price"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "total_price"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "currency"
      type = "STRING"
      mode = "REQUIRED"
    }
  ])

  labels = var.labels
}

# NPS Data (estruturado)
resource "google_bigquery_table" "nps_trusted" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_trusted"].dataset_id
  table_id            = "nps"
  description         = "Dados de NPS estruturados"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "nps_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "customer_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "survey_date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "nps_score"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "nps_category"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "feedback_text"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "respondent_email"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "survey_type"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "survey_quarter"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "survey_year"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])

  labels = var.labels
}

# Support Tickets (estruturado)
resource "google_bigquery_table" "support_tickets_trusted" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_trusted"].dataset_id
  table_id            = "support_tickets"
  description         = "Tickets de suporte estruturados"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "ticket_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "customer_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "created_date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "resolved_date"
      type = "DATE"
      mode = "NULLABLE"
    },
    {
      name = "resolution_time_hours"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "priority"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "category"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "status"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "description"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "assigned_to"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "created_quarter"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "created_year"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "updated_at"
      type = "TIMESTAMP"
      mode = "NULLABLE"
    }
  ])

  labels = var.labels
}

# Monthly Recurring Revenue (estruturado)
resource "google_bigquery_table" "mrr_trusted" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_trusted"].dataset_id
  table_id            = "mrr"
  description         = "Monthly Recurring Revenue estruturado"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "customer_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "month_year"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "mrr_value"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "currency"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "quarter"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "year"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "calculated_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])

  labels = var.labels
}

# External Data - Brazilian Market (estruturado)
resource "google_bigquery_table" "brazilian_market_trusted" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_trusted"].dataset_id
  table_id            = "brazilian_market"
  description         = "Dados do mercado brasileiro estruturados"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "industry_sector"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "market_size_brl"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "growth_rate_percent"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "gdp_correlation"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "inflation_rate"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "unemployment_rate"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "data_date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "quarter"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "year"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "source"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])

  labels = var.labels
}

# External Data - Demographics (estruturado)
resource "google_bigquery_table" "demographics_trusted" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_trusted"].dataset_id
  table_id            = "demographics"
  description         = "Dados demográficos estruturados"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "region_code"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "region_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "state"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "population"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "business_density"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "avg_income_brl"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "education_high_school_percent"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "education_university_percent"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "urban_population_percent"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "data_year"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "source"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "created_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])

  labels = var.labels
}

# ================================================
# REFINED LAYER TABLES - Star Schema para Analytics
# ================================================

# DIMENSION TABLES

# Dim Customer - Dimensão de Clientes
resource "google_bigquery_table" "dim_customer" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_refined"].dataset_id
  table_id            = "dim_customer"
  description         = "Dimensão de clientes para Star Schema"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "customer_key"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "customer_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "company_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "industry"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "company_size"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "annual_revenue"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "revenue_segment"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "region_code"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "region_name"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "state"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "contact_email"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "is_active"
      type = "BOOLEAN"
      mode = "REQUIRED"
    },
    {
      name = "customer_tier"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "acquisition_date"
      type = "DATE"
      mode = "NULLABLE"
    },
    {
      name = "last_activity_date"
      type = "DATE"
      mode = "NULLABLE"
    }
  ])

  labels = var.labels
}

# Dim Product - Dimensão de Produtos
resource "google_bigquery_table" "dim_product" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_refined"].dataset_id
  table_id            = "dim_product"
  description         = "Dimensão de produtos para Star Schema"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "product_key"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "product_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "product_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "product_category"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "product_subcategory"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "product_description"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "unit_price"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "price_tier"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "is_active"
      type = "BOOLEAN"
      mode = "REQUIRED"
    },
    {
      name = "launch_date"
      type = "DATE"
      mode = "NULLABLE"
    }
  ])

  labels = var.labels
}

# Dim Time - Dimensão de Tempo
resource "google_bigquery_table" "dim_time" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_refined"].dataset_id
  table_id            = "dim_time"
  description         = "Dimensão de tempo para Star Schema"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "date_key"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "year"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "quarter"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "quarter_number"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "month"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "month_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "week"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "day_of_month"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "day_of_week"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "day_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "is_weekend"
      type = "BOOLEAN"
      mode = "REQUIRED"
    },
    {
      name = "is_holiday"
      type = "BOOLEAN"
      mode = "REQUIRED"
    }
  ])

  labels = var.labels
}

# Dim Geography - Dimensão Geográfica
resource "google_bigquery_table" "dim_geography" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_refined"].dataset_id
  table_id            = "dim_geography"
  description         = "Dimensão geográfica para Star Schema"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "geography_key"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "region_code"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "region_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "state"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "state_code"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "population"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "business_density"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "avg_income_brl"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "education_university_percent"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "urban_population_percent"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "market_potential"
      type = "STRING"
      mode = "NULLABLE"
    }
  ])

  labels = var.labels
}

# FACT TABLES

# Fact Sales - Fatos de Vendas (Propostas + Contratos)
resource "google_bigquery_table" "fact_sales" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_refined"].dataset_id
  table_id            = "fact_sales"
  description         = "Tabela de fatos de vendas - Star Schema"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "sales_key"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "customer_key"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "product_key"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "date_key"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "geography_key"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "transaction_type"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "transaction_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "quantity"
      type = "INTEGER"
      mode = "REQUIRED"
    },
    {
      name = "unit_price"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "total_value"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "currency"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "status"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "sales_rep_id"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "contract_duration_months"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "is_recurring"
      type = "BOOLEAN"
      mode = "REQUIRED"
    }
  ])

  labels = var.labels
}

# Fact Customer Experience - Fatos de Experiência do Cliente (NPS + Support)
resource "google_bigquery_table" "fact_customer_experience" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_refined"].dataset_id
  table_id            = "fact_customer_experience"
  description         = "Tabela de fatos de experiência do cliente - Star Schema"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "experience_key"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "customer_key"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "date_key"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "geography_key"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "interaction_type"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "interaction_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "nps_score"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "nps_category"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "ticket_priority"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "ticket_category"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "resolution_time_hours"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "satisfaction_score"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "is_resolved"
      type = "BOOLEAN"
      mode = "NULLABLE"
    }
  ])

  labels = var.labels
}

# Fact Revenue - Fatos de Receita (MRR)
resource "google_bigquery_table" "fact_revenue" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_refined"].dataset_id
  table_id            = "fact_revenue"
  description         = "Tabela de fatos de receita mensal - Star Schema"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "revenue_key"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "customer_key"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "date_key"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "geography_key"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "mrr_value"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "arr_value"
      type = "NUMERIC"
      mode = "REQUIRED"
    },
    {
      name = "currency"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "revenue_type"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "churn_risk_score"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "expansion_opportunity"
      type = "NUMERIC"
      mode = "NULLABLE"
    }
  ])

  labels = var.labels
}

# ================================================
# ANALYTICS LAYER TABLES - Agregações e KPIs
# ================================================

# Customer 360 View - Visão completa do cliente
resource "google_bigquery_table" "customer_360" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_analytics"].dataset_id
  table_id            = "customer_360"
  description         = "Visão 360 do cliente com métricas agregadas"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "customer_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "company_name"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "industry"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "total_revenue"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "current_mrr"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "customer_lifetime_value"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "acquisition_cost"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "total_contracts"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "active_contracts"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "total_proposals"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "accepted_proposals"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "proposal_win_rate"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "avg_nps_score"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "latest_nps_category"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "total_support_tickets"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "avg_resolution_time_hours"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "churn_probability"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "expansion_score"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "last_activity_date"
      type = "DATE"
      mode = "NULLABLE"
    },
    {
      name = "customer_health_score"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "customer_segment"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "updated_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])

  labels = var.labels
}

# Sales Performance KPIs
resource "google_bigquery_table" "sales_performance_kpis" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_analytics"].dataset_id
  table_id            = "sales_performance_kpis"
  description         = "KPIs de performance de vendas"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "period_date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "period_type"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "total_sales_value"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "total_proposals"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "accepted_proposals"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "proposal_win_rate"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "avg_deal_size"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "new_customers"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "churned_customers"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "net_new_customers"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "total_mrr"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "mrr_growth_rate"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "customer_acquisition_cost"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "sales_velocity"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "market_share_estimate"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "updated_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])

  labels = var.labels
}

# Market Intelligence
resource "google_bigquery_table" "market_intelligence" {
  dataset_id          = google_bigquery_dataset.datasets["b2bshift_analytics"].dataset_id
  table_id            = "market_intelligence"
  description         = "Inteligência de mercado com dados externos"
  deletion_protection = false

  schema = jsonencode([
    {
      name = "analysis_date"
      type = "DATE"
      mode = "REQUIRED"
    },
    {
      name = "industry_sector"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "region_code"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "market_size_brl"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "market_growth_rate"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "our_market_share"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "addressable_market_brl"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "potential_customers"
      type = "INTEGER"
      mode = "NULLABLE"
    },
    {
      name = "competition_intensity"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "economic_health_score"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "opportunity_score"
      type = "NUMERIC"
      mode = "NULLABLE"
    },
    {
      name = "recommended_strategy"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "updated_at"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    }
  ])

  labels = var.labels
}

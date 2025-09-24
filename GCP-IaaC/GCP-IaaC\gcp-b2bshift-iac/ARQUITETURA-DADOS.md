# ================================================
# ARQUITETURA DE DADOS - B2BSHIFT PLATFORM
# Estrutura das camadas de dados e tabelas
# ================================================

## 📊 Visão Geral da Arquitetura

A plataforma B2BShift implementa uma arquitetura de dados em 4 camadas:

1. **Landing Zone** (Cloud Storage) - Dados brutos chegando das fontes
2. **Raw Layer** (BigQuery) - Dados brutos estruturados sem transformação
3. **Trusted Layer** (BigQuery) - Dados limpos e validados
4. **Refined Layer** (BigQuery) - Star Schema para analytics
5. **Analytics Layer** (BigQuery) - KPIs e métricas agregadas

## 🗂️ Fontes de Dados

### Dados Internos (Sistema B2BShift)
- **Sales Proposals History**: Histórico de propostas de vendas
- **Customer Stats**: Estatísticas e informações dos clientes
- **Recent Contracts**: Contratos recentes e ativos
- **Customer Master Data**: Dados mestres dos clientes
- **Customer MRR**: Monthly Recurring Revenue por cliente
- **NPS Relational**: Pesquisas de satisfação NPS
- **Support Tickets**: Tickets de suporte ao cliente

### Dados Externos
- **Brazilian Market Data**: Dados do mercado brasileiro por setor
- **Demographic Data**: Dados demográficos por região

## 📋 Estrutura das Camadas

### 🔵 RAW LAYER (`b2bshift_raw`)
Espelho dos dados brutos das fontes, com mínima transformação:

| Tabela | Descrição | Campos Principais |
|--------|-----------|-------------------|
| `sales_proposals` | Propostas de vendas brutas | proposal_id, customer_id, proposal_value, products_json |
| `customer_stats` | Estatísticas de clientes | customer_id, company_name, industry, address_json |
| `recent_contracts` | Contratos recentes | contract_id, customer_id, contract_value, products_json |
| `customer_master` | Dados mestres | customer_id, master_data_json, data_source |
| `customer_mrr` | MRR bruto | customer_id, month_year, mrr_value, products_json |
| `nps_relational` | NPS bruto | nps_id, customer_id, nps_score, feedback_text |
| `support_tickets` | Tickets brutos | ticket_id, customer_id, priority, description |
| `brazilian_market_data` | Mercado brasileiro | industry_sector, market_size_brl, economic_indicators_json |
| `demographic_data` | Demografia | region_code, population, education_level_json |

### 🟢 TRUSTED LAYER (`b2bshift_trusted`)
Dados limpos, validados e estruturados:

| Tabela | Descrição | Transformações Aplicadas |
|--------|-----------|-------------------------|
| `customers` | Clientes estruturados | Limpeza de nomes, validação de emails, normalização de endereços |
| `products` | Catálogo de produtos | Extração de JSON, categorização, padronização de preços |
| `sales_proposals` | Propostas estruturadas | Conversão de datas, cálculo de quarters, validação de status |
| `proposal_products` | Relação proposta-produto | Normalização de relacionamentos M:N |
| `contracts` | Contratos estruturados | Cálculo de datas de início/fim, validação de duração |
| `contract_products` | Relação contrato-produto | Normalização de relacionamentos M:N |
| `nps` | NPS estruturado | Categorização de scores, limpeza de feedback |
| `support_tickets` | Tickets estruturados | Cálculo de tempo de resolução, categorização |
| `mrr` | MRR estruturado | Agregação mensal, conversão de moedas |
| `brazilian_market` | Mercado estruturado | Extração de indicadores, cálculos de correlação |
| `demographics` | Demografia estruturada | Normalização de regiões, cálculos percentuais |

### 🟡 REFINED LAYER (`b2bshift_refined`) - Star Schema
Esquema estrela otimizado para analytics:

#### 🔹 Dimensões (Dimension Tables)
| Dimensão | Descrição | Atributos Principais |
|----------|-----------|---------------------|
| `dim_customer` | Dimensão de clientes | customer_key, company_name, industry, revenue_segment, customer_tier |
| `dim_product` | Dimensão de produtos | product_key, product_name, category, price_tier |
| `dim_time` | Dimensão temporal | date_key, year, quarter, month, day_name, is_weekend |
| `dim_geography` | Dimensão geográfica | geography_key, region_name, state, market_potential |

#### 🔸 Fatos (Fact Tables)
| Fato | Descrição | Métricas |
|------|-----------|----------|
| `fact_sales` | Vendas (propostas + contratos) | quantity, unit_price, total_value, contract_duration |
| `fact_customer_experience` | Experiência do cliente | nps_score, resolution_time, satisfaction_score |
| `fact_revenue` | Receita mensal | mrr_value, arr_value, churn_risk_score |

### 🔴 ANALYTICS LAYER (`b2bshift_analytics`)
Agregações e KPIs de negócio:

| Tabela | Descrição | Métricas Principais |
|--------|-----------|-------------------|
| `customer_360` | Visão 360 do cliente | CLV, MRR atual, NPS médio, churn probability |
| `sales_performance_kpis` | KPIs de vendas | Win rate, deal size médio, growth rate |
| `market_intelligence` | Inteligência de mercado | Market share, opportunity score, estratégias |

## 🔄 Fluxo de Dados

```
Landing Zone (Storage) 
    ↓ (Airflow + Dataflow)
Raw Layer (BigQuery)
    ↓ (dbt + Dataflow)  
Trusted Layer (BigQuery)
    ↓ (dbt + Spark)
Refined Layer (BigQuery) - Star Schema
    ↓ (Scheduled Queries)
Analytics Layer (BigQuery) - KPIs
    ↓
Dashboards & ML Models
```

## 🎯 Casos de Uso por Camada

### Raw Layer
- ✅ Auditoria de dados originais
- ✅ Reprocessamento de dados históricos
- ✅ Troubleshooting de pipelines

### Trusted Layer  
- ✅ Análises exploratórias
- ✅ Data Quality checks
- ✅ Feature engineering para ML

### Refined Layer
- ✅ Dashboards executivos
- ✅ Relatórios automatizados
- ✅ Análises OLAP de alta performance

### Analytics Layer
- ✅ KPIs de negócio
- ✅ Customer 360
- ✅ Predições de churn
- ✅ Market intelligence

## 🔧 Ferramentas de ETL

| Camada | Ferramenta | Uso |
|--------|------------|-----|
| Landing → Raw | **Dataflow** | Ingestão e estruturação inicial |
| Raw → Trusted | **BQ + Dataflow** | Limpeza e validação |
| Trusted → Refined | **BQ + Dataproc** | Transformações complexas, Star Schema |
| Refined → Analytics | **Scheduled Queries** | Agregações e KPIs |

## 🔍 Governança de Dados

### DataPlex Assets
- **Raw Zone**: Descoberta automática de esquemas
- **Curated Zone**: Monitoramento de qualidade
- **Quality Tasks**: Validações automatizadas

### Data Catalog
- **Metadados**: Documentação automática
- **Lineage**: Rastreamento de linhagem
- **Tags**: Classificação por sensibilidade

## 📈 Performance e Otimização

### Particionamento
- **Tabelas de fatos**: Particionadas por data
- **Dimensões**: Clustering por chaves principais

### Materialização
- **Views**: Para transformações leves
- **Tables**: Para agregações pesadas
- **Materialized Views**: Para KPIs frequentes

### Indexes e Clustering
- **Clustering**: Por customer_id, product_id, date_key
- **Partitioning**: Por ano/mês para dados temporais

---

📋 **Próximos Passos:**
1. Implementar pipelines para transformações
2. Configurar data quality checks
3. Criar dashboards no Looker/Data Studio
4. Treinar modelos de ML no Vertex AI

# ================================================
# README.MD - B2BSHIFT PLATFORM IaC
# Documentação da Infraestrutura como Código
# ================================================

# 🚀 B2BShift Platform - Infrastructure as Code

Este repositório contém os scripts Terraform para provisionar toda a infraestrutura da plataforma B2BShift no Google Cloud Platform (GCP).

## 📋 Arquitetura da Solução

A plataforma B2BShift é uma solução completa de analytics e data engineering que inclui:

### 🗂️ Data Lake (Cloud Storage)
- **Landing Zone**: Dados brutos recém-chegados
- **Raw Zone**: Dados não processados
- **Trusted Zone**: Dados limpos e validados  
- **Refined Zone**: Dados agregados e otimizados
- **Archive Zone**: Dados históricos

### 🏢 Data Warehouse (BigQuery)
- **Raw Dataset**: Dados brutos das fontes (Sales Proposals, Customer Stats, Contracts, NPS, Support Tickets, External Data)
- **Trusted Dataset**: Dados limpos e estruturados com validações aplicadas
- **Refined Dataset**: Star Schema otimizado com dimensões e fatos para analytics
- **Analytics Dataset**: Métricas agregadas, KPIs e visões 360 dos clientes

### ⚡ Processamento de Dados
- **Dataflow**: ETL/ELT em tempo real e batch
- **Dataproc**: Processamento big data com Spark/Hadoop
- **Pub/Sub**: Streaming de dados em tempo real

### 🤖 Machine Learning (Vertex AI)
- **Datasets**: Conjuntos de dados para treinamento
- **Endpoints**: Deploy de modelos em produção
- **Feature Store**: Armazenamento de features
- **Notebooks**: Ambiente de desenvolvimento ML

### 🔄 Orquestração (Cloud Composer/Airflow)
- **DAGs**: Workflows automatizados
- **Scheduling**: Execução programada de pipelines
- **Monitoring**: Monitoramento de execuções

### 📊 Governança (DataPlex)
- **Discovery**: Descoberta automática de dados
- **Quality**: Verificação de qualidade dos dados
- **Cataloging**: Catalogação e metadados

## 📁 Estrutura dos Arquivos

```
gcp-b2bshift-iac/
├── provider.tf              # Configuração do provider GCP
├── variables.tf             # Definição de variáveis
├── storage.tf               # Buckets do Data Lake
├── bigquery.tf              # Data Warehouse e tabelas
├── dataflow.tf              # Jobs de ETL/ELT
├── dataproc.tf              # Cluster Spark/Hadoop
├── vertex_ai.tf             # Infraestrutura de ML
├── composer.tf              # Orquestração Airflow
├── dataplex.tf              # Governança de dados
├── outputs.tf               # Outputs dos recursos
├── terraform.tfvars.example # Exemplo de variáveis
└── README.md                # Esta documentação
```

## 🛠️ Pré-requisitos

1. **Terraform** >= 1.3.0
2. **Google Cloud SDK** configurado
3. **Projeto GCP** com billing habilitado
4. **Permissões** de Editor/Owner no projeto

## ⚙️ Configuração Inicial

### 1. Clone e Configure
```bash
# Navegue até o diretório
cd gcp-b2bshift-iac

# Copie o arquivo de exemplo
cp terraform.tfvars.example terraform.tfvars

# Edite com seus valores
# Altere project_id, region, etc.
```

### 2. Autenticação no GCP
```bash
# Login no GCP
gcloud auth login

# Configure o projeto padrão
gcloud config set project SEU-PROJECT-ID

# Configure credenciais para Terraform
gcloud auth application-default login
```

### 3. Inicialização do Terraform
```bash
# Inicialize o Terraform
terraform init

# Valide a configuração
terraform validate

# Visualize o plano
terraform plan
```

## 🚀 Execução

### Deploy Completo
```bash
# Execute o deploy
terraform apply

# Confirme digitando 'yes'
```

### Deploy por Módulos (Recomendado)
```bash
# 1. APIs e configurações básicas
terraform apply -target=google_project_service.required_apis

# 2. Storage
terraform apply -target=module.storage

# 3. BigQuery
terraform apply -target=module.bigquery

# 4. Processamento (Dataflow + Dataproc)
terraform apply -target=module.dataflow
terraform apply -target=module.dataproc

# 5. ML (Vertex AI)
terraform apply -target=module.vertex_ai

# 6. Orquestração (Composer)
terraform apply -target=module.composer

# 7. Governança (DataPlex)
terraform apply -target=module.dataplex
```

## 📊 Recursos Criados

### Storage (5 buckets)
- landing-zone-{project}-{env}
- raw-zone-{project}-{env}
- trusted-zone-{project}-{env}
- refined-zone-{project}-{env}
- archive-zone-{project}-{env}

### BigQuery (4 datasets + tabelas)
- b2bshift_raw
- b2bshift_trusted
- b2bshift_refined
- b2bshift_analytics

### Processamento
- 3 jobs Dataflow configurados
- 1 cluster Dataproc com autoscaling
- 1 tópico Pub/Sub

### Machine Learning
- 2 datasets Vertex AI
- 1 endpoint para deploy
- 1 feature store
- 1 notebook instance

### Orquestração
- 1 ambiente Composer/Airflow
- 1 Cloud Function para triggers
- 1 Cloud Scheduler

### Governança
- 1 DataPlex Lake
- 2 DataPlex Zones
- Multiple assets configurados

## 🔍 Monitoramento

Após o deploy, acesse:

```bash
# URLs de acesso rápido
terraform output quick_access_urls
```

- **BigQuery Console**: Visualizar dados e executar queries
- **Dataflow Console**: Monitorar jobs de ETL
- **Dataproc Console**: Gerenciar clusters Spark
- **Vertex AI Console**: Treinar e implantar modelos
- **Composer Console**: Visualizar DAGs do Airflow
- **DataPlex Console**: Governança e qualidade

## 💰 Custos Estimados

| Serviço | Custo Mensal (USD) | Observações |
|---------|-------------------|-------------|
| BigQuery | $50-200 | Depende do volume de dados |
| Cloud Storage | $20-50 | Depende do armazenamento |
| Dataproc | $100-300 | Cluster sempre ativo |
| Composer | $150-250 | Ambiente gerenciado |
| Vertex AI | $50-150 | Depende do uso de ML |
| **Total** | **$370-950** | Estimativa para ambiente dev |

## 🧹 Limpeza

```bash
# Para destruir toda a infraestrutura
terraform destroy

# Confirme digitando 'yes'
```

⚠️ **ATENÇÃO**: Isso irá deletar TODOS os dados e recursos!

## 📋 Checklist de Deploy

- [ ] Projeto GCP criado e configurado
- [ ] Billing habilitado
- [ ] Terraform instalado
- [ ] Variáveis configuradas em terraform.tfvars
- [ ] `terraform init` executado
- [ ] `terraform plan` validado
- [ ] `terraform apply` executado
- [ ] Outputs verificados
- [ ] Acesso aos consoles testado

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Add: nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📞 Suporte

Para dúvidas ou suporte:
- **Email**: data-team@b2bshift.com
- **Slack**: #data-engineering
- **Wiki**: [Link para documentação interna]

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

---

🚀 **Happy Data Engineering!** 🚀

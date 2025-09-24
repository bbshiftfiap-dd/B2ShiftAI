# 🚀 Guia de Início Rápido - B2Shift Cluster Agent

## ⚡ Setup em 5 Minutos

### 1. Pré-requisitos
```bash
# Instalar Python 3.12+
python --version  # Deve ser 3.12+

# Instalar Poetry
curl -sSL https://install.python-poetry.org | python3 -
```

### 2. Clone e Setup
```bash
# Clone o repositório
git clone <repository-url>
cd b2shift-cluster-agent

# Setup automático
make quickstart
```

### 3. Configuração Básica
```bash
# Editar configurações (opcional para demo)
cp .env.example .env
# Edite .env com suas configurações Google Cloud se necessário
```

### 4. Teste Rápido
```bash
# Demo rápida (funciona sem configuração cloud)
make demo-quick

# OU executar exemplo básico
make example-basic
```

## 🎯 Comandos Essenciais

### Execução do Agent
```bash
# Interface CLI
make run-cli

# Interface Web (ADK)
make run-web

# Via ADK diretamente
make run
```

### Demonstrações
```bash
# Demo completa (10-15 min)
make demo

# Demo rápida (2-3 min)
make demo-quick

# Exemplo básico
make example-basic
```

### Testes
```bash
# Todos os testes
make test

# Apenas testes do agent
make test-agent

# Testes específicos de clustering
make test-clustering
```

## 🌊 Fluxo de Uso Típico

### 1. Análise Inicial
```bash
# Executar agent
make run-cli

# Query exemplo:
"Analise os dados de clientes B2B e identifique os principais clusters comportamentais"
```

### 2. Deep Dive em Cluster
```bash
# Query exemplo:
"Faça uma análise detalhada do cluster Mid-Market Tech, incluindo perfil, necessidades e estratégias recomendadas"
```

### 3. Geração de Estratégias
```bash
# Query exemplo:
"Gere estratégias personalizadas de go-to-market para cada cluster identificado, com ROI projetado e timeline de implementação"
```

### 4. Predição de Comportamento
```bash
# Query exemplo:
"Prediga o comportamento nos próximos 6 meses de um cliente Enterprise com churn risk de 15% e growth rate de -2%"
```

## 🔧 Configuração Avançada

### Google Cloud (Opcional)
```bash
# Configurar .env
GOOGLE_CLOUD_PROJECT=seu-projeto
GOOGLE_CLOUD_LOCATION=us-central1
GOOGLE_GENAI_USE_VERTEXAI=1

# BigQuery (se usar dados reais)
BQ_PROJECT_ID=seu-projeto-bq
BQ_DATASET_ID=b2shift_customer_data
```

### Dados Customizados
```bash
# Gerar dados de exemplo
make data-generate

# Usar seus próprios dados
# Coloque CSVs em data/sample/ seguindo o schema documentado
```

## 🚀 Deploy para Produção

### Vertex AI Agent Engine
```bash
# Deploy
make deploy-create

# Teste (substitua RESOURCE_ID)
make deploy-test RESOURCE_ID=seu_resource_id

# Remove deploy
make deploy-delete RESOURCE_ID=seu_resource_id
```

## 📊 Exemplos de Queries

### Análise de Clusters
```
"Execute uma análise completa de clusterização dos clientes B2B da TOTVS, identificando segmentos distintos e caracterizando cada um com métricas de negócio e recomendações estratégicas."
```

### Estratégias por Segmento
```
"Para o cluster Enterprise identificado, gere uma estratégia detalhada de go-to-market incluindo: canais de aquisição, messaging, produtos recomendados, pricing, e KPIs de sucesso."
```

### Predição Individual
```
"Analise o cliente TechCorp (Mid-Market, R$ 5M revenue, 18 meses de conta) e prediga: probabilidade de churn, potencial de expansão, e ações recomendadas para os próximos 90 dias."
```

### Otimização de Portfolio
```
"Baseado na performance atual (Enterprise: 15% growth, SMB: 8% growth), recomende realocação de recursos e ajustes de estratégia para maximizar ROI do portfolio."
```

## 🆘 Troubleshooting

### Problemas Comuns

**Erro de importação do ADK:**
```bash
poetry install
poetry run pip install google-adk
```

**Agent não responde:**
```bash
# Verificar configuração
make env-check

# Testar componentes
make test-agent
```

**Erro no Google Cloud:**
```bash
# Usar modo demo (sem cloud)
export GOOGLE_GENAI_USE_VERTEXAI=0

# Ou configurar credenciais
gcloud auth application-default login
```

### Logs e Debug
```bash
# Verificar logs
export LOG_LEVEL=DEBUG

# Status do projeto
make status

# Limpeza completa
make clean-all
```

## 📚 Documentação Completa

- **README.md**: Documentação completa
- **docs/b2shift_context.md**: Contexto do problema B2Shift
- **docs/algorithms.md**: Algoritmos de clusterização
- **examples/**: Exemplos de uso
- **tests/**: Testes e validações

## 🎯 Próximos Passos

1. **Execute a demo**: `make demo-quick`
2. **Teste com dados reais**: Configure BigQuery
3. **Customize estratégias**: Edite prompts em `b2shift_cluster/prompts.py`
4. **Deploy para produção**: `make deploy-create`
5. **Integre com sistemas**: Use APIs do agent deployado

## 📞 Suporte

- 📧 **Email**: fiap-team@totvs.com.br
- 🐛 **Issues**: GitHub Issues
- 📚 **Docs**: `docs/` directory
- 💬 **Demo**: `make demo` para ver todas as capacidades

---

**🎉 Bem-vindo ao B2Shift Customer Clustering Agent!**

Este agent representa o estado da arte em análise de clusterização B2B e tomada de decisões estratégicas. Use-o para transformar dados de clientes em insights acionáveis e estratégias de alto ROI.

*Desenvolvido com ❤️ pela equipe FIAP para TOTVS B2Shift*

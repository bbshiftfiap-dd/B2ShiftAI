# B2Shift Customer Clustering AI Agent

## Visão Geral

Este projeto implementa um AI Agent especializado para análise de dados de clusterização de clientes no contexto do problema B2Shift TOTVS. O agente utiliza o Google Agent Development Kit (ADK) para analisar padrões de comportamento de clientes, identificar clusters significativos e tomar decisões estratégicas baseadas em dados.

## Problema B2Shift

O B2Shift é uma iniciativa da TOTVS para transformação digital de negócios B2B, focando na análise comportamental de clientes para:

- **Segmentação Inteligente**: Identificar grupos de clientes com comportamentos similares
- **Personalização**: Adaptar estratégias de negócio para cada cluster
- **Predição de Comportamento**: Antecipar necessidades e tendências de clientes
- **Otimização de Recursos**: Alocar recursos de forma mais eficiente baseado nos clusters

## Arquitetura do Agente

O B2Shift Cluster Agent é construído usando uma arquitetura multi-agente baseada no ADK:

```
┌─────────────────────────────────────────────────────────┐
│                B2Shift Root Agent                       │
│  (Orquestração e Decisões Estratégicas)               │
└─────────────────────┬───────────────────────────────────┘
                      │
          ┌───────────┼───────────┐
          │           │           │
    ┌─────▼─────┐ ┌───▼───┐ ┌─────▼─────┐
    │   Data    │ │Cluster│ │ Decision  │
    │  Agent    │ │ Agent │ │   Agent   │
    │           │ │       │ │           │
    └───────────┘ └───────┘ └───────────┘
```

### Componentes Principais

1. **Root Agent**: Orquestra toda a análise e coordena os sub-agentes
2. **Data Agent**: Responsável por coleta e preparação de dados
3. **Cluster Agent**: Executa algoritmos de clusterização e análise
4. **Decision Agent**: Gera insights e recomendações estratégicas

## Funcionalidades

### 📊 Análise de Clusterização
- Implementação de múltiplos algoritmos (K-Means, DBSCAN, Hierarchical)
- Determinação automática do número ideal de clusters
- Validação e métricas de qualidade dos clusters

### 🎯 Tomada de Decisões
- Análise de características de cada cluster
- Recomendações personalizadas por segmento
- Estratégias de engajamento específicas

### 📈 Visualizações Interativas
- Gráficos de distribuição de clusters
- Análise de features mais importantes
- Dashboards executivos

### 🤖 Capacidades de IA
- Processamento de linguagem natural para consultas
- Análise preditiva de comportamento
- Geração automática de insights

## Instalação

```bash
# Clone o repositório
git clone <repository-url>
cd b2shift-cluster-agent

# Instale as dependências
poetry install

# Configure as variáveis de ambiente
cp .env.example .env
# Edite o arquivo .env com suas configurações
```

## Configuração

Crie um arquivo `.env` com as seguintes variáveis:

```env
# Configurações do Google Cloud
GOOGLE_CLOUD_PROJECT=seu-projeto-gcp
GOOGLE_CLOUD_LOCATION=us-central1
GOOGLE_GENAI_USE_VERTEXAI=1

# Configurações do BigQuery
BQ_PROJECT_ID=seu-projeto-bigquery
BQ_DATASET_ID=b2shift_customer_data

# Configurações dos Modelos
ROOT_AGENT_MODEL=gemini-1.5-pro
CLUSTER_AGENT_MODEL=gemini-1.5-flash
DATA_AGENT_MODEL=gemini-1.5-flash
DECISION_AGENT_MODEL=gemini-1.5-pro

# Configurações específicas do B2Shift
B2SHIFT_MIN_CLUSTER_SIZE=50
B2SHIFT_MAX_CLUSTERS=10
B2SHIFT_CONFIDENCE_THRESHOLD=0.8
```

## Uso

### Via CLI
```bash
# Executar análise completa
poetry run adk run b2shift_cluster

# Análise específica de cluster
b2shift-agent analyze --cluster-id 1

# Gerar recomendações
b2shift-agent recommend --segment enterprise
```

### Via Web Interface
```bash
# Iniciar interface web
poetry run adk web
```

### Exemplos de Interação

#### Análise de Clusters
```
Usuário: "Analise os dados de clientes e identifique os principais clusters"
Agent: Executando análise de clusterização nos dados B2Shift...
       - Identificados 5 clusters principais
       - Cluster 1: Empresas de grande porte (25% dos clientes)
       - Cluster 2: PMEs tecnológicas (30% dos clientes)
       - Cluster 3: Startups em crescimento (20% dos clientes)
       - ...
```

#### Recomendações Estratégicas
```
Usuário: "Que estratégias recomendar para o cluster de PMEs?"
Agent: Baseado na análise do cluster PME (Cluster 2):
       
       Características:
       - Faturamento médio: R$ 2-10M
       - Foco em eficiência operacional
       - Alta sensibilidade a preço
       
       Recomendações:
       1. Ofertas de pacotes econômicos
       2. Suporte técnico especializado
       3. Programas de capacitação
       4. ROI demonstrável em 6 meses
```

## Estrutura do Projeto

```
b2shift-cluster-agent/
├── b2shift_cluster/
│   ├── __init__.py
│   ├── agent.py                 # Root Agent principal
│   ├── prompts.py              # Templates de prompts
│   ├── tools.py                # Ferramentas customizadas
│   ├── sub_agents/
│   │   ├── __init__.py
│   │   ├── data/
│   │   │   ├── agent.py        # Agente de dados
│   │   │   ├── prompts.py
│   │   │   └── tools.py
│   │   ├── cluster/
│   │   │   ├── agent.py        # Agente de clusterização
│   │   │   ├── prompts.py
│   │   │   ├── tools.py
│   │   │   └── algorithms.py   # Algoritmos ML
│   │   └── decision/
│   │       ├── agent.py        # Agente de decisões
│   │       ├── prompts.py
│   │       └── strategies.py   # Estratégias de negócio
│   ├── utils/
│   │   ├── data_loader.py      # Carregamento de dados
│   │   ├── validators.py       # Validações
│   │   └── visualizations.py   # Visualizações
│   └── models/
│       ├── customer.py         # Modelos de dados
│       └── cluster.py
├── data/
│   ├── raw/                    # Dados brutos
│   ├── processed/              # Dados processados
│   └── sample/                 # Dados de exemplo
├── tests/
│   ├── test_agents.py
│   ├── test_clustering.py
│   └── test_decisions.py
├── docs/
│   ├── architecture.md
│   ├── algorithms.md
│   └── b2shift_context.md
├── deployment/
│   ├── deploy.py
│   └── test_deployment.py
└── examples/
    ├── basic_analysis.py
    ├── custom_clustering.py
    └── strategy_generation.py
```

## Algoritmos de Clusterização

### K-Means Adaptativo
- Determinação automática do número ideal de clusters usando Elbow Method e Silhouette Score
- Otimização específica para dados B2B

### DBSCAN para Outliers
- Identificação de clientes únicos ou em transição
- Tratamento de ruído nos dados

### Clustering Hierárquico
- Análise de sub-segmentos dentro de clusters principais
- Dendrogramas para visualização de relacionamentos

## Métricas e Validação

- **Silhouette Score**: Qualidade da separação entre clusters
- **Calinski-Harabasz Index**: Variância entre/dentro dos clusters
- **Davies-Bouldin Index**: Compacidade e separação
- **Business KPIs**: ROI, retenção, lifetime value por cluster

## Decisões Estratégicas

### Framework de Recomendações

1. **Análise de Perfil**: Características demográficas e comportamentais
2. **Potencial de Negócio**: Revenue potential e probabilidade de conversão
3. **Estratégias Personalizadas**: Abordagens específicas por cluster
4. **Métricas de Sucesso**: KPIs para acompanhamento

### Tipos de Recomendações

- **Produtos/Serviços**: Quais soluções oferecer
- **Canais de Comunicação**: Como abordar cada segmento
- **Preços**: Estratégias de pricing personalizadas
- **Timing**: Quando fazer cada abordagem

## Testes

```bash
# Executar todos os testes
poetry run pytest

# Testes específicos
poetry run pytest tests/test_clustering.py
poetry run pytest tests/test_decisions.py

# Testes de integração
poetry run pytest tests/integration/
```

## Deploy

```bash
# Deploy para Vertex AI Agent Engine
cd deployment/
python deploy.py --create

# Teste do deployment
python test_deployment.py --resource_id=<RESOURCE_ID>
```

## Exemplos de Uso

### Análise Básica
```python
from b2shift_cluster import B2ShiftAgent

agent = B2ShiftAgent()
result = agent.analyze_customers("Identifique os principais segmentos de clientes")
```

### Clustering Customizado
```python
from b2shift_cluster.sub_agents.cluster import ClusterAgent

cluster_agent = ClusterAgent()
clusters = cluster_agent.run_clustering(
    data=customer_data,
    algorithm="kmeans",
    features=["revenue", "industry", "size"]
)
```

### Geração de Estratégias
```python
from b2shift_cluster.sub_agents.decision import DecisionAgent

decision_agent = DecisionAgent()
strategies = decision_agent.generate_strategies(cluster_id=1)
```

## Roadmap

- [ ] Integração com CRM TOTVS
- [ ] Análise de séries temporais
- [ ] Predição de churn por cluster
- [ ] A/B testing automatizado
- [ ] Dashboard executivo em tempo real
- [ ] API REST para integração externa

## Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## Licença

Este projeto está licenciado sob a Licença Apache 2.0 - veja o arquivo [LICENSE](LICENSE) para detalhes.

## Equipe

- **Data Science Team**: Implementação dos algoritmos de ML
- **Engineering Team**: Arquitetura e integração ADK
- **Business Team**: Definição de estratégias e KPIs
- **TOTVS Partnership**: Contexto B2Shift e validação de negócio

## Suporte

Para dúvidas e suporte:
- 📧 Email: support@b2shift-agent.com
- 📚 Documentação: [docs.b2shift-agent.com](docs.b2shift-agent.com)
- 🐛 Issues: Use o GitHub Issues para reportar bugs
- 💬 Discussões: GitHub Discussions para perguntas gerais

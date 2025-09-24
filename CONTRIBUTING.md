# 📋 CONTRIBUTING.md

Obrigado por contribuir com o projeto AI-B2Shift! Este documento fornece diretrizes para contribuições.

## 🤝 Como Contribuir

### 1. Fork e Clone

```bash
# Fork no GitHub, depois clone
git clone https://github.com/seu-usuario/AI-B2Shift.git
cd AI-B2Shift

# Configure o remote upstream
git remote add upstream https://github.com/original-repo/AI-B2Shift.git
```

### 2. Configuração do Ambiente

```bash
# Para AI Agentic
cd AIAgentic/b2shift-cluster-agent-adk/b2shift-cluster-agent
poetry install

# Para ML/Data Science
cd AICluster
pip install -r requirements.txt

# Para Infraestrutura
cd GCP-IaaC/gcp-b2bshift-iac
terraform init
```

### 3. Workflow de Contribuição

```bash
# Criar nova branch
git checkout -b feature/nova-funcionalidade

# Fazer mudanças e commits
git add .
git commit -m "Add: nova funcionalidade X"

# Push e criar PR
git push origin feature/nova-funcionalidade
```

## 📝 Padrões de Código

### Python (AI Agents & ML)
- **PEP 8**: Style guide padrão
- **Type Hints**: Sempre usar quando possível
- **Docstrings**: Google style docstrings
- **Tests**: Mínimo 80% coverage

```python
def analyze_customer_cluster(
    customer_data: pd.DataFrame, 
    algorithm: str = "kmeans"
) -> ClusterResult:
    """
    Analisa clusterização de clientes usando algoritmo especificado.
    
    Args:
        customer_data: DataFrame com dados dos clientes
        algorithm: Algoritmo de clustering ("kmeans", "dbscan", "hierarchical")
    
    Returns:
        ClusterResult com labels e métricas de qualidade
        
    Raises:
        ValueError: Se algorithm não for suportado
    """
    if algorithm not in ["kmeans", "dbscan", "hierarchical"]:
        raise ValueError(f"Algoritmo {algorithm} não suportado")
    
    # Implementação...
    return result
```

### Terraform (Infrastructure)
- **HCL Best Practices**: Formatting consistente
- **Modules**: Código reutilizável
- **Variables**: Todas com descrição e tipo
- **Outputs**: Documentar recursos importantes

```hcl
variable "project_id" {
  description = "GCP Project ID para deploy dos recursos"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.project_id))
    error_message = "Project ID deve seguir naming conventions do GCP."
  }
}

resource "google_bigquery_dataset" "main" {
  dataset_id                  = var.dataset_name
  friendly_name              = "B2Shift ${title(var.environment)} Dataset"
  description                = "Dataset para dados ${var.layer} do B2Shift"
  location                   = var.region
  default_table_expiration_ms = var.table_expiration_ms

  labels = {
    environment = var.environment
    team        = "data-engineering"
    project     = "b2shift"
  }

  access {
    role          = "OWNER"
    user_by_email = var.dataset_owner_email
  }

  lifecycle {
    prevent_destroy = true
  }
}
```

### SQL (Data Transformations)
- **Style Guide**: Usar SQL Style Guide
- **Naming**: snake_case para tabelas e colunas
- **Comments**: Documentar lógica complexa
- **Performance**: Sempre considerar partitioning e clustering

```sql
-- Análise de Customer 360 com métricas agregadas
-- Atualizado diariamente via Airflow DAG
WITH customer_metrics AS (
  SELECT 
    c.customer_id,
    c.company_name,
    c.industry,
    c.customer_tier,
    
    -- Métricas financeiras
    COALESCE(SUM(s.total_value), 0) AS total_revenue_l12m,
    COALESCE(AVG(s.total_value), 0) AS avg_order_value,
    COALESCE(COUNT(DISTINCT s.sale_date), 0) AS purchase_frequency,
    
    -- Métricas de engajamento
    COALESCE(AVG(nps.nps_score), 0) AS avg_nps_score,
    COALESCE(COUNT(st.ticket_id), 0) AS support_tickets_l12m,
    
    -- Métricas de risco
    DATE_DIFF(CURRENT_DATE(), MAX(s.sale_date), DAY) AS days_since_last_purchase,
    
    CURRENT_TIMESTAMP() AS last_updated
    
  FROM `{{ var("project_id") }}.b2bshift_trusted.customers` c
  
  LEFT JOIN `{{ var("project_id") }}.b2bshift_trusted.sales` s
    ON c.customer_id = s.customer_id
    AND s.sale_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
    
  LEFT JOIN `{{ var("project_id") }}.b2bshift_trusted.nps` nps
    ON c.customer_id = nps.customer_id
    AND nps.survey_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
    
  LEFT JOIN `{{ var("project_id") }}.b2bshift_trusted.support_tickets` st
    ON c.customer_id = st.customer_id
    AND st.created_date >= DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)
  
  WHERE c.is_active = TRUE
  
  GROUP BY 1, 2, 3, 4
),

-- Cálculo de scores de saúde do cliente
customer_health AS (
  SELECT 
    *,
    
    -- Health score (0-100)
    LEAST(100, GREATEST(0, 
      (CASE 
        WHEN days_since_last_purchase <= 30 THEN 40
        WHEN days_since_last_purchase <= 90 THEN 25
        WHEN days_since_last_purchase <= 180 THEN 10
        ELSE 0
      END) +
      (CASE 
        WHEN avg_nps_score >= 9 THEN 30
        WHEN avg_nps_score >= 7 THEN 20
        WHEN avg_nps_score >= 5 THEN 10
        ELSE 0
      END) +
      (CASE 
        WHEN support_tickets_l12m = 0 THEN 20
        WHEN support_tickets_l12m <= 2 THEN 15
        WHEN support_tickets_l12m <= 5 THEN 10
        ELSE 0
      END) +
      (CASE 
        WHEN purchase_frequency >= 6 THEN 10
        WHEN purchase_frequency >= 3 THEN 5
        ELSE 0
      END)
    )) AS health_score,
    
    -- Churn risk segmentation
    CASE 
      WHEN days_since_last_purchase > 180 OR avg_nps_score < 5 THEN 'HIGH'
      WHEN days_since_last_purchase > 90 OR avg_nps_score < 7 THEN 'MEDIUM'
      ELSE 'LOW'
    END AS churn_risk_segment
    
  FROM customer_metrics
)

-- Final customer 360 view
SELECT 
  customer_id,
  company_name,
  industry,
  customer_tier,
  total_revenue_l12m,
  avg_order_value,
  purchase_frequency,
  avg_nps_score,
  support_tickets_l12m,
  days_since_last_purchase,
  health_score,
  churn_risk_segment,
  
  -- Segmentação de valor
  CASE 
    WHEN total_revenue_l12m >= 100000 THEN 'ENTERPRISE'
    WHEN total_revenue_l12m >= 50000 THEN 'MID_MARKET'
    WHEN total_revenue_l12m >= 10000 THEN 'SMB'
    ELSE 'STARTER'
  END AS value_segment,
  
  last_updated

FROM customer_health

ORDER BY total_revenue_l12m DESC;
```

## 🧪 Testes

### Python Tests

```python
# test_clustering.py
import pytest
import pandas as pd
import numpy as np
from b2shift_cluster.algorithms import adaptive_kmeans

class TestAdaptiveKMeans:
    """Testes para algoritmo K-Means adaptativo."""
    
    def setup_method(self):
        """Setup executado antes de cada teste."""
        np.random.seed(42)
        self.sample_data = pd.DataFrame({
            'feature_1': np.random.normal(0, 1, 1000),
            'feature_2': np.random.normal(0, 1, 1000),
            'feature_3': np.random.uniform(0, 1, 1000)
        })
    
    def test_optimal_clusters_detection(self):
        """Testa se detecta número ótimo de clusters."""
        result = adaptive_kmeans(self.sample_data, max_clusters=10)
        
        assert result.n_clusters >= 2
        assert result.n_clusters <= 10
        assert result.silhouette_score > 0.0
    
    def test_empty_data_handling(self):
        """Testa tratamento de dados vazios."""
        with pytest.raises(ValueError, match="Dataset não pode estar vazio"):
            adaptive_kmeans(pd.DataFrame())
    
    def test_single_cluster_data(self):
        """Testa dados com apenas um cluster natural."""
        # Dados com baixa variância (um cluster natural)
        single_cluster_data = pd.DataFrame({
            'x': np.random.normal(0, 0.1, 100),
            'y': np.random.normal(0, 0.1, 100)
        })
        
        result = adaptive_kmeans(single_cluster_data)
        assert result.n_clusters <= 3  # Não deve forçar muitos clusters

@pytest.fixture
def mock_bigquery_client():
    """Mock client do BigQuery para testes."""
    from unittest.mock import Mock
    client = Mock()
    client.query.return_value.to_dataframe.return_value = pd.DataFrame({
        'customer_id': ['1', '2', '3'],
        'revenue': [1000, 2000, 3000]
    })
    return client

def test_data_extraction(mock_bigquery_client):
    """Testa extração de dados do BigQuery."""
    from b2shift_cluster.data_agent import DataAgent
    
    agent = DataAgent(bq_client=mock_bigquery_client)
    result = agent.extract_customer_data(
        filters={'revenue_min': 1000}
    )
    
    assert len(result) == 3
    assert 'customer_id' in result.columns
    assert all(result['revenue'] >= 1000)
```

### Terraform Tests

```hcl
# tests/integration_test.go
package test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/gruntwork-io/terratest/modules/gcp"
    "github.com/stretchr/testify/assert"
)

func TestTerraformGcpExample(t *testing.T) {
    t.Parallel()

    projectID := "test-b2shift-project"
    region := "us-central1"

    terraformOptions := &terraform.Options{
        TerraformDir: "../gcp-b2bshift-iac",
        Vars: map[string]interface{}{
            "project_id": projectID,
            "region":     region,
            "environment": "test",
        },
    }

    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    // Validate BigQuery dataset creation
    datasetName := terraform.Output(t, terraformOptions, "bigquery_dataset_id")
    dataset := gcp.GetBigQueryDataset(t, projectID, datasetName)
    assert.Equal(t, datasetName, dataset.DatasetID)

    // Validate Cloud Storage bucket creation
    bucketName := terraform.Output(t, terraformOptions, "storage_bucket_name")
    gcp.AssertStorageBucketExists(t, bucketName)

    // Validate Vertex AI resources
    endpointName := terraform.Output(t, terraformOptions, "vertex_ai_endpoint")
    assert.NotEmpty(t, endpointName)
}
```

## 📋 Pull Request Process

### Checklist do PR

- [ ] **Código testado**: Todos os testes passam
- [ ] **Documentação atualizada**: READMEs e docstrings
- [ ] **Changelog atualizado**: Se aplicável
- [ ] **Performance verificada**: Não degrada performance
- [ ] **Security review**: Sem vulnerabilidades introduzidas

### Template de PR

```markdown
## Descrição
Breve descrição das mudanças implementadas.

## Tipo de Mudança
- [ ] Bug fix (non-breaking change)
- [ ] Nova feature (non-breaking change)
- [ ] Breaking change (causa quebra na compatibilidade)
- [ ] Documentação
- [ ] Refactoring

## Como foi testado?
Descreva os testes realizados para verificar as mudanças.

## Checklist
- [ ] Código segue style guides do projeto
- [ ] Self-review realizada
- [ ] Código comentado em áreas complexas
- [ ] Documentação atualizada
- [ ] Testes adicionados/atualizados
- [ ] Todos os testes passam
- [ ] Não há warnings ou erros de lint

## Screenshots (se aplicável)
Adicione screenshots para mudanças visuais.

## Impacto
- **Usuários afetados**: 
- **Breaking changes**: 
- **Rollback plan**: 
```

## 🏷️ Convenções de Commit

### Formato

```
tipo(escopo): descrição breve

Descrição mais detalhada se necessário.

- Lista de mudanças importantes
- Outra mudança

Closes #123
```

### Tipos de Commit

| Tipo | Descrição | Exemplo |
|------|-----------|---------|
| `feat` | Nova funcionalidade | `feat(clustering): add DBSCAN algorithm` |
| `fix` | Correção de bug | `fix(data): handle missing values in customer data` |
| `docs` | Documentação | `docs(readme): update installation instructions` |
| `style` | Formatação | `style(python): fix PEP 8 violations` |
| `refactor` | Refatoração | `refactor(agents): simplify agent orchestration` |
| `perf` | Performance | `perf(ml): optimize clustering for large datasets` |
| `test` | Testes | `test(clustering): add unit tests for k-means` |
| `chore` | Tarefas build/CI | `chore(deps): update tensorflow to 2.10.0` |

### Escopos Sugeridos

- `agents`: Sistema de AI Agents
- `clustering`: Algoritmos de clusterização
- `data`: Processamento de dados
- `infrastructure`: Terraform/GCP
- `ml`: Machine Learning
- `api`: APIs e interfaces
- `docs`: Documentação
- `tests`: Testes

## 🐛 Reportando Bugs

### Template de Bug Report

```markdown
**Descrição do Bug**
Descrição clara do que está acontecendo.

**Como Reproduzir**
Passos para reproduzir o bug:
1. Vá para '...'
2. Clique em '...'
3. Execute '...'
4. Veja o erro

**Comportamento Esperado**
Descrição do que deveria acontecer.

**Screenshots**
Se aplicável, adicione screenshots.

**Ambiente**
- OS: [e.g. macOS 12.1]
- Python: [e.g. 3.9.7]
- Terraform: [e.g. 1.3.0]
- Browser: [e.g. Chrome 96]

**Informações Adicionais**
Qualquer contexto adicional sobre o problema.

**Logs de Erro**
```
Paste error logs here
```

**Labels Sugeridas**
- bug
- priority/high|medium|low
- component/agents|ml|infrastructure
```

## 💡 Solicitando Features

### Template de Feature Request

```markdown
**Problema/Necessidade**
Descrição clara do problema que a feature resolveria.

**Solução Proposta**
Descrição detalhada da solução desejada.

**Alternativas Consideradas**
Outras soluções que foram consideradas.

**Impacto no Usuário**
Como essa feature beneficiaria os usuários?

**Complexidade Técnica**
- [ ] Baixa (1-2 dias)
- [ ] Média (1 semana)
- [ ] Alta (>1 semana)

**Dependências**
Lista de dependências ou pré-requisitos.

**Mockups/Wireframes**
Se aplicável, adicione mockups visuais.

**Labels Sugeridas**
- enhancement
- priority/high|medium|low
- component/agents|ml|infrastructure
```

## 📊 Métricas de Contribuição

### Reconhecimento

Contribuidores destacados são reconhecidos através de:
- **Hall of Fame** no README principal
- **Badges especiais** no GitHub profile
- **Convites** para apresentar em eventos
- **Swag** do projeto (camisetas, stickers)

### Estatísticas

Acompanhamos:
- **Lines of code** contributed
- **Issues** resolved
- **PRs** merged  
- **Code reviews** performed
- **Documentation** contributions

## 🎓 Learning Resources

### Para Contribuidores Novos

- **Google ADK Documentation**: [Link para docs oficiais]
- **Terraform Best Practices**: [Link para guia]
- **BigQuery SQL Reference**: [Link para referência]
- **Python ML Libraries**: [Links para tutoriais]

### Para Contribuidores Avançados

- **Architecture Deep Dive**: [Link para documentação técnica]
- **Performance Optimization**: [Link para guias]
- **Security Guidelines**: [Link para security docs]
- **MLOps Best Practices**: [Link para MLOps guides]

---

## 📞 Dúvidas?

- **💬 GitHub Discussions**: Para perguntas gerais
- **🔧 Issues**: Para bugs e problemas técnicos  
- **📧 Email**: contributing@b2shift.com
- **📱 Slack**: #contributors (invite only)

---

**Obrigado por contribuir para o AI-B2Shift! 🚀**

*Cada contribuição, por menor que seja, faz a diferença na construção de uma plataforma de IA de classe mundial.*

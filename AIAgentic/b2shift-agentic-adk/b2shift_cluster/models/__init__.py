"""
Modelos de dados para o B2Shift Customer Clustering Agent.

Este módulo define as estruturas de dados utilizadas para representar
clientes, clusters e estratégias de negócio no contexto B2Shift.
"""

from dataclasses import dataclass
from typing import List, Dict, Any, Optional
from datetime import datetime
from enum import Enum


class CompanySize(Enum):
    """Enum para tamanho de empresa."""
    STARTUP = "startup"
    SMALL = "small"
    MEDIUM = "medium"
    LARGE = "large"
    ENTERPRISE = "enterprise"


class Industry(Enum):
    """Enum para indústrias principais."""
    TECHNOLOGY = "technology"
    MANUFACTURING = "manufacturing"
    RETAIL = "retail"
    FINANCIAL = "financial"
    HEALTHCARE = "healthcare"
    GOVERNMENT = "government"
    EDUCATION = "education"
    OTHER = "other"


class PaymentHealth(Enum):
    """Enum para situação de pagamento."""
    CURRENT = "current"
    LATE = "late"
    AT_RISK = "at_risk"
    DELINQUENT = "delinquent"


@dataclass
class CustomerProfile:
    """
    Perfil completo de um cliente B2B no contexto B2Shift.
    """
    # Identificação
    customer_id: str
    company_name: str
    industry: Industry
    company_size: CompanySize
    
    # Dados demográficos/firmográficos
    annual_revenue: float
    employee_count: int
    location: str
    account_age_months: int
    
    # Métricas de engajamento
    monthly_active_users: int
    feature_adoption_score: float
    support_ticket_count: int
    training_sessions_completed: int
    
    # Métricas financeiras
    mrr: float  # Monthly Recurring Revenue
    lifetime_value: float
    churn_risk_score: float
    payment_health: PaymentHealth
    
    # Dados comportamentais
    login_frequency: float
    session_duration_avg: float
    api_calls_monthly: int
    integrations_count: int
    
    # Metadados
    created_at: datetime
    updated_at: datetime
    
    # Cluster assignment (preenchido após clusterização)
    cluster_id: Optional[int] = None
    cluster_confidence: Optional[float] = None


@dataclass
class ClusterResult:
    """
    Resultado da análise de clusterização.
    """
    cluster_id: int
    cluster_name: str
    cluster_description: str
    
    # Métricas do cluster
    size: int
    percentage_of_total: float
    
    # Características centrais
    typical_profile: Dict[str, Any]
    key_characteristics: List[str]
    
    # Métricas de negócio
    avg_revenue: float
    avg_ltv: float
    avg_churn_risk: float
    retention_rate: float
    
    # Métricas de qualidade do cluster
    intra_cluster_distance: float
    silhouette_score: float
    
    # Clientes no cluster
    customer_ids: List[str]
    
    
@dataclass
class BusinessStrategy:
    """
    Estratégia de negócio para um cluster específico.
    """
    cluster_id: int
    cluster_name: str
    
    # Estratégia go-to-market
    target_approach: str
    communication_channels: List[str]
    key_messages: List[str]
    
    # Estratégia de produtos
    recommended_products: List[str]
    pricing_strategy: str
    packaging_approach: str
    
    # Estratégia de suporte
    support_level: str
    onboarding_approach: str
    success_metrics: List[str]
    
    # Projeções de ROI
    expected_revenue_increase: float
    expected_retention_improvement: float
    implementation_cost: float
    projected_roi: float
    
    # Timeline e próximos passos
    implementation_timeline: str
    quick_wins: List[str]
    long_term_initiatives: List[str]
    
    # KPIs de acompanhamento
    success_kpis: List[str]
    monitoring_frequency: str


@dataclass
class ClusteringConfiguration:
    """
    Configuração para execução de algoritmos de clusterização.
    """
    algorithm: str  # 'kmeans', 'dbscan', 'hierarchical'
    features: List[str]
    
    # Parâmetros específicos do algoritmo
    n_clusters: Optional[int] = None  # Para K-means
    eps: Optional[float] = None  # Para DBSCAN
    min_samples: Optional[int] = None  # Para DBSCAN
    linkage: Optional[str] = None  # Para Hierarchical
    
    # Parâmetros de qualidade
    min_cluster_size: int = 50
    max_clusters: int = 10
    quality_threshold: float = 0.5
    
    # Preprocessing
    scale_features: bool = True
    handle_outliers: bool = True
    feature_selection: bool = True


@dataclass
class PredictionResult:
    """
    Resultado de predição de comportamento de cliente.
    """
    customer_id: str
    cluster_id: int
    prediction_horizon: str
    
    # Predições principais
    churn_probability: float
    upgrade_probability: float
    expansion_probability: float
    renewal_probability: float
    
    # Oportunidades identificadas
    cross_sell_opportunities: List[str]
    upsell_opportunities: List[str]
    
    # Fatores de risco
    risk_factors: List[str]
    mitigation_strategies: List[str]
    
    # Ações recomendadas
    recommended_actions: List[str]
    optimal_timing: Dict[str, str]
    
    # Confiança da predição
    confidence_score: float
    prediction_date: datetime


@dataclass
class B2ShiftAnalysisReport:
    """
    Relatório completo de análise B2Shift.
    """
    analysis_id: str
    analysis_date: datetime
    
    # Dados de entrada
    total_customers: int
    features_analyzed: List[str]
    configuration: ClusteringConfiguration
    
    # Resultados de clusterização
    clusters_identified: List[ClusterResult]
    clustering_quality_score: float
    
    # Estratégias geradas
    business_strategies: List[BusinessStrategy]
    
    # Insights principais
    key_insights: List[str]
    actionable_recommendations: List[str]
    
    # Métricas de impacto
    projected_revenue_impact: float
    projected_retention_impact: float
    implementation_priority: List[str]
    
    # Próximos passos
    next_actions: List[str]
    monitoring_plan: str
    review_schedule: str

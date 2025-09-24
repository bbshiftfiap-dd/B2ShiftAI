"""
B2Shift Customer Clustering and Decision Agent

Este módulo implementa o agente principal para análise de clusterização de clientes
no contexto do B2Shift TOTVS, focando em segmentação inteligente e tomada de decisões
estratégicas baseadas em dados.

O agente utiliza machine learning para identificar padrões de comportamento de clientes
B2B e gera recomendações personalizadas para cada segmento identificado.
"""

import os
from datetime import date
from typing import Dict, Any

from google.genai import types
from google.adk.agents import Agent
from google.adk.agents.callback_context import CallbackContext
from google.adk.tools import load_artifacts

from .sub_agents import cluster_agent, data_agent, decision_agent
from .prompts import return_instructions_root
from .tools import (
    call_data_agent,
    call_cluster_agent, 
    call_decision_agent,
    analyze_customer_clusters,
    generate_business_strategies
)

date_today = date.today()


def setup_b2shift_context(callback_context: CallbackContext):
    """
    Configura o contexto específico do B2Shift antes da execução do agente.
    
    Esta função inicializa:
    - Configurações de data sources (BigQuery, CRM TOTVS, etc.)
    - Parâmetros de clusterização específicos do B2Shift
    - Contexto de negócio e métricas KPI
    - Schema de dados de clientes B2B
    """
    
    # Configurações de fonte de dados
    if "data_sources" not in callback_context.state:
        data_config = {
            "primary_source": "BigQuery",
            "crm_integration": "TOTVS",
            "real_time_stream": "Pub/Sub",
            "data_warehouse": "BigQuery"
        }
        callback_context.state["data_sources"] = data_config

    # Configurações específicas do B2Shift
    if "b2shift_config" not in callback_context.state:
        b2shift_config = {
            "min_cluster_size": int(os.getenv("B2SHIFT_MIN_CLUSTER_SIZE", 50)),
            "max_clusters": int(os.getenv("B2SHIFT_MAX_CLUSTERS", 10)),
            "confidence_threshold": float(os.getenv("B2SHIFT_CONFIDENCE_THRESHOLD", 0.8)),
            "business_segments": [
                "enterprise", "mid-market", "smb", "startup", "government"
            ],
            "key_metrics": [
                "revenue", "retention_rate", "growth_rate", "engagement_score",
                "product_adoption", "support_tickets", "payment_behavior"
            ]
        }
        callback_context.state["b2shift_config"] = b2shift_config

    # Schema de dados de clientes B2B
    customer_schema = """
    -- Tabela principal de clientes B2Shift
    CREATE TABLE `customers` (
        customer_id STRING,
        company_name STRING,
        industry STRING,
        company_size STRING, -- startup, small, medium, large, enterprise
        annual_revenue NUMERIC,
        employee_count INTEGER,
        location STRING,
        account_age_months INTEGER,
        
        -- Métricas de engajamento
        monthly_active_users INTEGER,
        feature_adoption_score FLOAT64,
        support_ticket_count INTEGER,
        training_sessions_completed INTEGER,
        
        -- Métricas financeiras
        mrr NUMERIC, -- Monthly Recurring Revenue
        lifetime_value NUMERIC,
        churn_risk_score FLOAT64,
        payment_health STRING, -- current, late, at_risk
        
        -- Dados comportamentais
        login_frequency FLOAT64,
        session_duration_avg FLOAT64,
        api_calls_monthly INTEGER,
        integrations_count INTEGER,
        
        created_at TIMESTAMP,
        updated_at TIMESTAMP
    );

    -- Tabela de transações e uso de produtos
    CREATE TABLE `customer_usage` (
        customer_id STRING,
        product_module STRING,
        usage_metric STRING,
        usage_value NUMERIC,
        usage_date DATE
    );

    -- Tabela de eventos de clientes
    CREATE TABLE `customer_events` (
        customer_id STRING,
        event_type STRING, -- login, feature_use, support_contact, payment, etc.
        event_timestamp TIMESTAMP,
        event_details JSON
    );
    """

    # Atualizar instruções do agente com schema
    if hasattr(callback_context._invocation_context, 'agent'):
        callback_context._invocation_context.agent.instruction = (
            return_instructions_root() + f"""

        --------- Schema de Dados B2Shift - Clientes B2B TOTVS ---------
        {customer_schema}

        --------- Contexto de Negócio B2Shift ---------
        
        O B2Shift é uma iniciativa da TOTVS para transformação digital de empresas B2B.
        Foco principal:
        
        1. **Segmentação Inteligente**: Identificar grupos de clientes com comportamentos similares
        2. **Personalização**: Adaptar estratégias para cada segmento
        3. **Predição**: Antecipar necessidades e comportamentos de clientes
        4. **Otimização**: Alocar recursos eficientemente baseado nos clusters
        
        **Clusters Típicos Esperados**:
        - Empresas Enterprise: Grande porte, alta complexidade, foco em compliance
        - Mid-Market Tech: Empresas médias tecnológicas, crescimento rápido
        - SMB Tradicional: Pequenas/médias empresas, foco em eficiência
        - Startups: Jovens empresas, alta necessidade de suporte
        - Government: Setor público, processos específicos
        
        **Métricas Chave de Sucesso**:
        - Revenue per cluster
        - Retention rate por segmento  
        - Customer satisfaction score
        - Product adoption rate
        - Time to value
        - Churn prediction accuracy

        """
    )


# Agente principal B2Shift
b2shift_root_agent = Agent(
    model=os.getenv("ROOT_AGENT_MODEL", "gemini-1.5-pro"),
    name="b2shift_cluster_agent",
    instruction=return_instructions_root(),
    global_instruction=(
        f"""
        Você é o B2Shift Customer Clustering and Decision Agent da TOTVS.
        
        Sua missão é analisar dados de clientes B2B para identificar clusters comportamentais
        significativos e gerar estratégias de negócio personalizadas para cada segmento.
        
        Capacidades principais:
        1. Análise avançada de clusterização de clientes B2B
        2. Identificação de padrões comportamentais e de negócio
        3. Geração de insights estratégicos por segmento
        4. Recomendações de ações comerciais e de produto
        5. Predição de comportamentos futuros de clientes
        
        Contexto: TOTVS B2Shift - Transformação Digital B2B
        Data de hoje: {date_today}
        
        Sempre priorize:
        - Qualidade dos clusters (alta separação, baixa variância intra-cluster)
        - Insights acionáveis para equipes comerciais e de produto
        - ROI demonstrável das recomendações
        - Explicabilidade das decisões tomadas
        """
    ),
    sub_agents=[cluster_agent, data_agent, decision_agent],
    tools=[
        call_data_agent,
        call_cluster_agent,
        call_decision_agent,
        analyze_customer_clusters,
        generate_business_strategies,
        load_artifacts,
    ],
    before_agent_callback=setup_b2shift_context,
    generate_content_config=types.GenerateContentConfig(
        temperature=0.1,  # Baixa temperatura para decisões mais consistentes
        top_p=0.9,
        max_output_tokens=4096
    ),
)


def main():
    """
    Função principal para execução via CLI.
    """
    import argparse
    import asyncio
    
    parser = argparse.ArgumentParser(description="B2Shift Customer Clustering Agent")
    parser.add_argument("--query", "-q", type=str, 
                       default="Analise os dados de clientes e identifique os principais clusters de comportamento",
                       help="Query para análise de clusterização")
    parser.add_argument("--mode", "-m", choices=["analyze", "recommend", "predict"], 
                       default="analyze",
                       help="Modo de operação do agente")
    
    args = parser.parse_args()
    
    async def run_agent():
        response = await b2shift_root_agent.send_message_async(args.query)
        print("\n" + "="*80)
        print("B2SHIFT CUSTOMER CLUSTERING ANALYSIS")
        print("="*80)
        print(response.text)
        print("="*80 + "\n")
    
    asyncio.run(run_agent())


if __name__ == "__main__":
    main()

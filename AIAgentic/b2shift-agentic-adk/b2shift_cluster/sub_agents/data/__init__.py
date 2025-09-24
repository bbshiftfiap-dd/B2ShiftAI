"""
Data Agent para o B2Shift Customer Clustering Agent.

Este agente é responsável por:
- Extração de dados de clientes do BigQuery/CRM TOTVS
- Validação e limpeza de dados
- Feature engineering específico para análise B2B
- Preparação de datasets para clusterização
"""

import os
from google.adk.agents import Agent
from google.adk.code_executors import VertexAiCodeExecutor

from ..prompts import return_instructions_data_agent


data_agent = Agent(
    model=os.getenv("DATA_AGENT_MODEL", "gemini-1.5-flash"),
    name="b2shift_data_agent",
    instruction=return_instructions_data_agent(),
    code_executor=VertexAiCodeExecutor(
        optimize_data_file=True,
        stateful=True,
    ),
)

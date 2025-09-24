"""
Cluster Agent para o B2Shift Customer Clustering Agent.

Este agente é responsável por:
- Execução de algoritmos de clusterização (K-means, DBSCAN, Hierarchical)
- Determinação do número optimal de clusters
- Validação de qualidade com métricas estatísticas
- Caracterização de perfis de cada cluster
- Geração de visualizações interpretáveis
"""

import os
from google.adk.agents import Agent
from google.adk.code_executors import VertexAiCodeExecutor

from ..prompts import return_instructions_cluster_agent


cluster_agent = Agent(
    model=os.getenv("CLUSTER_AGENT_MODEL", "gemini-1.5-flash"),
    name="b2shift_cluster_agent",
    instruction=return_instructions_cluster_agent(),
    code_executor=VertexAiCodeExecutor(
        optimize_data_file=True,
        stateful=True,
    ),
)

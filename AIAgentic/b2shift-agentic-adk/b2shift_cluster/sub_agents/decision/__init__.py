"""
Decision Agent para o B2Shift Customer Clustering Agent.

Este agente é responsável por:
- Análise de implicações de negócio de cada cluster
- Geração de estratégias comerciais personalizadas
- Cálculo de potencial de ROI por segmento
- Definição de KPIs e métricas de acompanhamento
- Recomendações de ações concretas e mensuráveis
"""

import os
from google.adk.agents import Agent

from ..prompts import return_instructions_decision_agent


decision_agent = Agent(
    model=os.getenv("DECISION_AGENT_MODEL", "gemini-1.5-pro"),
    name="b2shift_decision_agent", 
    instruction=return_instructions_decision_agent(),
)

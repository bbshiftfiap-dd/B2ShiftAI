# B2Shift Customer Clustering Analysis Agent

## Copyright 2025 FIAP Team
## Licensed under the Apache License, Version 2.0

from .agent import b2shift_root_agent
from .sub_agents import cluster_agent, data_agent, decision_agent
from .tools import (
    analyze_customer_clusters,
    generate_business_strategies,
    evaluate_cluster_quality,
    predict_customer_behavior
)
from .models import CustomerProfile, ClusterResult, BusinessStrategy

__version__ = "0.1.0"
__author__ = "FIAP Data Science Team"

__all__ = [
    "b2shift_root_agent",
    "cluster_agent", 
    "data_agent",
    "decision_agent",
    "analyze_customer_clusters",
    "generate_business_strategies",
    "evaluate_cluster_quality",
    "predict_customer_behavior",
    "CustomerProfile",
    "ClusterResult", 
    "BusinessStrategy"
]

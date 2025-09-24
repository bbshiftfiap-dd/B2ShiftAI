#!/usr/bin/env python3
"""
Setup script para o B2Shift Customer Clustering Agent.

Este script automatiza a configuração inicial do ambiente, incluindo:
- Verificação de dependências
- Configuração de variáveis de ambiente
- Setup do Google Cloud
- Criação de datasets de exemplo
- Testes básicos de funcionamento
"""

import os
import sys
import subprocess
import json
import shutil
from pathlib import Path
from typing import Dict, Any

import pandas as pd
import numpy as np
from datetime import datetime, timedelta


class B2ShiftSetup:
    """
    Classe para setup e configuração do B2Shift Agent.
    """
    
    def __init__(self):
        self.project_root = Path(__file__).parent
        self.env_file = self.project_root / ".env"
        self.sample_data_dir = self.project_root / "data" / "sample"
        
    def check_dependencies(self) -> bool:
        """
        Verifica se todas as dependências estão instaladas.
        """
        print("🔍 Verificando dependências...")
        
        required_packages = [
            "google-adk",
            "pandas", 
            "numpy",
            "scikit-learn",
            "plotly",
            "python-dotenv"
        ]
        
        missing_packages = []
        
        for package in required_packages:
            try:
                __import__(package.replace("-", "_"))
                print(f"  ✅ {package}")
            except ImportError:
                print(f"  ❌ {package}")
                missing_packages.append(package)
        
        if missing_packages:
            print(f"\n⚠️  Pacotes ausentes: {', '.join(missing_packages)}")
            print("Execute: poetry install")
            return False
        
        print("✅ Todas as dependências estão instaladas!")
        return True
    
    def setup_environment(self) -> bool:
        """
        Configura variáveis de ambiente.
        """
        print("\n🔧 Configurando variáveis de ambiente...")
        
        if self.env_file.exists():
            print(f"  ℹ️  Arquivo .env já existe: {self.env_file}")
            return True
        
        # Copiar do template
        env_example = self.project_root / ".env.example"
        if env_example.exists():
            shutil.copy(env_example, self.env_file)
            print(f"  ✅ Arquivo .env criado a partir do template")
            
            print("\n📝 AÇÃO NECESSÁRIA:")
            print("  1. Edite o arquivo .env com suas configurações")
            print("  2. Configure seu Google Cloud Project ID")
            print("  3. Configure credenciais do BigQuery se necessário")
            
            return True
        else:
            print(f"  ❌ Template .env.example não encontrado")
            return False
    
    def create_sample_data(self) -> bool:
        """
        Cria dados de exemplo para testes.
        """
        print("\n📊 Criando dados de exemplo...")
        
        # Criar diretório se não existir
        self.sample_data_dir.mkdir(parents=True, exist_ok=True)
        
        # Gerar dataset de clientes B2B de exemplo
        customers_data = self.generate_sample_customers(1000)
        
        # Salvar como CSV
        customers_file = self.sample_data_dir / "sample_customers.csv"
        customers_data.to_csv(customers_file, index=False)
        print(f"  ✅ Dados de clientes salvos: {customers_file}")
        
        # Gerar eventos de uso
        usage_data = self.generate_sample_usage(customers_data, 5000)
        usage_file = self.sample_data_dir / "sample_usage.csv"
        usage_data.to_csv(usage_file, index=False)
        print(f"  ✅ Dados de uso salvos: {usage_file}")
        
        # Criar resumo dos dados
        self.create_data_summary(customers_data, usage_data)
        
        return True
    
    def generate_sample_customers(self, n_customers: int) -> pd.DataFrame:
        """
        Gera dataset de clientes B2B de exemplo.
        """
        np.random.seed(42)
        
        # Definir distribuições realistas
        industries = ["Technology", "Manufacturing", "Retail", "Financial", "Healthcare", "Government"]
        company_sizes = ["startup", "small", "medium", "large", "enterprise"]
        locations = ["São Paulo, BR", "Rio de Janeiro, BR", "Belo Horizonte, BR", "Porto Alegre, BR", "Brasília, BR"]
        payment_statuses = ["current", "late", "at_risk"]
        
        data = []
        
        for i in range(n_customers):
            # Gerar características correlacionadas
            company_size = np.random.choice(company_sizes, p=[0.15, 0.25, 0.30, 0.20, 0.10])
            
            # Revenue baseado no tamanho da empresa
            if company_size == "startup":
                revenue = np.random.lognormal(13, 1.2)  # ~500K-2M
                employees = np.random.randint(5, 50)
            elif company_size == "small":
                revenue = np.random.lognormal(14, 0.8)  # ~1M-5M
                employees = np.random.randint(20, 100)
            elif company_size == "medium":
                revenue = np.random.lognormal(15.5, 0.6)  # ~3M-15M
                employees = np.random.randint(50, 300)
            elif company_size == "large":
                revenue = np.random.lognormal(16.8, 0.5)  # ~10M-50M
                employees = np.random.randint(200, 1000)
            else:  # enterprise
                revenue = np.random.lognormal(18, 0.7)  # ~30M-200M
                employees = np.random.randint(500, 5000)
            
            # MRR baseado no revenue (tipicamente 0.5-2% do revenue anual)
            mrr = revenue * np.random.uniform(0.005, 0.02) / 12
            
            # Métricas de engajamento correlacionadas
            base_engagement = np.random.beta(2, 2)  # 0-1
            
            customer = {
                "customer_id": f"CUST_{i+1:06d}",
                "company_name": f"Company {i+1}",
                "industry": np.random.choice(industries),
                "company_size": company_size,
                "annual_revenue": round(revenue, 2),
                "employee_count": employees,
                "location": np.random.choice(locations),
                "account_age_months": np.random.randint(1, 60),
                
                # Métricas de engajamento
                "monthly_active_users": max(1, int(employees * np.random.uniform(0.1, 0.8))),
                "feature_adoption_score": round(base_engagement * np.random.uniform(0.3, 1.0), 3),
                "support_ticket_count": np.random.poisson(max(1, employees // 50)),
                "training_sessions_completed": np.random.poisson(2),
                
                # Métricas financeiras
                "mrr": round(mrr, 2),
                "lifetime_value": round(mrr * np.random.uniform(12, 36), 2),
                "churn_risk_score": round(np.random.beta(1, 4), 3),  # Biased toward low risk
                "payment_health": np.random.choice(payment_statuses, p=[0.8, 0.15, 0.05]),
                
                # Dados comportamentais
                "login_frequency": round(base_engagement * np.random.uniform(1, 10), 2),
                "session_duration_avg": round(np.random.lognormal(3, 0.5), 2),
                "api_calls_monthly": int(base_engagement * np.random.uniform(0, 5000)),
                "integrations_count": np.random.poisson(3),
                
                # Timestamps
                "created_at": (datetime.now() - timedelta(days=np.random.randint(1, 1000))).isoformat(),
                "updated_at": datetime.now().isoformat()
            }
            
            data.append(customer)
        
        return pd.DataFrame(data)
    
    def generate_sample_usage(self, customers_df: pd.DataFrame, n_events: int) -> pd.DataFrame:
        """
        Gera dados de uso dos produtos.
        """
        np.random.seed(42)
        
        product_modules = [
            "ERP_Core", "Financial_Management", "CRM", "Analytics", 
            "Reporting", "API_Gateway", "Mobile_App", "Integrations"
        ]
        
        usage_metrics = [
            "daily_active_sessions", "feature_usage_count", "data_processed_gb",
            "reports_generated", "api_calls", "integration_sync_count"
        ]
        
        data = []
        customer_ids = customers_df["customer_id"].tolist()
        
        for i in range(n_events):
            customer_id = np.random.choice(customer_ids)
            
            # Correlacionar uso com características do cliente
            customer_info = customers_df[customers_df["customer_id"] == customer_id].iloc[0]
            base_usage = customer_info["feature_adoption_score"]
            
            usage_event = {
                "customer_id": customer_id,
                "product_module": np.random.choice(product_modules),
                "usage_metric": np.random.choice(usage_metrics),
                "usage_value": round(base_usage * np.random.lognormal(2, 1), 2),
                "usage_date": (datetime.now() - timedelta(days=np.random.randint(1, 90))).date().isoformat()
            }
            
            data.append(usage_event)
        
        return pd.DataFrame(data)
    
    def create_data_summary(self, customers_df: pd.DataFrame, usage_df: pd.DataFrame):
        """
        Cria resumo dos dados gerados.
        """
        summary_file = self.sample_data_dir / "data_summary.json"
        
        summary = {
            "generated_at": datetime.now().isoformat(),
            "customers": {
                "total_count": len(customers_df),
                "company_sizes": customers_df["company_size"].value_counts().to_dict(),
                "industries": customers_df["industry"].value_counts().to_dict(),
                "avg_revenue": float(customers_df["annual_revenue"].mean()),
                "revenue_range": [float(customers_df["annual_revenue"].min()), 
                                float(customers_df["annual_revenue"].max())],
                "avg_mrr": float(customers_df["mrr"].mean()),
                "avg_churn_risk": float(customers_df["churn_risk_score"].mean())
            },
            "usage_events": {
                "total_count": len(usage_df),
                "date_range": [usage_df["usage_date"].min(), usage_df["usage_date"].max()],
                "modules": usage_df["product_module"].value_counts().to_dict(),
                "metrics": usage_df["usage_metric"].value_counts().to_dict()
            }
        }
        
        with open(summary_file, 'w') as f:
            json.dump(summary, f, indent=2)
        
        print(f"  ✅ Resumo dos dados salvo: {summary_file}")
        
        # Imprimir estatísticas
        print(f"\n📈 Estatísticas dos Dados Gerados:")
        print(f"  👥 Clientes: {len(customers_df):,}")
        print(f"  📊 Eventos de uso: {len(usage_df):,}")
        print(f"  💰 Revenue médio: R$ {customers_df['annual_revenue'].mean():,.2f}")
        print(f"  🎯 Churn risk médio: {customers_df['churn_risk_score'].mean():.2%}")
    
    def test_agent_import(self) -> bool:
        """
        Testa se o agente pode ser importado corretamente.
        """
        print("\n🧪 Testando importação do agente...")
        
        try:
            from b2shift_cluster import b2shift_root_agent
            print("  ✅ Agente principal importado com sucesso")
            
            from b2shift_cluster.sub_agents import data_agent, cluster_agent, decision_agent
            print("  ✅ Sub-agentes importados com sucesso")
            
            from b2shift_cluster.tools import analyze_customer_clusters
            print("  ✅ Ferramentas importadas com sucesso")
            
            return True
            
        except ImportError as e:
            print(f"  ❌ Erro na importação: {e}")
            return False
    
    def run_quick_test(self) -> bool:
        """
        Executa teste rápido de funcionalidade.
        """
        print("\n⚡ Executando teste rápido...")
        
        try:
            from b2shift_cluster.tools import analyze_customer_clusters
            
            # Teste das ferramentas
            result = analyze_customer_clusters(
                cluster_data="mock_data",
                metrics_focus=["revenue", "retention_rate"]
            )
            
            if "ANÁLISE DE CLUSTERS B2SHIFT" in result:
                print("  ✅ Ferramenta de análise funcionando")
                return True
            else:
                print("  ❌ Erro na ferramenta de análise")
                return False
                
        except Exception as e:
            print(f"  ❌ Erro no teste: {e}")
            return False
    
    def print_next_steps(self):
        """
        Imprime próximos passos para o usuário.
        """
        print("\n" + "="*80)
        print("🎉 SETUP DO B2SHIFT CLUSTER AGENT CONCLUÍDO!")
        print("="*80)
        
        print("\n📋 PRÓXIMOS PASSOS:")
        print("\n1. 🔧 CONFIGURAÇÃO:")
        print("   - Edite o arquivo .env com suas configurações")
        print("   - Configure Google Cloud Project ID")
        print("   - Configure credenciais do BigQuery (opcional)")
        
        print("\n2. 🧪 TESTES:")
        print("   - Execute: python examples/basic_analysis.py")
        print("   - Execute: poetry run pytest tests/")
        print("   - Execute: poetry run adk web")
        
        print("\n3. 📊 DADOS:")
        print("   - Use os dados de exemplo em data/sample/")
        print("   - Conecte seus próprios dados de clientes")
        print("   - Configure BigQuery datasets se necessário")
        
        print("\n4. 🚀 DEPLOY:")
        print("   - Execute: python deployment/deploy.py --action create")
        print("   - Teste: python deployment/test_deployment.py")
        
        print("\n5. 📚 DOCUMENTAÇÃO:")
        print("   - Leia: docs/b2shift_context.md")
        print("   - Veja: docs/algorithms.md")
        print("   - README.md para informações completas")
        
        print("\n💡 COMANDOS ÚTEIS:")
        print("   poetry run b2shift-agent --help")
        print("   poetry run adk run b2shift_cluster")
        print("   poetry run adk web")
        
        print("\n🆘 SUPORTE:")
        print("   - GitHub Issues para reportar problemas")
        print("   - Documentação em docs/")
        print("   - Exemplos em examples/")


def main():
    """
    Função principal do setup.
    """
    print("🤖 B2SHIFT CUSTOMER CLUSTERING AGENT - SETUP")
    print("="*60)
    print("📅 Configuração em:", datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    print("🏢 Contexto: TOTVS B2Shift - Transformação Digital B2B")
    print("="*60)
    
    setup = B2ShiftSetup()
    
    success_steps = 0
    total_steps = 5
    
    # 1. Verificar dependências
    if setup.check_dependencies():
        success_steps += 1
    
    # 2. Configurar ambiente
    if setup.setup_environment():
        success_steps += 1
    
    # 3. Criar dados de exemplo
    if setup.create_sample_data():
        success_steps += 1
    
    # 4. Testar importações
    if setup.test_agent_import():
        success_steps += 1
    
    # 5. Teste rápido
    if setup.run_quick_test():
        success_steps += 1
    
    # Resultado final
    print(f"\n📊 RESULTADO: {success_steps}/{total_steps} etapas concluídas com sucesso")
    
    if success_steps == total_steps:
        print("✅ Setup completo!")
        setup.print_next_steps()
    else:
        print("⚠️  Setup parcialmente concluído. Verifique os erros acima.")
        print("   Execute novamente após resolver os problemas.")


if __name__ == "__main__":
    main()

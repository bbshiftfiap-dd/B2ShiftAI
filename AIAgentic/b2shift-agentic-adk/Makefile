# Makefile para B2Shift Customer Clustering Agent
# Facilita execução de comandos comuns de desenvolvimento e deploy

.PHONY: help install setup test demo deploy clean docs

# Variáveis
PYTHON := python
POETRY := poetry
PROJECT_NAME := b2shift-cluster-agent

# Help
help: ## Mostra este menu de ajuda
	@echo "🤖 B2Shift Customer Clustering Agent - Comandos Disponíveis"
	@echo "================================================================"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

# Instalação e Setup
install: ## Instala dependências usando Poetry
	@echo "📦 Instalando dependências..."
	$(POETRY) install
	@echo "✅ Dependências instaladas!"

setup: install ## Executa setup completo do projeto
	@echo "🔧 Executando setup do projeto..."
	$(PYTHON) setup.py
	@echo "✅ Setup concluído!"

# Testes
test: ## Executa todos os testes
	@echo "🧪 Executando testes..."
	$(POETRY) run pytest tests/ -v
	@echo "✅ Testes concluídos!"

test-agent: ## Testa apenas o agente principal
	@echo "🤖 Testando agente principal..."
	$(POETRY) run pytest tests/test_b2shift_agent.py -v

test-clustering: ## Testa algoritmos de clusterização
	@echo "📊 Testando algoritmos de clusterização..."
	$(POETRY) run pytest tests/ -k "cluster" -v

# Demonstrações
demo: ## Executa demonstração completa
	@echo "🎬 Executando demonstração completa..."
	$(PYTHON) demo.py

demo-quick: ## Executa demonstração rápida
	@echo "⚡ Executando demonstração rápida..."
	$(PYTHON) demo.py --quick

example-basic: ## Executa exemplo básico
	@echo "📖 Executando exemplo básico..."
	$(PYTHON) examples/basic_analysis.py

# Execução do Agent
run: ## Executa o agent via ADK CLI
	@echo "🚀 Executando B2Shift Agent..."
	$(POETRY) run adk run b2shift_cluster

run-web: ## Executa interface web do ADK
	@echo "🌐 Iniciando interface web..."
	$(POETRY) run adk web

run-cli: ## Executa agent via CLI customizado
	@echo "💻 Executando CLI customizado..."
	$(POETRY) run b2shift-agent

# Deploy e Cloud
deploy-create: ## Faz deploy no Vertex AI Agent Engine
	@echo "☁️ Fazendo deploy no Vertex AI..."
	$(PYTHON) deployment/deploy.py --action create

deploy-test: ## Testa deployment (requer RESOURCE_ID)
	@echo "🧪 Testando deployment..."
	@if [ -z "$(RESOURCE_ID)" ]; then \
		echo "❌ Erro: RESOURCE_ID é obrigatório"; \
		echo "Uso: make deploy-test RESOURCE_ID=seu_resource_id"; \
		exit 1; \
	fi
	$(PYTHON) deployment/test_deployment.py --resource-id $(RESOURCE_ID)

deploy-delete: ## Remove deployment (requer RESOURCE_ID)
	@echo "🗑️ Removendo deployment..."
	@if [ -z "$(RESOURCE_ID)" ]; then \
		echo "❌ Erro: RESOURCE_ID é obrigatório"; \
		echo "Uso: make deploy-delete RESOURCE_ID=seu_resource_id"; \
		exit 1; \
	fi
	$(PYTHON) deployment/deploy.py --action delete --resource-id $(RESOURCE_ID)

# Build e Package
build: ## Constrói wheel package
	@echo "🔨 Construindo package..."
	$(POETRY) build --format=wheel --output=dist/
	@echo "✅ Package construído em dist/"

build-docker: ## Constrói imagem Docker (se Dockerfile existir)
	@if [ -f Dockerfile ]; then \
		echo "🐳 Construindo imagem Docker..."; \
		docker build -t $(PROJECT_NAME) .; \
	else \
		echo "⚠️ Dockerfile não encontrado"; \
	fi

# Linting e Formatação
lint: ## Executa linting com flake8
	@echo "🔍 Executando linting..."
	$(POETRY) run flake8 b2shift_cluster/ tests/ examples/

format: ## Formata código com black
	@echo "✨ Formatando código..."
	$(POETRY) run black b2shift_cluster/ tests/ examples/

format-check: ## Verifica formatação sem alterar
	@echo "👀 Verificando formatação..."
	$(POETRY) run black --check b2shift_cluster/ tests/ examples/

# Documentação
docs: ## Gera documentação
	@echo "📚 Gerando documentação..."
	@echo "Documentação disponível em docs/"
	@ls -la docs/

docs-serve: ## Serve documentação localmente (se MkDocs estiver configurado)
	@if command -v mkdocs >/dev/null 2>&1; then \
		echo "📖 Servindo documentação..."; \
		mkdocs serve; \
	else \
		echo "📚 Documentação em docs/"; \
		echo "📄 README: README.md"; \
		echo "🏢 Contexto B2Shift: docs/b2shift_context.md"; \
		echo "🧮 Algoritmos: docs/algorithms.md"; \
	fi

# Dados e Samples
data-generate: ## Gera dados de exemplo
	@echo "📊 Gerando dados de exemplo..."
	$(PYTHON) -c "from setup import B2ShiftSetup; B2ShiftSetup().create_sample_data()"

data-clean: ## Remove dados gerados
	@echo "🧹 Limpando dados gerados..."
	rm -rf data/sample/*.csv data/sample/*.json

# Ambiente e Configuração
env-check: ## Verifica configuração do ambiente
	@echo "🔍 Verificando ambiente..."
	@echo "Python: $$($(PYTHON) --version)"
	@echo "Poetry: $$($(POETRY) --version)"
	@if [ -f .env ]; then \
		echo "✅ Arquivo .env existe"; \
	else \
		echo "⚠️ Arquivo .env não encontrado - execute 'make setup'"; \
	fi

env-template: ## Cria template .env a partir do exemplo
	@if [ ! -f .env ] && [ -f .env.example ]; then \
		echo "📝 Criando .env a partir do template..."; \
		cp .env.example .env; \
		echo "✅ Arquivo .env criado - edite com suas configurações"; \
	else \
		echo "ℹ️ Arquivo .env já existe ou template não encontrado"; \
	fi

# Limpeza
clean: ## Remove arquivos temporários e cache
	@echo "🧹 Limpando arquivos temporários..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type f -name "*.pyo" -delete 2>/dev/null || true
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	rm -rf .pytest_cache/ 2>/dev/null || true
	rm -rf dist/ 2>/dev/null || true
	rm -rf build/ 2>/dev/null || true
	@echo "✅ Limpeza concluída!"

clean-all: clean data-clean ## Remove tudo (cache, dados, builds)
	@echo "🧹 Limpeza completa realizada!"

# Status e Info
status: ## Mostra status do projeto
	@echo "📊 B2Shift Customer Clustering Agent - Status"
	@echo "=============================================="
	@echo "📁 Projeto: $(PROJECT_NAME)"
	@echo "🐍 Python: $$($(PYTHON) --version)"
	@echo "📦 Poetry: $$($(POETRY) --version)"
	@echo ""
	@echo "📂 Estrutura do Projeto:"
	@find . -maxdepth 2 -type d -name "b2shift_cluster*" -o -name "tests" -o -name "docs" -o -name "examples" -o -name "deployment" | head -10
	@echo ""
	@echo "🧪 Últimos Testes:"
	@if [ -f .pytest_cache/README.md ]; then \
		echo "✅ Cache de testes encontrado"; \
	else \
		echo "⚠️ Nenhum teste executado ainda"; \
	fi
	@echo ""
	@echo "⚙️ Configuração:"
	@if [ -f .env ]; then \
		echo "✅ Arquivo .env configurado"; \
	else \
		echo "❌ Arquivo .env não encontrado"; \
	fi

info: status ## Alias para status

# Comandos de desenvolvimento
dev-install: ## Instala dependências de desenvolvimento
	@echo "👨‍💻 Instalando dependências de desenvolvimento..."
	$(POETRY) install --with dev

dev-shell: ## Ativa shell do Poetry
	@echo "🐚 Ativando shell do Poetry..."
	$(POETRY) shell

# Quick Start
quickstart: install setup demo-quick ## Setup rápido + demo
	@echo "🚀 Quick start concluído!"
	@echo ""
	@echo "🎉 B2Shift Agent está pronto para uso!"
	@echo ""
	@echo "📋 Próximos comandos úteis:"
	@echo "  make run          # Executa o agent"
	@echo "  make run-web      # Interface web"
	@echo "  make demo         # Demo completa"
	@echo "  make test         # Executar testes"
	@echo "  make help         # Ver todos os comandos"

# Default target
.DEFAULT_GOAL := help

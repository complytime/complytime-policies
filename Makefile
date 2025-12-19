# ComplyTime Policies Makefile

# Variables
CALM_CLI := calm
ARCHITECTURE_DIR := architecture
STANDARDS_DIR := standards
PATTERNS_DIR := patterns
CONTROLS_DIR := controls
URL_MAPPING := $(STANDARDS_DIR)/url-mapping.json
ARCHITECTURES := $(wildcard $(ARCHITECTURE_DIR)/*.json)
PATTERNS := $(wildcard $(PATTERNS_DIR)/*.pattern.json)
STANDARDS := $(wildcard $(STANDARDS_DIR)/*.standard.json)
CONTROLS := $(wildcard $(CONTROLS_DIR)/*.json)

.PHONY: help validate validate-architectures validate-patterns validate-standards validate-all check-calm validate-example validate-control-files validate-deployment-examples

help: ## Display this help screen
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help



check-calm: ## Check if calm CLI is installed
	@command -v $(CALM_CLI) >/dev/null 2>&1 || \
		(echo "Error: calm CLI not found. Install with: npm install -g @finos/calm-cli" && exit 1)
	@echo "✓ calm CLI found: $$($(CALM_CLI) --version 2>/dev/null || echo 'installed')"


validate-architectures: check-calm ## Validate all CALM architectures
	@echo "Validating CALM architectures..."
	@ARCH_FILES=$$(ls $(ARCHITECTURE_DIR)/*.json 2>/dev/null | grep -v -E '(url-mapping|mapping)\.json$$' || true); \
	if [ -z "$$ARCH_FILES" ]; then \
		echo "No architecture files found in $(ARCHITECTURE_DIR)/"; \
		exit 1; \
	fi; \
	for arch in $$ARCH_FILES; do \
		echo "Validating $$arch..."; \
		$(CALM_CLI) validate -a $$arch || exit 1; \
	done
	@echo "✓ All architectures validated successfully"


validate-patterns: check-calm ## Validate all CALM patterns
	@echo "Validating CALM patterns..."
	@if [ -z "$(PATTERNS)" ]; then \
		echo "No pattern files found in $(STANDARDS_DIR)/"; \
		exit 1; \
	fi
	@for pattern in $(PATTERNS); do \
		echo "Validating $$pattern..."; \
		$(CALM_CLI) validate -p $$pattern -u $(URL_MAPPING) || exit 1; \
	done
	@echo "✓ All patterns validated successfully"


validate-standards: check-calm ## Validate all CALM standards (as JSON Schema)
	@echo "Validating CALM standards..."
	@if [ -z "$(STANDARDS)" ]; then \
		echo "No standard files found in $(STANDARDS_DIR)/"; \
		exit 1; \
	fi
	@for standard in $(STANDARDS); do \
		echo "Validating $$standard..."; \
		if command -v ajv >/dev/null 2>&1; then \
			ajv validate -s $$standard -d /dev/null 2>&1 || echo "Warning: ajv not available, skipping JSON Schema validation"; \
		else \
			echo "  (Skipping JSON Schema validation - install ajv-cli for full validation)"; \
		fi; \
		python3 -m json.tool $$standard > /dev/null 2>&1 || (echo "Error: $$standard is not valid JSON" && exit 1); \
	done
	@echo "✓ All standards validated successfully"


validate-example: check-calm ## Validate example architecture against deployment pattern
	@echo "Validating example architecture..."
	@if [ ! -f "$(ARCHITECTURE_DIR)/complytime-example.arch.json" ]; then \
		echo "Error: Example architecture not found"; \
		exit 1; \
	fi
	@if [ ! -f "$(PATTERNS_DIR)/complytime-deployment.pattern.json" ]; then \
		echo "Error: Deployment pattern not found"; \
		exit 1; \
	fi
	@$(CALM_CLI) validate \
		-p $(PATTERNS_DIR)/complytime-deployment.pattern.json \
		-a $(ARCHITECTURE_DIR)/complytime-example.arch.json \
		-u $(URL_MAPPING)
	@echo "✓ Example architecture validated successfully"

validate-control-files: ## Validate that control requirement files exist and conform to standards
	@echo "Validating control requirement files..."
	@python3 tools/validate-control-files.py
	@echo "✓ Control files validated successfully"

validate-deployment-examples: validate-example ## Validate all deployment examples
	@echo "✓ All deployment examples validated successfully"


docify: check-calm ## Generate visual documentation website from CALM architecture
	@echo "Generating documentation website..."
	@if [ ! -f "$(ARCHITECTURE_DIR)/complytime-example.arch.json" ]; then \
		echo "Error: Architecture file not found: $(ARCHITECTURE_DIR)/complytime-example.arch.json"; \
		exit 1; \
	fi
	@mkdir -p docs
	@$(CALM_CLI) docify \
		-a $(ARCHITECTURE_DIR)/complytime-example.arch.json \
		-o docs/ \
		-u $(URL_MAPPING) \
		--clear-output-directory
	@echo "✓ Documentation website generated in docs/ directory"
	@echo "  Run cd docs && npm install && npm start"

# Validate everything
validate: validate-architectures validate-patterns validate-standards validate-control-files validate-deployment-examples
	@echo ""
	@echo "✓ All validations passed"

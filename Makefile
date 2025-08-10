# Makefile for UniFi Helm Chart Testing
.PHONY: help test test-unit test-lint test-install clean build deps

# Default target
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Variables
CHART_DIR := charts/unifi
CHART_NAME := unifi
CT_CONFIG := ct.yaml

# Install required tools
install-tools: install-helm-unittest install-yamllint ## Install required development tools
	@echo "Required tools installed successfully!"

# Install helm-unittest plugin
install-helm-unittest: ## Install helm-unittest plugin for unit testing
	@helm plugin list | grep -q unittest || helm plugin install https://github.com/helm-unittest/helm-unittest.git

# Install chart-testing
install-chart-testing: ## Install chart-testing for chart linting and testing
	@which ct > /dev/null || brew install chart-testing

# Install yamllint
install-yamllint: ## Install yamllint for YAML linting
	@which yamllint > /dev/null || brew install yamllint

# Install kind
install-kind: ## Install kind for local Kubernetes testing
	@which kind > /dev/null || brew install kind

# Build and package chart
build: ## Build and package the chart
	@echo "Building chart..."
	@helm package $(CHART_DIR) -d dist/
	@echo "Chart built successfully!"

# Run helm unittest
test-unit: install-helm-unittest ## Run helm unittest tests
	@echo "Running helm unittest..."
	@helm unittest $(CHART_DIR)
	@echo "Unit tests completed!"

# Run chart-testing lint
test-lint: install-chart-testing install-yamllint ## Run chart-testing lint
	@echo "Running chart-testing lint..."
	@ct lint --config $(CT_CONFIG) --chart-dirs charts
	@echo "Lint tests completed!"

# Run chart-testing install (requires Kubernetes cluster)
test-install: install-chart-testing ## Run chart-testing install tests
	@echo "Running chart-testing install..."
	@echo "Note: This requires a running Kubernetes cluster"
	@ct install --config $(CT_CONFIG) --chart-dirs charts
	@echo "Install tests completed!"

# Run all tests
test: test-unit test-lint ## Run unit tests and lint tests
	@echo "All tests completed!"

# Run full test suite including install tests
test-full: test test-install ## Run all tests including install tests
	@echo "Full test suite completed!"

# Create a kind cluster for testing
kind-cluster: install-kind ## Create a kind cluster for testing
	@echo "Creating kind cluster..."
	@kind create cluster --name unifi-test || echo "Cluster already exists"
	@kubectl cluster-info --context kind-unifi-test
	@echo "Kind cluster ready!"

# Delete kind cluster
kind-clean: ## Delete the kind test cluster
	@echo "Deleting kind cluster..."
	@kind delete cluster --name unifi-test
	@echo "Kind cluster deleted!"

# Test with kind cluster
test-kind: install-kind kind-cluster test-full kind-clean ## Run full tests with temporary kind cluster
	@echo "Kind-based testing completed!"

# Clean up build artifacts
clean: ## Clean up build artifacts
	@echo "Cleaning up..."
	@rm -rf dist/
	@rm -rf $(CHART_DIR)/charts/
	@rm -f $(CHART_DIR)/Chart.lock
	@echo "Cleanup completed!"

# Development helpers
template: ## Render chart templates with default values
	@echo "Rendering chart templates..."
	@helm template test-release $(CHART_DIR)

template-debug: ## Render chart templates with debug output
	@echo "Rendering chart templates with debug..."
	@helm template test-release $(CHART_DIR) --debug

# Validate chart syntax
validate: ## Validate chart syntax
	@echo "Validating chart syntax..."
	@helm lint $(CHART_DIR)
	@echo "Chart validation completed!"

# Quick development cycle
dev: clean validate test-unit ## Quick development cycle: clean, validate, unit test
	@echo "Development cycle completed!"

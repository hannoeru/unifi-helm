# Makefile for UniFi Helm Chart Testing
.PHONY: help install-tools test test-unit test-lint test-install clean build deps

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
install-tools: ## Install helm plugins and tools
	@echo "Installing helm-unittest plugin..."
	@helm plugin list | grep -q unittest || helm plugin install https://github.com/helm-unittest/helm-unittest.git
	@echo "Installing chart-testing..."
	@which ct > /dev/null || (echo "Please install chart-testing: https://github.com/helm/chart-testing" && exit 1)
	@echo "Tools installed successfully!"

# Add helm repositories
repos: ## Add required helm repositories
	@echo "Adding helm repositories..."
	@helm repo add bitnami https://charts.bitnami.com/bitnami
	@helm repo update
	@echo "Repositories added and updated!"

# Build chart dependencies
deps: repos ## Update chart dependencies
	@echo "Updating chart dependencies..."
	@helm dependency update $(CHART_DIR)
	@echo "Dependencies updated!"

# Build and package chart
build: deps ## Build and package the chart
	@echo "Building chart..."
	@helm package $(CHART_DIR) -d dist/
	@echo "Chart built successfully!"

# Run helm unittest
test-unit: install-tools ## Run helm unittest tests
	@echo "Running helm unittest..."
	@helm unittest $(CHART_DIR)
	@echo "Unit tests completed!"

# Run chart-testing lint
test-lint: install-tools repos ## Run chart-testing lint
	@echo "Running chart-testing lint..."
	@ct lint --config $(CT_CONFIG) --chart-dirs charts
	@echo "Lint tests completed!"

# Run chart-testing install (requires Kubernetes cluster)
test-install: install-tools repos ## Run chart-testing install tests
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
kind-cluster: ## Create a kind cluster for testing
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
test-kind: kind-cluster test-full kind-clean ## Run full tests with temporary kind cluster
	@echo "Kind-based testing completed!"

# Clean up build artifacts
clean: ## Clean up build artifacts
	@echo "Cleaning up..."
	@rm -rf dist/
	@rm -rf $(CHART_DIR)/charts/
	@rm -f $(CHART_DIR)/Chart.lock
	@echo "Cleanup completed!"

# Development helpers
template: deps ## Render chart templates with default values
	@echo "Rendering chart templates..."
	@helm template test-release $(CHART_DIR)

template-debug: deps ## Render chart templates with debug output
	@echo "Rendering chart templates with debug..."
	@helm template test-release $(CHART_DIR) --debug

# Validate chart syntax
validate: deps ## Validate chart syntax
	@echo "Validating chart syntax..."
	@helm lint $(CHART_DIR)
	@echo "Chart validation completed!"

# Quick development cycle
dev: clean validate test-unit ## Quick development cycle: clean, validate, unit test
	@echo "Development cycle completed!"
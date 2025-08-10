# UniFi Helm Charts

[![Lint and Test Charts](https://github.com/hannoeru/unifi-helm/actions/workflows/lint-test.yaml/badge.svg)](https://github.com/hannoeru/unifi-helm/actions/workflows/lint-test.yaml)
[![Release Charts](https://github.com/hannoeru/unifi-helm/actions/workflows/release.yaml/badge.svg)](https://github.com/hannoeru/unifi-helm/actions/workflows/release.yaml)

A collection of Helm charts for UniFi Network infrastructure components.

## Charts

| Chart | Description | Version |
|-------|-------------|---------|
| [unifi](charts/unifi/) | UniFi Network Controller | 0.2.0 |

## Quick Start

Add the Helm repository:

```bash
helm repo add unifi https://hannoeru.github.io/unifi-helm/
helm repo update
```

Install a chart:

```bash
helm install my-unifi unifi/unifi
```

## Documentation

For detailed installation instructions, configuration options, and examples, see the individual chart documentation:

- **[UniFi Network Controller](charts/unifi/README.md)** - Complete setup guide with MongoDB Community Operator, configuration examples, and troubleshooting

## Development

### Prerequisites

- Helm 3.8+
- Docker
- Kind (for local testing)

### Setup

```bash
# Clone the repository
git clone https://github.com/hannoeru/unifi-helm.git
cd unifi-helm

# Install development tools
make install-tools

# Run tests
make test
```

### Available Make Targets

```bash
make help                 # Show available targets
make install-tools        # Install all development tools
make test                 # Run unit tests and linting
make test-full           # Run all tests including install tests
make test-kind           # Run tests with temporary kind cluster
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Run the test suite: `make test`
6. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

# UniFi Network Controller Helm Chart

[![Lint and Test Charts](https://github.com/hannoeru/unifi-helm/actions/workflows/lint-test.yaml/badge.svg)](https://github.com/hannoeru/unifi-helm/actions/workflows/lint-test.yaml)
[![Release Charts](https://github.com/hannoeru/unifi-helm/actions/workflows/release.yaml/badge.svg)](https://github.com/hannoeru/unifi-helm/actions/workflows/release.yaml)

A Helm chart for deploying the UniFi Network Controller on Kubernetes.

## Features

- 🚀 **Easy Deployment**: One-command deployment of UniFi Network Controller
- 🗄️ **MongoDB Support**: Integrated MongoDB subchart for data persistence
- 🔒 **Security**: Runs as non-root user with proper security contexts
- 📊 **Monitoring**: Built-in health checks and readiness probes
- 🌐 **Ingress**: Optional ingress configuration with TLS support
- 💾 **Persistence**: Configurable persistent storage for UniFi data
- 🔄 **High Availability**: PodDisruptionBudget support for HA deployments
- ✅ **Tested**: Comprehensive test suite with unittest and chart-testing

## Quick Start

### Prerequisites

- Kubernetes 1.19+
- Helm 3.8+

### Installation

1. Add the Helm repository:
```bash
helm repo add unifi https://hannoeru.github.io/unifi-helm/
helm repo update
```

2. Install the chart:
```bash
helm install my-unifi unifi/unifi
```

3. Access the UniFi Controller:
```bash
# Port forward to access locally
kubectl port-forward svc/my-unifi 8443:8443

# Open https://localhost:8443 in your browser
```

### Installation with MongoDB

```bash
helm install my-unifi unifi/unifi --set mongodb.enabled=true
```

## Configuration

The following table lists the configurable parameters and their default values.

### UniFi Controller Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | UniFi controller image repository | `ghcr.io/jacobalberty/unifi-docker` |
| `image.tag` | UniFi controller image tag | `v9.3.43` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `replicaCount` | Number of replicas | `1` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.deviceControl` | Device control port | `8080` |
| `service.webInterface` | Web interface port | `8443` |
| `service.stun` | STUN service port | `3478` |
| `service.httpsPortal` | HTTPS portal port | `8843` |
| `service.httpPortal` | HTTP portal port | `8880` |
| `service.speedtest` | Speed test port | `6789` |
| `service.discovery` | Discovery port | `10001` |

### Persistence Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.size` | Storage size | `8Gi` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.accessMode` | Access mode | `ReadWriteOnce` |

### MongoDB Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mongodb.enabled` | Enable MongoDB subchart | `true` |
| `mongodb.auth.enabled` | Enable MongoDB authentication | `false` |
| `mongodb.persistence.enabled` | Enable MongoDB persistence | `true` |
| `mongodb.persistence.size` | MongoDB storage size | `8Gi` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.hosts` | Ingress hosts | `[{host: "unifi.local", paths: [{path: "/", pathType: "Prefix"}]}]` |

## Examples

### Basic Installation
```bash
helm install unifi unifi/unifi
```

### With Custom Values
```bash
helm install unifi unifi/unifi -f my-values.yaml
```

### With Ingress
```bash
helm install unifi unifi/unifi \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=unifi.example.com \
  --set ingress.tls[0].secretName=unifi-tls \
  --set ingress.tls[0].hosts[0]=unifi.example.com
```

### High Availability Setup
```bash
helm install unifi unifi/unifi \
  --set replicaCount=2 \
  --set podDisruptionBudget.enabled=true \
  --set podDisruptionBudget.minAvailable=1 \
  --set mongodb.enabled=true
```

## Development

### Prerequisites

- Helm 3.8+
- Docker
- Kind (for local testing)
- Make

### Setup Development Environment

```bash
# Clone the repository
git clone https://github.com/hannoeru/unifi-helm.git
cd unifi-helm

# Install development tools
make install-tools

# Run tests
make test

# Run full test suite with kind cluster
make test-kind
```

### Available Make Targets

```bash
make help                 # Show available targets
make dev                  # Quick development cycle
make test                 # Run unit tests and linting
make test-full           # Run all tests including install tests
make test-kind           # Run tests with temporary kind cluster
make build               # Build and package chart
make clean               # Clean up build artifacts
```

### Testing

The chart includes comprehensive tests:

- **Unit Tests**: Helm unittest for template validation
- **Lint Tests**: Chart-testing for linting and best practices
- **Install Tests**: End-to-end installation testing
- **CI/CD**: GitHub Actions for automated testing

Run tests locally:
```bash
# Unit tests only
make test-unit

# Linting only  
make test-lint

# All tests
make test

# Full test suite with install tests
make test-full
```

## UniFi Network Controller Ports

The chart exposes the following ports based on [official UniFi documentation](https://help.ui.com/hc/en-us/articles/218506997-UniFi-Network-Ports-Used):

| Port | Protocol | Purpose | Required |
|------|----------|---------|----------|
| 8080 | TCP | Device command/control | ✅ |
| 8443 | TCP | Web interface + API | ✅ |
| 3478 | UDP | STUN service | ✅ |
| 8843 | TCP | HTTPS portal | Optional |
| 8880 | TCP | HTTP portal | Optional |
| 6789 | TCP | Speed test (UniFi 5 only) | Optional |
| 10001 | UDP | Device discovery | Optional |

## Security

The chart follows security best practices:

- Runs as non-root user (UID/GID 999)
- Includes security contexts and pod security contexts
- Uses read-only root filesystem where possible
- Supports network policies (user-configured)
- Includes liveness and readiness probes

## Troubleshooting

### Common Issues

1. **UniFi Controller not starting**
   - Check persistent volume availability
   - Verify MongoDB connection (if enabled)
   - Check resource limits

2. **Cannot access web interface**
   - Verify service and ingress configuration
   - Check firewall rules
   - Ensure correct port forwarding

3. **Database connection issues**
   - Verify MongoDB is running (if enabled)
   - Check database URI configuration
   - Review MongoDB logs

### Debug Commands

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=unifi

# View logs
kubectl logs -f deployment/my-unifi

# Check service endpoints
kubectl get endpoints my-unifi

# Test connectivity
kubectl port-forward svc/my-unifi 8443:8443
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

## Acknowledgments

- [jacobalberty/unifi-docker](https://github.com/jacobalberty/unifi-docker) for the UniFi Docker image
- [Bitnami](https://github.com/bitnami/charts) for the MongoDB chart
- [Helm community](https://helm.sh/) for the excellent tooling

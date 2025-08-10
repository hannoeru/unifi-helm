# UniFi Network Controller

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v9.3.43](https://img.shields.io/badge/AppVersion-v9.3.43-informational?style=flat-square)

A Helm chart for deploying the UniFi Network Controller on Kubernetes with MongoDB Community Operator support.

## Features

- 🚀 **Easy Deployment**: One-command deployment of UniFi Network Controller
- 🗄️ **MongoDB Support**: MongoDB Community Kubernetes Operator for data persistence
- 🔒 **Security**: Runs as non-root user with proper security contexts
- 📊 **Monitoring**: Built-in health checks and readiness probes
- 🌐 **Ingress**: Optional ingress configuration with TLS support
- 💾 **Persistence**: Configurable persistent storage for UniFi data
- 🔄 **High Availability**: PodDisruptionBudget support for HA deployments
- ✅ **Tested**: Comprehensive test suite with unittest and chart-testing

## Prerequisites

- Kubernetes 1.19+
- Helm 3.8+
- MongoDB Community Kubernetes Operator (for MongoDB support)

## Installing MongoDB Community Operator

Before installing the UniFi chart, you need to install the MongoDB Community Kubernetes Operator:

### Method 1: Using Helm (Recommended)

```bash
# Add the MongoDB Community Operator Helm repository
helm repo add mongodb https://mongodb.github.io/helm-charts
helm repo update

# Install the MongoDB Community Operator
helm install community-operator mongodb/community-operator --namespace mongodb-system --create-namespace
```

### Method 2: Using kubectl

```bash
# Install MongoDB Community Operator CRDs
kubectl apply -f https://raw.githubusercontent.com/mongodb/mongodb-kubernetes-operator/master/config/crd/bases/mongodbcommunity.mongodb.com_mongodbcommunity.yaml

# Install MongoDB Community Operator RBAC
kubectl apply -k https://github.com/mongodb/mongodb-kubernetes-operator/config/rbac/

# Install MongoDB Community Operator
kubectl apply -f https://raw.githubusercontent.com/mongodb/mongodb-kubernetes-operator/master/config/manager/manager.yaml
```

### Verify Installation

```bash
# Check that the operator is running
kubectl get pods -n mongodb-system

# Expected output:
# NAME                                           READY   STATUS    RESTARTS   AGE
# mongodb-kubernetes-operator-<hash>             1/1     Running   0          1m
```

## Installation

### Add Helm Repository

```bash
helm repo add unifi https://hannoeru.github.io/unifi-helm/
helm repo update
```

### Basic Installation

```bash
# Install with default values (no database - you need to configure one)
helm install my-unifi unifi/unifi
```

### Installation with MongoDB Community Operator

```bash
# First install the MongoDB Community Operator (see above)
# Then install UniFi with MongoDB Community Operator
helm install my-unifi unifi/unifi --set mongodbCommunity.enabled=true
```

### Installation with External Database

```bash
# Install with external database
helm install my-unifi unifi/unifi \
  --set externalDatabase.enabled=true \
  --set externalDatabase.host=mongodb.example.com \
  --set externalDatabase.username=unifi \
  --set externalDatabase.password=your-password \
  --set externalDatabase.database=unifi
```

### Installation with Custom Values

```bash
# Install with custom values file
helm install my-unifi unifi/unifi -f values.yaml
```

## Configuration

### Database Configuration

**Choose one of the following database options:**

#### MongoDB Community Operator Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mongodbCommunity.enabled` | Enable MongoDB Community Operator | `false` |
| `mongodbCommunity.database` | MongoDB database name | `"unifi"` |
| `mongodbCommunity.version` | MongoDB version | `"7.0.0"` |
| `mongodbCommunity.persistence.enabled` | Enable MongoDB persistence | `true` |
| `mongodbCommunity.persistence.size` | MongoDB storage size | `"8Gi"` |
| `mongodbCommunity.persistence.storageClass` | MongoDB storage class | `""` |
| `mongodbCommunity.resources.limits.cpu` | MongoDB CPU limit | `"1"` |
| `mongodbCommunity.resources.limits.memory` | MongoDB memory limit | `"1Gi"` |
| `mongodbCommunity.resources.requests.cpu` | MongoDB CPU request | `"500m"` |
| `mongodbCommunity.resources.requests.memory` | MongoDB memory request | `"512Mi"` |

#### External Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `externalDatabase.enabled` | Enable external database connection | `false` |
| `externalDatabase.host` | MongoDB server hostname | `"mongodb.example.com"` |
| `externalDatabase.port` | MongoDB server port | `27017` |
| `externalDatabase.database` | MongoDB database name | `"unifi"` |
| `externalDatabase.username` | MongoDB username | `"unifi"` |
| `externalDatabase.password` | MongoDB password (plain text) | `""` |
| `externalDatabase.existingSecret` | Existing secret name for password | `""` |
| `externalDatabase.passwordKey` | Key in existing secret for password | `"password"` |
| `externalDatabase.authSource` | MongoDB authentication database | `"admin"` |
| `externalDatabase.options` | Additional connection string options | `""` |
| `externalDatabase.tls.enabled` | Enable TLS/SSL for MongoDB connection | `false` |
| `externalDatabase.tls.existingSecret` | Existing secret name for TLS certificates | `""` |

### UniFi Controller Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | UniFi controller image repository | `lscr.io/linuxserver/unifi-network-application` |
| `image.tag` | UniFi controller image tag | `latest` |
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

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.hosts` | Ingress hosts | See values.yaml |

### ServiceMonitor Configuration (Prometheus)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceMonitor.enabled` | Enable ServiceMonitor for Prometheus | `false` |
| `serviceMonitor.interval` | Scrape interval | `"30s"` |
| `serviceMonitor.scrapeTimeout` | Scrape timeout | `"10s"` |
| `serviceMonitor.path` | Metrics endpoint path | `"/status"` |
| `serviceMonitor.targetPort` | Target port for scraping | `"web-interface"` |
| `serviceMonitor.scheme` | HTTP scheme (http/https) | `"https"` |
| `serviceMonitor.tlsConfig.insecureSkipVerify` | Skip TLS certificate verification | `true` |
| `serviceMonitor.labels` | Additional labels for ServiceMonitor | `{}` |
| `serviceMonitor.selector` | Prometheus instance selector | `{}` |

## Examples

### Basic Installation with MongoDB Community Operator

```yaml
# mongodb-values.yaml
mongodbCommunity:
  enabled: true
  persistence:
    size: 20Gi
    storageClass: "fast-ssd"

persistence:
  enabled: true
  size: 10Gi
  storageClass: "fast-ssd"

resources:
  limits:
    cpu: 2000m
    memory: 2Gi
  requests:
    cpu: 1000m
    memory: 1Gi
```

### Basic Installation with External Database

```yaml
# external-db-values.yaml
externalDatabase:
  enabled: true
  host: "mongodb.example.com"
  port: 27017
  database: "unifi"
  username: "unifi"
  # Use existing secret for password (recommended)
  existingSecret: "mongodb-credentials"
  passwordKey: "password"
  authSource: "admin"

persistence:
  enabled: true
  size: 10Gi
  storageClass: "fast-ssd"
```

### External Database with TLS

```yaml
# external-db-tls-values.yaml
externalDatabase:
  enabled: true
  host: "mongodb.example.com"
  port: 27017
  database: "unifi"
  username: "unifi"
  existingSecret: "mongodb-credentials"
  passwordKey: "password"
  authSource: "admin"
  # Additional connection options
  options: "ssl=true&replicaSet=rs0"
  # TLS configuration
  tls:
    enabled: true
    existingSecret: "mongodb-tls-certs"
    caKey: "ca.crt"
    certKey: "tls.crt"
    keyKey: "tls.key"
```

### External Database with MongoDB Atlas

```yaml
# atlas-values.yaml
externalDatabase:
  enabled: true
  host: "cluster0.abcde.mongodb.net"
  port: 27017
  database: "unifi"
  username: "unifi-user"
  existingSecret: "mongodb-atlas-credentials"
  passwordKey: "password"
  authSource: "admin"
  options: "retryWrites=true&w=majority&ssl=true"
```

### High Availability Setup

```yaml
# ha-values.yaml
replicaCount: 2

podDisruptionBudget:
  enabled: true
  minAvailable: 1

mongodbCommunity:
  enabled: true
  persistence:
    enabled: true
    size: 50Gi
    storageClass: "fast-ssd"
  resources:
    limits:
      cpu: "2"
      memory: "4Gi"
    requests:
      cpu: "1"
      memory: "2Gi"

affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app.kubernetes.io/name
            operator: In
            values:
            - unifi
        topologyKey: kubernetes.io/hostname
```

### Ingress with TLS

```yaml
# ingress-values.yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: unifi.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: unifi-tls
      hosts:
        - unifi.example.com
```

### Raspberry Pi Optimized

```yaml
# rpi-values.yaml
resources:
  limits:
    memory: 1.5Gi
  requests:
    cpu: 300m
    memory: 768Mi

mongodbCommunity:
  enabled: true
  persistence:
    enabled: true
    storageClass: "local-path"
    size: 20Gi
  resources:
    limits:
      memory: 1Gi
    requests:
      cpu: 100m
      memory: 512Mi

nodeSelector:
  kubernetes.io/arch: arm64
```

### Monitoring with Prometheus

```yaml
# monitoring-values.yaml
serviceMonitor:
  enabled: true
  interval: "60s"
  scrapeTimeout: "30s"
  labels:
    release: prometheus
  tlsConfig:
    insecureSkipVerify: true

# Optional: Add custom relabeling
serviceMonitor:
  enabled: true
  relabelings:
    - sourceLabels: [__meta_kubernetes_pod_name]
      targetLabel: pod_name
    - sourceLabels: [__meta_kubernetes_namespace]
      targetLabel: kubernetes_namespace
  metricRelabelings:
    - sourceLabels: [__name__]
      regex: "unifi_.*"
      action: keep
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

## Accessing the UniFi Controller

### Port Forward (Development)

```bash
kubectl port-forward svc/my-unifi 8443:8443
# Open https://localhost:8443 in your browser
```

### LoadBalancer Service

```yaml
service:
  type: LoadBalancer
  loadBalancerIP: "192.168.1.100"  # Optional: specify IP
```

### NodePort Service

```yaml
service:
  type: NodePort
  nodePort: 30443  # Optional: specify port (30000-32767)
```

## Troubleshooting

### MongoDB Connection Issues

Check MongoDB Community resources:

```bash
# Check MongoDBCommunity resource status
kubectl get mongodbcommunity

# Check MongoDB pod logs
kubectl logs -l app=my-unifi-mongodb-svc

# Check MongoDB Community Operator logs
kubectl logs -n mongodb-system deployment/mongodb-kubernetes-operator
```

### UniFi Controller Issues

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=unifi

# View UniFi Controller logs
kubectl logs -f deployment/my-unifi

# Check service endpoints
kubectl get endpoints my-unifi

# Describe pod for events
kubectl describe pod -l app.kubernetes.io/name=unifi
```

### Common Issues

1. **MongoDB not starting**: Verify MongoDB Community Operator is installed and running
2. **Persistent volume issues**: Check storage class availability and permissions
3. **Network connectivity**: Verify service configuration and firewall rules
4. **Resource constraints**: Check resource limits and node capacity

### Debug Commands

```bash
# Test MongoDB connectivity from UniFi pod
kubectl exec -it deployment/my-unifi -- nc -zv my-unifi-mongodb-svc 27017

# Check MongoDB authentication
kubectl get secrets -l app=my-unifi-mongodb

# Validate chart templates
helm template my-unifi unifi/unifi --debug
```

## Upgrade

```bash
# Upgrade to latest version
helm upgrade my-unifi unifi/unifi

# Upgrade with new values
helm upgrade my-unifi unifi/unifi -f new-values.yaml

# Upgrade with specific version
helm upgrade my-unifi unifi/unifi --version 0.2.0
```

## Uninstall

```bash
# Uninstall the chart
helm uninstall my-unifi

# Note: PVCs and MongoDB data are preserved by default
# To remove all data:
kubectl delete pvc -l app.kubernetes.io/instance=my-unifi
kubectl delete mongodbcommunity my-unifi-mongodb
```

## Source Code

- **Chart Source**: [https://github.com/hannoeru/unifi-helm](https://github.com/hannoeru/unifi-helm)
- **UniFi Docker Image**: [https://github.com/linuxserver/docker-unifi-network-application](https://github.com/linuxserver/docker-unifi-network-application)
- **MongoDB Community Operator**: [https://github.com/mongodb/mongodb-kubernetes-operator](https://github.com/mongodb/mongodb-kubernetes-operator)
# UniFi Network Controller

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v9.3.43](https://img.shields.io/badge/AppVersion-v9.3.43-informational?style=flat-square)

A Helm chart for UniFi Network Controller

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | mongodb | 16.5.35 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Affinity settings for pod assignment |
| fullnameOverride | string | `""` | Override the full name of the chart |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.repository | string | `"ghcr.io/jacobalberty/unifi-docker"` | UniFi controller image repository |
| image.tag | string | `"v9.3.43"` | UniFi controller image tag |
| imagePullSecrets | list | `[]` | Image pull secrets |
| ingress.annotations | object | `{}` | Ingress annotations |
| ingress.className | string | `""` | Ingress class name |
| ingress.enabled | bool | `false` | Enable ingress |
| ingress.hosts[0].host | string | `"unifi.local"` | Ingress hostname |
| ingress.hosts[0].paths[0].path | string | `"/"` | Ingress path |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | Ingress path type |
| ingress.tls | list | `[]` | Ingress TLS configuration |
| mongodb.architecture | string | `"standalone"` | MongoDB architecture |
| mongodb.auth.enabled | bool | `false` | Enable MongoDB authentication |
| mongodb.enabled | bool | `true` | Enable MongoDB subchart |
| mongodb.initdbScripts."init-unifi.js" | string | `"db = db.getSiblingDB('unifi');\ndb.createUser({\n  user: 'unifi',\n  pwd: 'unifi',\n  roles: [{ role: 'dbOwner', db: 'unifi' }]\n});\n"` | MongoDB initialization script for UniFi |
| mongodb.persistence.enabled | bool | `true` | Enable MongoDB persistence |
| mongodb.persistence.size | string | `"8Gi"` | MongoDB storage size |
| mongodb.resources.limits.cpu | string | `"1000m"` | MongoDB CPU limit |
| mongodb.resources.limits.memory | string | `"1Gi"` | MongoDB memory limit |
| mongodb.resources.requests.cpu | string | `"500m"` | MongoDB CPU request |
| mongodb.resources.requests.memory | string | `"512Mi"` | MongoDB memory request |
| mongodb.service.ports.mongodb | int | `27017` | MongoDB service port |
| nameOverride | string | `""` | Override the name of the chart |
| nodeSelector | object | `{}` | Node selector for pod assignment |
| persistence.accessMode | string | `"ReadWriteOnce"` | Persistent volume access mode |
| persistence.annotations | object | `{}` | Persistent volume annotations |
| persistence.enabled | bool | `true` | Enable persistent storage |
| persistence.size | string | `"8Gi"` | Persistent volume size |
| persistence.storageClass | string | `""` | Persistent volume storage class |
| podAnnotations | object | `{}` | Pod annotations |
| podDisruptionBudget.enabled | bool | `false` | Enable PodDisruptionBudget |
| podSecurityContext.fsGroup | int | `999` | Pod security context fsGroup |
| podSecurityContext.runAsGroup | int | `999` | Pod security context runAsGroup |
| podSecurityContext.runAsUser | int | `999` | Pod security context runAsUser |
| replicaCount | int | `1` | Number of replicas |
| resources | object | `{}` | Resource limits and requests |
| securityContext | object | `{}` | Container security context |
| service.deviceControl | int | `8080` | Device command/control port (required) |
| service.discovery | int | `10001` | Device discovery port (optional) |
| service.httpPortal | int | `8880` | HTTP portal port (optional) |
| service.httpsPortal | int | `8843` | HTTPS portal port (optional) |
| service.speedtest | int | `6789` | Speed Test port (unifi5 only) (optional) |
| service.stun | int | `3478` | STUN service port (required) |
| service.type | string | `"ClusterIP"` | Service type |
| service.webInterface | int | `8443` | Web interface + API port (required) |
| serviceAccount.annotations | object | `{}` | Service account annotations |
| serviceAccount.create | bool | `true` | Create service account |
| serviceAccount.name | string | `""` | Service account name |
| tolerations | list | `[]` | Tolerations for pod assignment |
| unifi.env.RUNAS_UID0 | string | `"false"` | Run as UID 0 |
| unifi.env.TZ | string | `"UTC"` | Timezone |
| unifi.env.UNIFI_GID | string | `"999"` | UniFi group ID |
| unifi.env.UNIFI_UID | string | `"999"` | UniFi user ID |
| unifi.extraEnv | list | `[]` | Additional environment variables |

## Installation

### Add Helm Repository

```bash
helm repo add unifi https://hannoeru.github.io/unifi-helm/
helm repo update
```

### Install Chart

```bash
# Install with default values
helm install my-unifi unifi/unifi

# Install with MongoDB enabled
helm install my-unifi unifi/unifi --set mongodb.enabled=true

# Install with custom values file
helm install my-unifi unifi/unifi -f values.yaml
```

## Configuration Examples

### Basic Configuration

```yaml
# Basic installation
replicaCount: 1
persistence:
  enabled: true
  size: 8Gi
```

### With MongoDB

```yaml
# Enable MongoDB subchart
mongodb:
  enabled: true
  auth:
    enabled: false
  persistence:
    enabled: true
    size: 8Gi
```

### With Ingress

```yaml
# Enable ingress with TLS
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

### High Availability

```yaml
# HA configuration with PDB
replicaCount: 2
podDisruptionBudget:
  enabled: true
  minAvailable: 1

mongodb:
  enabled: true
  persistence:
    enabled: true

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi
```

## Exposed Ports

The chart exposes the following ports based on [UniFi documentation](https://help.ui.com/hc/en-us/articles/218506997):

| Port | Protocol | Purpose | Required |
|------|----------|---------|----------|
| 8080 | TCP | Device command/control | ✅ |
| 8443 | TCP | Web interface + API | ✅ |
| 3478 | UDP | STUN service | ✅ |
| 8843 | TCP | HTTPS portal | Optional |
| 8880 | TCP | HTTP portal | Optional |
| 6789 | TCP | Speed test (UniFi 5 only) | Optional |
| 10001 | UDP | Device discovery | Optional |

## Upgrade

```bash
# Upgrade to latest version
helm upgrade my-unifi unifi/unifi

# Upgrade with new values
helm upgrade my-unifi unifi/unifi -f new-values.yaml
```

## Uninstall

```bash
helm uninstall my-unifi
```

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -l app.kubernetes.io/name=unifi
```

### View Logs
```bash
kubectl logs -f deployment/my-unifi
```

### Access Controller Locally
```bash
kubectl port-forward svc/my-unifi 8443:8443
# Then open https://localhost:8443
```

### Check MongoDB Connection (if enabled)
```bash
kubectl logs -f deployment/my-unifi-mongodb
```

## Source Code

- **Chart Source**: [https://github.com/hannoeru/unifi-helm](https://github.com/hannoeru/unifi-helm)
- **UniFi Docker Image**: [https://github.com/jacobalberty/unifi-docker](https://github.com/jacobalberty/unifi-docker)

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs)
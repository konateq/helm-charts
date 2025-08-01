# EHRbase Helm Chart

![Version: 2.3.0](https://img.shields.io/badge/Version-2.3.0-informational?style=flat-square)
![AppVersion: 2.20.0](https://img.shields.io/badge/AppVersion-2.20.0-informational?style=flat-square)
![GitHub License](https://img.shields.io/github/license/konateq/helm-charts)

[EHRbase](https://ehrbase.org) is an open source software backend for clinical application systems and electronic health
records. It is based on the openEHR specifications.

## Prerequisites

- Kubernetes: `>=1.31`

## Configuration

The following sections provide some examples of how to configure the EHRbase chart. For a complete list of configurable
parameters, see the [Values](#values) section below.

### Authentication

#### Basic Authentication

> [!NOTE]
> By default, passwords are generated randomly during the installation of the chart.

You can provide the user credentials directly in the `values.yaml` file:

```yaml
auth:
  type: basic
  basic:
    adminUsername: ehrbase-admin
    adminPassword: MyAdminPassword
    username: ehrbase-user
    password: MyUserPassword
```

Alternatively, you can use a Kubernetes secret to store the user credentials:

```yaml
auth:
  type: basic
  basic:
    existingSecret: ehrbase-users
```

The secret should look like this:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ehrbase-users
type: Opaque
data:
  admin-username: <base64-encoded-admin-username>
  admin-password: <base64-encoded-admin-password>
  username: <base64-encoded-username>
  password: <base64-encoded-password>
```

> [!TIP]
> We highly recommend using a tool like [external-secrets](https://github.com/external-secrets/external-secrets)
> or [sealed-secrets](https://github.com/bitnami-labs/sealed-secrets) to manage secrets in a more secure way.

#### OAuth2

To configure EHRbase to use OAuth2 for authentication, you need to specify the JWK Set URI of your authorization server:

```yaml
auth:
  type: oauth2
  oauth2:
    jwkSetUri: https://keycloak.example.com/realms/ehrbase/protocol/openid-connect/certs
```

### PostgreSQL Database

> [!NOTE]
> By default, the chart automatically deploys a PostgreSQL database using
> the [Bitnami PostgreSQL chart](https://github.com/bitnami/charts/tree/main/bitnami/postgresql). Please refer to the
> documentation to learn more about the available configuration options.

```yaml
postgresql:
  auth:
    postgresPassword: MyAdminPassword
    password: MyPostgresPassword
```

The Bitnami PostgreSQL chart also supports using an existing secret to store the PostgreSQL passwords. In that case,
you can specify the name of the secret using the `existingSecret` parameter:

```yaml
postgresql:
  auth:
    existingSecret: ehrbase-postgres
```

With the following secret structure:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ehrbase-postgres
type: Opaque
data:
  postgres-password: <base64-postgresql-admin-password>
  password: <base64-postgresql-password>
```

### External PostgreSQL Database

You can also use an existing database by disabling the default database deployment and providing the connection details:

```yaml
postgresql:
  enabled: false

externalPostgresql:
  host: postgres.example.com
  port: 15432
  user: ehrbase_app
  password: MyPostgresPassword
  database: ehrbase_db
```

> [!IMPORTANT]
> In that case, you must ensure that the database has been created according to
> the [createdb.sql](https://github.com/ehrbase/ehrbase/blob/master/createdb.sql) provided by EHRbase.

Similarly to authentication, you can also use a Kubernetes secret to store the PostgreSQL credentials:

```yaml
postgresql:
  enabled: false

externalPostgresql:
  host: postgres.example.com
  port: 15432
  user: ehrbase_app
  database: ehrbase_db
  existingSecret: ehrbase-postgres
```

With the following secret structure:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ehrbase-postgres
type: Opaque
data:
  password: <base64-postgresql-password>
```

> [!TIP]
> We highly recommend using a tool like [external-secrets](https://github.com/external-secrets/external-secrets)
> or [sealed-secrets](https://github.com/bitnami-labs/sealed-secrets) to manage secrets in a more secure way.

### Ingress

To expose the EHRbase instance to external traffic, you can enable the ingress resource:

```yaml
ingress:
  enabled: false
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: my-cluster-issuer
  hosts:
    - host: ehrbase.example.com
      paths:
        - path: /
          pathType: ImplementationSpecific
  tls:
    - hosts:
        - ehrbase.example.com
      secretName: ehrbase-tls
```

If you are not using [cert-manager](https://cert-manager.io/docs/) to issue TLS certificates, you can create a
Kubernetes secret with the TLS certificate and key:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ehrbase-tls
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded-certificate>
  tls.key: <base64-encoded-private-key>``
```

### Transport Layer Security

To enable TLS for internal communication, you can set the `tls.enabled` parameter to `true`. If you have an existing
Kubernetes secret with the TLS certificate and key, specify it using `tls.existingSecret`. Otherwise, a self-signed
certificate will be generated.

  ```yaml
tls:
  enabled: true
  existingSecret: ehrbase-internal-tls
```

With the following secret structure:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ehrbase-internal-tls
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded-tls-certificate>
  tls.key: <base64-encoded-tls-key>
```

> [!TIP]
> We highly recommend using [cert-manager](https://cert-manager.io/docs/) to issue and manage TLS certificates within
> your Kubernetes cluster.

## High Availability

To achieve high availability, you can increase the number of replicas for the EHRbase deployment.

```yaml
replicaCount: 3
```

You can also enable autoscaling based on CPU (or memory usage). The following example sets the minimum number of
replicas to 3, and the maximum to 9, with target CPU utilization of 80%.

```yaml
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 9
  targetCPU: 80
#  targetMemory: 80
```

### External Redis

> [!NOTE]
> To ensure that EHRbase can scale horizontally, the chart automatically deploys a Redis instance using
> the [Bitnami Redis chart](https://github.com/bitnami/charts/tree/main/bitnami/redis). Please refer to the
> documentation if you want to customize the Redis deployment.

You can also use an existing Redis instance by disabling the default Redis deployment and providing the connection
details:

```yaml
redis:
  enabled: false

externalRedis:
  host: redis.example.com
  port: 6379
  password: MyRedisPassword
```

Similarly to authentication and PostgreSQL, you can use a Kubernetes secret to store the Redis credentials:

```yaml
redis:
  enabled: false

externalRedis:
  host: redis.example.com
  port: 6379
  existingSecret: ehrbase-redis
```

With the following secret structure:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ehrbase-redis
type: Opaque
data:
  redis-password: <base64-redis-password>
```

> [!TIP]
> We highly recommend using a tool like [external-secrets](https://github.com/external-secrets/external-secrets)
> or [sealed-secrets](https://github.com/bitnami-labs/sealed-secrets) to manage secrets in a more secure way.

### EHRbase Advanced Configuration

If you need more advanced configurations options, you can use the `configuration` parameter to provide a custom Spring
Boot configuration file. This file will be mounted as a ConfigMap and used by the EHRbase application.

```yaml
configuration: |
  ehrbase:
    template:
      allow-overwrite: true
    rest:
      ehrscape:
        enabled: true
  logging:
    level:
      root: INFO
      org.ehrbase: DEBUG
```

Please refer to the [EHRbase documentation](https://docs.ehrbase.org/) for more details on the available configuration
options.

## Values

The following table lists all configurable parameters for the EHRbase chart, along with their default values and
descriptions.

| Key                                          | Type   | Default                                                                                 | Description                                                                                                                              |
|----------------------------------------------|--------|-----------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| affinity                                     | object | `{}`                                                                                    | Affinity settings for the deployment                                                                                                     |
| auth.basic.adminPassword                     | string | `""`                                                                                    | Password for the admin user                                                                                                              |
| auth.basic.adminUsername                     | string | `"ehrbase-admin"`                                                                       | Username for the admin user                                                                                                              |
| auth.basic.existingSecret                    | string | `""`                                                                                    | Name of the existing Kubernetes Secret that contains the credentials                                                                     |
| auth.basic.existingSecretAdminPasswordKey    | string | `"admin-password"`                                                                      | Key in the existing Kubernetes Secret that contains the admin password                                                                   |
| auth.basic.existingSecretAdminUsernameKey    | string | `"admin-username"`                                                                      | Key in the existing Kubernetes Secret that contains the admin username                                                                   |
| auth.basic.existingSecretPasswordKey         | string | `"password"`                                                                            | Key in the existing Kubernetes Secret that contains the regular password                                                                 |
| auth.basic.existingSecretUsernameKey         | string | `"username"`                                                                            | Key in the existing Kubernetes Secret that contains the regular username                                                                 |
| auth.basic.password                          | string | `""`                                                                                    | Password for the regular user                                                                                                            |
| auth.basic.username                          | string | `"ehrbase-user"`                                                                        | Username for the regular user                                                                                                            |
| auth.oauth2.jwkSetUri                        | string | `""`                                                                                    | Authorization Server's JWK Set Endpoint                                                                                                  |
| auth.type                                    | string | `"basic"`                                                                               | Type of authentication to use, either `basic`, `oauth2` or `none`                                                                        |
| autoscaling.enabled                          | bool   | `false`                                                                                 |                                                                                                                                          |
| autoscaling.maxReplicas                      | int    | `10`                                                                                    |                                                                                                                                          |
| autoscaling.minReplicas                      | int    | `1`                                                                                     |                                                                                                                                          |
| autoscaling.targetCPU                        | int    | `80`                                                                                    |                                                                                                                                          |
| configuration                                | string | `""`                                                                                    |                                                                                                                                          |
| containerPorts.http                          | int    | `8080`                                                                                  | Port for HTTP traffic                                                                                                                    |
| containerPorts.https                         | int    | `8443`                                                                                  | Port for HTTPS traffic                                                                                                                   |
| containerPorts.management                    | int    | `9000`                                                                                  | Port for management traffic                                                                                                              |
| contextPath                                  | string | `"/"`                                                                                   | Context path used by the application                                                                                                     |
| customLivenessProbe                          | object | `{}`                                                                                    | Custom liveness probe                                                                                                                    |
| customReadinessProbe                         | object | `{}`                                                                                    | Custom readiness probe                                                                                                                   |
| externalPostgresql.database                  | string | `"ehrbase"`                                                                             | Database name for the external PostgreSQL server                                                                                         |
| externalPostgresql.existingSecret            | string | `""`                                                                                    | Name of the existing Kubernetes Secret that contains the PostgreSQL password                                                             |
| externalPostgresql.existingSecretPasswordKey | string | `"password"`                                                                            | Key in the existing Kubernetes Secret that contains the PostgreSQL password                                                              |
| externalPostgresql.host                      | string | `""`                                                                                    |                                                                                                                                          |
| externalPostgresql.password                  | string | `""`                                                                                    | Password for the external PostgreSQL server                                                                                              |
| externalPostgresql.port                      | int    | `5432`                                                                                  | Port number of the external PostgreSQL server                                                                                            |
| externalPostgresql.username                  | string | `"ehrbase"`                                                                             | Username for the external PostgreSQL server                                                                                              |
| externalRedis.existingSecret                 | string | `""`                                                                                    | Name of the existing Kubernetes Secret that contains the Redis password                                                                  |
| externalRedis.existingSecretPasswordKey      | string | `"redis-password"`                                                                      | Key in the existing Kubernetes Secret that contains the Redis password                                                                   |
| externalRedis.host                           | string | `""`                                                                                    | Hostname or IP address of the external Redis server                                                                                      |
| externalRedis.password                       | string | `""`                                                                                    | Password for the external Redis server                                                                                                   |
| externalRedis.port                           | int    | `6379`                                                                                  | Port number of the external Redis server                                                                                                 |
| extraEnvVars                                 | list   | `[]`                                                                                    | Additional environment variables                                                                                                         |
| extraEnvVarsSecret                           | string | `""`                                                                                    | Name of the existing Kubernetes Secret that contains additional environment variables                                                    |
| extraVolumeMounts                            | list   | `[]`                                                                                    | Additional volume mounts on the output Deployment definition.                                                                            |
| extraVolumes                                 | list   | `[]`                                                                                    | Additional volumes on the output Deployment definition.                                                                                  |
| fullnameOverride                             | string | `""`                                                                                    | Override the full name of the chart                                                                                                      |
| image.pullPolicy                             | string | `"IfNotPresent"`                                                                        | Image pull policy, can be Always, IfNotPresent, or Never                                                                                 |
| image.repository                             | string | `"ehrbase/ehrbase"`                                                                     | Image repository, defaults to the chart app version                                                                                      |
| image.tag                                    | string | `""`                                                                                    | Tag for the image, defaults to the chart app version                                                                                     |
| imagePullSecrets                             | list   | `[]`                                                                                    | Image pull secrets for the deployment                                                                                                    |
| ingress.annotations                          | object | `{}`                                                                                    | Annotations for the ingress                                                                                                              |
| ingress.className                            | string | `""`                                                                                    | Ingress class name, e.g., "nginx", "traefik", etc.                                                                                       |
| ingress.enabled                              | bool   | `false`                                                                                 | Enable or disable the ingress resource                                                                                                   |
| ingress.hosts                                | list   | `[{"host":"ehrbase.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | Ingress hosts configuration                                                                                                              |
| ingress.tls                                  | list   | `[]`                                                                                    | TLS configuration for the ingress                                                                                                        |
| nameOverride                                 | string | `""`                                                                                    | Override the name of the chart                                                                                                           |
| nodeSelector                                 | object | `{}`                                                                                    | Node selector for the deployment                                                                                                         |
| podAnnotations                               | object | `{}`                                                                                    | Annotations to add to the Pod                                                                                                            |
| podLabels                                    | object | `{}`                                                                                    | Labels to add to the Pod                                                                                                                 |
| podSecurityContext                           | object | `{}`                                                                                    | Security context for the pod                                                                                                             |
| postgresql.architecture                      | string | `"standalone"`                                                                          | Architecture of the PostgreSQL deployment, either `standalone` or `replication`                                                          |
| postgresql.auth.database                     | string | `"ehrbase"`                                                                             | Database name for the PostgreSQL user                                                                                                    |
| postgresql.auth.existingSecret               | string | `""`                                                                                    | Name of the existing Kubernetes Secret that contains the PostgreSQL password                                                             |
| postgresql.auth.password                     | string | `""`                                                                                    | Password for the PostgreSQL user                                                                                                         |
| postgresql.auth.postgresPassword             | string | `""`                                                                                    | Password for the PostgreSQL admin user                                                                                                   |
| postgresql.auth.username                     | string | `"ehrbase"`                                                                             | Username for the PostgreSQL user                                                                                                         |
| postgresql.enabled                           | bool   | `true`                                                                                  | Enable or disable the PostgreSQL chart                                                                                                   |
| postgresql.primary.initdb.scripts            | object | `{}`                                                                                    |                                                                                                                                          |
| redis.architecture                           | string | `"standalone"`                                                                          | The Redis architecture to use, either `standalone` or `replication`                                                                      |
| redis.auth.enabled                           | bool   | `true`                                                                                  | Enable or disable Redis authentication                                                                                                   |
| redis.auth.existingSecret                    | string | `""`                                                                                    | Name of the existing Kubernetes Secret that contains the Redis password                                                                  |
| redis.auth.existingSecretPasswordKey         | string | `""`                                                                                    | Key in the existing Kubernetes Secret that contains the Redis password                                                                   |
| redis.auth.password                          | string | `""`                                                                                    | Password for the Redis server                                                                                                            |
| redis.enabled                                | bool   | `true`                                                                                  | Enable or disable the Redis chart                                                                                                        |
| replicaCount                                 | int    | `1`                                                                                     | Number of replicas for the deployment                                                                                                    |
| resources                                    | object | `{}`                                                                                    | Resource requests and limits for the container                                                                                           |
| securityContext                              | object | `{}`                                                                                    | Security context for the container                                                                                                       |
| service.ports.http                           | int    | `8080`                                                                                  | Port for HTTP traffic                                                                                                                    |
| service.ports.https                          | int    | `8443`                                                                                  | Port for HTTPS traffic                                                                                                                   |
| service.ports.management                     | int    | `9000`                                                                                  | Port for management traffic                                                                                                              |
| service.type                                 | string | `"ClusterIP"`                                                                           | Type of service to create, e.g., ClusterIP, NodePort, LoadBalancer                                                                       |
| serviceAccount.annotations                   | object | `{}`                                                                                    | Annotations to add to the service account                                                                                                |
| serviceAccount.automount                     | bool   | `true`                                                                                  | Automatically mount the service account token                                                                                            |
| serviceAccount.create                        | bool   | `true`                                                                                  | Create a service account for the deployment                                                                                              |
| serviceAccount.name                          | string | `""`                                                                                    | Name of the service account to use                                                                                                       |
| tls.enabled                                  | bool   | `false`                                                                                 | Enable or disable TLS for internal communication                                                                                         |
| tls.existingSecret                           | string | `""`                                                                                    | Name of the existing Kubernetes Secret that contains the TLS certificate and key. Otherwise, a self-signed certificate will be generated |
| tolerations                                  | list   | `[]`                                                                                    | Tolerations for the deployment                                                                                                           |

# Konateq Helm Charts

![GitHub License](https://img.shields.io/github/license/konateq/helm-charts)

A collection of Helm charts for deploying various applications and services in Kubernetes clusters.

## Usage

[Helm](https://helm.sh) must be installed to use the charts. Please refer to
Helm's [documentation](https://helm.sh/docs) to get started.

To install the `<chart-name>` chart:

```shell
helm install my-<chart-name> oci://ghcr.io/konateq/charts/<chart-name>
```

To upgrade the chart:

```shell
helm upgrade my-<chart-name> oci://ghcr.io/konateq/charts/<chart-name>
```

To uninstall the chart:

```shell
helm uninstall my-<chart-name>
```

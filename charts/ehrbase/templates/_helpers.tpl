{{/*
Expand the name of the chart.
*/}}
{{- define "ehrbase.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ehrbase.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ehrbase.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ehrbase.labels" -}}
helm.sh/chart: {{ include "ehrbase.chart" . }}
{{ include "ehrbase.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ehrbase.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ehrbase.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ehrbase.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ehrbase.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "ehrbase.postgresql" -}}
{{- if .Values.postgresql.fullnameOverride }}
{{- .Values.postgresql.fullnameOverride }}
{{- else }}
{{- include "ehrbase.fullname" . }}-postgresql
{{- end }}
{{- end }}

{{- define "ehrbase.databaseHost" -}}
{{- if .Values.postgresql.enabled }}
{{- if eq .Values.postgresql.architecture "replication" }}
{{- include "ehrbase.postgresql" . }}-primary
{{- else }}
{{- include "ehrbase.postgresql" . }}
{{- end }}
{{- else }}
{{- .Values.externalDatabase.host }}
{{- end }}
{{- end }}

{{- define "ehrbase.databasePort" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.primary.service.ports.postgresql }}
{{- else }}
{{- .Values.externalDatabase.port }}
{{- end }}
{{- end }}

{{- define "ehrbase.databaseName" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database }}
{{- else }}
{{- .Values.externalDatabase.database }}
{{- end }}
{{- end }}

{{- define "ehrbase.databaseUrl" -}}
{{- printf "jdbc:postgresql://%s:%s/%s" (include "ehrbase.databaseHost" .) (include "ehrbase.databasePort" .) (include "ehrbase.databaseName" .) }}
{{- end }}

{{- define "ehrbase.databaseAdminUser" -}}
{{- if .Values.postgresql.enabled }}
{{- "postgres" }}
{{- else }}
{{- .Values.externalDatabase.user }}
{{- end }}
{{- end }}

{{- define "ehrbase.databaseUser" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username }}
{{- else }}
{{- .Values.externalDatabase.user }}
{{- end }}
{{- end }}

{{- define "ehrbase.databaseSecretName" -}}
{{- if .Values.postgresql.enabled }}
{{- coalesce .Values.postgresql.auth.existingSecret (include "ehrbase.postgresql" .) }}
{{- end }}
{{- end }}

{{- define "ehrbase.databaseAdminPasswordKey" -}}
{{- if .Values.postgresql.enabled }}
{{- default "postgres-password" .Values.postgresql.auth.secretKeys.adminPasswordKey }}
{{- else -}}
{{- default "password" .Values.externalDatabase.existingSecretPasswordKey }}
{{- end }}
{{- end }}

{{- define "ehrbase.databaseUserPasswordKey" -}}
{{- if .Values.postgresql.enabled }}
{{- default "password" .Values.postgresql.auth.secretKeys.userPasswordKey }}
{{- else -}}
{{- default "password" .Values.externalDatabase.existingSecretPasswordKey }}
{{- end }}
{{- end }}

{{- define "ehrbase.serverPort" -}}
{{- ternary .Values.containerPorts.https .Values.containerPorts.http .Values.tls.enabled }}
{{- end }}

{{- define "ehrbase.servicePortName" -}}
{{- ternary "https" "http" .Values.tls.enabled }}
{{- end }}
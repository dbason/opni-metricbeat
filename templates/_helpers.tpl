{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "opni-metricbeat.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "opni-metricbeat.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "opni-metricbeat.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "opni-metricbeat.labels" -}}
app.kubernetes.io/name: {{ include "opni-metricbeat.name" . }}
helm.sh/chart: {{ include "opni-metricbeat.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Configure the kube-state-metrics address
*/}}
{{- define "kube-state-metrics.address" }}
{{- if .Values.kubeStateMetrics.enabled -}}
{{- $name := include "opni-metricbeat.name" . -}}
{{- printf "%s-kube-state-metrics:8080" $name -}}
{{- else -}}
{{ required ".Values.kubeStateMetrics.address is required if the kube-state-metrics chart is disabled" .Values.kubeStateMetrics.address }}
{{- end -}}
{{- end }}

{{/*
Calculate the kubernetes distribution
*/}}
{{- define "identifyDistribution" -}}
{{- $nodes := (lookup "v1" "Node" "" "") -}}
{{- if $nodes -}}
{{- $_ := set . "dist" (first $nodes.items | dig "metadata" "labels" "node.kubernetes.io/instance-type" "nodist") -}}
  {{- if eq .dist "nodist" -}}
  {{- $_ := set . "dist" (hasKey ((first $nodes.items).metadata.annotations) "rke.cattle.io/internal-ip" | ternary "rke" "nodist") -}}
  {{- end -}}
{{- else -}}
{{- $_ := set . "dist" "nodist" -}}
{{- end -}}
{{ .dist }}
{{- end -}}

{{/*
Calculate the controlplane/master label
*/}}
{{- define "controlplaneLabel" -}}
{{- $dist := include "identifyDistribution" . -}}
{{- $default := or (eq $dist "rke2") (eq $dist "k3s") | ternary "node-role.kubernetes.io/master" "node-role.kubernetes.io/controlplane" -}}
{{ default $default .Values.controlplaneLabel }}
{{- end -}}
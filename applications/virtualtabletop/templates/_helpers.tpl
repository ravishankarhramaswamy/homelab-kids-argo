{{- define "virtualtabletop.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "virtualtabletop.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "virtualtabletop.name" . -}}
{{- end -}}
{{- end -}}

{{- define "virtualtabletop.selectorLabels" -}}
app.kubernetes.io/name: {{ include "virtualtabletop.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "virtualtabletop.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{ include "virtualtabletop.selectorLabels" . }}
app.kubernetes.io/part-of: kids-games
app.kubernetes.io/managed-by: argocd
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end -}}

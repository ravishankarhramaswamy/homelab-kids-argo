{{- define "wordpress-h5p.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "wordpress-h5p.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "wordpress-h5p.name" . -}}
{{- end -}}
{{- end -}}

{{- define "wordpress-h5p.selectorLabels" -}}
app.kubernetes.io/name: {{ include "wordpress-h5p.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "wordpress-h5p.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{ include "wordpress-h5p.selectorLabels" . }}
app.kubernetes.io/part-of: kids-games
app.kubernetes.io/managed-by: argocd
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end -}}

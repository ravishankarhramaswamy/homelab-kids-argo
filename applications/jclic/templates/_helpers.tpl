{{- define "jclic.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "jclic.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "jclic.name" . -}}
{{- end -}}
{{- end -}}

{{- define "jclic.selectorLabels" -}}
app.kubernetes.io/name: {{ include "jclic.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "jclic.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{ include "jclic.selectorLabels" . }}
app.kubernetes.io/part-of: kids-games
app.kubernetes.io/managed-by: argocd
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end -}}

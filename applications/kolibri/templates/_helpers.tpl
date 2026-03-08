{{- define "kolibri.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "kolibri.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- include "kolibri.name" . -}}
{{- end -}}
{{- end -}}

{{- define "kolibri.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kolibri.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "kolibri.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{ include "kolibri.selectorLabels" . }}
app.kubernetes.io/part-of: kids-games
app.kubernetes.io/managed-by: argocd
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end -}}

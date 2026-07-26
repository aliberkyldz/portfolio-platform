{{- define "portfolio.name" -}}portfolio{{- end }}
{{- define "portfolio.fullname" -}}{{ .Release.Name }}{{- end }}
{{- define "portfolio.labels" -}}
app.kubernetes.io/name: {{ include "portfolio.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

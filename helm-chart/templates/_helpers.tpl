{{- define "myapp.name" -}}
{{ .Chart.Name }}
{{- end -}}

{{- define "myapp.labels" -}}
app.kubernetes.io/name: {{ include "myapp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

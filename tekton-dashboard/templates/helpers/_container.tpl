{{- define "helpers.container.resources" -}}
{{- $Global := index . "Global" -}}
{{- $Application := index . "Application" -}}
{{- if $.Global.Values.pod.resources.enabled }}
resources:
{{- index $.Global.Values.pod.resources $Application | toYaml | trim | nindent 2 }}
{{- end }}
{{- end -}}

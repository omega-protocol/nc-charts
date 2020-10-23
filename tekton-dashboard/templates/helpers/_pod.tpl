{{- define "helpers.pod.container.image" -}}
    {{- $Global := index . "Global" -}}
    {{- $Application := index . "Application" -}}
    {{- with index $.Global.Values.images.applications $Application -}}
        {{- printf "%s/%s:%s" .repo .name ( .tag | toString ) | quote -}}
    {{- end -}}
{{- end -}}

{{- define "helpers.pod.node_selector" -}}
    {{- $Global := index . "Global" -}}
    {{- $Application := index . "Application" -}}
    {{- with index $.Global.Values.node_labels $Application -}}
        {{- if kindIs "slice" . -}}
            {{- range $k, $item := . }}
{{ $item.key }}: {{ $item.value | quote }}
            {{- end }}
        {{- else -}}
{{ .key }}: {{ .value | quote }}
        {{- end }}
    {{- end -}}
{{- end -}}

{{- define "tekton.pod_anti_affinity._match_expressions" -}}
{{- $envAll := index . "envAll" -}}
{{- $application := index . "application" -}}
{{- $component := index . "component" -}}
{{- $expressionRelease := dict "key" "release_group" "operator" "In"  "values" ( list ( $envAll.Values.release_group | default $envAll.Release.Name ) ) -}}
{{- $expressionApplication := dict "key" "application" "operator" "In"  "values" ( list $application ) -}}
{{- $expressionComponent := dict "key" "component" "operator" "In"  "values" ( list $component ) -}}
{{- list $expressionRelease $expressionApplication $expressionComponent | toYaml }}
{{- end -}}

{{- define "tekton.pod_anti_affinity" -}}
{{- $envAll := index . 0 -}}
{{- $application := index . 1 -}}
{{- $component := index . 2 -}}
{{- $antiAffinityType := index $envAll.Values.pod.affinity.anti.type $component | default $envAll.Values.pod.affinity.anti.type.default }}
{{- $antiAffinityKey := index $envAll.Values.pod.affinity.anti.topologyKey $component | default $envAll.Values.pod.affinity.anti.topologyKey.default }}
podAntiAffinity:
{{- $matchExpressions := include "tekton.pod_anti_affinity._match_expressions" ( dict "envAll" $envAll "application" $application "component" $component ) -}}
{{- if eq $antiAffinityType "preferredDuringSchedulingIgnoredDuringExecution" }}
  {{ $antiAffinityType }}:
  - podAffinityTerm:
      labelSelector:
        matchExpressions:
{{ $matchExpressions | indent 10 }}
      topologyKey: {{ $antiAffinityKey }}
{{- if  $envAll.Values.pod.affinity.anti.weight }}
    weight: {{ index $envAll.Values.pod.affinity.anti.weight $component | default $envAll.Values.pod.affinity.anti.weight.default }}
{{- else }}
    weight: 10
{{- end -}}
{{- else if eq $antiAffinityType "requiredDuringSchedulingIgnoredDuringExecution" }}
  {{ $antiAffinityType }}:
  - labelSelector:
      matchExpressions:
{{ $matchExpressions | indent 8 }}
    topologyKey: {{ $antiAffinityKey }}
{{- end -}}
{{- end -}}

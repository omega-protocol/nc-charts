{{- define "tekton.port_lookup" -}}
{{- $type := index . 0 -}}
{{- $endpoint := index . 1 -}}
{{- $port := index . 2 -}}
{{- $context := index . 3 -}}
{{- $typeYamlSafe := $type | replace "-" "_" }}
{{- $endpointMap := index $context.Values.endpoints $typeYamlSafe }}
{{- $endpointPortMAP := index $endpointMap.port $port }}
{{- $endpointPort := index $endpointPortMAP $endpoint | default ( index $endpointPortMAP "default" ) }}
{{- printf "%1.f" $endpointPort -}}
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

variable "kube_monitoring_stack_values" {
  type    = string
  default = <<-EOF
    grafana:
      adminUser: admin
      adminPassword: admin
      enabled: true
      ingress:
        enabled: true
        ingressClassName: nginx
        annotations:
          cert-manager.io/cluster-issuer: letsencrypt-production
        hosts:
          - grafana.aboali.cloud
        tls:
          - secretName: grafana-tls
            hosts:
              - grafana.aboali.cloud

    alertmanager:
      enabled: true
      ingress:
        enabled: true
        ingressClassName: nginx
        annotations:
          cert-manager.io/cluster-issuer: letsencrypt-production
        hosts:
          - alertmanager.aboali.cloud
        tls:
          - secretName: alertmanager-tls
            hosts:
              - alertmanager.aboali.cloud

    prometheus:
      ingress:
        enabled: true
        ingressClassName: nginx
        annotations:
          cert-manager.io/cluster-issuer: letsencrypt-production
        hosts:
          - prometheus.aboali.cloud
        tls:
          - secretName: prometheus-tls
            hosts:
              - prometheus.aboali.cloud
      prometheusSpec:
        replicas: 2
        replicaExternalLabelName: prometheus_replica
        prometheusExternalLabelName: prometheus_cluster
        enableAdminAPI: false
        logFormat: logfmt
        logLevel: info
        retention: 120h
        serviceMonitorSelectorNilUsesHelmValues: false
        serviceMonitorNamespaceSelector: {}
        serviceMonitorSelector: {}
        resources:
          limits:
            memory: 2Gi
          requests:
            cpu: 500m
            memory: 2Gi

    prometheus-node-exporter:
      resources:
        limits:
          memory: 30Mi
        requests:
          cpu: 20m
          memory: 30Mi

    kube-state-metrics:
      resources:
        limits:
          memory: 300Mi
        requests:
          cpu: 10m
          memory: 300Mi

    prometheusOperator:
      resources:
        limits:
          memory: 400Mi
        requests:
          cpu: 10m
          memory: 400Mi
    EOF
}

resource "helm_release" "kube_monitoring_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  version    = "45.29.0"

  create_namespace = true

  values = [var.kube_monitoring_stack_values]
}

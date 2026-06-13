require "prometheus_exporter/middleware"

Rails.application.middleware.unshift(
  PrometheusExporter::Middleware
)

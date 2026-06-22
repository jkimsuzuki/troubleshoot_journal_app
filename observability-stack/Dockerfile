FROM grafana/grafana:latest

USER root

RUN apk add --no-cache curl tar gzip supervisor

ARG PROMETHEUS_VERSION=2.55.1

RUN curl -L "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz" -o /tmp/prometheus.tar.gz \
  && mkdir -p /tmp/prometheus \
  && tar -xzf /tmp/prometheus.tar.gz -C /tmp/prometheus --strip-components=1 \
  && mv /tmp/prometheus/prometheus /usr/local/bin/prometheus \
  && mv /tmp/prometheus/promtool /usr/local/bin/promtool \
  && chmod +x /usr/local/bin/prometheus /usr/local/bin/promtool \
  && rm -rf /tmp/prometheus /tmp/prometheus.tar.gz

COPY observability-stack/supervisord.conf /etc/supervisord.conf
COPY observability-stack/prometheus.yml /etc/prometheus/prometheus.yml
COPY observability-stack/grafana/provisioning /etc/grafana/provisioning
COPY observability-stack/grafana/dashboards /etc/grafana/dashboards

ENV GF_SECURITY_ALLOW_EMBEDDING=true
ENV GF_AUTH_ANONYMOUS_ENABLED=true
ENV GF_AUTH_ANONYMOUS_ORG_ROLE=Viewer
ENV GF_AUTH_DISABLE_LOGIN_FORM=false
ENV GF_SERVER_HTTP_PORT=3000
ENV GF_SERVER_ROOT_URL=%(protocol)s://%(domain)s/
ENV GF_SERVER_SERVE_FROM_SUB_PATH=false

EXPOSE 3000

ENTRYPOINT []
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

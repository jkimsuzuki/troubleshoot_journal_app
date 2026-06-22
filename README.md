# SignalDesk

SignalDesk is a Rails-based incident tracking and observability platform designed to simulate real-world troubleshooting, incident response, and operational monitoring workflows.

Built as part of my journey toward Resiliency Incident Response, Site Reliability Engineering (SRE), and Production Support Engineering roles, SignalDesk combines issue management, reporting, metrics collection, monitoring, and alerting into a single application.

---

## Why I Built This

I built SignalDesk to simulate the workflow of Incident Response Engineers, Production Support Engineers, and Site Reliability Engineers.

The project combines issue tracking, observability tooling, monitoring, alerting, and troubleshooting workflows into a single platform. My goal was to gain hands-on experience with the same concepts used in production environments while strengthening my Ruby on Rails, monitoring, and operational troubleshooting skills.

---

## Overview

SignalDesk helps document, investigate, and resolve operational issues while providing visibility into system health through integrated monitoring and alerting.

The application was inspired by workflows used by Resiliency Incident Response Engineers, Technical Support Engineers, and Site Reliability Engineers who need to track incidents, identify patterns, monitor trends, and respond to operational issues.

---

## Key Features

### Authentication & Account Management

- Secure user authentication
- Session management
- Password reset via email
- Protected application routes

### Incident Tracking

Create and manage troubleshooting records including:

- Error messages
- Investigation notes
- Root causes
- Resolution steps
- Prevention strategies
- Interview-ready summaries

### Project Management

Organize incidents into projects and track operational issues across multiple systems.

### Tag Management

Categorize incidents using reusable tags for easier filtering and analysis.

### Search & Filtering

Quickly find historical incidents using:

- Full-text search
- Project filters
- Status filters
- Tag filters

### Timeline View

Track troubleshooting activity chronologically and review investigation history over time.

### Reporting Dashboard

Analyze operational trends through:

- Total incidents
- Resolution rates
- Active investigations
- Project breakdowns
- Tag statistics

### Embedded Observability Dashboard

View live operational metrics directly inside the application through an embedded Grafana dashboard.

### Slack Alerting

Receive notifications when:

- Application availability issues occur
- Incident backlog exceeds thresholds
- Aging incidents require attention

---

## Architecture

```text
Users
  ↓
Ruby on Rails Application (Koyeb)
  ↓
Neon PostgreSQL

Rails Metrics Endpoint (/metrics)
  ↓
Prometheus
  ↓
Grafana
  ↓
Slack Alerting
```

---

## Tech Stack

### Application

- Ruby
- Ruby on Rails 8
- ERB
- HTML5
- CSS3

### Database

- Neon PostgreSQL
- Active Record
- Rails Migrations

### Authentication

- Rails Authentication
- Session-Based Authentication
- Password Reset via Email

### Observability

- Prometheus
- Grafana
- Grafana Alerting
- Custom Rails Metrics Exporter

### Monitoring

- Embedded Grafana Dashboards
- Prometheus Time-Series Storage
- Persistent Metric Retention
- Slack Operational Alerting

### Infrastructure

- Docker
- Supervisor
- Koyeb
- Northflank

### Version Control & CI/CD

- Git
- GitHub
- GitHub Actions

### Testing & Quality

- Automated Rails Tests (Minitest)
- RuboCop
- Brakeman Security Scanning

---

## Monitoring & Alerting

SignalDesk includes a self-hosted observability stack designed to monitor application health and operational trends.

### Metrics Collected

- Total incidents
- Resolved incidents
- Active investigations
- Incident backlog
- Resolution rate
- Aging incidents
- Application uptime

### Alert Rules

#### Application Down

Triggers when Prometheus can no longer scrape SignalDesk metrics.

**Severity:** Critical

#### Backlog Too High

Triggers when unresolved incidents exceed the configured threshold.

**Severity:** Warning

#### Aging Incidents

Triggers when incidents remain unresolved beyond the acceptable investigation window.

**Severity:** Warning

### Alert Delivery

Alerts are delivered directly to Slack using Grafana Alerting.

---

## CI/CD

GitHub Actions automatically performs:

- Automated test execution
- RuboCop linting
- Brakeman security scanning
- Dependency auditing
- Deployment validation

This helps ensure application stability before deployment.

---

## Production Environment

### Application Hosting

Hosted on Koyeb.

### Database Hosting

Hosted on Neon PostgreSQL.

### Observability Hosting

Self-hosted on Northflank using:

- Grafana
- Prometheus

### Metrics Storage

Prometheus stores historical metrics with:

- 5 GB retention limit
- Up to 3 years of historical retention

### Visualization

Grafana dashboards are embedded directly within the Reports page of the application.

---

## Screenshots

### Dashboard

![Dashboard](docs/screenshots/dashboard.png)

### Timeline

![Timeline](docs/screenshots/timeline.png)

### Search

![Search](docs/screenshots/search.png)

### Reports

![Reports](docs/screenshots/reports.png)

### Grafana Monitoring

![Grafana](docs/screenshots/grafana.png)

### Slack Alerting

![Slack Alert](docs/screenshots/slack-alert.png)

---

## Lessons Learned

Building SignalDesk provided hands-on experience with:

- Rails application architecture
- Authentication and session management
- PostgreSQL database management
- Production deployments
- Metrics collection
- Observability tooling
- Dashboard creation
- Alerting systems
- Infrastructure troubleshooting
- Incident response workflows
- CI/CD pipelines
- Monitoring and alerting strategy

The project evolved from a simple troubleshooting journal into a production-style application with integrated monitoring, alerting, and operational visibility.

---

## Future Improvements

- Team collaboration features
- Incident assignment workflows
- Severity classifications
- Audit logging
- Service ownership mapping
- SLO and Error Budget tracking
- API endpoints
- Multi-tenant support
- Incident escalation workflows
- PagerDuty integration

---

## Author

### Joseph Kim-Suzuki

Built as part of a portfolio focused on:

- Incident Response
- Site Reliability Engineering (SRE)
- Observability
- Troubleshooting
- Production Support Engineering

GitHub: https://github.com/jkimsuzuki
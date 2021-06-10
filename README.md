# opni-metricbeat

## Prerequisites
- An elasticsearch endpoint available for metricbeat to connect to
- A Kubernetes secret with the Elasticsearch password
- Helm client >= 3.5.x

## Install chart
Clone the repo
```
git clone https://github.com/dbason/opni-metricbeat.git
```

Install the chart
```
helm install opni-metricbeat ./opni-metricbeat
```

### Important values
| Value | Default | Usage |
| --- | --- | --- |
| elasticsearch.host | elasticsearch | Elasticsearch hostname to connect to |
| elasticsearch.port | 9200 | Port Elasticsearch is listening on |
| elasticsearch.insecureSkipVerification | false | Boolean to control TLS verification (Set this to true if using an ELB for Elasticsearch for example) |
| elasticsearch.passwordSecret.name | es-password | Name of the secret containing the Elasticsearch password |
| elasticsearch.passwordSecret.key | password | Key containing the password |
| elasticsearch.loadDashboards | false | Boolean to configure whether to install the metricbeat dashboards in Elasticsearch (requires access to the Kibana API) |
| kibana.url | http://localhost | URL to connect to Kibana to load the dashboards |
| kubeStateMetrics.enabled | true | Install the kube-state-metrics subchart (disable if kube-state-metrics is already installed) |
| kubeStateMetrics.address | "" | kube-state-metrics endpoint; required if the subchart is disabled |

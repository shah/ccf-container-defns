local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";
local prometheusConf = import "prometheus.ccf-conf.jsonnet";
local dockerConf = import "docker-localhost.ccf-facts.json";
local prometheusSqlAgentExporterConf = import "prometheus-sql-agent-exporter.ccf-conf.jsonnet";

local webServicePort = prometheusConf.webServicePort;
local webServicePortInContainer = webServicePort;
local promConfigFileInContainer = '/etc/prometheus/prometheus.yml';
local tsdbStoragePathInContainer = '/var/prometheus/data';

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				container_name: context.containerName,
				image: 'prom/prometheus:latest',
				command: '--storage.tsdb.path='+ tsdbStoragePathInContainer +' --web.listen-address :'+ webServicePortInContainer +' --config.file=' + promConfigFileInContainer,
				restart: 'always',
				ports: [webServicePort + ':' + webServicePortInContainer],
				networks: ['network'],
				volumes: [
					'storage:' + tsdbStoragePathInContainer,
					context.containerDefnHome + '/etc/prometheus.yml:' + promConfigFileInContainer,
				],
				user: "root", // SNS: by default Prometheus container runs as nobody:nogroup but volumes are owned by root so we switch
				labels: {
					'traefik.enable': 'true',
					'traefik.docker.network': common.defaultDockerNetworkName,
					'traefik.domain': context.containerName + '.' + common.applianceFQDN,
					'traefik.backend': context.containerName,
					'traefik.frontend.entryPoints': 'http,https',
					'traefik.frontend.rule': 'Host:' + context.containerName + '.' + common.applianceFQDN,
				}
			},
		},

		networks: {
			network: {
				external: {
					name: common.defaultDockerNetworkName
				},
			},
		},

		volumes: {
			storage: {
				name: context.containerName
			},
		},
	}),

	"etc/prometheus.yml" : std.manifestYamlDoc({
		global: {
			scrape_interval: "1m",
			scrape_timeout: "10s",
			evaluation_interval: "1m",
			external_labels: {
				monitor: "appliance"
			}
		},
		rule_files: null,
		scrape_configs: [
			// This monitors prometheus itself, localhost refers to the container, not Docker host
			{
				job_name: "prometheus",
				scrape_interval: "5s",
				static_configs: [ { targets: ["localhost:8010"] } ]
			},
			// This requires prometheus-node-exporter package to be installed in Docker host
			{
				job_name: "node",
				scrape_interval: "15s",
				static_configs: [ { targets: [dockerConf.dockerHostIPAddress + ":9100"] } ]
			},
			// This requires prometheus-node-exporter package to be installed in Docker host
			{
				job_name: "sql-agent",
				scrape_interval: "1m", // watch this carefully and make sure sql-agent exporter doesn't encounter jitter
				static_configs: [ { targets: [dockerConf.dockerHostIPAddress + ":" + prometheusSqlAgentExporterConf.webServicePort] } ]
			},
			{
				job_name: "cadvisor",
				scrape_interval: "15s",
				static_configs: [ {	targets: [ dockerConf.dockerHostIPAddress + ":8080"] } ]
			},
			// TODO: figure out how to add container tags and auto-discovery of metrics sources
			//       using file_sd_config instead of static_configs
			// {
			// 	job_name: "containers",
			// 	honor_labels: true,
			// 	file_sd_configs: [
			// 		{
			// 			files: [
			// 				"foo/*.slow.json",
			// 				"foo/*.slow.yml",
			// 				"single/file.yml"
			// 			],
			// 			refresh_interval: "10m"
			// 		},
			// 		{
			// 			files: [
			// 				"bar/*.yaml"
			// 			]
			// 		}
			// 	],
			// },
		]
	})
}

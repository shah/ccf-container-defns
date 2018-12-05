local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";
local sqlAgentConf = import "sql-agent.ccf-conf.jsonnet";
local prometheusSqlAgentExporterConf = import "prometheus-sql-agent-exporter.ccf-conf.jsonnet";
local dockerConf = import "docker-localhost.ccf-facts.json";

local webServicePort = prometheusSqlAgentExporterConf.webServicePort;
local webServicePortInContainer = webServicePort;

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3',

		services: {
			container: {
				container_name: context.containerName,
				image: 'dbhi/prometheus-sql',
				restart: 'always',
				ports: [webServicePort + ':' + webServicePortInContainer],
				networks: ['network'],
				volumes: [
					context.containerRuntimeConfigHome + '/data-sources.yml:/data-sources.yml',
					context.containerRuntimeConfigHome + '/queries:/queries',
				],
				// TODO: replace the -service config with a CAF.libsonnet function call so multiple containers can share
				command: "-port "+ webServicePortInContainer + " " +
				         "-service http://" + dockerConf.dockerHostIPAddress + ":" + sqlAgentConf.webServicePort + " " +
				         "-config /data-sources.yml " +
						 "-queryDir /queries"
			}
		},

		networks: {
			network: {
				external: {
					name: common.defaultDockerNetworkName
				},
			},
		},
	}),
}


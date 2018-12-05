local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";
local sqlAgentConf = import "sql-agent.ccf-conf.jsonnet";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3',

		services: {
			container: {
				container_name: context.containerName,
				image: 'dbhi/sql-agent',
				restart: 'always',
				ports: [sqlAgentConf.webServicePort + ':5000'],
				networks: ['network'],
				labels: {
					'traefik.enable': 'true',
					'traefik.docker.network': common.defaultDockerNetworkName,
					'traefik.domain': context.containerName + '.' + common.applianceFQDN,
					'traefik.backend': context.containerName,
					'traefik.frontend.entryPoints': 'http,https',
					'traefik.frontend.rule': 'Host:' + context.containerName + '.' + common.applianceFQDN,
				}
			}
		},

		networks: {
			network: {
				external: {
					name: common.defaultDockerNetworkName
				},
			},
		},
	})
}

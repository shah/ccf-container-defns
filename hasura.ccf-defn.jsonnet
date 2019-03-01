local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";
local traefikConf = import "traefik.ccf-conf.jsonnet";
local containerSecrets = import "hasura.secrets.ccf-conf.jsonnet";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				container_name: context.containerName,
				image: 'hasura/graphql-engine:v1.0.0-alpha38',
				restart: 'always',
				ports: ['8085:8080'],
				networks: ['network'],
                                environment: [
                                             'HASURA_GRAPHQL_DATABASE_URL=postgres://' + containerSecrets.databaseUser + ':' + containerSecrets.databasePassword + '@' + containerSecrets.databaseHost + ':' + containerSecrets.databasePort + '/' + containerSecrets.databaseName,
                                             'HASURA_GRAPHQL_ENABLE_CONSOLE=true'
                                ],
				labels: {
					'traefik.enable': 'true',
					'traefik.docker.network': common.defaultDockerNetworkName,
					'traefik.domain': context.containerName + '.' + traefikConf.applianceFQDN,
					'traefik.backend': context.containerName,
					'traefik.frontend.entryPoints': 'http,https',
					'traefik.frontend.rule': 'Host:' + context.containerName + '.' + traefikConf.applianceFQDN,
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

		volumes: {
			storage: {
				name: context.containerName
			},
		},
	})
}

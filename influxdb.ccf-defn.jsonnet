local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";
local traefikConf = import "traefik.ccf-conf.jsonnet";
local webServicePort = 8086;

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				container_name: context.containerName,
				image: 'influxdb',
				restart: 'always',
				ports: [webServicePort + ':8086'],
				networks: ['network'],
				volumes: [
					'storage:/var/lib/influxdb'
				],
				labels: {
					'traefik.enable': 'true',
					'traefik.docker.network': common.defaultDockerNetworkName,
					'traefik.domain': context.containerName + '.' + traefikConf.applianceFQDN,
					'traefik.backend': context.containerName,
					'traefik.frontend.entryPoints': 'http,https',
					'traefik.frontend.rule': 'Host:' + context.containerName + '.' + traefikConf.applianceFQDN,
					'traefik.frontend.auth.basic': traefikConf.influxUserName + ':' + traefikConf.influxPassword,
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

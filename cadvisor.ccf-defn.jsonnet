local applianceConf = import "common.ccf-conf.jsonnet";
local containerFacts = import "container.facts.json";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3',

		services: {
			container: {
				container_name: containerFacts.containerName,
				image: 'google/cadvisor:latest',
				restart: 'always',
				ports: ['8080:8080'],
				networks: ['network'],
				volumes: [
					'/:/rootfs:ro',
					'/var/run:/var/run:rw',
					'/sys:/sys:ro',
					'/var/lib/docker/:/var/lib/docker:ro',
					'/dev/disk/:/dev/disk:ro'
				],
				labels: {
					'traefik.enable': 'true',
					'traefik.docker.network': applianceConf.defaultDockerNetworkName,
					'traefik.domain': containerFacts.containerName + '.' + applianceConf.applianceFQDN,
					'traefik.backend': containerFacts.containerName,
					'traefik.frontend.entryPoints': 'http,https',
					'traefik.frontend.rule': 'Host:' + containerFacts.containerName + '.' + applianceConf.applianceFQDN,
				}
			}
		},

		networks: {
			network: {
				external: {
					name: applianceConf.defaultDockerNetworkName
				},
			},
		},
	})
}

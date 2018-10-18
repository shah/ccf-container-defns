local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3',

		services: {
			container: {
				container_name: context.containerName,
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

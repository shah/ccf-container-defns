local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3',

		services: {
			container: {
				container_name: context.containerName,
				image: 'jaegertracing/all-in-one:latest',
				restart: 'always',
				ports: [
					'5775:5775/udp',
					'6831:6831/udp',
					'6832:6832/udp',
					'5778:5778',
					'16686:16686',
					'14268:14268',
					'9411:9411'
				],
				networks: ['network'],
				environment: [
					'COLLECTOR_ZIPKIN_HTTP_PORT=9411',
				],
				labels: {
					'traefik.enable': 'true',
					'traefik.port': '16686',
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

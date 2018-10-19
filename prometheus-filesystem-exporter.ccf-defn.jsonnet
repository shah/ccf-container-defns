local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";

local webServicePort = 9119;
local webServicePortInContainer = webServicePort;

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3',

		services: {
			container: {
				build: '.',
				container_name: context.containerName,
				image: context.containerName + ':latest',
				restart: 'always',
				ports: [webServicePort + ':' + webServicePortInContainer],
				networks: ['network'],
				volumes: [context.containerRuntimeConfigHome + '/metrics:/container/metrics'],
				command: "--listen-addr :"+ webServicePortInContainer +" --metrics-directory /container/metrics",
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

	"Dockerfile" : |||
		FROM alpine:latest
		EXPOSE 8080
		ENTRYPOINT ["./prometheus-filesystem-exporter"]
		ADD https://github.com/larscheid-schmitzhermes/prometheus-filesystem-exporter/releases/download/1.0.0/prometheus-filesystem-exporter prometheus-filesystem-exporter
		RUN chmod +x prometheus-filesystem-exporter
	|||,
}
local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";

local webServicePort = 4260;

{
	"Dockerfile" : |||
		FROM openjdk:8-alpine
		ADD https://github.com/KyleU/databaseflow/releases/download/v1.5.1/DatabaseFlow.jar /root/DatabaseFlow.jar
		WORKDIR /root
		VOLUME ["/root/.databaseflow"]
		EXPOSE %(webServicePort)d
		CMD ["java", "-jar" , "DatabaseFlow.jar"]
	||| % { webServicePort: webServicePort },

	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				build: '.',
				container_name: context.containerName,
				image: context.containerName + ':latest',
				restart: 'always',
				ports: [webServicePort + ':' + webServicePort],
				networks: ['network'],
				volumes: ['storage:/root/.databaseflow'],
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

		volumes: {
			storage: { 
				name: context.containerName
			},
		},
	})
}
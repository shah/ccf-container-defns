local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";
local gitExporter = import "gitExporter.secrets.ccf-conf.jsonnet";
{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				container_name: context.containerName,
				image: 'infinityworks/github-exporter:latest',
				restart: 'always',
				ports: ['9171:9171'],
				networks: ['network'],
		                environment: [
                		    'REPOS=' + gitExporter.repos,
		                    'GITHUB_TOKEN=' + gitExporter.token
                		    ]
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

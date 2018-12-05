local common = import "common.ccf-conf.jsonnet";
local ccflib = import "ccf.libsonnet";
local context = import "context.ccf-facts.json";
local containerSecrets = import "postgres.secrets.ccf-conf.jsonnet";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				container_name: context.containerName,
				image: 'postgres',
				restart: 'always',
				ports: [containerSecrets.databasePort + ':5432'],
				networks: ['network'],
				volumes: ['storage:/var/lib/postgresql/data'],
				environment: [
					'POSTGRES_USER=' + containerSecrets.adminUser,
					'POSTGRES_PASSWORD=' + containerSecrets.adminPassword
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

		volumes: {
			storage: {
				name: context.containerName
			},
		},
	}),

	"after_start.make-plugin.sh" :
		ccflib.bashSnippets.preamble(context) + 
		ccflib.bashSnippets.waitForContainerStatus(context, 'running'),
}

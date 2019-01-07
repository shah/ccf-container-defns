local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";
local dockerConf = import "docker-localhost.ccf-facts.json";
local containerSecrets = import "postgres.secrets.ccf-conf.jsonnet";
local postgresExporterPort = "9187";


{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3',

		services: {
			container: {
				container_name: context.containerName,
				image: 'wrouesnel/postgres_exporter',
				restart: 'always',
				ports: [postgresExporterPort + ':9187'],
				networks: ['network'],
                environment: ['DATA_SOURCE_NAME=postgresql://' + containerSecrets.adminUser + ':' + containerSecrets.adminPassword + '@' + dockerConf.dockerHostIPAddress + ':5432/postgres?sslmode=disable'],
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

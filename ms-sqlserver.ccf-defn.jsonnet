local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";
local containerSecrets = import "ms-sqlserver.secrets.jsonnet";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				container_name: context.containerName,
				image: 'microsoft/mssql-server-linux',
				restart: 'always',
				ports: ['1433:1433'],
				networks: ['network'],
				volumes: ['storage:/var/opt/mssql'],
				environment: ['SA_PASSWORD=' + containerSecrets.SA_password, 'ACCEPT_EULA=Y']
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

	"container.make.inc" : |||
		## Run a SQL command in the container
		sqlcmd:
			sudo docker exec -it $(CONTAINER_NAME) /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P $(DBA_USER_PASSWORD)
	|||,

	"after_start.make-plugin.sh" :
		ccflib.bashSnippets.preamble(context) + 
		ccflib.bashSnippets.waitForContainerLogMessage(context, 'SQL Server is now ready for client connections.'),

	"README.md" : |||
		Please see [this blog post](https://cardano.github.io/blog/2017/11/15/mssql-docker-container) for a good explanation
		of how to setup Microsoft SQL Server containers.
	|||,
}
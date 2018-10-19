local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";
local containerSecrets = import "mysql.secrets.jsonnet";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				container_name: context.containerName,
				image: 'mysql/mysql-server',
				restart: 'always',
				ports: [containerSecrets.databasePort + ':3306'],
				command: "mysqld --innodb-buffer-pool-size=20M",
				networks: ['network'],
				volumes: ['storage:/var/lib/mysql'],
				environment: [
					'MYSQL_ROOT_HOST=%',  // allow root access from any host (TODO: make this secure later)
					'MYSQL_ROOT_PASSWORD=' + containerSecrets.rootPassword
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
		ccflib.bashSnippets.waitForContainerHealthStatus(context, 'healthy') +
		ccflib.bashSnippets.openHostFirewallPortNumber(context, containerSecrets.databasePort) +

	"container.make.inc" : |||
		## Run a SQL command in the container
		mysql:
			sudo docker exec -it $(CONTAINER_NAME) mysql -uroot -p
		#
		## One some mysql clients you might encounter ERROR 2059 (HY000): Authentication plugin 'caching_sha2_password' cannot be loaded
		## If so, this target fixes that error
		fix-error-2059:
			sudo docker exec -d $(CONTAINER_NAME) mysql -uroot -p -e "use mysql; ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '1234'; FLUSH PRIVILEGES;"
	|||
}
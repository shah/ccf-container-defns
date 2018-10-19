local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";
local containerSecrets = import "sematext-agent.conf.jsonnet";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3',

		services: {
			container: {
				container_name: context.containerName,
				image: 'sematext/sematext-agent-docker:latest',
				restart: 'always',
				networks: ['network'],
				environment: [
					"SPM_TOKEN=%(sematextSPMToken)s" % containerSecrets,
					"LOGSENE_TOKEN=%(logSeneToken)s" % containerSecrets,
					"affinity:container!=*sematext-agent*"
				],
				cap_add: [
					"SYS_ADMIN"
				],
				volumes: [
					'/var/run/docker.sock:/var/run/docker.sock',
					'/:/rootfs:ro',
				],
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

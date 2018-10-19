local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3',

		services: {
			container: {
				container_name: context.containerName,
				image: 'linuxserver/syncthing', // https://github.com/linuxserver/docker-syncthing
				restart: 'always',
				ports: [
					'8384:8384',
					'22000:22000',
					'21027:21027/udp'
				],
				networks: ['network'],
				volumes: [
					'*host path to config*:/config', // TODO: fill this out
					'*host path to data*:/mnt/any/dir/you/want', // TODO: fill this out
				],
				environment: [
					"PUID=" + context.currentUserId,
					"PGID=" + context.currentUserGroupId
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

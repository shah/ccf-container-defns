local common = import "common.ccf-conf.jsonnet";
local ccflib = import "ccf.libsonnet";
local context = import "context.ccf-facts.json";
local traefikConf = import "traefik.conf.jsonnet";
{

     "docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
                                container_name: context.containerName,
                                image: 'linuxserver/tt-rss:142',
                                networks: ['network'],
                                volumes: ['storage:/config'],
                                labels: {
                                        'traefik.enable': 'true',
                                        'traefik.docker.network': common.defaultDockerNetworkName,
                                        'traefik.domain': traefikConf.ttrssurl,
                                        'traefik.backend': context.containerName,
                                        'traefik.port': '80',
                                        'traefik.frontend.entryPoints': 'http,https',
                                        'traefik.frontend.rule': 'Host:' + traefikConf.ttrssurl,
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
                                name: context.containerName + "_data"
                        },
                },

    }),

    "after_start.make-plugin.sh" : |||
     ccflib.bashSnippets.preamble(context) + 
     ccfLib.bashSnippets.waitForContainerLogMessage(context, 'starting services')
    |||,
}

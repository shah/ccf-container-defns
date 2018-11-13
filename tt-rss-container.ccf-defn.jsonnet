local common = import "common.ccf-conf.jsonnet";
local ccflib = import "ccf.libsonnet";
local context = import "context.ccf-facts.json";
local traefik = import "tt-rss-traefik.ccf-conf.jsonnet";
{

     "docker-compose.yml" : std.manifestYamlDoc({
                version: '3.4',

                services: {
                        container: {
                                container_name: context.containerName,
                                image: 'linuxserver/tt-rss:latest',
                                networks: ['network'],
                                volumes: ['storage:/config'],
                                labels: {
                                        'traefik.enable': 'true',
                                        'traefik.docker.network': common.defaultDockerNetworkName,
                                        'traefik.domain': traefik.ttrssurl,
                                        'traefik.backend': context.containerName,
                                        'traefik.port': '80',
                                        'traefik.frontend.entryPoints': 'http,https',
                                        'traefik.frontend.rule': 'Host:' + traefik.ttrssurl,
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

    }),

 "after_start.make-plugin.sh" :
    ccflib.bashSnippets.preamble(context) +
    ccflib.bashSnippets.waitForContainerLogMessage(context, 'starting services') +
    'echo -e "\n****************************************************\n"
    echo -e "Please take tt-rss URL in browser and do the following steps:"
    echo -e "\n  1. Give database details \n  2. Initialize database \n  3. Save config file"'
}


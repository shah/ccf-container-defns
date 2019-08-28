local common = import "common.ccf-conf.jsonnet";
local ccflib = import "ccf.libsonnet";
local context = import "context.ccf-facts.json";
local traefikConf = import "traefik.ccf-conf.jsonnet";
{

     "docker-compose.yml" : std.manifestYamlDoc({
                version: '3.4',

                services: {
                        container: {
                                container_name: context.containerName,
                                restart: 'unless-stopped',
                                image: 'rancher/rancher',
                                networks: ['network'],
                                labels: {
                                        'traefik.enable': 'true',
                                        'traefik.docker.network': common.defaultDockerNetworkName,
                                        'traefik.domain': traefikConf.rancherHost,
                                        'traefik.backend': context.containerName,
                                        'traefik.protocol': 'https',
                                        'traefik.port': '443',
                                        'traefik.frontend.entryPoints': 'http,https',
                                        'traefik.frontend.rule': 'Host: '+traefikConf.rancherHost,
                                },
                                     }
                },

                networks: {
                        network: {
                                external: {
                                        name: common.defaultDockerNetworkName
                                },
                        },
                },

    }),
}

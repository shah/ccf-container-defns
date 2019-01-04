local common = import "common.ccf-conf.jsonnet";
local ccflib = import "ccf.libsonnet";
local context = import "context.ccf-facts.json";
local owasp = import "owasp-dependency-track.ccf-conf.jsonnet";


{

 "docker-compose.yml" : std.manifestYamlDoc({
               version: '3.4',
                services: {
                        container: {
                                container_name: context.containerName,
                                image: 'owasp/dependency-track',
                                networks: ['network'],
                                ports: ['8110:8080'],
                                volumes: [ 'storage:/data'],
                                labels: {
                                        'traefik.enable': 'true',
                                        'traefik.docker.network': common.defaultDockerNetworkName,
                                        'traefik.domain': owasp.url,
                                        'traefik.backend': context.containerName,
                                        'traefik.port': '80',
                                        'traefik.frontend.entryPoints': 'http,https',
                                        'traefik.frontend.rule': 'Host:' + owasp.url,
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
}


local common = import "common.ccf-conf.jsonnet";
local ccflib = import "ccf.libsonnet";
local context = import "context.ccf-facts.json";
local cupsAgentConf = import "cups-agent.ccf-conf.jsonnet";
local traefikConf = import "traefik.ccf-conf.jsonnet";

local cupsServicePort = cupsAgentConf.cupsServicePort;
local cupsPortInContainer = cupsServicePort;
{
'Dockerfile': |||
  FROM ubuntu:trusty
  RUN apt-get update -y && apt-get -y --force-yes --no-install-recommends install \
  cups \
  cups-pdf \
  cups-client \
  cups-common \
  cups-filters \
  cups-pk-helper \
  cups-ppdc  \
  cups-client \
  cups-browsed \
  printer-driver-all \
  vim
  RUN mkdir -p /var/spool/cups-pdf/ANONYMOUS
  VOLUME "/var/spool/cups-pdf/ANONYMOUS"
  EXPOSE 631
  CMD ["/usr/sbin/cupsd", "-f"]
|||,

        "docker-compose.yml" : std.manifestYamlDoc({
                version: '3.4',
                services: {
                        container: {
                                build: '.',
                                container_name: context.containerName,
                                image: context.containerName + ':latest',
                                restart: 'always',
                                ports: [ webServicePort +':631'],
                                networks: ['network'],
                                volumes: ['storage:/var/spool/cups-pdf/ANONYMOUS'],
				labels: {
					'traefik.enable': 'true',
					'traefik.docker.network': common.defaultDockerNetworkName,
					'traefik.domain': context.containerName + '.' + traefikConf.applianceFQDN,
					'traefik.backend': context.containerName,
					'traefik.frontend.entryPoints': 'http,https',
					'traefik.frontend.rule': 'Host:' + context.containerName + '.' + traefikConf.applianceFQDN,
				}

                },

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





        })
}

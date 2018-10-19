local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";
local mtailExporterConf = import "prometheus-mtail-exporter.conf.json";

local webServicePort = mtailExporterConf.webServicePort;
local webServicePortInContainer = webServicePort;
local mtailProgramsHomeInHost = context.containerDefnHome + "/mtail-3.0.0-rc16-examples";
local mtailProgramsHomeInContainer = "/etc/mtail";
local mtailLogsHomeInContainer = "/var/log/mtail";

{
	"Dockerfile" : |||
		FROM ubuntu
		ARG mtailVersion=3.0.0-rc16
		ARG mtailHome=/mtail
		ARG mtailReleasePackage=https://github.com/google/mtail/releases/download/v${mtailVersion}/mtail_v${mtailVersion}_linux_amd64
		ARG mtailProgramsHome=/etc/mtail
		WORKDIR ${mtailHome}
		ADD ${mtailReleasePackage} ${mtailHome}/mtail-${mtailVersion}
		RUN chmod a+rx ${mtailHome}/mtail-${mtailVersion} && ln -s ${mtailHome}/mtail-${mtailVersion} /usr/bin/mtail
		VOLUME ["${mtailProgramsHome}"]
		EXPOSE 3903
		LABEL author="Shahid N. Shah <shahid@shah.org>" \
			deploy.mtail.releases.version="${mtailVersion}" \
			deploy.mtail.releases.downloadPath="${mtailReleasePackage}" \
			deploy.mtail.home="${mtailProgramsHome}" \
			deploy.mtail.progsHome="${mtailProgramsHome}"
		ENTRYPOINT ["/usr/bin/mtail"]
	|||,

	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				build: '.',
				container_name: context.containerName,
				image: context.containerName + ':latest',
				restart: 'always',
				ports: [webServicePort + ':' + webServicePortInContainer],
				networks: ['network'],
				volumes: [
					"logs:" + mtailLogsHomeInContainer,
				 	mtailProgramsHomeInHost + ':' + mtailProgramsHomeInContainer,
				],
				command: 
					"--port "+ webServicePortInContainer + " " +
					"--progs " + mtailProgramsHomeInContainer + " " +
					"--log_dir " + mtailLogsHomeInContainer + " " +
					"--logs /var/log/syslog", // for testing, this is just logging the internal container's logs
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

		volumes: {
			logs: {
				name: context.containerName + "_logs"
			},
		},
	}),

	"container.make.inc" : |||
		MTAIL_VERSION_IN_CONTAINER := $(shell docker inspect --format "{{ index .Config.Labels \""deploy.mtail.releases.version"\"}}" $(CONTAINER_NAME))
		## Get the examples from the deployed version of mtail
		get-mtail-examples:
			echo "Downloading mtail $(MTAIL_VERSION_IN_CONTAINER) examples from source release package on GitHub"
			wget -O mtail-SRC-$(MTAIL_VERSION_IN_CONTAINER).tar.gz https://github.com/google/mtail/archive/v$(MTAIL_VERSION_IN_CONTAINER).tar.gz
			tar -xzf mtail-SRC-$(MTAIL_VERSION_IN_CONTAINER).tar.gz
			mv mtail-$(MTAIL_VERSION_IN_CONTAINER)/examples ./mtail-$(MTAIL_VERSION_IN_CONTAINER)-examples
			rm -rf mtail-SRC-$(MTAIL_VERSION_IN_CONTAINER).tar.gz mtail-$(MTAIL_VERSION_IN_CONTAINER)
			echo "Examples are available in ./mtail-$(MTAIL_VERSION_IN_CONTAINER)-examples"
	|||
}
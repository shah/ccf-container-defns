local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";
local dockerFacts = import "eth0-interface-localhost.ccf-facts.json";
local traefikConf = import "traefikEventNav.ccf-conf.jsonnet";

local webServicePort = 3100;
local webServicePortInContainer = webServicePort;
local lokiConfigFileInContainer = '/etc/loki/loki-local-config.yml';
local promtailConfigFileInContainer = '/etc/promtail/promtail-docker-config.yml';
local lokiLogDirectory = '/var/log/loki';

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3',

		services: {
			 loki: {
				container_name: 'loki',
				image: 'grafana/loki:master',
				command: '-config.file=' + lokiConfigFileInContainer,
				restart: 'always',
				ports: [webServicePort + ':' + webServicePortInContainer],
				networks: ['network'],
				volumes: [
					context.containerDefnHome + '/etc/loki:/etc/loki',
				],
			 },
             promtail: {
                container_name: 'promtail',
                image: 'grafana/promtail:make-images-static-26a87c9',
                command: '-config.file=' + promtailConfigFileInContainer,
                restart: 'always',
                networks: ['network'],
                volumes: [
                     context.containerDefnHome + '/etc/promtail:/etc/promtail',
                     lokiLogDirectory + ':/var/log',
                ],
		     },
        },

		networks: {
			network: {
				external: {
					name: common.defaultDockerNetworkName
				},
			},
		},
	}),

	"etc/loki/loki-local-config.yml" : std.manifestYamlDoc({
    	 auth_enabled: false,
		 server: {
		    http_listen_port: 3100,
  		 },
	     ingester: {
	       lifecycler: {
             address: '127.0.0.1',
             ring: {
               store: 'inmemory',
               replication_factor: 1,
             },
           },
         },
         schema_config: {
           configs: [
             {
               from: 0,
               store: 'boltdb',
               object_store: 'filesystem',
               schema: 'v9',
               index: {
                prefix: 'index_',
                period: '168h',
             },
           },
          ],
         },
         storage_config: {
           boltdb: {
             directory: '/tmp/loki/index',
           },
           filesystem: {
             directory: '/tmp/loki/chunks',
           },
         },
	}),

    "etc/promtail/promtail-docker-config.yml" : std.manifestYamlDoc({
     server: {
       http_listen_port: 0,
       grpc_listen_port: 0,
     },
     positions: {
       filename: '/tmp/positions.yaml',
     },
     client: {
       url: 'http://loki:3100/api/prom/push',
     },
     scrape_configs: [
        {
          job_name: 'system',
          entry_parser: 'raw',
          static_configs: [
          {
            targets: [
             'localhost',
            ],
            labels: {
              job: 'varlogs',
              __path__: '/var/log',
            },
          },
         ],
       },
    ],
   }),

}

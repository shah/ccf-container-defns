local manifestToml = import "manifestToml.libsonnet";
local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";

local traefikLogsDirInContainer = "/var/log/traefik";

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3.4',

		services: {
			container: {
				container_name: context.containerName,
				image: 'traefik:latest',
				restart: 'always',
				ports: ['80:80', '443:443', '8099:8099'],
				networks: ['network'],
				volumes: [
					'/var/run/docker.sock:/var/run/docker.sock',
					context.containerDefnHome + '/traefik.toml:/traefik.toml',
					context.containerDefnHome + '/acme.json:/acme.json',
					'logs:' + traefikLogsDirInContainer,
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

		volumes: {
			logs: { 
				name: context.containerName + "_logs"
			},
		},
	}),

 	"traefik.toml" : manifestToml({
		debug: false,
		logLevel: "INFO",
		defaultEntryPoints: [
			"https",
			"http"
		],
		entryPoints: {
			http: {
				address: ":80",
				redirect: {
					entryPoint: "https"
				}
			},
			https: {
			address: ":443",
			tls: {}
			}
		},
		retry: {},
		docker: {
			endpoint: "unix:///var/run/docker.sock",
			domain: "appliance.local",
			watch: true,
			exposedByDefault: false
		},
		acme: {
			email: "admin@appliance.local",
			storage: "acme.json",
			entryPoint: "https",
			onHostRule: true,
			httpChallenge: {
				entryPoint: "http"
			}
		},
		traefikLog: {
			filePath: traefikLogsDirInContainer + "/service.log"
		},
		accessLog: {
			filePath: traefikLogsDirInContainer + "/access.log"
		},
		web: {
			address: ":8099",
			// auth : {
			// 	basic : {
			// 		users : [
			// 			"admin:generate with htpasswd -nb secret",
			// 		],
			// 	},
			// },
		}
	}),

	"after_configure.make-plugin.sh" : |||
	    #!/usr/bin/env bash
		echo "Preparing ACME config permissions for LetsEncrypt configuration"
		sudo touch acme.json
		sudo chmod 600 acme.json
	|||,

	"container.make.inc" : |||
		## Generate an HTTP Basic Auth password
		htpasswd:
			sudo apt-get install apache2-utils
			htpasswd -nb admin secure_password
	|||
}
local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";

local webServicePort = 9232;
local webServicePortInContainer = webServicePort;

{
	"Dockerfile" : |||
		FROM golang:alpine as builder
		RUN apk update && apk add git && \
			git clone https://github.com/%(module)s /go/src/github.com/%(module)s
		WORKDIR /go/src/github.com/%(module)s
		RUN go get -d && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -ldflags='-w -s' -o /go/bin/%(goTargetBinaryName)s
		FROM scratch
		COPY --from=builder /go/bin/%(goTargetBinaryName)s %(appPath)s/%(goTargetBinaryName)s
		EXPOSE %(webServicePortInContainer)d
		VOLUME ["%(appPath)s/config.yaml"]
		ENTRYPOINT ["%(appPath)s/%(goTargetBinaryName)s"]
		CMD ["-config.file", "%(appPath)s/config.yaml", "-web.listen-address", "%(webServicePortInContainer)d"]
	||| % { 
			module: "zwopir/osquery_exporter",
			goTargetBinaryName: "agent",
	        webServicePortInContainer: webServicePortInContainer,
			appPath: "/app"
		},

	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3',

		services: {
			container: {
				build: '.',
				container_name: context.containerName,
				image: context.containerName + ':latest',
				restart: 'always',
				ports: [webServicePort + ':' + webServicePortInContainer],
				volumes: ["./config.yaml:/app/config.yaml"],
				networks: ['network'],
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
	}),

	"config.yaml" : std.manifestYamlDoc({
        runtime: {
            osquery: "osqueryi",
            timeout: "10s"
        },
        metrics: {
            counters: [
                {
                    name: "history_lines_count",
                    help: "number of entries in the history",
                    query: "select count(*) as count from shell_history",
                    valueidentifier: "count"
                }
            ],
            countervecs: [
                {
                    name: "last_users_count",
                    help: "number of last logins by username and tty",
                    query: "select username, tty, count(*) as count from last where username != '' group by username;",
                    valueidentifier: "count",
                    labelidentifier: [
                        "username",
                        "tty"
                    ]
                }
            ],
            gauges: [
                {
                    name: "block_devices",
                    help: "number of block devices which are not partitions",
                    query: "select count(*) as count from block_devices where parent = '';",
                    valueidentifier: "count"
                },
                {
                    name: "crontab_entries",
                    help: "number of entries in the crontab",
                    query: "select count(*) as count from crontab;",
                    valueidentifier: "count"
                }
            ],
            gaugevecs: [
                {
                    name: "users_by_shell",
                    help: "number of users by login shell",
                    query: "select count(*) as count, shell from users group by shell;",
                    valueidentifier: "count",
                    labelidentifier: [
                        "shell"
                    ]
                }
            ]
        }
    })
}
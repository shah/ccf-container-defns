local common = import "common.ccf-conf.jsonnet";
local ccflib = import "ccf.libsonnet";
local context = import "context.ccf-facts.json";
local containerSecrets = import "serposcope.secrets.ccf-conf.jsonnet";
local serposcopePort = "7134";
{
        "Dockerfile" : |||
         FROM java:8-jre
         ENV SERPOSCOPE_VERSION %(serposcopeVersion)s 
         COPY serposcope /etc/default/serposcope
         RUN wget https://serposcope.serphacker.com/download/${SERPOSCOPE_VERSION}/serposcope_${SERPOSCOPE_VERSION}_all.deb -O /tmp/serposcope.deb
         RUN dpkg --force-confold -i /tmp/serposcope.deb
         RUN rm /tmp/serposcope.deb
         VOLUME /var/lib/serposcope/
         EXPOSE 7134
         COPY entrypoint.sh /entrypoint.sh
         RUN chmod +x /entrypoint.sh
         ENTRYPOINT ["/entrypoint.sh"]
        ||| % { serposcopeVersion: containerSecrets.serposcopeVersion },

        "serposcope" : |||
         JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
         LOGDIR=/var/log/serposcope
         DATADIR=/var/lib/serposcope
         CONF=/etc/serposcope.conf
         PARAMS="-Dserposcope.conf=$CONF"
        |||,

        "entrypoint.sh" : |||
         #! /bin/bash
         conf_file="/etc/serposcope.conf"
         function replace_param {
           sed -i -r -e "/^# *${1}=/ {s|^# *||;s|=.*$|=|;s|$|$(eval echo \$$2)|}" $conf_file
         }
         if [ -n "$SERPOSCOPE_DB_URL" ]
         then
           replace_param "serposcope.db.url" "SERPOSCOPE_DB_URL"
         else
           echo "SERPOSCOPE_DB_URL is not set, keeping the default value"
         fi
         if [ -n "$SERPOSCOPE_DB_OPTIONS" ]
         then
           replace_param  "serposcope.db.options" "SERPOSCOPE_DB_OPTIONS"
         else
           echo "SERPOSCOPE_DB_OPTIONS not set, keeping the default value"
         fi
         if [ -n "$SERPOSCOPE_DB_DEBUG" ]
         then
         replace_param  "serposcope.db.debug" "SERPOSCOPE_DB_DEBUG"
         else
           echo "SERPOSCOPE_DB_DEBUG not set, keeping the default value"
         fi
         service serposcope start && tail -F /var/log/serposcope/startup.log
        |||,

        "docker-compose.yml" : std.manifestYamlDoc({
                version: '3.4',
                services: {
                        container: {
                                build: {
                                        context: '.',
                                        dockerfile: 'Dockerfile',
                                       },
                                container_name: context.containerName,
                                restart: 'always',
                                image: context.containerName + ':latest',
                                networks: ['network'],
                                volumes: ['storageDb:/var/lib/serposcope','storageLogs:/var/log/serposcope'],
                                ports: [serposcopePort + ':7134'],
                                labels: {
                                        'traefik.enable': 'true',
                                        'traefik.port': '7134',
                                        'traefik.docker.network': common.defaultDockerNetworkName,
                                        'traefik.domain': containerSecrets.FQDN,
                                        'traefik.backend': context.containerName,
                                        'traefik.frontend.entryPoints': 'http,https',
                                        'traefik.frontend.rule': 'Host:'+  containerSecrets.FQDN,
                                        'traefik.frontend.redirect.entryPoint': 'https'
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
                volumes: {
			storageDb: {
				name: context.containerName + "_db"
			},
			storageLogs: {
				name: context.containerName + "_logs"
			},
		},
        }),
}

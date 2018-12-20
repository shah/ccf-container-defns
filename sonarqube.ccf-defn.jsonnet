local common = import "common.ccf-conf.jsonnet";
local ccflib = import "ccf.libsonnet";
local context = import "context.ccf-facts.json";
local sonar = import "sonar.ccf-conf.jsonnet";

{
 "run.sh" : |||
   #!/usr/bin/env bash

   set -e

   if [ "${1:0:1}" != '-' ]; then
     exec "$@"
   fi

   # Parse Docker env vars to customize SonarQube
   #
   # e.g. Setting the env var sonar.jdbc.username=foo
   #
   # will cause SonarQube to be invoked with -Dsonar.jdbc.username=foo

   declare -a sq_opts

   while IFS='=' read -r envvar_key envvar_value
   do
       if [[ "$envvar_key" =~ sonar.* ]]; then
           sq_opts+=("-D${envvar_key}=${envvar_value}")
       fi
   done < <(env)

   exec java -jar lib/sonar-application-$SONAR_VERSION.jar \
     -Dsonar.log.console=true \
     -Dsonar.jdbc.username="$SONARQUBE_JDBC_USERNAME" \
     -Dsonar.jdbc.password="$SONARQUBE_JDBC_PASSWORD" \
     -Dsonar.jdbc.url="$SONARQUBE_JDBC_URL" \
     -Dsonar.web.javaAdditionalOpts="$SONARQUBE_WEB_JVM_OPTS -Djava.security.egd=file:/dev/./urandom" \
     "${sq_opts[@]}" \
   "$@"
  |||,

 "Dockerfile" : |||
   FROM openjdk:8
   ENV SONAR_VERSION=%(sonarqubeVersion)s \
       SONARQUBE_HOME=/opt/sonarqube \
       # Database configuration
       # Defaults to using H2
       # DEPRECATED. Use -v sonar.jdbc.username=... instead
       # Drop these in the next release, also in the run script
       SONARQUBE_JDBC_USERNAME=%(postgresUser)s \
       SONARQUBE_JDBC_PASSWORD=%(posrgresPassword)s \
       SONARQUBE_JDBC_URL=
   RUN groupadd -r sonarqube && useradd -r -g sonarqube sonarqube
   # grab gosu for easy step-down from root
   RUN set -x \
       && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture)" \
       && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.10/gosu-$(dpkg --print-architecture).asc" \
       && export GNUPGHOME="$(mktemp -d)" \
       && (gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
           || gpg --batch --keyserver ipv4.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4) \
       && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
       && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
       && chmod +x /usr/local/bin/gosu \
       && gosu nobody true
   RUN set -x \
       # pub   2048R/D26468DE 2015-05-25
       #       Key fingerprint = F118 2E81 C792 9289 21DB  CAB4 CFCA 4A29 D264 68DE
       # uid                  sonarsource_deployer (Sonarsource Deployer) <infra@sonarsource.com>
       # sub   2048R/06855C1D 2015-05-25
       && (gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys F1182E81C792928921DBCAB4CFCA4A29D26468DE \
               || gpg --batch --keyserver ipv4.pool.sks-keyservers.net --recv-keys F1182E81C792928921DBCAB4CFCA4A29D26468DE) \
       && cd /opt \
       && curl -o sonarqube.zip -fSL https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip \
       && curl -o sonarqube.zip.asc -fSL https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip.asc \
       && gpg --batch --verify sonarqube.zip.asc sonarqube.zip \
       && unzip sonarqube.zip \
       && mv sonarqube-$SONAR_VERSION sonarqube \
       && chown -R sonarqube:sonarqube sonarqube \
       && rm sonarqube.zip*
   RUN cd /opt/sonarqube/extensions/plugins && wget https://github.com/dmeiners88/sonarqube-prometheus-exporter/releases/download/v1.0.0-SNAPSHOT-2018-07-04/sonar-prometheus-exporter-1.0.0-SNAPSHOT.jar
   VOLUME "$SONARQUBE_HOME/data"
   # Http port
   EXPOSE 9000
   WORKDIR $SONARQUBE_HOME
   COPY run.sh $SONARQUBE_HOME/bin/
   RUN chmod a+x ./bin/run.sh
   USER sonarqube
   ENTRYPOINT ["./bin/run.sh"]
  ||| % { posrgresPassword : sonar.posrgresPassword, postgresUser : sonar.postgresUser, sonarqubeVersion : sonar.sonarqubeVersion },

 "docker-compose.yml" : std.manifestYamlDoc({

                version: '3.4',
                services: {
                        db: {
                                image: 'postgres',
                                networks: ['network'],
                                restart: 'always',
                                volumes: ['db:' + '/var/lib/postgresql/data'],
                                environment: {
                                             'POSTGRES_PASSWORD': sonar.posrgresPassword,
                                             'POSTGRES_USER': sonar.postgresUser
                                             },
                            },
                        sonarqube: {
                                build: '.',
                                image: 'sonarqube:latest',
                                networks: ['network'],
                                restart: 'always',
                                volumes: ['sonar:' + '/opt/sonarqube/data'],
                                ports: [ sonar.sonarqubePort + ':9000', '4092:9092'],
                                labels: {
                                        'traefik.enable': 'true',
                                        'traefik.docker.network': common.defaultDockerNetworkName,
                                        'traefik.domain': sonar.sonarUrl,
                                        'traefik.backend': context.containerName,
                                        'traefik.port': '9000',
                                        'traefik.frontend.entryPoints': 'http,https',
                                        'traefik.frontend.rule': 'Host:' + sonar.sonarUrl,
                                },
                                environment: {
                                              'SONARQUBE_JDBC_USERNAME': sonar.postgresUser,
                                              'SONARQUBE_JDBC_PASSWORD': sonar.posrgresPassword,
                                              'SONARQUBE_JDBC_URL': 'jdbc:postgresql://db/' + sonar.sonarqubeDatabaseName,
                                             },
                                depends_on: ['db'],
                                },
                       adminer: {
                                image: 'adminer',
                                networks: ['network'],
                                restart: 'always',
                                ports: [ sonar.adminerPort + ':8080'],
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
                        db: {
                                name: context.containerName + "_db"
                        },
                        sonar: {
                                name: context.containerName + "_sonar"
                        },

                      },
    }),
}


local common = import "common.ccf-conf.jsonnet";
local ccflib = import "ccf.libsonnet";
local context = import "context.ccf-facts.json";
local traefikConf = import "lformsBuilder.traefik.ccf-conf.jsonnet";
local network = import "eth0-interface-localhost.ccf-facts.json";

local webServicePort = 9020;

{
  "Dockerfile" : |||
   FROM ubuntu:18.04
   ENV NODE_VERSION=8.10.0
   ENV NODE_OPTIONS=--max_old_space_size=2000
   RUN apt-get update && \
     apt-get install wget curl ca-certificates rsync git -y
   RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
   ENV NVM_DIR=/root/.nvm
   RUN . "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
   RUN . "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
   RUN . "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
   RUN cp /root/.nvm/versions/node/v${NODE_VERSION}/bin/node /usr/bin/
   RUN cp /root/.nvm/versions/node/v${NODE_VERSION}/bin/npm /usr/bin/
   RUN cd /opt && git clone https://github.com/lhncbc/formbuilder-lhcforms.git
   WORKDIR /opt/formbuilder-lhcforms
   RUN cd /opt/formbuilder-lhcforms && \
        /root/.nvm/versions/node/v${NODE_VERSION}/bin/npm install
   RUN  /root/.nvm/versions/node/v${NODE_VERSION}/bin/npm install -g bower && \
       /bin/bash -c "source /opt/formbuilder-lhcforms/bashrc.formbuilder" && \
       bower install --allow-root 
   RUN  /root/.nvm/versions/node/v${NODE_VERSION}/bin/npm install -g grunt-cli && \
        grunt template
   EXPOSE %(webServicePort)d
   CMD grunt serve
  ||| % { webServicePort: webServicePort },

"docker-compose.yml" : std.manifestYamlDoc({
        version: '3.4',

        services: {
                container: {
                       build: {
                               context: '.',
                               dockerfile: 'Dockerfile',
                              },
                        container_name: context.containerName,
                        image: context.containerName + ':latest',
                        restart: 'always',
                        networks: ['network'],
                        labels: {
                                  'traefik.enable': 'true',
                                  'traefik.docker.network': common.defaultDockerNetworkName,
                                  'traefik.domain': traefikConf.lformsBuilderFQDN,
                                  'traefik.backend': context.containerName,
                                  'traefik.frontend.entryPoints': 'http,https',
                                  'traefik.port': webServicePort,
                                  'traefik.frontend.rule': 'Host:' + traefikConf.lformsBuilderFQDN,
                                },
               },
        },

        networks: {
                network: {
                        external: {
                                name: common.defaultDockerNetworkName
                        },
                },
        },

})
}


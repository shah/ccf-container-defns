local common = import "common.ccf-conf.jsonnet";
local ccflib = import "ccf.libsonnet";
local context = import "context.ccf-facts.json";
local hugoConf = import "hugo.ccf-conf";

local webServicePort = 80;

{
 "generate-site.sh" : |||
   #!/usr/bin/env bash
   
   git-log2json () {
   git log \
       --pretty=format:'{%n  "commit": "%H",%n  "author": "%aN <%aE>",%n  "date": "%ad",%n  "message": "%f"%n},' \
       $@ | \
       perl -pe 'BEGIN{print "["}; END{print "]\n"}' | \
   perl -pe 's/},]/}]/'
   }
   
   WATCH="${HUGO_WATCH:=false}"
   SLEEP="${HUGO_REFRESH_TIME:=-1}"
   echo "HUGO_WATCH:" $WATCH
   echo "HUGO_THEME:" $HUGO_THEME
   echo "HUGO_BASEURL" $HUGO_BASEURL
   echo "ARGS" $@
   
   HUGO=/usr/bin/hugo
   
   echo "Building one time..."
   mkdir -p /src/data/todo
   mkdir -p /src/data/changelog
   leasot -x --reporter json './**/*.js' > /src/data/todo/todo.json
   cd /src/ && git-log2json > /src/data/changelog/changelog.json
   mkdir /output
   $HUGO --source="/src" --theme="$HUGO_THEME" --destination="/output" --baseUrl="$HUGO_BASEURL" "$@" || exit 1
  |||,

 "run.sh" : |||
   #!/bin/sh
   nginx
   tail -f /dev/null
  |||,

 "default.conf" : |||
   server {
       listen %(webServicePort)d;
       server_name  localhost;
       root   /usr/share/nginx/html/output;
       index  index.html index.htm;
   }
  ||| % { webServicePort: webServicePort },

 "Dockerfile" : |||
   FROM ubuntu:18.04 as builder
   ENV HUGO_VERSION=0.42
   RUN apt-get update && \
       apt-get install wget curl ca-certificates rsync -y
   RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash
   ENV NVM_DIR=/root/.nvm
   RUN . "$NVM_DIR/nvm.sh" && nvm install 8.10.0
   RUN . "$NVM_DIR/nvm.sh" &&  nvm use v8.10.0
   RUN . "$NVM_DIR/nvm.sh" && nvm alias default v8.10.0
   RUN cp /root/.nvm/versions/node/v8.10.0/bin/node /usr/bin/
   RUN cp /root/.nvm/versions/node/v8.10.0/bin/npm /usr/bin/
   RUN cd /tmp/ && \
       wget https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
       tar xzf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
       rm -r hugo_${HUGO_VERSION}_Linux-64bit.tar.gz && \
       mv hugo /usr/bin/hugo

   RUN /root/.nvm/versions/node/v8.10.0/bin/npm install  leasot@next -g
   RUN apt-get install git -y
   COPY ./generate-site.sh /generate-site.sh
   COPY ./git-repo /src
   VOLUME /src
   WORKDIR /src
   RUN chmod +x /generate-site.sh
   RUN bash /generate-site.sh
   #Nginx
   FROM nginx:alpine
   RUN rm -rf /usr/share/nginx/html/*
   COPY --from=builder /output /usr/share/nginx/html/output
   COPY default.conf /etc/nginx/conf.d/default.conf
   EXPOSE %(webServicePort)d
   RUN apk  update && apk add vim
   COPY run.sh /root/run.sh
   RUN chmod a+x /root/run.sh
   CMD sh /root/run.sh
  ||| % { webServicePort: webServicePort },

 "docker-compose.yml" : std.manifestYamlDoc({
                version: '3.4',
                services: {
                        container: {
                                build: '.',
                                container_name: context.containerName,
                		image: context.containerName + ':latest',
                                networks: ['network'],
				environment: {
		        	        'HUGO_THEME': hugoConf.theme,
					'HUGO_BASEURL': hugoConf.baseurl,
				},
                                ports: [ hugoConf.port + ':' + webServicePort ],
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

local common = import "common.ccf-conf.jsonnet";
local ccflib = import "ccf.libsonnet";
local context = import "context.ccf-facts.json";
local hugo = import "hugoDirectoauth2.ccf-conf.jsonnet";

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

   RUN /root/.nvm/versions/node/v8.10.0/bin/npm install  leasot@latest -g
   RUN apt-get install git -y
   COPY ./generate-site.sh /generate-site.sh
   RUN cd / && git clone --recursive  https://%(gitHubId)s:%(gitHubAccessToken)s@%(hugoGitRepo)s src
   VOLUME /src
   WORKDIR /src
   RUN chmod +x /generate-site.sh
   RUN bash /generate-site.sh
   #Alpine
   FROM alpine
   COPY --from=builder /output /static
   COPY --from=builder /src/%(authorizedUsersFilePath)s /opt/oauth2-authorized-users.conf
   EXPOSE %(webServicePort)d
   RUN apk add wget
   RUN apk add libc6-compat
   RUN apk add ca-certificates
   RUN cd /opt && wget https://github.com/pusher/oauth2_proxy/releases/download/v3.1.0/oauth2_proxy-v3.1.0.linux-amd64.go1.11.tar.gz
   RUN cd /opt && tar -xvf oauth2_proxy-v3.1.0.linux-amd64.go1.11.tar.gz
   RUN mv /opt/release/oauth2_proxy-linux-amd64 /bin/oauth2_proxy
   CMD /bin/oauth2_proxy -upstream=file:///static/#/ -http-address=0.0.0.0:%(webServicePort)d  -authenticated-emails-file=/opt/oauth2-authorized-users.conf \
      -cookie-secure=%(oauth2CookieSecure)s -cookie-secret=%(oauth2CookieSecret)s -client-id=%(oauth2ClientId)s  -client-secret=%(oauth2ClientSecret)s \
      -provider=%(oauth2Provider)s
  ||| % { webServicePort: webServicePort, hugoGitRepo : hugo.hugoGitRepo, gitHubAccessToken : hugo.gitHubAccessToken, gitHubId : hugo.gitHubId, authorizedUsersFilePath : hugo.authorizedUsersFilePath, oauth2Provider : hugo.oauth2Provider, oauth2ClientSecret : hugo.oauth2ClientSecret, oauth2ClientId : hugo.oauth2ClientId, oauth2CookieSecret : hugo.oauth2CookieSecret, oauth2CookieSecure : hugo.oauth2CookieSecure },

 "docker-compose.yml" : std.manifestYamlDoc({
                version: '3.4',
                services: {
                        container: {
                                build: '.',
                                container_name: context.containerName,
                                image: context.containerName + ':latest',
                                networks: ['network'],
                                restart: 'always',
                                environment: {
                                        'HUGO_THEME': hugo.theme,
                                        'HUGO_BASEURL': hugo.baseUrl,
                                },
                                volumes: ['storage:/opt'],
                                labels: {
                                        'traefik.enable': 'true',
                                        'traefik.docker.network': common.defaultDockerNetworkName,
                                        'traefik.domain': hugo.hugoUrl,
                                        'traefik.backend': context.containerName,
                                        'traefik.port': webServicePort,
                                        'traefik.frontend.entryPoints': 'http,https',
                                        'traefik.frontend.rule': 'Host:' + hugo.hugoUrl,
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


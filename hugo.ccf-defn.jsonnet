local common = import "common.ccf-conf.jsonnet";
local ccflib = import "ccf.libsonnet";
local context = import "context.ccf-facts.json";
local hugo = import "hugo.ccf-conf.jsonnet";

local webServicePort = 80;
local oauth2_http_port = 4180;

{
 "oauth2-proxy.sh" : |||
   cd /opt/
   screen -S oauth2-proxy -X logfile /opt/oauth2-proxy.log &&  screen -S oauth2-proxy -X log
   ./oauth2_proxy   --authenticated-emails-file=/opt/oauth2-authorized-users.conf -upstream=%(upstream)s -cookie-secret=%(cookie_secret)s -client-id=%(client_id)s -client-secret=%(client_secret)s  -provider="%(provider)s" -cookie-secure=%(cookie_secure)s
  |||  % { upstream : hugo.oauth2_upstream, cookie_secret : hugo.oauth2_cookie_secret, client_id : hugo.oauth2_client_id, client_secret : hugo.oauth2_client_secret, provider : hugo.oauth2_provider, cookie_secure : hugo.oauth2_cookie_secure},

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
   /usr/bin/screen -dmS oauth2-proxy /bin/sh /opt/oauth2-proxy.sh
   nginx
   tail -f /dev/null
  |||,

 "default.conf" : |||
   server {
   listen %(webServicePort)d;

   location /oauth2/ {
   proxy_pass       http://localhost:%(oath_http_port)s;
   proxy_set_header Host                    $host;
   proxy_set_header X-Real-IP               $remote_addr;
   proxy_set_header X-Scheme                $scheme;
   proxy_set_header X-Auth-Request-Redirect $request_uri;
   }

   location = /oauth2/auth {
   proxy_pass       http://localhost:%(oath_http_port)s;
   proxy_set_header Host             $host;
   proxy_set_header X-Real-IP        $remote_addr;
   proxy_set_header X-Scheme         $scheme;
   # nginx auth_request includes headers but not body
   proxy_set_header Content-Length   "";
   proxy_pass_request_body           off;
   }
   location / {
   auth_request /oauth2/auth;
   error_page 401 = /oauth2/sign_in;

   # pass information via X-User and X-Email headers to backend,
   # requires running with --set-xauthrequest flag
   auth_request_set $user   $upstream_http_x_auth_request_user;
   auth_request_set $email  $upstream_http_x_auth_request_email;
   proxy_set_header X-User  $user;
   proxy_set_header X-Email $email;

   # if you enabled --cookie-refresh, this is needed for it to work with auth_request
   auth_request_set $auth_cookie $upstream_http_set_cookie;
   add_header Set-Cookie $auth_cookie;
   root   /usr/share/nginx/html/output;
   index  index.html index.htm;
   }
   }
  ||| % { webServicePort : webServicePort, oath_http_port : oauth2_http_port },

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
   RUN cd / && git clone --recursive https://%(github_id)s:%(github_access_token)s@%(github_repo)s src
   VOLUME /src
   WORKDIR /src
   RUN chmod +x /generate-site.sh
   RUN bash /generate-site.sh
   #Nginx
   FROM nginx:alpine
   RUN rm -rf /usr/share/nginx/html/*
   COPY --from=builder /output /usr/share/nginx/html/output
   COPY --from=builder /src/%(authorizedUsersFilePath)s /opt/oauth2-authorized-users.conf
   COPY default.conf /etc/nginx/conf.d/default.conf
   EXPOSE %(webServicePort)d
   RUN apk  update && apk add vim
   RUN apk add wget
   RUN apk add screen
   RUN apk add libc6-compat
   RUN apk add ca-certificates
   RUN cd /opt && wget https://github.com/bitly/oauth2_proxy/releases/download/v2.2/oauth2_proxy-2.2.0.linux-amd64.go1.8.1.tar.gz
   RUN cd /opt && tar -xvf oauth2_proxy-2.2.0.linux-amd64.go1.8.1.tar.gz
   RUN mv /opt/oauth2_proxy-2.2.0.linux-amd64.go1.8.1/oauth2_proxy /opt/oauth2_proxy
   COPY oauth2-proxy.sh /opt/oauth2-proxy.sh
   RUN chmod a+x /opt/oauth2-proxy.sh
   COPY run.sh /root/run.sh
   RUN chmod a+x /root/run.sh
   CMD sh /root/run.sh
  ||| % { webServicePort: webServicePort, github_repo : hugo.github_repo, github_access_token : hugo.github_access_token, github_id : hugo.github_id, authorizedUsersFilePath : hugo.authorizedUsersFilePath },

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
                                        'HUGO_BASEURL': hugo.baseurl,
                                },
                                volumes: ['storage:' + hugo.oauth2_StoragePathInContainer],
                                labels: {
                                        'traefik.enable': 'true',
                                        'traefik.docker.network': common.defaultDockerNetworkName,
                                        'traefik.domain': hugo.hugourl,
                                        'traefik.backend': context.containerName,
                                        'traefik.port': '80',
                                        'traefik.frontend.entryPoints': 'http,https',
                                        'traefik.frontend.rule': 'Host:' + hugo.hugourl,
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


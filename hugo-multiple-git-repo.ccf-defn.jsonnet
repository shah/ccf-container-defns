local common = import "common.ccf-conf.jsonnet";
local ccflib = import "ccf.libsonnet";
local context = import "context.ccf-facts.json";
local hugo = import "hugo.ccf-conf.jsonnet";

local webServicePort = 80;
local oauth2HttpPort = 4180;

{

 "oauth2-proxy.sh" : |||
   cd /opt/
   screen -S oauth2-proxy -X logfile /opt/oauth2-proxy.log &&  screen -S oauth2-proxy -X log
   ./oauth2_proxy   --authenticated-emails-file=/opt/oauth2-authorized-users.conf -upstream=%(upstream)s -cookie-secret=%(cookieSecret)s -client-id=%(clientId)s -client-secret=%(clientSecret)s  -provider="%(provider)s" -cookie-secure=%(cookieSecure)s
  |||  % { upstream : hugo.oauth2Upstream, cookieSecret : hugo.oauth2CookieSecret, clientId : hugo.oauth2ClientId, clientSecret : hugo.oauth2ClientSecret, provider : hugo.oauth2Provider, cookieSecure : hugo.oauth2CookieSecure},

 "generate-site.sh" : |||
   #!/bin/bash

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
   mkdir -p /src/layouts/_default
   mkdir -p mkdir -p /src/layouts/partials

  ||| + std.lines([ 'mkdir -p /src/content/repositories/%(menuItemName)s/changelog && cd /src/content/repositories/%(menuItemName)s/changelog &&  cat <<EOF >> _index.md
---
title: Changelog
type: page
layout: %(menuItemName)s-changelog
---
EOF' % item for item in hugo.gitRepo]) +
std.lines([ 'cd /src/content/repositories/%(menuItemName)s &&  cat <<EOF >> _index.md
---
title: %(menuItemName)s
type: page
layout: %(menuItemName)s-changelog
---
EOF' % item for item in hugo.gitRepo]) +
std.lines([ 'mkdir -p /src/content/repositories/%(menuItemName)s/to-do && cd /src/content/repositories/%(menuItemName)s/to-do && cat <<EOF >>_index.md
---
title: To-do
type: page
layout: %(menuItemName)s-todo
---
EOF' % item for item in hugo.gitRepo]) +
std.lines([ 'cd /src/layouts/_default && cat <<EOF >> /src/layouts/_default/%(menuItemName)s-changelog.html
{{ partial "header.html" . }}
<span id="sidebar-toggle-span">
<a href="#" id="sidebar-toggle" data-sidebar-toggle=""><i class="fa fa-bars"></i> navigation</a>
</span>
{{ partial "%(menuItemName)s-changelog.html" . }}
{{ partial "footer.html" . }}
EOF' % item for item in hugo.gitRepo]) +
std.lines([ 'cat <<EOF >> /src/layouts/_default/%(menuItemName)s-todo.html
{{ partial "header.html" . }}
<span id="sidebar-toggle-span">
<a href="#" id="sidebar-toggle" data-sidebar-toggle=""><i class="fa fa-bars"></i> navigation</a>
</span>
{{ partial "%(menuItemName)s-to-do.html" . }}
{{ partial "footer.html" . }}
EOF' % item for item in hugo.gitRepo]) +
std.lines([ 'cd /src/layouts/partials && cat <<EOF >>/src/layouts/partials/%(menuItemName)s-to-do.html
<table>
    <thead>
        <tr>
        <th>File Name</th>
        <th>Tag</th>
        <th>Line</th>
        <th>Ref</th>
        <th>Text</th>
        </tr>
    </thead>
    <tbody>
  {{$jsonURL := "data/%(menuItemName)s/todo/todo.json" }}
    {{$json :=getJSON $jsonURL }}

      {{range $json}}
            <tr>

                    <td class = "tdstyle">{{ .file }}</td>
                    <td class = "tdstyle">{{ .tag }}</td>
                    <td class = "tdstyle">{{ .line }}</td>
                    <td class = "tdstyle">{{ .ref }}</td>
                    <td class = "tdstyle">{{ .text }}</td>

            </tr>
     {{ end }}
    </tbody>
</table>
EOF' % item for item in hugo.gitRepo]) +
std.lines([ "sed -i 's#:= #$jsonURL := #g' /src/layouts/partials/%(menuItemName)s-to-do.html && sed -i 's#:=getJSON#$json := getJSON $jsonURL #g' /src/layouts/partials/%(menuItemName)s-to-do.html && sed -i 's#range# range $json#g' /src/layouts/partials/%(menuItemName)s-to-do.html" % item for item in hugo.gitRepo]) +
std.lines([ 'cat <<EOF >> /src/layouts/partials/%(menuItemName)s-changelog.html
<table>
    <thead>
        <tr>
        <th style="white-space: nowrap;">Commit Message</th>
         <th>Author</th>
         <th>Commit ID</th>
         <th>Date</th>
         </tr>
    </thead>
    <tbody>
  {{$jsonURL := "data/%(menuItemName)s/changelog/changelog.json" }}
    {{$json :=getJSON $jsonURL }}

      {{range $json}}
            <tr>

                     <td class = "tdstyle">{{ .message }}</td>
                     <td class = "tdstyle">{{ .author }}</td>
                     <td class = "tdstyle">{{ .commit }}</td>
                     <td class = "tdstyle" style="white-space: nowrap;">{{ .date }}</td>





            </tr>
     {{ end }}
    </tbody>
</table>
EOF' % item for item in hugo.gitRepo]) +
std.lines([ "sed -i 's#:= #$jsonURL := #g' /src/layouts/partials/%(menuItemName)s-changelog.html && sed -i 's#:=getJSON#$json := getJSON $jsonURL #g' /src/layouts/partials/%(menuItemName)s-changelog.html && sed -i 's#range# range $json#g' /src/layouts/partials/%(menuItemName)s-changelog.html" % item for item in hugo.gitRepo]) +
  |||
   ls
  ||| +  std.lines([ "mkdir -p /src/data/%(menuItemName)s/todo/ && cd /%(menuItemName)s && leasot -x --reporter json './**/*.js' > /src/data/%(menuItemName)s/todo/todo.json && mkdir -p /src/data/%(menuItemName)s/changelog/ && git-log2json > /src/data/%(menuItemName)s/changelog/changelog.json" % item for item in hugo.gitRepo]) +
  |||
   mkdir /output
   $HUGO --source="/src" --theme="$HUGO_THEME" --destination="/output" --baseUrl="$HUGO_BASEURL" "$@" || exit 1
  |||,

 "run.sh" : |||
   #!/bin/sh
   sysctl fs.inotify.max_user_watches=524288
   /usr/bin/screen -dmS oauth2-proxy /bin/sh /opt/oauth2-proxy.sh
   nginx
   tail -f /dev/null
  |||,

 "default.conf" : |||
   server {
   listen %(webServicePort)d;

   location /oauth2/ {
   proxy_pass       http://localhost:%(oauth2HttpPort)s;
   proxy_set_header Host                    $host;
   proxy_set_header X-Real-IP               $remote_addr;
   proxy_set_header X-Scheme                $scheme;
   proxy_set_header X-Auth-Request-Redirect $request_uri;
   }

   location = /oauth2/auth {
   proxy_pass       http://localhost:%(oauth2HttpPort)s;
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
  ||| % { webServicePort : webServicePort, oauth2HttpPort : oauth2HttpPort },

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
   RUN cd / && git clone https://%(gitHubId)s:%(gitHubAccessToken)s@%(hugoGitRepo)s src
  ||| % { hugoGitRepo: hugo.hugoGitRepo, gitHubId: hugo.gitHubId, gitHubAccessToken: hugo.gitHubAccessToken } + std.lines([ 'RUN cd / && git clone https://%(gitHubId)s:%(gitHubAccessToken)s@%(gitHubRepo)s %(menuItemName)s' % item for item in hugo.gitRepo]) +
  |||
   COPY ./generate-site.sh /generate-site.sh
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
  ||| % { webServicePort: webServicePort, authorizedUsersFilePath : hugo.authorizedUsersFilePath },

 "docker-compose.yml" : std.manifestYamlDoc({
                version: '3.4',
                services: {
                        container: {
                                build: '.',
                                container_name: context.containerName,
                                image: context.containerName + ':latest',
                                networks: ['network'],
                                environment: {
                                        'HUGO_THEME': hugo.theme,
                                        'HUGO_BASEURL': hugo.baseUrl,
                                },
                                volumes: ['storage:' + hugo.oauth2StoragePathInContainer],
                                labels: {
                                        'traefik.enable': 'true',
                                        'traefik.docker.network': common.defaultDockerNetworkName,
                                        'traefik.domain': hugo.hugoUrl,
                                        'traefik.backend': context.containerName,
                                        'traefik.port': '80',
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


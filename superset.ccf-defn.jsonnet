local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";
local containerSecrets = import "superset.secrets.ccf-conf.jsonnet";
{
 "Dockerfile": |||
  FROM python:3.6
  ENV GUNICORN_BIND=0.0.0.0:8088 \
  GUNICORN_LIMIT_REQUEST_FIELD_SIZE=0 \
  GUNICORN_LIMIT_REQUEST_LINE=0 \
  GUNICORN_TIMEOUT=60 \
  GUNICORN_WORKERS=2 \
  LANG=C.UTF-8 \
  LC_ALL=C.UTF-8 \
  PYTHONPATH=/etc/superset:/home/superset:$PYTHONPATH \
  SUPERSET_REPO=apache/incubator-superset \
  SUPERSET_VERSION=%(supersetVersion)s \
  SUPERSET_HOME=/var/lib/superset
  ENV GUNICORN_CMD_ARGS="--workers ${GUNICORN_WORKERS} --timeout ${GUNICORN_TIMEOUT} --bind ${GUNICORN_BIND} --limit-request-line ${GUNICORN_LIMIT_REQUEST_LINE} --limit-request-field_size   ${GUNICORN_LIMIT_REQUEST_FIELD_SIZE}"
  RUN useradd -U -m superset && \
  mkdir /etc/superset  && \
  mkdir ${SUPERSET_HOME} && \
  chown -R superset:superset /etc/superset && \
  chown -R superset:superset ${SUPERSET_HOME} && \
  apt-get update && \
  apt-get install -y \
  build-essential \
  curl \
  default-libmysqlclient-dev \
  freetds-dev \
  freetds-bin \
  libffi-dev \
  libldap2-dev \
  libpq-dev \
  libsasl2-dev \
  libssl-dev \
  postgresql-client && \
  apt-get clean && \
  rm -r /var/lib/apt/lists/* && \
  pip install --no-cache-dir cryptography==2.4.2 && \
  curl https://raw.githubusercontent.com/${SUPERSET_REPO}/${SUPERSET_VERSION}/requirements.txt -o requirements-tmp.txt && \
  grep -ivE "cryptography" requirements-tmp.txt > requirements.txt && \
  pip install --no-cache-dir -r requirements.txt && \
  pip install --no-cache-dir \
  Werkzeug==0.14 \
  flask-cors==3.0.3 \
  flask-mail==0.9.1 \
  flask-oauth==0.12 \
  flask_oauthlib==0.9.3 \
  gevent==1.2.2 \
  impyla==0.14.0 \
  infi.clickhouse-orm==1.0.2 \
  mysqlclient==1.3.12 \
  psycopg2 \
  pyathena==1.2.5 \
  pyhive==0.5.1 \
  pyldap==2.4.28 \
  pymssql==2.1.4 \
  redis==2.10.5 \
  sqlalchemy-clickhouse==0.1.5.post0 \
  sqlalchemy-redshift==0.7.1 \
  superset==${SUPERSET_VERSION} && \
  rm requirements.txt requirements-tmp.txt
  COPY superset-init /usr/local/bin/
  RUN chmod +x /usr/local/bin/superset-init
  VOLUME /home/superset \
  /etc/superset \
  /var/lib/superset
  WORKDIR /home/superset
  EXPOSE 8088
  HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
  CMD ["/usr/local/bin/superset-init"]
  USER superset
 ||| % { supersetVersion: containerSecrets.supersetVersion },
   
 "superset-init" : |||
  #!/bin/bash
  # Waiting for postgres database
  until PGPASSWORD=%(postgresPassword)s psql -h "postgres_superset" -U "%(postgresUser)s" -c '\q' >/dev/null 2>&1; do
  sleep 2
  done
  USER_COUNT=$(fabmanager list-users --app superset | awk '/email/ {print}' | wc -l)
  if [ "$?" ==  0 ] && [ $USER_COUNT == 0 ]; then
   echo "Initializing Database"
   # Create an admin user
   fabmanager create-admin --app superset --username admin --firstname admin --lastname admin --email admin@fab.org --password %(uiPassword)s
   # Initialize the database
   superset db upgrade
   # Create default roles and permissions
   export SUPERSET_UPDATE_PERMS=1
   superset init
   export SUPERSET_UPDATE_PERMS=0 
   gunicorn superset:app
  else
   export SUPERSET_UPDATE_PERMS=0
   gunicorn superset:app
  fi
 ||| % { uiPassword : containerSecrets.adminPassword, postgresUser : containerSecrets.databaseUser, postgresPassword : containerSecrets.databasePassword }, 
   
"superset_config.py" : |||
 import os
 MAPBOX_API_KEY = os.getenv('MAPBOX_API_KEY', '')
 CACHE_CONFIG = {
 'CACHE_TYPE': 'redis',
 'CACHE_DEFAULT_TIMEOUT': 300,
 'CACHE_KEY_PREFIX': 'superset_',
 'CACHE_REDIS_HOST': 'redis_superset',
 'CACHE_REDIS_PORT': 6379,
 'CACHE_REDIS_DB': 1,
 'CACHE_REDIS_URL': 'redis://redis_superset:6379/1'}
 SQLALCHEMY_DATABASE_URI = \
 'postgresql+psycopg2://%(postgresUser)s:%(postgresPassword)s@postgres_superset:5432/%(postgresDB)s'
 SQLALCHEMY_TRACK_MODIFICATIONS = True
 SECRET_KEY = 'ItIsSECrET786'
||| % { postgresUser : containerSecrets.databaseUser, postgresPassword : containerSecrets.databasePassword, postgresDB : containerSecrets.databaseName },
   
"docker-compose.yml" : std.manifestYamlDoc({
              version: '3.4',
              services: {
		redis_superset: {
                       	container_name: 'redis_superset',
                       	image: 'redis',
                       	restart: 'always',
                       	networks: ['network'],
                       	volumes: ['storage1:/data'],
                      	},	        
                postgres_superset: {
                      	container_name: 'postgres_superset',
                      	image: 'postgres',
              		restart: 'always',
                      	networks: ['network'],
                       	volumes: ['storage2:/var/lib/postgresql/data'],
                       	environment: [
                     		'POSTGRES_USER=' + containerSecrets.databaseUser,
                      		'POSTGRES_PASSWORD=' + containerSecrets.databasePassword,
                       		'POSTGRES_DB=' + containerSecrets.databaseName
                       		]
                       	},
                superset: {
                        container_name: 'superset' ,
                        restart: 'always',
                        build: '.',
                        ports: ['8088:8088'],
                        networks: ['network'],
                        volumes: [context.containerDefnHome + '/superset_config.py:/etc/superset/superset_config.py'],
                        depends_on: ['redis_superset','postgres_superset'],
                        labels: {
				'traefik.enable': 'true',
                                'traefik.docker.network': common.defaultDockerNetworkName,
                                'traefik.domain': containerSecrets.supersetUrl,
                                'traefik.backend': 'superset',
                                'traefik.port': '8088',
                                'traefik.frontend.entryPoints': 'http,https',
                                'traefik.frontend.rule': 'Host:' + containerSecrets.supersetUrl
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
                      storage1: {
	                      name: 'redis_superset'
                      },
                      storage2: {
                              name: 'postgres_superset'
                      },
            },
}),
}

local common = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";
local fider = import "fider-ccf-conf.jsonet";
local containerSecrets = import "postgres.secrets.jsonnet";
{
        "docker-compose.yml" : std.manifestYamlDoc({
                version: '3.4',

                services: {
                        db: {
                                container_name: 'db',
                                image: 'postgres:9.6',
                                restart: 'always',
                                ports: ['5432:5432'],
                                networks: ['network'],
                                volumes: ['storage:/var/lib/postgresql/data'],
                                environment: [
                                        'POSTGRES_USER=' + containerSecrets.POSTGRES_USER,
                                        'POSTGRES_PASSWORD=' + containerSecrets.POSTGRES_PASSWORD,
                                        'POSTGRES_DB=' + containerSecrets.POSTGRES_DB
                                ]
                        },
                    app: {
                       container_name: 'fider' ,
                       restart: 'always',
                       image: 'getfider/fider:stable',
                       ports: ['9000:3000'],
                       networks: ['network'],
                       environment: [
                               'GO_ENV=production',
                               'DATABASE_URL=postgres://'+containerSecrets.POSTGRES_USER+':'+containerSecrets.POSTGRES_PASSWORD+'@db:5432/'+containerSecrets.POSTGRES_DB+'?sslmode=disable',
                                   'JWT_SECRET='+fider.JWT_SECRET,
                                   'EMAIL_NOREPLY='+fider.EMAIL_NOREPLY,
                                   'EMAIL_SMTP_HOST='+fider.EMAIL_SMTP_HOST,
                                   'EMAIL_SMTP_PORT='+fider.EMAIL_SMTP_PORT,
                                   'EMAIL_SMTP_USERNAME='+fider.EMAIL_SMTP_USERNAME,
                                   'EMAIL_SMTP_PASSWORD='+fider.EMAIL_SMTP_PASSWORD,
                                        ],
                           depends_on: ['db']

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
        },
)
}

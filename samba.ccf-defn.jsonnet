local applianceConf = import "common.ccf-conf.jsonnet";
local context = import "context.ccf-facts.json";
local containerSecrets = import "samba.secrets.ccf-conf.jsonnet";
local sambaConf = import "samba.ccf-conf.jsonnet";

local command(cmd, params, repl) = [cmd, params % repl];

{
	"docker-compose.yml" : std.manifestYamlDoc({
		version: '3',

		services: {
			container: {
				container_name: context.containerName,
				image: 'dperson/samba',
				restart: 'always',
				ports: ['139:139', '445:445'],
				networks: ['network'],
				command: 
					std.flattenArrays(
						[command("-u", "%(userName)s;%(password)s;%(userId)d;%(groupName)s", x) for x in containerSecrets.sambaUsers] +
						[command("-s", "%(shareName)s;%(sharePathInContainer)s;%(browseable)s;%(readOnly)s;%(guest)s;%(users)s;%(admins)s;%(usersThatCanWriteToROShare)s;%(comment)s", x) for x in sambaConf.sambaShares]
					),
				volumes:
					["%(sharePathInHost)s:%(sharePathInContainer)s" % x for x in sambaConf.sambaShares],
				environment: [
					'USERID=' + sambaConf.sambaSetup.userId,
					'GROUPID=' + sambaConf.sambaSetup.groupId,
					'TZ=' + sambaConf.sambaSetup.timeZone,
					'NMBD=' + sambaConf.sambaSetup.serveNetBIOS,
					'RECYCLE=' + sambaConf.sambaSetup.recycle,
				],
			}
		},

		networks: {
			network: {
				external: {
					name: applianceConf.defaultDockerNetworkName
				},
			},
		},
	}),

	"after_start.make-plugin.sh" : applianceConf.waitForContainerHealthStatus(context, 'healthy')
}

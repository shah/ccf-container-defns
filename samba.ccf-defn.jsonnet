local common = import "common.ccf-conf.jsonnet";
local ccflib = import "ccf.libsonnet";
local context = import "context.ccf-facts.json";
local containerSecrets = import "samba.secrets.ccf-conf.jsonnet";
local containerConf = import "samba.ccf-conf.jsonnet";

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
						[command("-s", "%(shareName)s;%(sharePathInContainer)s;%(browseable)s;%(readOnly)s;%(guest)s;%(users)s;%(admins)s;%(usersThatCanWriteToROShare)s;%(comment)s", x) for x in containerConf.sambaShares]
					),
				volumes:
					["%(sharePathInHost)s:%(sharePathInContainer)s" % x for x in containerConf.sambaShares],
				environment: [
					'USERID=' + containerConf.sambaSetup.userId,
					'GROUPID=' + containerConf.sambaSetup.groupId,
					'TZ=' + containerConf.sambaSetup.timeZone,
					'NMBD=' + containerConf.sambaSetup.serveNetBIOS,
					'RECYCLE=' + containerConf.sambaSetup.recycle,
				],
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

	"container.make.inc" : ccflib.makeTargets.firewall(context, [139, 445]),

	"after_start.make-plugin.sh" :
		ccflib.bashSnippets.preamble(context) + 
		ccflib.bashSnippets.waitForContainerHealthStatus(context, 'healthy') +
		ccflib.bashSnippets.openHostFirewallPortNumber(context, 139) +
		ccflib.bashSnippets.openHostFirewallPortNumber(context, 445),
}

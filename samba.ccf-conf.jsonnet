local context = import "context.ccf-facts.json";

{	
	sambaSetup : {
		userId: context.currentUser.id,
		groupId: context.currentUser.groupId,
		timeZone: "EST5EDT",
		serveNetBIOS: true,
		recycle: false
	},	
	
	sambaShares : [
		{
			shareName: "%(name)s_Home" % context.currentUser,
			sharePathInContainer: "/%(name)s_Home" % context.currentUser,
			sharePathInHost: context.currentUser.home,
			browseable: "yes",
			readOnly: "no",
			guest: "no",
			users: "admin",
			admins: "admin",
			usersThatCanWriteToROShare: "admin",
			comment: "%(name)s Home" % context.currentUser,
		},
	],
}

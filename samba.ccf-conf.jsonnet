local containerFacts = import "container.facts.json";

{	
	sambaSetup : {
		userId: containerFacts.currentUser.id,
		groupId: containerFacts.currentUser.groupId,
		timeZone: "EST5EDT",
		serveNetBIOS: true,
		recycle: false
	},	
	
	sambaShares : [
		{
			shareName: "%(name)s_Home" % containerFacts.currentUser,
			sharePathInContainer: "/%(name)s_Home" % containerFacts.currentUser,
			sharePathInHost: containerFacts.currentUser.home,
			browseable: "yes",
			readOnly: "no",
			guest: "no",
			users: "admin",
			admins: "admin",
			usersThatCanWriteToROShare: "admin",
			comment: "%(name)s Home" % containerFacts.currentUser,
		},
	],
}

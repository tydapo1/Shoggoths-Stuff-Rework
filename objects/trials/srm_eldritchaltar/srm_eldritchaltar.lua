require "/scripts/util.lua"

function init()
	object.setInteractive(config.getParameter("interactive", true))
	location = config.getParameter("lastLocation", "srm_trials_poison")
	if location == "srm_trials_poison" then
		location = "srm_trials_fire"
	elseif location == "srm_trials_fire" then
		location = "srm_trials_ice"
	elseif location == "srm_trials_ice" then
		location = "srm_trials_electric"
	elseif location == "srm_trials_electric" then
		location = "srm_trials_poison"
	end
	object.setConfigParameter("lastLocation", location)
end

function onInteraction(args)
	return { "OpenTeleportDialog", {
 		canBookmark = false,
 		includePlayerBookmarks = false,
 		destinations = { {
 			name = "A Tainted Place...",
 			planetName = "Cursed Pocket Dimension",
 			icon = "default",
 			warpAction = string.format("InstanceWorld:%s:%s", location, sb.makeUuid())
 			} }
 	} }
end
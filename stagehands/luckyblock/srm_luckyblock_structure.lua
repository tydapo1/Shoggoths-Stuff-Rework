function init()
	stuff = config.getParameter("parameters")
	readyToBuild = false
end

function update()
	--sb.logInfo(sb.printJson(stuff))
	local position = {}
	position[1] = stuff.offset[1]
	position[2] = stuff.offset[2]
	if stuff.spawnOnPlayer == "false" then
		position[1] = position[1] + entity.position()[1]
		position[2] = position[2] + entity.position()[2]
	else
		local playerArray = world.playerQuery(entity.position(), 100, {__order__ = "nearest"})
		local player = playerArray[1]
		position[1] = position[1] + world.entityPosition(player)[1]
		position[2] = position[2] + world.entityPosition(player)[2]
	end
	world.placeDungeon(stuff.name, position, 1)
	world.setTileProtection(1, false)
	stagehand.die()
end
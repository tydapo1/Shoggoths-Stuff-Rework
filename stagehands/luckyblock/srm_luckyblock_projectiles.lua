function init()
	stuff = config.getParameter("parameters")
end

function update()
	--sb.logInfo(sb.printJson(stuff))
	for k,v in pairs(stuff) do
		local position = {}
		position[1] = stuff[k].offset[1]
		position[2] = stuff[k].offset[2]
		if stuff[k].spawnOnPlayer == "false" then
			position[1] = position[1] + entity.position()[1]
			position[2] = position[2] + entity.position()[2]
		else
			local playerArray = world.playerQuery(entity.position(), 100, {__order__ = "nearest"})
			local player = playerArray[1]
			position[1] = position[1] + world.entityPosition(player)[1]
			position[2] = position[2] + world.entityPosition(player)[2]
		end
		world.spawnProjectile(stuff[k].name, position, entity.id(), stuff[k].direction, false, stuff[k].parameters)
	end
	stagehand.die()
end
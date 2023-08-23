function init()
	stuff = config.getParameter("parameters")
end

function update()
	--sb.logInfo(sb.printJson(stuff))
	for k,v in pairs(stuff) do
		if stuff[k].type == "item" then
			world.spawnItem(stuff[k].name, entity.position(), stuff[k].count, stuff[k].parameters, {((math.random()-0.5)*15),(30-(math.random()*10))})
		else
			world.spawnTreasure(entity.position(), stuff[k].name, world.threatLevel())
		end
	end
	stagehand.die()
end
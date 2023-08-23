require "/scripts/util.lua"

function init()
	stuff = config.getParameter("parameters")
	local assets = root.assetJson("/config/racial.config")
	races = {}
	for k,v in pairs(assets) do
		if ((k ~= "default") and (k ~= "monster")) then
			races[#races+1] = k
		end
	end
end

function update()
	--sb.logInfo(sb.printJson(stuff))
	for k,v in pairs(stuff) do
		local position = entity.position()
		position[2] = position[2] + 2
		if stuff[k].type == "npc" then
			local race = stuff[k].species
			if race == "random" then
				race = races[math.random(1,#races)]
			end
			world.spawnNpc(position, race, stuff[k].name, world.threatLevel(), sb.makeRandomSource():randu32(), stuff[k].parameters)
		else
			world.spawnMonster(stuff[k].name, position, stuff[k].parameters)
		end
	end
	stagehand.die()
end
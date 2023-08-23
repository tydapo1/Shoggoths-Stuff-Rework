function init()
	script.setUpdateDelta(1)
end

function update(dt)
	local position = mcontroller.position()
	local possibleMonsters = world.entityQuery(position, 25, {__order__ = "nearest"})
	local reachableMonsters = {}
	
	if possibleMonsters then
		for i = 1,#possibleMonsters,1 do
			if (world.lineCollision(position, world.entityPosition(possibleMonsters[i]),{"Null","Block","Dynamic"},1) == nil and entity.isValidTarget(possibleMonsters[i])) then
				reachableMonsters[#reachableMonsters+1] = possibleMonsters[i]
			end
		end
	end
	
	local aimedMonster = reachableMonsters[1]
	
	if aimedMonster then
		local positionMonster = world.entityPosition(aimedMonster)
		positionMonster[2] = positionMonster[2] - 0.5
		local direction = world.distance(positionMonster, position)
		if mcontroller.crouching() then
			if direction[1] < 0 then
				position[1] = position[1] - 0.625
				position[2] = position[2] - 0.375
			else
				position[1] = position[1] + 0.625
				position[2] = position[2] - 0.375
			end
		else
			if direction[1] < 0 then
				position[1] = position[1] - 0.625
				position[2] = position[2] + 0.625
			else
				position[1] = position[1] + 0.625
				position[2] = position[2] + 0.625
			end
		end
		world.spawnProjectile("srm_lasereyes", position, entity.id(), direction, true, {power = (status.stat("powerMultiplier"))})
	end
end
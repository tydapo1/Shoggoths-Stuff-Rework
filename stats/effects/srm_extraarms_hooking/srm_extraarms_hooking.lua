function init()
	--playerEntityId = effect.sourceEntity()
	--playerPosition = world.entityPosition(playerEntityId)
	--monsterEntityId = entity.id()
	--monsterPosition = world.entityPosition(monsterEntityId)
	projectId = nil
	timer = 0
	
	message.setHandler("extraarms_trackHook", function(_, isItMine, projectileId, vector)
		projectId = projectileId
		mcontroller.setVelocity(vector)
	end)
	
	script.setUpdateDelta(1)
end

function update(dt)
	if (projectId ~= nil) then
		if world.entityExists(projectId) then
			timer = 0
		end
	end
	
	if timer < 0.17 then
		timer = timer + dt
	else
		effect.expire()
	end
end

function uninit()

end

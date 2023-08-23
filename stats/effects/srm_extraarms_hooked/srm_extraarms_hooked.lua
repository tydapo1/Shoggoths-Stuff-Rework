function init()
	--playerEntityId = effect.sourceEntity()
	--playerPosition = world.entityPosition(playerEntityId)
	--monsterEntityId = entity.id()
	--monsterPosition = world.entityPosition(monsterEntityId)
	projectId = nil
	timer = 0
	
	message.setHandler("extraarms_trackProjectile", function(_, isItMine, projectileId)
		projectId = projectileId
	end)
	
	script.setUpdateDelta(1)
end

function update(dt)
	mcontroller.setVelocity({0, 0})
	mcontroller.controlModifiers({
		facingSuppressed = true,
		movementSuppressed = true
	})
	
	if status.isResource("stunned") then
		status.setResource("stunned", math.max(status.resource("stunned"), effect.duration()))
	end
	
	if (projectId ~= nil) then
		if world.entityExists(projectId) then
			mcontroller.setPosition(world.entityPosition(projectId))
			timer = 0
		else
			if timer == 0.25 then
				effect.expire()
			end
		end
	else
		if timer == 0.25 then
			effect.expire()
		end
	end
	
	if timer < 0.25 then
		timer = timer + dt
	end
end

function uninit()
	if status.isResource("stunned") then
		status.setResource("stunned", 0)
	end
end

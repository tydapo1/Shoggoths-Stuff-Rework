require "/scripts/vec2.lua"

function init()
	hasHit = false
	hitEntity = false
	hitEntityId = nil
	hitObject = false
	hitItem = false
	pickupDistance = 3
	maxDistance = 55
	returning = false
	returnVector = {config.getParameter("speed", 60),0}
	preventLoop = false
	message.setHandler("extraarms_killHook", function(_, isItMine)
		projectile.die()
	end)
	message.setHandler("extraarms_returnHook", function(_, isItMine)
		returning = true
	end)
end

function update(dt)
	if (not hasHit) then
		if (world.itemDropQuery(entity.position(), 3)) then
			local itemsFound = world.itemDropQuery(entity.position(), 3)
			--sb.logInfo(sb.print(itemsFound))
			if ((itemsFound ~= nil) and (#itemsFound ~= 0)) then
				hasHit = true
				hitItem = true
			end
		end
	end
	if (not hasHit) then
		local projectileLengthVector = vec2.norm(mcontroller.velocity())
		projectileLengthVector = vec2.mul(projectileLengthVector, 1.2)
		local backVector = vec2.rotate(vec2.mul(projectileLengthVector, 0.5), (math.pi))
		local upVector = vec2.rotate(projectileLengthVector, (math.pi * -0.2))
		local upMidVector = vec2.rotate(projectileLengthVector, (math.pi * -0.1))
		local middleVector = projectileLengthVector
		local downMidVector = vec2.rotate(projectileLengthVector, (math.pi * 0.1))
		local downVector = vec2.rotate(projectileLengthVector, (math.pi * 0.2))
		local poly = {backVector, upVector, upMidVector, middleVector, downMidVector, downVector}
		local collidedWithPoly = world.polyCollision(poly, mcontroller.position())
		if (collidedWithPoly) then
			hasHit = true
			hitObject = true
			mcontroller.setVelocity({0,0})
		end
	end
	--this takes care of the cases when the projectile hit something
	if (hasHit) then
		if (hitItem) then
			if not preventLoop then world.sendEntityMessage(projectile.sourceEntity(), "extraarms_playSound", "/sfx/melee/dagger_hit_robotic.ogg", 0, 1) preventLoop = true end
			returning = true
		elseif (hitEntity) then
			if not preventLoop then world.sendEntityMessage(projectile.sourceEntity(), "extraarms_playSound", "/sfx/melee/lash_hit_organic.ogg", 0, 1) preventLoop = true end
			returning = true
			world.sendEntityMessage(hitEntityId, "extraarms_trackProjectile", entity.id())
		elseif (hitObject) then
			if not preventLoop then world.sendEntityMessage(projectile.sourceEntity(), "extraarms_followHook") world.sendEntityMessage(projectile.sourceEntity(), "extraarms_playSound", "/sfx/melee/sword_hit_stone1.ogg", 0, 1) preventLoop = true end
			mcontroller.setVelocity({0,0})
			local angle = vec2.angle(vec2.sub(entity.position(), world.entityPosition(projectile.sourceEntity())))
			world.sendEntityMessage(projectile.sourceEntity(), "extraarms_trackHook", entity.id(), (vec2.rotate(returnVector, angle)))
		else
			hasHit = false
			--sb.logInfo("Nothing")
		end
	end
	if (hasHit or returning) then
		if (world.magnitude(entity.position(), world.entityPosition(projectile.sourceEntity())) < pickupDistance) then
			projectile.die()
		end
	end
	if (world.magnitude(entity.position(), world.entityPosition(projectile.sourceEntity())) > maxDistance) then
		returning = true
	end
	if (returning) then
		local angle = vec2.angle(vec2.sub(world.entityPosition(projectile.sourceEntity()), entity.position()))
		mcontroller.setVelocity(vec2.rotate(returnVector, angle))
	end
end

function hit(entityId)
	if (not (entityId == projectile.sourceEntity())) then
		if (not hasHit) then
			hasHit = true
			hitEntity = true
			hitEntityId = entityId
		end
	end
end
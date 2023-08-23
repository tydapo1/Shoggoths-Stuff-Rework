function right_fist_init()
	right_fist_preventSpam = false
	right_fist_projectileId = nil
	right_fist_projectileParameters = {
		power = 5 * status.stat("powerMultiplier"),
		knockback = 35,
		returnOnHit = true,
		ignoreTerrain = false,
		pickupDistance = 1.5,
		snapDistance = 5.0
	}
end

function right_fist_update(args, dt)
	if ((args.moves["altFire"]) and (not right_fist_preventSpam)) then
		animator.setGlobalTag("rightFrame", "active.1")
		animator.playSound("rightfistswing", 0)
		local pos = vec2.add(animator.partPoint("rightFist", "limbTip"),entity.position())
		local direction = vec2.rotate(extraarmstech_defaultVec,extraarmstech_rightAngle)
		right_fist_projectileId = world.spawnProjectile("srm_extraarms_rightfist", pos, entity.id(), direction, false, right_fist_projectileParameters)
		right_fist_preventSpam = true
	end
	if (not right_fist_projectileId) then
		right_fist_destroyProjectile()
	elseif (world.entityExists(right_fist_projectileId) == false) then
		right_fist_destroyProjectile()
	end
end

function right_fist_uninit()
	animator.setGlobalTag("rightFrame", "idle")
	right_fist_preventSpam = false
end

function right_fist_destroyProjectile()
	if (right_fist_preventSpam) then
		right_fist_projectileId = nil
		animator.playSound("rightfistreceive", 0)
		animator.setGlobalTag("rightFrame", "idle")
		right_fist_preventSpam = false
	end
end
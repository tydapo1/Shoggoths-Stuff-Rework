function left_fist_init()
	left_fist_preventSpam = false
	left_fist_projectileId = nil
	left_fist_projectileParameters = {
		power = 5 * status.stat("powerMultiplier"),
		knockback = 35,
		returnOnHit = true,
		ignoreTerrain = false,
		pickupDistance = 1.5,
		snapDistance = 5.0
	}
end

function left_fist_update(args, dt)
	if ((args.moves["primaryFire"]) and (not left_fist_preventSpam)) then
		animator.setGlobalTag("leftFrame", "active.1")
		animator.playSound("leftfistswing", 0)
		local pos = vec2.add(animator.partPoint("leftFist", "limbTip"),entity.position())
		local direction = vec2.rotate(extraarmstech_defaultVec,extraarmstech_leftAngle)
		left_fist_projectileId = world.spawnProjectile("srm_extraarms_leftfist", pos, entity.id(), direction, false, left_fist_projectileParameters)
		left_fist_preventSpam = true
	end
	if (not left_fist_projectileId) then
		left_fist_destroyProjectile()
	elseif (world.entityExists(left_fist_projectileId) == false) then
		left_fist_destroyProjectile()
	end
end

function left_fist_uninit()
	animator.setGlobalTag("leftFrame", "idle")
	left_fist_preventSpam = false
end

function left_fist_destroyProjectile()
	if (left_fist_preventSpam) then
		left_fist_projectileId = nil
		animator.playSound("leftfistreceive", 0)
		animator.setGlobalTag("leftFrame", "idle")
		left_fist_preventSpam = false
	end
end
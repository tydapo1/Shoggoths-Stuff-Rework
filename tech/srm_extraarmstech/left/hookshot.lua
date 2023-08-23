function left_hookshot_init()
	left_hookshot_preventSpam = false
	left_hookshot_preventRefire = false
	left_hookshot_projectileId = nil
	left_hookshot_projectileParameters = {
		power = 1 * status.stat("powerMultiplier"),
		speed = 60 * (status.stat("maxEnergy") / 100),
		physicsForces = { 
			pull = {
				type = "RadialForceRegion",
				categoryWhitelist = {"itemdrop"},
				outerRadius = 20,
				innerRadius = 0,
				targetRadialVelocity = -1 * 60 * (status.stat("maxEnergy") / 100),
				controlForce = 300000
			}
		},
		knockback = 1,
		returnOnHit = true,
		ignoreTerrain = false,
		pickupDistance = 1.5,
		snapDistance = 5.0
	}
end

function left_hookshot_update(args, dt)
	chains.left_chain = {
		arcRadiusRatio = {8,8},
		taper = 0,
		startOffset = {0,0},
		segmentSize = 0.5,
		overdrawLength = 0.2,
		segmentImage = "/tech/srm_extraarmstech/chain.png",
		endSegmentImage = "/tech/srm_extraarmstech/chain.png",
		renderLayer = "Player+1"
	}
	if ((args.moves["primaryFire"]) and (not left_hookshot_preventSpam) and (not left_hookshot_projectileId) and (not left_hookshot_preventRefire)) then
		animator.setGlobalTag("leftFrame", "active.1")
		--animator.playSound("lefthookshotswing", 0)
		local pos = vec2.add(animator.partPoint("leftFist", "limbTip"),entity.position())
		local direction = vec2.rotate(extraarmstech_defaultVec,extraarmstech_leftAngle)
		left_hookshot_projectileId = world.spawnProjectile("srm_extraarms_lefthook", pos, entity.id(), direction, false, left_hookshot_projectileParameters)
		left_hookshot_preventSpam = true
		left_hookshot_preventRefire = true
	end
	
	if ((not args.moves["primaryFire"]) and left_hookshot_preventRefire) then left_hookshot_preventRefire = false end
	
	-- renders chain
	if (left_hookshot_projectileId) then
		if world.entityExists(left_hookshot_projectileId) then
			local pos = animator.partPoint("leftFist", "limbTip")
			chains.left_chain.startPosition = vec2.sub(world.entityPosition(left_hookshot_projectileId),entity.position())
			--chains.left_chain.targetEntityId = left_hookshot_projectileId
			chains.left_chain.endPosition = pos
		else
			local pos = animator.partPoint("leftFist", "limbTip")
			chains.left_chain.startPosition = pos
			--chains.left_chain.targetEntityId = nil
			chains.left_chain.endPosition = pos
		end
	else
		local pos = animator.partPoint("leftFist", "limbTip")
		chains.left_chain.startPosition = pos
		--chains.left_chain.targetEntityId = nil
		chains.left_chain.endPosition = pos
	end
	
	if (left_hookshot_projectileId) then
		if (not world.entityExists(left_hookshot_projectileId)) then 
			left_hookshot_destroyProjectile()
			world.sendEntityMessage(left_hookshot_projectileId, "extraarms_killHook")
			left_hookshot_projectileId = nil
			left_hookshot_preventSpam = false
			animator.playSound("leftfistreceive", 0)
			animator.setGlobalTag("leftFrame", "idle")
		end
	end
	
	if ((not args.moves["primaryFire"]) and (left_hookshot_preventSpam)) then
		world.sendEntityMessage(left_hookshot_projectileId, "extraarms_returnHook")
		left_hookshot_preventSpam = false
	end
end

function left_hookshot_uninit()
	animator.setGlobalTag("leftFrame", "idle")
	left_hookshot_preventSpam = false
	if left_hookshot_projectileId then
		world.sendEntityMessage(left_hookshot_projectileId, "extraarms_killHook")
	end
	left_hookshot_projectileId = nil
	chains.left_chain = nil
end

function left_hookshot_destroyProjectile()
	if (left_hookshot_preventSpam) then
		if (not world.entityExists(left_hookshot_projectileId)) then
		end
	end
end
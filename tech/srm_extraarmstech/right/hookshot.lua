function right_hookshot_init()
	right_hookshot_preventSpam = false
	right_hookshot_preventRefire = false
	right_hookshot_projectileId = nil
	right_hookshot_projectileParameters = {
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

function right_hookshot_update(args, dt)
	chains.right_chain = {
		arcRadiusRatio = {8,8},
		taper = 0,
		startOffset = {0,0},
		segmentSize = 0.5,
		overdrawLength = 0.2,
		segmentImage = "/tech/srm_extraarmstech/chain.png",
		endSegmentImage = "/tech/srm_extraarmstech/chain.png",
		renderLayer = "Player+1"
	}
	if ((args.moves["altFire"]) and (not right_hookshot_preventSpam) and (not right_hookshot_projectileId) and (not right_hookshot_preventRefire)) then
		animator.setGlobalTag("rightFrame", "active.1")
		--animator.playSound("righthookshotswing", 0)
		local pos = vec2.add(animator.partPoint("rightFist", "limbTip"),entity.position())
		local direction = vec2.rotate(extraarmstech_defaultVec,extraarmstech_rightAngle)
		right_hookshot_projectileId = world.spawnProjectile("srm_extraarms_righthook", pos, entity.id(), direction, false, right_hookshot_projectileParameters)
		right_hookshot_preventSpam = true
		right_hookshot_preventRefire = true
	end
	
	if ((not args.moves["altFire"]) and right_hookshot_preventRefire) then right_hookshot_preventRefire = false end
	
	-- renders chain
	if (right_hookshot_projectileId) then
		if world.entityExists(right_hookshot_projectileId) then
			local pos = animator.partPoint("rightFist", "limbTip")
			chains.right_chain.startPosition = vec2.sub(world.entityPosition(right_hookshot_projectileId),entity.position())
			--chains.right_chain.targetEntityId = right_hookshot_projectileId
			chains.right_chain.endPosition = pos
		else
			local pos = animator.partPoint("rightFist", "limbTip")
			chains.right_chain.startPosition = pos
			--chains.right_chain.targetEntityId = nil
			chains.right_chain.endPosition = pos
		end
	else
		local pos = animator.partPoint("rightFist", "limbTip")
		chains.right_chain.startPosition = pos
		--chains.right_chain.targetEntityId = nil
		chains.right_chain.endPosition = pos
	end
	
	if (right_hookshot_projectileId) then
		if (not world.entityExists(right_hookshot_projectileId)) then 
			right_hookshot_destroyProjectile()
			world.sendEntityMessage(right_hookshot_projectileId, "extraarms_killHook")
			right_hookshot_projectileId = nil
			right_hookshot_preventSpam = false
			animator.playSound("rightfistreceive", 0)
			animator.setGlobalTag("rightFrame", "idle")
		end
	end
	
	if ((not args.moves["altFire"]) and (right_hookshot_preventSpam)) then
		world.sendEntityMessage(right_hookshot_projectileId, "extraarms_returnHook")
		right_hookshot_preventSpam = false
	end
end

function right_hookshot_uninit()
	animator.setGlobalTag("rightFrame", "idle")
	right_hookshot_preventSpam = false
	if right_hookshot_projectileId then
		world.sendEntityMessage(right_hookshot_projectileId, "extraarms_killHook")
	end
	right_hookshot_projectileId = nil
	chains.right_chain = nil
end

function right_hookshot_destroyProjectile()
	if (right_hookshot_preventSpam) then
		if (not world.entityExists(right_hookshot_projectileId)) then
		end
	end
end
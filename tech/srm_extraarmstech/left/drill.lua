function left_drill_init()
	left_drill_frameArray = {1, 2, 3, 4}
	left_drill_currentFrame = 1
	left_drill_animationTimerDelay = 0.066
	left_drill_animationTimer = 0
	left_drill_preventdrill = false
	left_drill_preventwinddown = true
end

function left_drill_update(args, dt)
	if (args.moves["primaryFire"]) then
		local pos = vec2.add(animator.partPoint("leftFist", "limbTip"),entity.position())
		world.damageTileArea(pos, 2.93, "foreground", entity.position(), "blockish", (10*status.stat("powerMultiplier"))/60, entity.id())
		world.damageTileArea(pos, 2.93, "background", entity.position(), "blockish", (10*status.stat("powerMultiplier"))/60, entity.id())
		world.spawnProjectile("srm_extraarms_drill", pos, entity.id(), animator.partPoint("leftFist", "limbTip"), true, {power=1*status.stat("powerMultiplier")})
		--world.damageTileArea(entity.position(), 2.5, "foreground", entity.position(), "blockish", (10*status.stat("powerMultiplier"))/60, entity.id())
		--local drillTiles = world.collisionBlocksAlongLine(entity.position(), pos, nil, 50)
		--if #drillTiles > 0 then
		--	world.damageTiles(drillTiles, "foreground", entity.position(), "blockish", (10*status.stat("powerMultiplier"))/60, entity.id())
		--	world.damageTiles(drillTiles, "background", entity.position(), "blockish", (10*status.stat("powerMultiplier"))/60, entity.id())
		--end
		if (left_drill_animationTimer <= 0) then
			local nextFrame = left_drill_currentFrame + 1
			if (nextFrame > #left_drill_frameArray) then
				nextFrame = 1
			end
			animator.setGlobalTag("leftFrame", "active." .. nextFrame)
			left_drill_currentFrame = nextFrame
			left_drill_animationTimer = left_drill_animationTimerDelay
		else
			left_drill_animationTimer = left_drill_animationTimer - dt
		end
		if (not left_drill_preventdrill) then
			animator.playSound("leftdrillspin", -1)
			left_drill_preventdrill = true
		end
		left_drill_preventwinddown = false
		animator.stopAllSounds("leftdrillwinddown")
	else
		animator.setGlobalTag("leftFrame", "idle")
		if (not left_drill_preventwinddown) then
			animator.playSound("leftdrillwinddown", 0)
			left_drill_preventwinddown = true
		end
		left_drill_preventdrill = false
		animator.stopAllSounds("leftdrillspin")
	end
end

function left_drill_uninit()
	animator.setGlobalTag("leftFrame", "idle")
	if (not left_drill_preventwinddown) then
		animator.playSound("leftdrillwinddown", 0)
		left_drill_preventwinddown = true
	end
	left_drill_preventdrill = false
	animator.stopAllSounds("leftdrillspin")
end
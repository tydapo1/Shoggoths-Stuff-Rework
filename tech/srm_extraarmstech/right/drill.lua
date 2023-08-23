function right_drill_init()
	right_drill_frameArray = {1, 2, 3, 4}
	right_drill_currentFrame = 1
	right_drill_animationTimerDelay = 0.066
	right_drill_animationTimer = 0
	right_drill_preventdrill = false
	right_drill_preventwinddown = true
end

function right_drill_update(args, dt)
	if (args.moves["altFire"]) then
		local pos = vec2.add(animator.partPoint("rightFist", "limbTip"),entity.position())
		world.damageTileArea(pos, 2.93, "foreground", entity.position(), "blockish", (10*status.stat("powerMultiplier"))/60, entity.id())
		world.damageTileArea(pos, 2.93, "background", entity.position(), "blockish", (10*status.stat("powerMultiplier"))/60, entity.id())
		world.spawnProjectile("srm_extraarms_drill", pos, entity.id(), animator.partPoint("rightFist", "limbTip"), true, {power=1*status.stat("powerMultiplier")})
		--world.damageTileArea(entity.position(), 2.5, "foreground", entity.position(), "blockish", (10*status.stat("powerMultiplier"))/60, entity.id())
		--local drillTiles = world.collisionBlocksAlongLine(entity.position(), pos, nil, 50)
		--if #drillTiles > 0 then
		--	world.damageTiles(drillTiles, "foreground", entity.position(), "blockish", (10*status.stat("powerMultiplier"))/60, entity.id())
		--	world.damageTiles(drillTiles, "background", entity.position(), "blockish", (10*status.stat("powerMultiplier"))/60, entity.id())
		--end
		if (right_drill_animationTimer <= 0) then
			local nextFrame = right_drill_currentFrame + 1
			if (nextFrame > #right_drill_frameArray) then
				nextFrame = 1
			end
			animator.setGlobalTag("rightFrame", "active." .. nextFrame)
			right_drill_currentFrame = nextFrame
			right_drill_animationTimer = right_drill_animationTimerDelay
		else
			right_drill_animationTimer = right_drill_animationTimer - dt
		end
		if (not right_drill_preventdrill) then
			animator.playSound("rightdrillspin", -1)
			right_drill_preventdrill = true
		end
		right_drill_preventwinddown = false
		animator.stopAllSounds("rightdrillwinddown")
	else
		animator.setGlobalTag("rightFrame", "idle")
		if (not right_drill_preventwinddown) then
			animator.playSound("rightdrillwinddown", 0)
			right_drill_preventwinddown = true
		end
		right_drill_preventdrill = false
		animator.stopAllSounds("rightdrillspin")
	end
end

function right_drill_uninit()
	animator.setGlobalTag("rightFrame", "idle")
	if (not right_drill_preventwinddown) then
		animator.playSound("rightdrillwinddown", 0)
		right_drill_preventwinddown = true
	end
	right_drill_preventdrill = false
	animator.stopAllSounds("rightdrillspin")
end
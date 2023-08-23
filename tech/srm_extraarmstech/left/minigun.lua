function left_minigun_init()
	left_minigun_ammoMax = math.ceil(300 * (status.stat("maxEnergy") / 100))
	left_minigun_ammo = left_minigun_ammoMax
	left_minigun_recoil = {-3.0,0}
	left_minigun_idleTimerMax = 5
	left_minigun_idleTimer = 0
	left_minigun_revCounterMax = 1
	left_minigun_revCounter = 0
	left_minigun_preventUse = false
	left_minigun_states = { "idle", "revUp", "firing", "revDown" }
	left_minigun_currentState = left_minigun_states[1]
	left_minigun_preventminigunshoot = false
	left_minigun_preventminigunempty = false
	left_minigun_preventminigunwindup = false
	left_minigun_preventminigunwinddown = false
	left_minigun_frameArray = {1, 2, 3, 4}
	left_minigun_currentFrame = 1
	left_minigun_animationTimerDelay = 2
	left_minigun_animationTimer = 0
	left_minigun_damagePerBullet = 0.5*status.stat("powerMultiplier")
end

function left_minigun_update(args, dt)
	if (left_minigun_currentState == left_minigun_states[2]) then
		animator.stopAllSounds("leftminigunshoot")
		left_minigun_preventminigunshoot = false
		animator.stopAllSounds("leftminigunempty")
		left_minigun_preventminigunempty = false
		animator.stopAllSounds("leftminigunwinddown")
		left_minigun_preventminigunwinddown = false
		if (not left_minigun_preventminigunwindup) then animator.playSound("leftminigunwindup", 0) left_minigun_preventminigunwindup = true end 
		left_minigun_preventUse = true
		if (left_minigun_revCounter < left_minigun_revCounterMax) then
			left_minigun_revCounter = left_minigun_revCounter + dt
		else
			left_minigun_preventUse = false
			left_minigun_currentState = left_minigun_states[3]
		end
	end
	if (left_minigun_currentState == left_minigun_states[4]) then
		animator.stopAllSounds("leftminigunshoot")
		left_minigun_preventminigunshoot = false
		animator.stopAllSounds("leftminigunempty")
		left_minigun_preventminigunempty = false
		animator.stopAllSounds("leftminigunwindup")
		left_minigun_preventminigunwindup = false
		if (not left_minigun_preventminigunwinddown) then animator.playSound("leftminigunwinddown", 0) left_minigun_preventminigunwinddown = true end 
		left_minigun_preventUse = true
		if (left_minigun_revCounter > 0) then
			left_minigun_revCounter = left_minigun_revCounter - dt
		else
			left_minigun_preventUse = false
			left_minigun_currentState = left_minigun_states[1]
		end
	end
	if (left_minigun_currentState == left_minigun_states[1]) then
		if (not (left_minigun_ammo == left_minigun_ammoMax)) then
			if (left_minigun_idleTimer >= left_minigun_idleTimerMax) then
				left_minigun_ammo = left_minigun_ammoMax
				animator.playSound("leftminigunreload", 0)
			else
				left_minigun_idleTimer = left_minigun_idleTimer + dt
			end
		end
		animator.stopAllSounds("leftminigunshoot")
		left_minigun_preventminigunshoot = false
		animator.stopAllSounds("leftminigunempty")
		left_minigun_preventminigunempty = false
		animator.stopAllSounds("leftminigunwindup")
		left_minigun_preventminigunwindup = false
		animator.stopAllSounds("leftminigunwinddown")
		left_minigun_preventminigunwinddown = false
	end
	if (not left_minigun_preventUse) then
		if (args.moves["primaryFire"]) then
			if (left_minigun_currentState == left_minigun_states[3]) then
				if (left_minigun_ammo > 0) then
					-- actual firing
					animator.stopAllSounds("leftminigunempty")
					left_minigun_preventminigunempty = false
					animator.stopAllSounds("leftminigunwindup")
					left_minigun_preventminigunwindup = false
					animator.stopAllSounds("leftminigunwinddown")
					left_minigun_preventminigunwinddown = false
					if (not left_minigun_preventminigunshoot) then animator.playSound("leftminigunshoot", -1) left_minigun_preventminigunshoot = true end 
					left_minigun_ammo = left_minigun_ammo - 1
					local pos = vec2.add(animator.partPoint("leftFist", "limbTip"),entity.position())
					local direction = vec2.rotate(extraarmstech_defaultVec,extraarmstech_leftAngle)
					local spread = (math.random() - 0.5) * 0.075 * math.pi
					direction = vec2.rotate(direction, spread)
					world.spawnProjectile("srm_extraarms_muzzleflash", pos, entity.id(), direction, true)
					world.spawnProjectile("bullet-1", pos, entity.id(), direction, false, {knockback=2,piercing=true,power=left_minigun_damagePerBullet})
					-- recoil
					local finalVector = vec2.div((vec2.rotate(left_minigun_recoil, extraarmstech_leftAngle)), 2)
					mcontroller.addMomentum(finalVector)
				else
					-- blank firing
					animator.stopAllSounds("leftminigunshoot")
					left_minigun_preventminigunshoot = false
					animator.stopAllSounds("leftminigunwindup")
					left_minigun_preventminigunwindup = false
					animator.stopAllSounds("leftminigunwinddown")
					left_minigun_preventminigunwinddown = false
					if (not left_minigun_preventminigunempty) then animator.playSound("leftminigunempty", -1) left_minigun_preventminigunempty = true end 
				end
			else
				left_minigun_preventUse = true
				left_minigun_currentState = left_minigun_states[2]
			end
		else
			if (not (left_minigun_currentState == left_minigun_states[1])) then
				left_minigun_preventUse = true
				left_minigun_currentState = left_minigun_states[4]
			end
		end
	end
	if (not (left_minigun_currentState == left_minigun_states[1])) then
		left_minigun_idleTimer = 0
		if (left_minigun_animationTimer <= 0) then
			local nextFrame = left_minigun_currentFrame + 1
			if (nextFrame > #left_minigun_frameArray) then
				nextFrame = 1
			end
			animator.setGlobalTag("leftFrame", "active." .. nextFrame)
			left_minigun_currentFrame = nextFrame
			left_minigun_animationTimer = left_minigun_animationTimerDelay
		else
			left_minigun_animationTimer = left_minigun_animationTimer - 1
		end
	else
		animator.setGlobalTag("leftFrame", "idle")
	end
end

function left_minigun_uninit()
	animator.setGlobalTag("leftFrame", "idle")
	left_minigun_ammo = 0
	left_minigun_idleTimer = 0
	left_minigun_revCounter = 0
	left_minigun_preventUse = false
	left_minigun_currentState = left_minigun_states[1]
	animator.stopAllSounds("leftminigunshoot")
	left_minigun_preventminigunshoot = false
	animator.stopAllSounds("leftminigunempty")
	left_minigun_preventminigunempty = false
	animator.stopAllSounds("leftminigunwindup")
	left_minigun_preventminigunwindup = false
	animator.stopAllSounds("leftminigunwinddown")
	left_minigun_preventminigunwinddown = false
end
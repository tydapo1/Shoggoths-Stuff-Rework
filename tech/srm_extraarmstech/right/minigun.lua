function right_minigun_init()
	right_minigun_ammoMax = math.ceil(300 * (status.stat("maxEnergy") / 100))
	right_minigun_ammo = right_minigun_ammoMax
	right_minigun_recoil = {-3.0,0}
	right_minigun_idleTimerMax = 5
	right_minigun_idleTimer = 0
	right_minigun_revCounterMax = 1
	right_minigun_revCounter = 0
	right_minigun_preventUse = false
	right_minigun_states = { "idle", "revUp", "firing", "revDown" }
	right_minigun_currentState = right_minigun_states[1]
	right_minigun_preventminigunshoot = false
	right_minigun_preventminigunempty = false
	right_minigun_preventminigunwindup = false
	right_minigun_preventminigunwinddown = false
	right_minigun_frameArray = {1, 2, 3, 4}
	right_minigun_currentFrame = 1
	right_minigun_animationTimerDelay = 2
	right_minigun_animationTimer = 0
	right_minigun_damagePerBullet = 0.5*status.stat("powerMultiplier")
end

function right_minigun_update(args, dt)
	if (right_minigun_currentState == right_minigun_states[2]) then
		animator.stopAllSounds("rightminigunshoot")
		right_minigun_preventminigunshoot = false
		animator.stopAllSounds("rightminigunempty")
		right_minigun_preventminigunempty = false
		animator.stopAllSounds("rightminigunwinddown")
		right_minigun_preventminigunwinddown = false
		if (not right_minigun_preventminigunwindup) then animator.playSound("rightminigunwindup", 0) right_minigun_preventminigunwindup = true end 
		right_minigun_preventUse = true
		if (right_minigun_revCounter < right_minigun_revCounterMax) then
			right_minigun_revCounter = right_minigun_revCounter + dt
		else
			right_minigun_preventUse = false
			right_minigun_currentState = right_minigun_states[3]
		end
	end
	if (right_minigun_currentState == right_minigun_states[4]) then
		animator.stopAllSounds("rightminigunshoot")
		right_minigun_preventminigunshoot = false
		animator.stopAllSounds("rightminigunempty")
		right_minigun_preventminigunempty = false
		animator.stopAllSounds("rightminigunwindup")
		right_minigun_preventminigunwindup = false
		if (not right_minigun_preventminigunwinddown) then animator.playSound("rightminigunwinddown", 0) right_minigun_preventminigunwinddown = true end 
		right_minigun_preventUse = true
		if (right_minigun_revCounter > 0) then
			right_minigun_revCounter = right_minigun_revCounter - dt
		else
			right_minigun_preventUse = false
			right_minigun_currentState = right_minigun_states[1]
		end
	end
	if (right_minigun_currentState == right_minigun_states[1]) then
		if (not (right_minigun_ammo == right_minigun_ammoMax)) then
			if (right_minigun_idleTimer >= right_minigun_idleTimerMax) then
				right_minigun_ammo = right_minigun_ammoMax
				animator.playSound("rightminigunreload", 0)
			else
				right_minigun_idleTimer = right_minigun_idleTimer + dt
			end
		end
		animator.stopAllSounds("rightminigunshoot")
		right_minigun_preventminigunshoot = false
		animator.stopAllSounds("rightminigunempty")
		right_minigun_preventminigunempty = false
		animator.stopAllSounds("rightminigunwindup")
		right_minigun_preventminigunwindup = false
		animator.stopAllSounds("rightminigunwinddown")
		right_minigun_preventminigunwinddown = false
	end
	if (not right_minigun_preventUse) then
		if (args.moves["altFire"]) then
			if (right_minigun_currentState == right_minigun_states[3]) then
				if (right_minigun_ammo > 0) then
					-- actual firing
					animator.stopAllSounds("rightminigunempty")
					right_minigun_preventminigunempty = false
					animator.stopAllSounds("rightminigunwindup")
					right_minigun_preventminigunwindup = false
					animator.stopAllSounds("rightminigunwinddown")
					right_minigun_preventminigunwinddown = false
					if (not right_minigun_preventminigunshoot) then animator.playSound("rightminigunshoot", -1) right_minigun_preventminigunshoot = true end 
					right_minigun_ammo = right_minigun_ammo - 1
					local pos = vec2.add(animator.partPoint("rightFist", "limbTip"),entity.position())
					local direction = vec2.rotate(extraarmstech_defaultVec,extraarmstech_rightAngle)
					local spread = (math.random() - 0.5) * 0.075 * math.pi
					direction = vec2.rotate(direction, spread)
					world.spawnProjectile("srm_extraarms_muzzleflash", pos, entity.id(), direction, true)
					world.spawnProjectile("bullet-1", pos, entity.id(), direction, false, {knockback=2,piercing=true,power=right_minigun_damagePerBullet})
					-- recoil
					local finalVector = vec2.div((vec2.rotate(right_minigun_recoil, extraarmstech_rightAngle)), 2)
					mcontroller.addMomentum(finalVector)
				else
					-- blank firing
					animator.stopAllSounds("rightminigunshoot")
					right_minigun_preventminigunshoot = false
					animator.stopAllSounds("rightminigunwindup")
					right_minigun_preventminigunwindup = false
					animator.stopAllSounds("rightminigunwinddown")
					right_minigun_preventminigunwinddown = false
					if (not right_minigun_preventminigunempty) then animator.playSound("rightminigunempty", -1) right_minigun_preventminigunempty = true end 
				end
			else
				right_minigun_preventUse = true
				right_minigun_currentState = right_minigun_states[2]
			end
		else
			if (not (right_minigun_currentState == right_minigun_states[1])) then
				right_minigun_preventUse = true
				right_minigun_currentState = right_minigun_states[4]
			end
		end
	end
	if (not (right_minigun_currentState == right_minigun_states[1])) then
		right_minigun_idleTimer = 0
		if (right_minigun_animationTimer <= 0) then
			local nextFrame = right_minigun_currentFrame + 1
			if (nextFrame > #right_minigun_frameArray) then
				nextFrame = 1
			end
			animator.setGlobalTag("rightFrame", "active." .. nextFrame)
			right_minigun_currentFrame = nextFrame
			right_minigun_animationTimer = right_minigun_animationTimerDelay
		else
			right_minigun_animationTimer = right_minigun_animationTimer - 1
		end
	else
		animator.setGlobalTag("rightFrame", "idle")
	end
end

function right_minigun_uninit()
	animator.setGlobalTag("rightFrame", "idle")
	right_minigun_ammo = 0
	right_minigun_idleTimer = 0
	right_minigun_revCounter = 0
	right_minigun_preventUse = false
	right_minigun_currentState = right_minigun_states[1]
	animator.stopAllSounds("rightminigunshoot")
	right_minigun_preventminigunshoot = false
	animator.stopAllSounds("rightminigunempty")
	right_minigun_preventminigunempty = false
	animator.stopAllSounds("rightminigunwindup")
	right_minigun_preventminigunwindup = false
	animator.stopAllSounds("rightminigunwinddown")
	right_minigun_preventminigunwinddown = false
end
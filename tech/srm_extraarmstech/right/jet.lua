function right_jet_init()
	right_jet_fuelMax = 5 * (status.stat("maxEnergy") / 100)
	right_jet_fuel = right_jet_fuelMax
	right_jet_power = {2.5,0}
	right_jet_preventrightjet = false
	right_jet_preventrightjetbubbles = false
	right_jet_preventrightjethover = false
	right_jet_preventrightjetstop = true
	right_jet_frameArray = {1, 2, 3, 4}
	right_jet_currentFrame = 1
	right_jet_animationTimerDelay = 4
	right_jet_animationTimer = 0
end

function right_jet_update(args, dt)
	if (mcontroller.onGround() or mcontroller.zeroG()) then right_jet_fuel = right_jet_fuelMax end
	if (mcontroller.liquidMovement()) then right_jet_fuel = right_jet_fuelMax end
	if ((args.moves["altFire"]) and (mcontroller.liquidMovement())) then
		right_jet_fuel = right_jet_fuel - dt
		local angle = vec2.angle(world.distance(tech.aimPosition(),entity.position()))
		local finalVector = vec2.mul((vec2.rotate(right_jet_power, angle)), 2.0)
		mcontroller.addMomentum(finalVector)
		right_jet_animationFunction(false, true, false, true, false, false)
	elseif ((args.moves["altFire"]) and (right_jet_fuel > 0)) then
		right_jet_fuel = right_jet_fuel - dt
		local angle = vec2.angle(world.distance(tech.aimPosition(),entity.position()))
		local finalVector = vec2.rotate(right_jet_power, angle)
		mcontroller.addMomentum(finalVector)
		right_jet_animationFunction(true, false, true, false, false, false)
	elseif ((args.moves["altFire"]) and (right_jet_fuel <= 0)) then
		local angle = vec2.angle(world.distance(tech.aimPosition(),entity.position()))
		local finalVector = vec2.div((vec2.rotate(right_jet_power, angle)), 2)
		mcontroller.addMomentum(finalVector)
		right_jet_animationFunction(true, false, false, false, true, false)
	else
		right_jet_animationFunction(false, false, false, false, false, true)
	end
	if (args.moves["altFire"]) then
		animator.setLightActive("rightjetglow", true)
		if (right_jet_animationTimer <= 0) then
			local nextFrame = right_jet_currentFrame + 1
			if (nextFrame > #right_jet_frameArray) then
				nextFrame = 1
			end
			animator.setGlobalTag("rightFrame", "active." .. nextFrame)
			right_jet_currentFrame = nextFrame
			right_jet_animationTimer = right_jet_animationTimerDelay
		else
			right_jet_animationTimer = right_jet_animationTimer - 1
		end
	else
		animator.setLightActive("rightjetglow", false)
		animator.setGlobalTag("rightFrame", "idle")
	end
end

function right_jet_uninit()
	animator.setGlobalTag("rightFrame", "idle")
	right_jet_fuel = 0
	animator.setLightActive("rightjetglow", false)
	right_jet_animationFunction(false, false, false, false, false, false)
end

function right_jet_animationFunction(particles_rightjetsmoke, particles_rightjetbubbles, sound_rightjet, sound_rightjetbubbles, sound_rightjethover, sound_rightjetstop)
	animator.setParticleEmitterActive("rightjetsmoke", particles_rightjetsmoke)
	animator.setParticleEmitterActive("rightjetbubbles", particles_rightjetbubbles)
	if (sound_rightjet) then
		if (not right_jet_preventrightjet) then animator.playSound("rightjet", -1) end
		right_jet_preventrightjet = true
	else
		animator.stopAllSounds("rightjet")
		right_jet_preventrightjet = false
	end
	if (sound_rightjetbubbles) then
		if (not right_jet_preventrightjetbubbles) then animator.playSound("rightjetbubbles", -1) end
		right_jet_preventrightjetbubbles = true
	else
		animator.stopAllSounds("rightjetbubbles")
		right_jet_preventrightjetbubbles = false
	end
	if (sound_rightjethover) then
		if (not right_jet_preventrightjethover) then animator.playSound("rightjethover", -1) end
		right_jet_preventrightjethover = true
	else
		animator.stopAllSounds("rightjethover")
		right_jet_preventrightjethover = false
	end
	if (sound_rightjetstop) then
		if (not right_jet_preventrightjetstop) then animator.playSound("rightjetstop", 0) end
		right_jet_preventrightjetstop = true
	else
		animator.stopAllSounds("rightjetstop")
		right_jet_preventrightjetstop = false
	end
end
function left_jet_init()
	left_jet_fuelMax = 5 * (status.stat("maxEnergy") / 100)
	left_jet_fuel = left_jet_fuelMax
	left_jet_power = {2.5,0}
	left_jet_preventleftjet = false
	left_jet_preventleftjetbubbles = false
	left_jet_preventleftjethover = false
	left_jet_preventleftjetstop = true
	left_jet_frameArray = {1, 2, 3, 4}
	left_jet_currentFrame = 1
	left_jet_animationTimerDelay = 4
	left_jet_animationTimer = 0
end

function left_jet_update(args, dt)
	if (mcontroller.onGround() or mcontroller.zeroG()) then left_jet_fuel = left_jet_fuelMax end
	if (mcontroller.liquidMovement()) then left_jet_fuel = left_jet_fuelMax end
	if ((args.moves["primaryFire"]) and (mcontroller.liquidMovement())) then
		left_jet_fuel = left_jet_fuel - dt
		local angle = vec2.angle(world.distance(tech.aimPosition(),entity.position()))
		local finalVector = vec2.mul((vec2.rotate(left_jet_power, angle)), 2.0)
		mcontroller.addMomentum(finalVector)
		left_jet_animationFunction(false, true, false, true, false, false)
	elseif ((args.moves["primaryFire"]) and (left_jet_fuel > 0)) then
		left_jet_fuel = left_jet_fuel - dt
		local angle = vec2.angle(world.distance(tech.aimPosition(),entity.position()))
		local finalVector = vec2.rotate(left_jet_power, angle)
		mcontroller.addMomentum(finalVector)
		left_jet_animationFunction(true, false, true, false, false, false)
	elseif ((args.moves["primaryFire"]) and (left_jet_fuel <= 0)) then
		local angle = vec2.angle(world.distance(tech.aimPosition(),entity.position()))
		local finalVector = vec2.div((vec2.rotate(left_jet_power, angle)), 2)
		mcontroller.addMomentum(finalVector)
		left_jet_animationFunction(true, false, false, false, true, false)
	else
		left_jet_animationFunction(false, false, false, false, false, true)
	end
	if (args.moves["primaryFire"]) then
		animator.setLightActive("leftjetglow", true)
		if (left_jet_animationTimer <= 0) then
			local nextFrame = left_jet_currentFrame + 1
			if (nextFrame > #left_jet_frameArray) then
				nextFrame = 1
			end
			animator.setGlobalTag("leftFrame", "active." .. nextFrame)
			left_jet_currentFrame = nextFrame
			left_jet_animationTimer = left_jet_animationTimerDelay
		else
			left_jet_animationTimer = left_jet_animationTimer - 1
		end
	else
		animator.setLightActive("leftjetglow", false)
		animator.setGlobalTag("leftFrame", "idle")
	end
end

function left_jet_uninit()
	animator.setGlobalTag("leftFrame", "idle")
	left_jet_fuel = 0
	animator.setLightActive("leftjetglow", false)
	left_jet_animationFunction(false, false, false, false, false, false)
end

function left_jet_animationFunction(particles_leftjetsmoke, particles_leftjetbubbles, sound_leftjet, sound_leftjetbubbles, sound_leftjethover, sound_leftjetstop)
	animator.setParticleEmitterActive("leftjetsmoke", particles_leftjetsmoke)
	animator.setParticleEmitterActive("leftjetbubbles", particles_leftjetbubbles)
	if (sound_leftjet) then
		if (not left_jet_preventleftjet) then animator.playSound("leftjet", -1) end
		left_jet_preventleftjet = true
	else
		animator.stopAllSounds("leftjet")
		left_jet_preventleftjet = false
	end
	if (sound_leftjetbubbles) then
		if (not left_jet_preventleftjetbubbles) then animator.playSound("leftjetbubbles", -1) end
		left_jet_preventleftjetbubbles = true
	else
		animator.stopAllSounds("leftjetbubbles")
		left_jet_preventleftjetbubbles = false
	end
	if (sound_leftjethover) then
		if (not left_jet_preventleftjethover) then animator.playSound("leftjethover", -1) end
		left_jet_preventleftjethover = true
	else
		animator.stopAllSounds("leftjethover")
		left_jet_preventleftjethover = false
	end
	if (sound_leftjetstop) then
		if (not left_jet_preventleftjetstop) then animator.playSound("leftjetstop", 0) end
		left_jet_preventleftjetstop = true
	else
		animator.stopAllSounds("leftjetstop")
		left_jet_preventleftjetstop = false
	end
end
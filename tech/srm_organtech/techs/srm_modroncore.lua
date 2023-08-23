local oldUpdate = update
update = function(args,dt)
	if oldUpdate then oldUpdate(args,dt) end
	
	if (hasStatus("srm_modroncore")) then 
		update_modroncore(args,dt)
	end
end

-- Init for the Modron Core
function init_modroncore()
	if not modroncore_setup then
		modroncore_setup = true
		
		modroncore_timerReset = 3
		modroncore_juice = modroncore_timerReset
		modroncore_speedBase = (mcontroller.baseParameters().runSpeed)
		modroncore_speed = modroncore_speedBase
		modroncore_soundTriggered = false
		modroncore_vecX = 0
		modroncore_vecY = 0
	end
end

-- Update for the Modron Core
function update_modroncore(args)
	local dt = args.dt
	init_modroncore()
	
	if (mcontroller.onGround() and mcontroller.running()) then
		if ((math.abs(mcontroller.xVelocity())) > modroncore_speedBase) then
			modroncore_speed = (math.abs(mcontroller.xVelocity()))
	else
		modroncore_speed = modroncore_speedBase
	end
	end
	if (args.moves["up"]) then
		mcontroller.controlJump()
	end
	if ((not mcontroller.onGround()) and modroncore_juice > 0) then
	if (modroncore_soundTriggered == false) then
			animator.playSound("hoverStart", 0)
			animator.playSound("hoverLoop", -1)
		animator.stopAllSounds("hoverEnd")
			animator.setParticleEmitterActive("hovering", true)
		modroncore_soundTriggered = true
	end
		mcontroller.controlParameters({
			gravityMultiplier = 0.05
		})
		modroncore_vecX = 0
		modroncore_vecY = 0
		if (args.moves["left"]) then
			modroncore_vecX = modroncore_vecX + (-1 * modroncore_speed)
			modroncore_vecY = modroncore_vecY
		end
		if (args.moves["up"] or args.moves["jump"]) then
			modroncore_vecX = modroncore_vecX
			modroncore_vecY = modroncore_vecY + (1 * modroncore_speed)
		end
		if (args.moves["right"]) then
			modroncore_vecX = modroncore_vecX + (1 * modroncore_speed)
			modroncore_vecY = modroncore_vecY
		end
		if (args.moves["down"]) then
			modroncore_vecX = modroncore_vecX
			modroncore_vecY = modroncore_vecY + (-1 * modroncore_speed)
		end
	local vec = defaultVec
	vec[1] = modroncore_vecX
	vec[2] = modroncore_vecY
		mcontroller.setVelocity(vec)
	if ((math.abs(vec[1]) > 0) or (math.abs(vec[2]) > 0)) then
		modroncore_juice = modroncore_juice - dt
	end
	elseif ((not mcontroller.onGround()) and modroncore_juice == 0) then
		mcontroller.controlParameters({
			gravityMultiplier = 1
		})
	if (modroncore_soundTriggered == true) then
		animator.stopAllSounds("hoverStart")
		animator.stopAllSounds("hoverLoop")
		animator.playSound("hoverEnd", 0)
			animator.setParticleEmitterActive("hovering", false)
		modroncore_soundTriggered = false
	end
	else
		mcontroller.controlParameters({
			gravityMultiplier = 1
		})
	if (modroncore_soundTriggered == true) then
		animator.stopAllSounds("hoverStart")
		animator.stopAllSounds("hoverLoop")
		animator.playSound("hoverEnd", 0)
			animator.setParticleEmitterActive("hovering", false)
		modroncore_soundTriggered = false
	end
		modroncore_juice = modroncore_timerReset
	end
end
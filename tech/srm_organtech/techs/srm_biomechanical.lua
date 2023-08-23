local oldUpdate = update
update = function(args,dt)
	if oldUpdate then oldUpdate(args,dt) end
	
	if (hasStatus("srm_biomechanicalgut") and hasStatus("srm_biomechanicalheart") and hasStatus("srm_biomechanicalbrain")) then 
		update_biomechanical(args,dt)
	end
end

-- Init for the Biomechanical set
function init_biomech()
	if not biomech_setup then
		biomech_setup = true
		
		biomech_mechTimer = 0
		biomech_mechCooldown = 0
		biomech_runTimer = 0
		biomech_runReset = 16
		biomech_walkTimer = 0
		biomech_walkReset = 24
		biomech_jumpLock = false
		biomech_queryDamageSince = 0
		biomech_jpackPrevent = false
		biomech_jpackhoverPrevent = false
		biomech_jpackstopPrevent = false
	end
end

-- Update for the Biomechanical set
function update_biomechanical(args)
	local dt = args.dt
	init_biomech()
	
	-- Bonus stats
	mcontroller.controlParameters({runSpeed = 20.00, walkSpeed = 10.00, jumpSpeed = 16.00, airForce = 600.00, airJumpProfile = {jumpHoldTime = 1.0}})
	if status.resourceLocked("energy") then
		mcontroller.controlModifiers({
			speedModifier = 0.0,
			airJumpModifier = 0.0
		})
	end
	
	-- Mech call
	if (biomech_mechCooldown > 0) then biomech_mechCooldown = biomech_mechCooldown - 1 end
	if (biomech_mechCooldown == 0) then
		if ((args.moves["run"] == false) and (args.moves["down"] == true)) then
		if (biomech_mechTimer == 180) then
			biomech_mechTimer = 0
			biomech_mechCooldown = 600
			animator.playSound("mechCalled", 0)
			world.sendEntityMessage(entity.id(), "deployMech")
		elseif (math.fmod(biomech_mechTimer,60) == 0) then
			animator.playSound("mechCallWarmup", 0)
		end
			biomech_mechTimer = biomech_mechTimer + 1
		else
			biomech_mechTimer = 0
		end
	end
	
	-- Simple stuff for making the player sound like a mech
	if (mcontroller.onGround() and mcontroller.running() and (not mcontroller.walking())) then
		if (biomech_runTimer == 0) then
			animator.playSound("walk", 0)
		biomech_runTimer = biomech_runReset
	end
	if (biomech_runTimer > 0) then biomech_runTimer = biomech_runTimer - 1 end
	if (biomech_walkTimer > 0) then biomech_walkTimer = biomech_walkTimer - 1 end
	elseif (mcontroller.onGround() and mcontroller.walking() and (not mcontroller.running())) then
		if (biomech_walkTimer == 0) then
			animator.playSound("walk", 0)
		biomech_walkTimer = biomech_walkReset
	end
	if (biomech_runTimer > 0) then biomech_runTimer = biomech_runTimer - 1 end
	if (biomech_walkTimer > 0) then biomech_walkTimer = biomech_walkTimer - 1 end
	else
	biomech_runTimer = 0
	biomech_walkTimer = 0
	end
	if (mcontroller.jumping() and (not biomech_jumpLock)) then
		animator.playSound("jump", 0)
	biomech_jumpLock = true
	elseif ((not mcontroller.jumping()) and biomech_jumpLock) then
		biomech_jumpLock = false
	end
	if ((not mcontroller.onGround()) and args.moves["jump"] and mcontroller.jumping()) then
		if (not biomech_jpackPrevent) then
			animator.playSound("jpack", -1)
			biomech_jpackPrevent = true
			animator.setParticleEmitterActive("jetpack", true)
	end
	animator.stopAllSounds("jpackhover")
	animator.stopAllSounds("jpackstop")
		biomech_jpackhoverPrevent = false
		biomech_jpackstopPrevent = false
	elseif ((not mcontroller.onGround()) and args.moves["jump"] and (not mcontroller.jumping())) then
		if (not biomech_jpackhoverPrevent) then
		animator.playSound("jpackhover", -1)
			biomech_jpackhoverPrevent = true
			animator.setParticleEmitterActive("jetpack", true)
	end
	animator.stopAllSounds("jpack")
	animator.stopAllSounds("jpackstop")
		biomech_jpackPrevent = false
		biomech_jpackstopPrevent = false
	if (mcontroller.yVelocity() < -21) then
		mcontroller.setYVelocity(-21) 
	end
	else
		if (not biomech_jpackstopPrevent) then
			animator.playSound("jpackstop", 0)
			biomech_jpackstopPrevent = true
			animator.setParticleEmitterActive("jetpack", false)
	end
	animator.stopAllSounds("jpack")
	animator.stopAllSounds("jpackhover")
		biomech_jpackPrevent = false
		biomech_jpackhoverPrevent = false
	end
	local damageNotifications, nextStep = status.damageTakenSince(biomech_queryDamageSince)
	biomech_queryDamageSince = nextStep
	for _, notification in ipairs(damageNotifications) do
		if notification.healthLost > 0 and notification.sourceEntityId ~= notification.targetEntityId then
			animator.playSound("hurt", 0)
			break
		end
	end
end
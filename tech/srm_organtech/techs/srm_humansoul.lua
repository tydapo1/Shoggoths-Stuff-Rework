local oldUpdate = update
update = function(args,dt)
	if oldUpdate then oldUpdate(args,dt) end
	
	if (hasStatus("srm_humansoul")) then 
		update_humansoul(args,dt)
	end
end

-- Init for the Human Soul
function init_humansoul()
	if not humansoul_setup then
		humansoul_setup = true
		
		humansoul_maxabsorption = 32767
		humansoul_specialfall = false
		humansoul_isairdodging = false
		humansoul_onlyaironce = true
		humansoul_preventautoair = false
		
		humansoul_airmaxframes = 22
		humansoul_airdistance = 25
		humansoul_airframe = humansoul_airmaxframes
		humansoul_airdodgehorizontal = "neutral"
		humansoul_airdodgevertical = "neutral"
		humansoul_isrolling = false
		humansoul_onlyrollonce = true
		humansoul_preventautoroll = false
		humansoul_rolldistance = 25
		humansoul_rollmaxframes = 30
		humansoul_spotmaxframes = 18
		humansoul_rollframe = 0
		humansoul_rolldirection = "left"
		humansoul_onlyactivateonce = true
		humansoul_graceperiodmax = 4
		humansoul_gracetimer = humansoul_graceperiodmax
		humansoul_shieldmultiplier = 4
		humansoul_maxshield = status.resourceMax("health") * humansoul_shieldmultiplier
		humansoul_shield = humansoul_maxshield
		
		humansoul_shieldbroken = false
		humansoul_onlybreakonce = true
		humansoul_minimumdizzytimer = 0.05
		humansoul_dizzytimer = humansoul_minimumdizzytimer
		humansoul_onlydizzyonce = true
		humansoul_brokentimermax = 10
		humansoul_brokentimer = humansoul_brokentimermax
		humansoul_queryDamageSince = 0
	end
end

-- Update for the Human Soul
function update_humansoul(args)
	local dt = args.dt
	init_humansoul()
	
	humansoul_maxshield = status.resourceMax("health") * humansoul_shieldmultiplier
	
	animator.resetTransformationGroup("shieldbubble")
	if (mcontroller.crouching()) then
		animator.translateTransformationGroup("shieldbubble", {0,-0.675})
	end
	animator.scaleTransformationGroup("shieldbubble", {(humansoul_shield/humansoul_maxshield),(humansoul_shield/humansoul_maxshield)})
	
	if (args.moves["run"] == true) then humansoul_preventautoair = false end
	--if (args.moves["down"] == true) then mcontroller.addMomentum({0,-15}) end
	if humansoul_shield <= 0 then humansoul_shieldbroken = true end
	if not humansoul_shieldbroken then
		-- This covers basic shielding
		if mcontroller.onGround() then humansoul_specialfall = false end
		status.removeEphemeralEffect("srm_shieldbroken")
		animator.stopAllSounds("shielddizzyloop")
		if (not humansoul_isrolling) and (not humansoul_isairdodging) then
			humansoul_onlybreakonce = true
			if ((mcontroller.onGround()) and (args.moves["run"] == false)) then
				tech.setToolUsageSuppressed(true)
				humansoul_gracetimer = humansoul_graceperiodmax
			elseif ((not mcontroller.onGround()) and (args.moves["run"] == false) and (humansoul_specialfall == false) and (not humansoul_preventautoair)) then
				humansoul_preventautoair = true
				tech.setToolUsageSuppressed(true)
				local xdirection = "neutral"
				local ydirection = "neutral"
				if (args.moves["left"] == true) then
					xdirection = "left"
				elseif (args.moves["right"] == true) then
					xdirection = "right"
				end
				if (args.moves["up"] == true) then
					ydirection = "up"
				elseif (args.moves["down"] == true) then
					ydirection = "down"
				end
				humansoul_airdodgehorizontal = xdirection
				humansoul_airdodgevertical = ydirection
				humansoul_isairdodging = true
			else
			tech.setToolUsageSuppressed(false)
			humansoul_gracetimer = humansoul_gracetimer - 1
			end
	
			if humansoul_gracetimer > 0 then
				if humansoul_onlyactivateonce then
					humansoul_onlyactivateonce = false
					animator.playSound("shieldon", 0)
					animator.setAnimationState("shieldState", "on")
				end
			else
				if not humansoul_onlyactivateonce then
					humansoul_onlyactivateonce = true
					animator.playSound("shieldoff", 0)
					animator.setAnimationState("shieldState", "off")
				end
			end
		
			if animator.animationState("shieldState") == "on" then
				if not humansoul_preventautoroll then
					if (args.moves["left"] == true) then
						humansoul_isrolling = true
						humansoul_rolldirection = "left"
					elseif (args.moves["right"] == true) then
						humansoul_isrolling = true
						humansoul_rolldirection = "right"
					elseif ((args.moves["down"] == true) or (args.moves["up"] == true) or (args.moves["jump"] == true)) then
						humansoul_isrolling = true
						humansoul_rolldirection = "down"
					end
				else
					if ((args.moves["left"] ~= true) and (args.moves["right"] ~= true) and (args.moves["down"] ~= true) and (args.moves["up"] ~= true) and (args.moves["jump"] ~= true)) then
						humansoul_preventautoroll = false
					end
				end
					
				local damageNotifications, nextStep = status.damageTakenSince(humansoul_queryDamageSince)
				humansoul_queryDamageSince = nextStep
				for _, notification in ipairs(damageNotifications) do
					if notification.sourceEntityId ~= notification.targetEntityId then
						animator.playSound("shieldhit", 0)
						humansoul_shield = humansoul_shield - 65
						break
					end
				end
				mcontroller.clearControls()
				mcontroller.controlParameters({runSpeed = 0.0, walkSpeed = 0.0, jumpSpeed = 0.0, airForce = 0.0, airJumpProfile = {jumpHoldTime = 0.0}})
				if (status.stat("damageAbsorption") ~= 0) then
					local damageTaken = (humansoul_maxabsorption - status.stat("damageAbsorption"))
					humansoul_shield = humansoul_shield - (damageTaken * humansoul_shieldmultiplier)
				end
				status.setResource("damageAbsorption", humansoul_maxabsorption)
				if humansoul_shield > 0 then humansoul_shield = humansoul_shield - 1 end
			else
				status.setResource("damageAbsorption", 0)
				if humansoul_shield < humansoul_maxshield then humansoul_shield = humansoul_shield + 1 end
			end
		-- This covers grounded dodging maneuvers
		elseif not humansoul_isairdodging then
			mcontroller.clearControls()
			mcontroller.controlParameters({runSpeed = 0.0, walkSpeed = 0.0, jumpSpeed = 0.0, airForce = 0.0, airJumpProfile = {jumpHoldTime = 0.0}})
			humansoul_preventautoroll = true
			local maxframes = 0
			if ((humansoul_rolldirection == "left") or (humansoul_rolldirection == "right"))then
				maxframes = humansoul_rollmaxframes
			else
				maxframes = humansoul_spotmaxframes
			end
			if humansoul_onlyrollonce then
				humansoul_onlyrollonce = false
				tech.setToolUsageSuppressed(true)
				animator.playSound("shieldairdodge", 0)
				animator.setAnimationState("shieldState", "off")
				status.addEphemeralEffect("srm_iframes", maxframes/60)
			end
			humansoul_rollframe = humansoul_rollframe + 1
			if humansoul_rollframe > maxframes then
				humansoul_rollframe = 0
				humansoul_isrolling = false
				humansoul_onlyactivateonce = true
				humansoul_onlyrollonce = true
				humansoul_shield = humansoul_shield - (maxframes*2)
			end
			if (humansoul_rolldirection == "left") then
				mcontroller.setXVelocity(-1*humansoul_rolldistance)
				mcontroller.setRotation((math.pi*2) * (humansoul_rollframe/humansoul_rollmaxframes))
			elseif (humansoul_rolldirection == "right") then
				mcontroller.setXVelocity(humansoul_rolldistance)
				mcontroller.setRotation((math.pi*2) * (-1 * (humansoul_rollframe/humansoul_rollmaxframes)))
			else
				local number = math.floor((humansoul_rollframe/5)+0.5)
				local face = 0
				if math.fmod(number,2) == 1 then face = -1 else face = 1 end
				mcontroller.controlCrouch()
				mcontroller.controlFace(face)
			end
		-- This covers aerial dodging maneuvers
		else
			mcontroller.clearControls()
			mcontroller.controlParameters({runSpeed = 0.0, walkSpeed = 0.0, jumpSpeed = 0.0, airForce = 0.0, airJumpProfile = {jumpHoldTime = 0.0}})
			if humansoul_onlyaironce then
				humansoul_onlyaironce = false
				humansoul_specialfall = true
				animator.playSound("shieldairdodge", 0)
				tech.setToolUsageSuppressed(true)
				status.setResource("damageAbsorption", 0)
				animator.setAnimationState("shieldState", "off")
				status.addEphemeralEffect("srm_iframes", humansoul_airmaxframes/60)
			end
			
			local x = 0
			local y = 0
			local angle = 0
			local isSpotAirDodge = false
			if humansoul_airdodgehorizontal == "left" then x = -1 end
			if humansoul_airdodgehorizontal == "right" then x = 1 end
			if humansoul_airdodgevertical == "down" then y = -1 end
			if humansoul_airdodgevertical == "up" then y = 1 end
			if x==0 and y==0 then
				isSpotAirDodge = true
			else
				angle = vec2.angle({x,y})
			end
			local vector = {humansoul_airdistance,0}
			vector = vec2.rotate(vector, angle)
			vector = vec2.mul(vector, ((1-(humansoul_airframe/humansoul_airmaxframes))*2))
			
			humansoul_airframe = humansoul_airframe + 1
			if humansoul_airframe > humansoul_airmaxframes then
				humansoul_preventautoroll = true
				humansoul_airframe = 0
				humansoul_onlyaironce = true
				humansoul_isairdodging = false
			end
			
			if mcontroller.onGround() then
				status.removeEphemeralEffect("srm_iframes")
				mcontroller.setVelocity({(vector[1]*3),15})
				humansoul_preventautoroll = true
				humansoul_airframe = 0
				humansoul_onlyaironce = true
				humansoul_isairdodging = false
			else
				if isSpotAirDodge then
					mcontroller.setVelocity({0,0})
				else
					mcontroller.setVelocity(vector)
				end
			end
		end
	else
		mcontroller.clearControls()
		mcontroller.controlParameters({runSpeed = 0.0, walkSpeed = 0.0, jumpSpeed = 0.0, airForce = 0.0, airJumpProfile = {jumpHoldTime = 0.0}})
		if humansoul_onlybreakonce then
			humansoul_onlybreakonce = false
			humansoul_onlydizzyonce = true
			tech.setToolUsageSuppressed(true)
			status.setResource("damageAbsorption", 0)
			animator.setAnimationState("shieldState", "off")
			animator.playSound("shieldbreak", 0)
			humansoul_brokentimer = humansoul_brokentimermax
			humansoul_dizzytimer = humansoul_minimumdizzytimer
			mcontroller.translate({0,2})
			mcontroller.setVelocity({0,40})
		end
		if humansoul_brokentimer <= 0 then
			tech.setToolUsageSuppressed(false)
			humansoul_shieldbroken = false
			status.removeEphemeralEffect("srm_shieldbroken")
			animator.stopAllSounds("shielddizzyloop")
			humansoul_shield = humansoul_maxshield
		elseif (mcontroller.onGround() and (humansoul_dizzytimer <= 0)) then
			if humansoul_onlydizzyonce then
				status.addEphemeralEffect("srm_shieldbroken", humansoul_brokentimermax/60)
				humansoul_onlydizzyonce = false
				animator.playSound("shielddizzy", 0)
				animator.playSound("shielddizzyloop", -1)
			end
			humansoul_brokentimer = humansoul_brokentimer - dt
		end
		humansoul_dizzytimer = humansoul_dizzytimer - dt
	end
end
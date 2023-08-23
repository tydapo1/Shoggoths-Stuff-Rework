function update_init()	
	initiated = true
	
	-- (dynamite) Delayed seconds at position 1 second ago
	maxDeltaBomb = 0.1
	deltaBomb = maxDeltaBomb
	bombParameters = {
		knockback=0,
		power=0,
		speed=0,
		piercing=true,
		timeToLive=1.0,
		damageKind="hidden",
		damageTeam={type="indiscriminate"},
		actionOnReap={{action="config",file="/projectiles/explosions/regularexplosion2/srm_trialexplosion.config"}}
	}
	
	-- The message
	srm_message = { 
		important = false,
		unique = false,
		type = "generic",
		textSpeed = 30,
		portraitFrames = 2,
		persistTime = 1,
		messageId = sb.makeUuid(),		
		chatterSound = "/sfx/interface/aichatter3_loop.ogg",
	
		portraitImage = "/ai/portraits/gibberingbladder.png:talk.<frame>",
		senderName = "Crypt Helper",
		text = "You have been afflicted by the curse of dynamite. The position you were a second ago will explode."
	}
	srm_message.messageId = sb.makeUuid()
	world.sendEntityMessage(
		entity.id(),
		"queueRadioMessage",
		srm_message
	)
end

local oldUpdate = update_ready
update_ready = function(dt)
	if oldUpdate then oldUpdate(dt) end
	if not initiated then update_init() end
	
	if (deltaBomb >= maxDeltaBomb) then
		deltaBomb = 0
		world.spawnProjectile("invisibleprojectile", world.entityPosition(entity.id()), entity.id(), {0,0}, false, bombParameters)
	end
	deltaBomb = deltaBomb + dt
end
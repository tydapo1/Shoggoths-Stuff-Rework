function update_init()	
	initiated = true
	
	-- (glass) 1 hit KO
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
		text = "You have been afflicted by the curse of glass. Any damage will result in death."
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
	
	status.setResource("health", 1)
end
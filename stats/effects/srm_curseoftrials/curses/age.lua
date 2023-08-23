function update_init()	
	initiated = true
	
	-- (age) All stats down
	ageStatsMultiplier = 0.7
	effect.addStatModifierGroup({{
		stat = "maxEnergy", effectiveMultiplier = ageStatsMultiplier
	}})
	effect.addStatModifierGroup({{
		stat = "maxHealth", effectiveMultiplier = ageStatsMultiplier
	}})
	effect.addStatModifierGroup({{
		stat = "powerMultiplier", effectiveMultiplier = ageStatsMultiplier
	}})
	effect.addStatModifierGroup({{
		stat = "protection", effectiveMultiplier = ageStatsMultiplier
	}})
	effect.addStatModifierGroup({{
		stat = "grit", effectiveMultiplier = ageStatsMultiplier
	}})
	
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
		text = "You have been afflicted by the curse of age. You are much weaker than you remember being."
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
	
	mcontroller.controlModifiers({
		speedModifier = 0.7
	})
end
function update_init()	
	initiated = true
	
	-- (chaos) Random debuffs
	maxTimeStatus = 5
	timeStatus = maxTimeStatus
	debuffPool = { 	
		"burning", "l6doomed", "frostsnare", "glueslow", 
		"levitation", "nude", "electrified", "mudslow", 
		"overload", "paralysis", "slimeslow", "stun", 
		"weakpoison", "wet", "vulnerability", "timefreeze",
		"bouncy", "tarslow", "crash", "erchiussickness" 
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
		text = "You have been afflicted by the curse of chaos. You will be afflicted with random negative statuses each " .. maxTimeStatus .. " seconds."
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
	
	timeStatus = timeStatus + dt
	if (timeStatus >= maxTimeStatus) then
		timeStatus = 0
		status.addEphemeralEffect(debuffPool[math.random(1,#debuffPool)], maxTimeStatus)
	end
end
function update_init()	
	initiated = true
	
	-- (timetrial) Timer till death
	maxTimerValue = 300
	timerValue = maxTimerValue
	
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
		text = "You have been afflicted by the curse of time. You have " .. maxTimerValue .. " seconds to leave the dungeon or else you will perish."
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
	
	local colorValue = ((maxTimerValue - timerValue) / maxTimerValue)
	if timerValue > 0 then
		if (timerValue > 10 * (60/updateRatio)) then
			effect.setParentDirectives("fade=FF0000=" .. colorValue)
		end
		if (timerValue <= 10 * (60/updateRatio)) then
			if ((math.fmod(timerValue,10) >= 0) and (math.fmod(timerValue,10) <= 4)) then
				effect.setParentDirectives("fade=FF0000=1.0")
			else
			effect.setParentDirectives("fade=FFA500=1.0")
		end
		end
		timerValue = timerValue - dt
	else
		status.setResource("health", 0)
		effect.setParentDirectives("fade=000000=1.0")
	end
end
function update_init()	
	initiated = true
	
	-- (sloth) No energy moving too much slows down the player
	maxTime = 5
	timeTillFullyStopped = maxTime
	maxSpeed = 1.2
	
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
		text = "You have been afflicted by the curse of sloth. You cannot have energy, and running too much is tiresome."
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
	
	status.setResource("energy", 0)
	if (mcontroller.running() or (not (mcontroller.onGround()))) then
		if (timeTillFullyStopped>0) then timeTillFullyStopped = timeTillFullyStopped - dt end
	else
		if (timeTillFullyStopped<maxTime) then timeTillFullyStopped = timeTillFullyStopped + dt*2 end
	end
	mcontroller.controlModifiers({
		speedModifier = maxSpeed * (timeTillFullyStopped / maxTime)
	})
end
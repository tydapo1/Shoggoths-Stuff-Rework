function update_init()	
	initiated = true
	
	-- (lava) The floor hurts
	world.spawnItem("srm_trialhook", world.entityPosition(entity.id()))
	
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
		text = "You have been afflicted by the curse of lava. Touching the ground will be quite painful."
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
	
	if mcontroller.onGround() then
		status.applySelfDamageRequest({
			damageType = "IgnoresDef",
			damage = 1,
			damageSourceKind = "heat",
			sourceEntityId = entity.id()
		})
	end
end
function update_init()	
	initiated = true
	
	-- (wrath) Lifesteal but lose health over time
	self.inflictedDamage = damageListener("inflictedDamage", inflictedDamageCallback)
	timer = 0
	
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
		text = "You have been afflicted by the curse of wrath. You steal life from your foes, but your health drains over time."
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
	
	timer = timer + dt
	if timer>=1 then timer = 0 end
	if timer == 0 then
		status.applySelfDamageRequest({
			damageType = "IgnoresDef",
			damage = 3,
			damageSourceKind = "bite",
			sourceEntityId = entity.id()
		})
	end
	self.inflictedDamage:update()
end

function inflictedDamageCallback(notifications)
	for _,notification in ipairs(notifications) do
		if world.entityExists(notification.targetEntityId) then
			local entityType = world.entityType(notification.targetEntityId)
			if entityType == "npc" or entityType == "monster" or entityType == "player" then
				local multiplier = 0.0;
				if notification.hitType == "Kill" then
					multiplier = 1.00
				elseif notification.hitType == "Hit" then
					multiplier = 0.05
				elseif notification.hitType == "StrongHit" then
					multiplier = 0.10
				else
					return
				end
				local lifesteal = status.resourceMax("health")*multiplier
				--sb.logInfo(string.format("Enemy HP: %0.2f, Lifesteal: %0.2f (%0.2f percent)",entityHealth[2],lifesteal,multiplier))
				status.modifyResource("health", lifesteal)
			end
		else
			--sb.logInfo("Skipped event recording for nonexistent entity %s", notification.targetEntityId)
		end
	end
end
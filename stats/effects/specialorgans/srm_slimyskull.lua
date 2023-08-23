require "/scripts/status.lua"

function init()
	self.inflictedDamage = damageListener("inflictedDamage", inflictedDamageCallback)
end

function update(dt)
	self.inflictedDamage:update()
end

function uninit()
end

function inflictedDamageCallback(notifications)
	for _,notification in ipairs(notifications) do
		if world.entityExists(notification.targetEntityId) then
			local entityType = world.entityType(notification.targetEntityId)
			if entityType == "npc" or entityType == "monster" or entityType == "player" then
				if notification.hitType == "Kill" then
					status.giveResource("energy", status.resourceMax("energy"))
					status.setResourceLocked("energy", false)
					status.giveResource("energy", status.resourceMax("energy"))
					animator.playSound("trigger", 0)
				else
					return
				end
			end
		else
			--sb.logInfo("Skipped event recording for nonexistent entity %s", notification.targetEntityId)
		end
	end
end


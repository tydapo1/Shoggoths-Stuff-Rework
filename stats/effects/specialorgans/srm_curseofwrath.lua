require "/scripts/status.lua"

function init()
	script.setUpdateDelta(1)
	self.inflictedDamage = damageListener("inflictedDamage", inflictedDamageCallback)
	parameters = config.getParameter("projectileParameters", {})
	combo = 0
	comboMaxDmgMultiplier = 2.0
	comboCap = 50
	comboTimerReset = 3
	comboTimer = comboTimerReset
	
	powerStatGroup = effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = 1.0}})
end

function update(dt)
	self.inflictedDamage:update()
	effect.setStatModifierGroup(powerStatGroup, {{ stat = "powerMultiplier", effectiveMultiplier = (((comboMaxDmgMultiplier-1) * (combo/comboCap)) + 1) }})
	if combo > 0 then
		if comboTimer >= comboTimerReset then
			combo = 0
			comboTimer = 0
		end
		comboTimer = comboTimer + dt
	end
	local fade = 0.8 * (combo/comboCap)
	effect.setParentDirectives("fade=FF0000=" .. fade)
end

function uninit()
end

function inflictedDamageCallback(notifications)
	for _,notification in ipairs(notifications) do
		if world.entityExists(notification.targetEntityId) then
			local entityType = world.entityType(notification.targetEntityId)
			if entityType == "npc" or entityType == "monster" or entityType == "player" then
				if notification.hitType == "Kill" or notification.hitType == "StrongHit" or notification.hitType == "Hit" then
					if combo < comboCap then
						combo = combo + 1
						local position = entity.position()
						position[2] = position[2] + 2
						parameters.actionOnReap[1].specification.text = "^shadow;" .. combo
						world.spawnProjectile("invisibleprojectile", position, entity.id(), {0,0}, false, parameters)
					end
					comboTimer = 0
				else
					return
				end
			end
		else
			--sb.logInfo("Skipped event recording for nonexistent entity %s", notification.targetEntityId)
		end
	end
end
function init()
	effect.addStatModifierGroup({{stat = "poisonResistance", amount = 1.00}, {stat = "poisonStatusImmunity", amount = 0}})
	effect.addStatModifierGroup({{stat = "electricResistance", amount = -0.50}, {stat = "electricStatusImmunity", amount = 0}})

	script.setUpdateDelta(1)
end

function update(dt)
	effects = status.activeUniqueStatusEffectSummary()
	if (#effects > 0) then
		for i=1, #effects do
			if (effects[i][1] == "weakpoison") then
				status.modifyResource("health", 25)
				status.removeEphemeralEffect("weakpoison")
			end
		end		 
	end
end

function uninit()
	
end

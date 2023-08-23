function init()
	effect.addStatModifierGroup({{stat = "electricResistance", amount = 1.00}, {stat = "electricStatusImmunity", amount = 0}})
	effect.addStatModifierGroup({{stat = "poisonResistance", amount = -0.50}, {stat = "poisonStatusImmunity", amount = 0}})

	script.setUpdateDelta(1)
end

function update(dt)
	effects = status.activeUniqueStatusEffectSummary()
	if (#effects > 0) then
		for i=1, #effects do
			if (effects[i][1] == "electrified") then
				status.modifyResource("health", 25)
				status.removeEphemeralEffect("electrified")
			end
		end		 
	end
end

function uninit()
	
end

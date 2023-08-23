function init()
	effect.addStatModifierGroup({{stat = "iceResistance", amount = 1.00}, {stat = "iceStatusImmunity", amount = 0}})
	effect.addStatModifierGroup({{stat = "fireResistance", amount = -0.50}, {stat = "fireStatusImmunity", amount = 0}})

	script.setUpdateDelta(1)
end

function update(dt)
	effects = status.activeUniqueStatusEffectSummary()
	if (#effects > 0) then
		for i=1, #effects do
			if (effects[i][1] == "frostslow") then
				status.modifyResource("health", 25)
				status.removeEphemeralEffect("frostslow")
			end
		end		 
	end
end

function uninit()
	
end

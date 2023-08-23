function init()
	effect.addStatModifierGroup({{stat = "fireResistance", amount = 1.00}, {stat = "fireStatusImmunity", amount = 0}})
	effect.addStatModifierGroup({{stat = "iceResistance", amount = -0.50}, {stat = "iceStatusImmunity", amount = 0}})

	script.setUpdateDelta(1)
end

function update(dt)
	effects = status.activeUniqueStatusEffectSummary()
	if (#effects > 0) then
		for i=1, #effects do
			if (effects[i][1] == "burning") then
				status.modifyResource("health", 25)
				status.removeEphemeralEffect("burning")
			end
		end		 
	end
end

function uninit()
	
end

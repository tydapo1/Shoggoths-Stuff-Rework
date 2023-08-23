function init()
	effect.addStatModifierGroup({{stat = "electricResistance", amount = 0.25}, {stat = "electricStatusImmunity", amount = 1}})
	effect.addStatModifierGroup({{stat = "poisonResistance", amount = 0.25}, {stat = "poisonStatusImmunity", amount = 1}})
	effect.addStatModifierGroup({{stat = "iceResistance", amount = 0.25}, {stat = "iceStatusImmunity", amount = 1}})
	effect.addStatModifierGroup({{stat = "fireResistance", amount = 0.25}, {stat = "fireStatusImmunity", amount = 1}})
	effect.addStatModifierGroup({{stat = "physicalResistance", amount = -0.00}})

	script.setUpdateDelta(0)
end

function update(dt)

end

function uninit()
	
end

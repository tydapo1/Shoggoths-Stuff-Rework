function init()
	effect.addStatModifierGroup({{stat = "electricResistance", amount = -1.00}, {stat = "electricStatusImmunity", amount = 0}})
	effect.addStatModifierGroup({{stat = "poisonResistance", amount = -1.00}, {stat = "poisonStatusImmunity", amount = 0}})
	effect.addStatModifierGroup({{stat = "iceResistance", amount = -1.00}, {stat = "iceStatusImmunity", amount = 0}})
	effect.addStatModifierGroup({{stat = "fireResistance", amount = -1.00}, {stat = "fireStatusImmunity", amount = 0}})
	effect.addStatModifierGroup({{stat = "physicalResistance", amount = 1.00}})

	script.setUpdateDelta(0)
end

function update(dt)

end

function uninit()
	
end

function init()
	effect.addStatModifierGroup({{stat = "electricResistance", amount = -0.00}, {stat = "electricStatusImmunity", amount = 0}})
	effect.addStatModifierGroup({{stat = "poisonResistance", amount = -0.00}, {stat = "poisonStatusImmunity", amount = 0}})
	effect.addStatModifierGroup({{stat = "iceResistance", amount = -0.00}, {stat = "iceStatusImmunity", amount = 0}})
	effect.addStatModifierGroup({{stat = "fireResistance", amount = -0.00}, {stat = "fireStatusImmunity", amount = 0}})
	effect.addStatModifierGroup({{stat = "physicalResistance", amount = 0.25}})

	script.setUpdateDelta(0)
end

function update(dt)

end

function uninit()
	
end

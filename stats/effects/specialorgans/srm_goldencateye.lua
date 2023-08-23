function init()
	effect.addStatModifierGroup({{stat = "fireResistance", amount = 0.50}, {stat = "fireStatusImmunity", amount = 1}})
	effect.addStatModifierGroup({{stat = "iceResistance", amount = -0.25}, {stat = "iceStatusImmunity", amount = 0}})

	script.setUpdateDelta(0)
end

function update(dt)

end

function uninit()
	
end

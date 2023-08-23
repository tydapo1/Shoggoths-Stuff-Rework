function init()
	effect.addStatModifierGroup({{stat = "electricResistance", amount = 0.25}, {stat = "electricStatusImmunity", amount = 1}})	 
	effect.addStatModifierGroup({{stat = "poisonResistance", amount = -0.00}, {stat = "poisonStatusImmunity", amount = 0}})

	script.setUpdateDelta(0)
end

function update(dt)

end

function uninit()
	
end

function init()
	 script.setUpdateDelta(60)
	 powerStatGroup = effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = 1.00}})
	 damageMultiplier = 1.00
end

function update(dt)
	 if math.random(20) == 20 then
		 damageMultiplier = 10.0
	 else
		 damageMultiplier = 1.00
	 end
	 effect.setStatModifierGroup(powerStatGroup, {{stat = "powerMultiplier", effectiveMultiplier = damageMultiplier}})	 
end

function uninit()
	
end

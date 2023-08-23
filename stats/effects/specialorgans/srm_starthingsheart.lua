function init()
	timer = 0
	damageMultiplier = 0.5
	powerStatGroup = effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = damageMultiplier}})
	script.setUpdateDelta(1)
end

function update(dt)
	timer = timer + dt
	if timer >= 3600 then timer = 0 end
	
	if math.fmod(timer, 40) == 0 then animator.playSound("beat", 0) end
	if (math.fmod(timer, 0.666666666) >= 0 and math.fmod(timer, 0.666666666) < 8) then damageMultiplier = 2.5 else damageMultiplier = 0.5 end
	effect.setStatModifierGroup(powerStatGroup, {{stat = "powerMultiplier", effectiveMultiplier = damageMultiplier}})
end

function uninit()
	
end
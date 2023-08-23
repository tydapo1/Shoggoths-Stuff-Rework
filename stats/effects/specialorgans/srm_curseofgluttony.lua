function init()
	script.setUpdateDelta(5)
	
	digestionRate = 60
	digestionTimer = digestionRate
	satedStacks = 0
	baseHealingRate = 1 / 120
	powerStatGroup = effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = 1.00}})
end

function update(dt)
	if hasStatus("wellfed") then
		satedStacks = satedStacks + 1
		status.removeEphemeralEffect("wellfed")
		animator.playSound("gulp")
	end
	
	if satedStacks > 0 then
		if digestionTimer <= 0 then
			digestionTimer = digestionRate
			satedStacks = satedStacks - 1
		else
			digestionTimer = digestionTimer - dt
		end
	else
		digestionTimer = digestionRate
	end
	
	local multiplier = (satedStacks * 0.35) + 1
	mcontroller.controlModifiers({ speedModifier = (multiplier^-1) })
	status.modifyResourcePercentage("health", baseHealingRate * dt * (multiplier-1))
	effect.setStatModifierGroup(powerStatGroup, {{ stat = "powerMultiplier", effectiveMultiplier = multiplier }})	 
end

function uninit()
end

--finds status, returns true if it is found
function hasStatus(theStatusInQuestion)
	effects = status.activeUniqueStatusEffectSummary()
	if (#effects > 0) then
		for i=1, #effects do
			if (effects[i][1] == theStatusInQuestion) then
				return true
			end
		end		 
	end
	return false
end
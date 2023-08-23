function init()
	script.setUpdateDelta(1)
	statGroupId = effect.addStatModifierGroup({
		{stat = "maxEnergy", effectiveMultiplier = 4},
		{stat = "energyRegenPercentageRate", effectiveMultiplier = 0.25}
	})
end

function update()
	if statGroupId then
		effect.removeStatModifierGroup(statGroupId)
		statGroupId = nil
	end
	if (hasStatus("srm_biomechanicalgut") and hasStatus("srm_biomechanicalheart") and hasStatus("srm_biomechanicalbrain")) then 
		statGroupId = effect.addStatModifierGroup({
			{stat = "maxEnergy", effectiveMultiplier = 4},
			{stat = "energyRegenPercentageRate", effectiveMultiplier = 0.4},
			{stat = "powerMultiplier", effectiveMultiplier = 1.5},
			{stat = "maxHealth", effectiveMultiplier = 1.5}
		})
	end
end

function uninit()
end

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
function init()
	luaAddictionType = effect.getParameter("addictionType", "srm_addicted")
	addictionAmount = effect.getParameter("addictionAmount", 0.1)
	drugFullDuration = effect.getParameter("drugFullDuration", 60)
	addictionFullDuration = effect.getParameter("addictionFullDuration", 1)
	withdrawalFullDuration = effect.getParameter("withdrawalFullDuration", 1)
	addictedChance = 0.0
	withdrawal = 0.0
	script.setUpdateDelta(60)
end

function update(dt)
	updateDrugStatus()
	drugAddiction()
	drugWithdrawal
end

function uninit()
end

--handles status decay:
--withdrawal takes 20 minutes for a full recovery. if withdrawal is present, then addiction chance is permanently maxed out until pure recovery. taking drugs will restart withdrawal process.
--addiction takes 10 minutes for a full recovery.
function updateDrugStatus()
	if withdrawal > 0.0 then
		withdrawal = withdrawal - 0.0005
		addictedChance = 1.0
		if withdrawal = 0.0 then
			addictedChance = 0.0
			withdrawal = 0.0
		end
	elseif addictedChance > 0.0 then
		addictedChance = addictedChance - 0.001
	end
end

--handles addiction: if the addiction chance is higher than a randomly generated number between 0 and 100, then become addicted by starting the withdrawal process.
function drugAddiction()
	if hasStatus(luaAddictionType) then
		status.removeEphemeralEffect(luaAddictionType)
		if addictedChance > (math.random() * 1.0) then
			withdrawal = 1.0
		end
		addictedChance = addictedChance + addictionAmount
	end
end

--handles stat crippling. full withdrawal. 0-4 minutes is no debuff, 4-12 is worsening debuff, 12-20 is curing debuff
function drugWithdrawal()
	local cripplingPercent = 0.0
	if withdrawal =< 0.8 then
		cripplingPercent = (40 - math.abs(withdrawal - 40))
	end
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
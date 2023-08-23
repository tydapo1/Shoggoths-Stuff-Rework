function init()
end

function update(dt)
	if hasStatus("srm_corn") then
		status.removeEphemeralEffect("srm_corn")
		status.addEphemeralEffect("srm_cornallergy", 10)
	end
	if hasStatus("srm_cornallergy") then
		status.removeEphemeralEffect("wellfed")
	end
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
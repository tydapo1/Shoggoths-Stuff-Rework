require "/scripts/vec2.lua"

function init()
	-- Generic script data
	script.setUpdateDelta(1)
	defaultVec = {0,0}
	defaultVec[1] = 0
	defaultVec[2] = 0
	organTechArray = config.getParameter("techScripts")
	for k,v in pairs(organTechArray) do
		local requ = "/tech/srm_organtech/techs/" .. v
		require(requ)
	end
end

-- This solely calls the right functions at the right time, mister Freeman
function update(args)
	player = math.srm_player
	-- The requires patch the update to add the right function calls
end

function uninit()
	-- The requires patch the update to add the right function calls
end

-- Utility functions

-- Finds a status, returns true if it is found
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
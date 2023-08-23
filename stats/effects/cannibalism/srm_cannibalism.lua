function init()
	raceConfig = root.assetJson("/config/srm_racial.config")
	local livingType = world.entitySpecies(entity.id())
	
	local effectTime = effect.duration()
	if ( not (entity.entityType() == "npc" or entity.entityType() == "player" ) ) then
	  livingType = "monster"
    end
	
	if (livingType == nil) then livingType = "default" end
	if (raceConfig[livingType] == nil) then livingType = "default" end
	
	if (raceConfig[livingType].isCannibal == "true") then
		--yes
		status.addEphemeralEffect("srm_cannibalism_rocks", effectTime)
	else
		--no
		status.addEphemeralEffect("srm_cannibalism_sucks", effectTime)
	end
	effect.expire()
end

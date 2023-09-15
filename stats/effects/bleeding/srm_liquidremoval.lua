function init()
	script.setUpdateDelta(config.getParameter("procRate", 60))
	animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
	animator.setParticleEmitterActive("drips", true)
	racialTables = root.assetJson("/config/srm_racial.config")
end

function update(dt)
	if status.resourcePercentage("health") > (config.getParameter("bleedThreshold", 0)/100) then
		if ( not ( (world.type() == "unknown") and (not world.terrestrial()) ) ) then
			spawnBlood()
		end
	end
end

function spawnBlood()
	world.spawnItem(itemToGive(),entity.position(),1) 
	status.modifyResource("health",-1)
end

function itemToGive()
	local livingType = world.entitySpecies(entity.id())
	if ( not (entity.entityType() == "npc" or entity.entityType() == "player" ) ) then
		livingType = "monster"
	end
	if (livingType == nil) then livingType = "default" end
	if (racialTables[livingType] == nil) then livingType = "default" end
	return racialTables[livingType].bloodType or racialTables.default.bloodType
end

function uninit()
    
end

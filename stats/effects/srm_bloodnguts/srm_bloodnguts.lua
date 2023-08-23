function init()
	droptables = root.assetJson("/config/srm_racial.config")
	spawnStuff()
	if ((status.resource("health") / status.resourceMax("health")) <= 0.33) then
		deathStuff()
		status.setResource("health", 0)
		status.removeEphemeralEffect("srm_bloodnguts")
	end
	status.removeEphemeralEffect("srm_bloodnguts")
end

function deathStuff()
	world.spawnTreasure(entity.position(), "bleedCellsDeath", 1)
	world.spawnTreasure(entity.position(), "bleedOrgans", 1)
	for i=1,10 do spawnStuff() end
end

function spawnStuff()
	-- blood
	world.spawnProjectile("srm_fleshchunk", mcontroller.position(), entity.id(), generateDirection(), false, { power = 0, actionOnReap = {{ action = "item", name = itemToGive() }}})
	-- cells
	if (math.random(1,100) <= 33) then
		world.spawnProjectile("srm_cellprojectile", mcontroller.position(), entity.id(), generateDirection(), false, { power = 0, bounces = 0 })
	end
end

function itemToGive()
	local livingType = world.entitySpecies(entity.id())
	if ( not (entity.entityType() == "npc" or entity.entityType() == "player" ) ) then
		livingType = "monster"
	elseif (livingType == nil) then 
		livingType = "default" 
	elseif (droptables[livingType] == nil) then 
		livingType = "default"
	end
	return droptables[livingType].bloodType or droptables.default.bloodType
end

function generateDirection()
	local quadrant = math.random(1, 2)
	local directionX = math.random()*5
	local directionY = math.random()*5
	local direction = {0,0}
	
	if quadrant == 1 then 
		directionX = directionX * 1 
	else
		directionX = directionX * -1 
	end
	direction = {directionX,directionY}
	return direction
end

function uninit()
		
end
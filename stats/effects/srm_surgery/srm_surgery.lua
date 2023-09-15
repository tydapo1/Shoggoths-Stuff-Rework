function init()
	if (status.resourceMax("health") >= 10 and status.resource("health") <= 0) then
		world.spawnTreasure(entity.position(), "bleedOrgans", 1)
		status.removeEphemeralEffect("srm_surgery")
	end
	status.removeEphemeralEffect("srm_surgery")
end
function init()
	if ((status.resource("health") / status.resourceMax("health")) <= 0.25) then
		world.spawnTreasure(entity.position(), "bleedOrgans", 1)
		status.setResource("health", 0)
		status.removeEphemeralEffect("srm_surgery")
	end
	status.removeEphemeralEffect("srm_surgery")
end
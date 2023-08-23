require "/scripts/util.lua"
require "/scripts/companions/util.lua"
require "/scripts/messageutil.lua"

function update(dt)
	--mcontroller.setVelocity(world.distance(config.getParameter("targetPosition", {0,0}), mcontroller.position()))
	if math.abs(world.magnitude(config.getParameter("targetPosition", {0,0}), mcontroller.position())) < 2 then
		self.terrainHit = true
	end
end

function hit(entityId)
	if self.foeHit then return end
	if world.entityType(entityId) then
		self.foeHit = true
	end
end

function shouldDestroy()
	return (
		(projectile.timeToLive() <= 0) or 
		(self.foeHit) or 
		(self.terrainHit and world.tileIsOccupied(config.getParameter("targetPosition", {0,0}), false)) or 
		(self.terrainHit and world.tileIsOccupied(mcontroller.position(), false))
	)
end

function destroy()
	if not self.foeHit then
		if self.terrainHit and world.tileIsOccupied(config.getParameter("targetPosition", {0,0}), false) then
			world.spawnStagehand(mcontroller.position(), "srm_torcher", {pos=config.getParameter("targetPosition", {0,0})})
		elseif self.terrainHit and world.tileIsOccupied(mcontroller.position(), false) then
			world.spawnStagehand(mcontroller.position(), "srm_torcher", {pos=mcontroller.position()})
		else
			world.spawnStagehand(mcontroller.position(), "srm_torcher", {pos=mcontroller.position()})
		end			
	end
end
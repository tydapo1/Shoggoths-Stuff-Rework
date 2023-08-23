function init()
	script.setUpdateDelta(300)
end

function update(dt)
	world.spawnProjectile("smallmeteor", mcontroller.position(), entity.id(), {0, 10}, true)
end

function uninit()
	
end

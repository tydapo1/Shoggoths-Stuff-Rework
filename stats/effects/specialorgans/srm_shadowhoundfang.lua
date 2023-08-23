function init()
	script.setUpdateDelta(240)
end

function update(dt)
	local damageConfig = {
		power = 0,
		speed = 0,
		physics = "default"
	}
	world.spawnProjectile("srm_shadowhoundfangwolf", mcontroller.position(), entity.id(), {0, 0}, true, damageConfig)
end

function uninit()
	
end

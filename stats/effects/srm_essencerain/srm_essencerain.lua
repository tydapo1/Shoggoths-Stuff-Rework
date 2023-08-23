function init()
	script.setUpdateDelta(1)
	animator.playSound("odetojoy")
	timerMax = 25
	timer = 0
end

function update(dt)
	local position = {}
	position[1] = world.entityPosition(entity.id())[1]
	position[2] = world.entityPosition(entity.id())[2] + 30
	world.spawnItem("essence", position, 1, {}, {((math.random()-0.5)*50),0})
	world.spawnItem("essence", position, 1, {}, {((math.random()-0.5)*50),0})
	timer = timer + dt
	if timer >= timerMax then effect.expire() end
end

function uninit()
	
end

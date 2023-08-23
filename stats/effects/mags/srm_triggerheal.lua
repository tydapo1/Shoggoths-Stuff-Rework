function init()
	script.setUpdateDelta(1)
	animator.playSound("triggerSound", 0)
	animator.burstParticleEmitter("resta")
end

function update(dt)
	status.modifyResource("health", (status.resourceMax("health")) * dt)
end

function uninit()
	
end

function init()
	animator.setParticleEmitterOffsetRegion("healing", mcontroller.boundBox())
	animator.setParticleEmitterEmissionRate("healing", config.getParameter("emissionRate", 3))
	animator.setParticleEmitterActive("healing", true)

	script.setUpdateDelta(5)

	self.healingRate = ((config.getParameter("healPercent", 30) / effect.duration()) * (status.resourceMax("health")/100))
end

function update(dt)
	status.modifyResource("health", self.healingRate * dt)
end

function uninit()
	
end

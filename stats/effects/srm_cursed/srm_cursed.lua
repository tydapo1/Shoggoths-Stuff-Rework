function init()
	animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
	animator.setParticleEmitterActive("drips", true)
	effect.addStatModifierGroup({
		{stat = "protection", amount = config.getParameter("protection", -413413413)}
	})
	script.setUpdateDelta(1)
end

function update(dt)
	status.setResource("health", 1)
end

function uninit()

end

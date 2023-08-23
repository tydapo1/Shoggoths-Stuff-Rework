function init()
	animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
	animator.setParticleEmitterActive("drips", true)
	effect.setParentDirectives("fade=41446f=0.3")
	effect.addStatModifierGroup({
		{stat = "jumpModifier", amount = -0.20}
	})
end

function update(dt)
	mcontroller.controlModifiers({
		groundMovementModifier = 0.3,
		speedModifier = 0.3,
		airJumpModifier = 0.3
	})
end

function uninit()

end

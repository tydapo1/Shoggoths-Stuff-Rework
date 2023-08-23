function init()
	animator.setParticleEmitterOffsetRegion("drips", mcontroller.boundBox())
	animator.setParticleEmitterActive("drips", true)
	effect.setParentDirectives("fade=a1ab72=0.4")
	effect.addStatModifierGroup({
		{stat = "jumpModifier", amount = -0.20}
	})
end

function update(dt)
	mcontroller.controlModifiers({
		groundMovementModifier = 0.3,
		speedModifier = 0.5,
		airJumpModifier = 0.4
	})
end

function uninit()

end

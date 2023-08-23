function init()
	effect.addStatModifierGroup({{stat = "invulnerable", amount = 1}})
	animator.playSound("triggerSound", -1)
	animator.setParticleEmitterActive("invincibility", true)
end

function update(dt)
end

function uninit()
	animator.stopAllSounds("triggerSound")
	animator.setParticleEmitterActive("invincibility", false)
end

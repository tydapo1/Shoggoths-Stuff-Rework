function init()
	effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = 1.5}})
	effect.addStatModifierGroup({{stat = "maxHealth", effectiveMultiplier = 1.5}})
	animator.playSound("triggerSound", 0)
	animator.playSound("triggerSound2", 0)
	script.setUpdateDelta(90)
end

function update(dt)
	animator.playSound("triggerLoopSound", 0)
	animator.playSound("triggerLoopSound2", 0)
	animator.burstParticleEmitter("shifta")
	animator.burstParticleEmitter("shifta2")
	animator.burstParticleEmitter("deband")
end

function uninit()
	
end

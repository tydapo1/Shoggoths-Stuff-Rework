function init()
	animator.setParticleEmitterActive("sparks", true)
end

function update(dt)
	effect.setParentDirectives("fade=FF0000=" .. math.fmod(effect.duration(),1))
end

function uninit()
end

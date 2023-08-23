function init()
	script.setUpdateDelta(12)
	powerStatGroup = effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = 1.00}})
	damageMultiplier = 1.0
	storedHealth = 0
	animator.setParticleEmitterOffsetRegion("embers", mcontroller.boundBox())
end

function update(dt)
	if status.resource("health") > (status.resourceMax("health")/2) then
		local eatHP = status.resource("health") - (status.resourceMax("health")/2)
		status.consumeResource("health", eatHP)
		storedHealth = storedHealth + eatHP
	end
	if storedHealth > 0 then
		storedHealth = storedHealth - 1
		damageMultiplier = 2.0
		animator.setParticleEmitterActive("embers", true)
		animator.setLightActive("bloodglow", true)
	else
		damageMultiplier = 1.0
		animator.setParticleEmitterActive("embers", false)
		animator.setLightActive("bloodglow", false)
	end
	 
	effect.setStatModifierGroup(powerStatGroup, {{stat = "powerMultiplier", effectiveMultiplier = damageMultiplier}})	 
end

function uninit()
	
end

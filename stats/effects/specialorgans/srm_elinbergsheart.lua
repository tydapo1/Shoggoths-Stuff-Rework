function init()
	script.setUpdateDelta(5)
	powerStatGroup = effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = 1.00}})
	timerValue = 0
end

function update(dt)
	if ( ( mcontroller.xVelocity() < 5 ) and ( mcontroller.xVelocity() > -5 ) and ( mcontroller.yVelocity() < 5 ) and ( mcontroller.yVelocity() > -5 ) ) then 
		timerValue = timerValue + dt
	else
		timerValue = 0
	end
	 
	if timerValue < 1 then
		stages(1.00, false, false, false, false)
	elseif ( timerValue >= 1 and timerValue < 2 ) then
		stages(1.25, true, false, false, false)
	elseif ( timerValue >= 2 and timerValue < 3 ) then
		stages(1.50, false, true, false, false)
	elseif ( timerValue >= 3 and timerValue < 4 ) then
		stages(1.75, false, false, true, false)
	elseif timerValue >= 4 then
		stages(2.00, false, false, false, true)
	end
	 
	if timerValue == 1 then animator.playSound("stage0") end
	if timerValue == 2 then animator.playSound("stage1") end
	if timerValue == 3 then animator.playSound("stage2") end
	if timerValue == 4 then animator.playSound("stage3") end	 
end

function stages(damageMultiplier, enabled0, enabled1, enabled2, enabled3)
	effect.setStatModifierGroup(powerStatGroup, {{stat = "powerMultiplier", effectiveMultiplier = damageMultiplier}})
	animator.setParticleEmitterOffsetRegion("stage0", mcontroller.boundBox())
	animator.setParticleEmitterOffsetRegion("stage1", mcontroller.boundBox())
	animator.setParticleEmitterOffsetRegion("stage2", mcontroller.boundBox())
	animator.setParticleEmitterOffsetRegion("stage3", mcontroller.boundBox())
	animator.setParticleEmitterActive("stage0", enabled0)
	animator.setParticleEmitterActive("stage1", enabled1)
	animator.setParticleEmitterActive("stage2", enabled2)
	animator.setParticleEmitterActive("stage3", enabled3)
end

function uninit()
	
end

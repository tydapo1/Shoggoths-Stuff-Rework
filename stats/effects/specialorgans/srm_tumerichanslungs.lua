function init()
	script.setUpdateDelta(20)
	timerValue = 0
end

function update(dt)
	if mcontroller.crouching() then 
		timerValue = timerValue + dt
	else
		timerValue = 0
	end
	 
	if timerValue < 1 then
		stages(false, false, false)
	elseif ( timerValue >= 1 and timerValue < 2 ) then
		stages(true, false, false)
	elseif ( timerValue >= 2 and timerValue < 3 ) then
		stages(false, true, false)
	elseif ( timerValue >= 3 and timerValue < 4 ) then
		stages(false, false, true)
	elseif timerValue >= 4 then
		stages(false, false, false)
		world.spawnProjectile("srm_healauraexplosion", mcontroller.position(), entity.id(), {0, 0}, true)
	end
	 
	if timerValue == 1 then animator.playSound("stage0") end
	if timerValue == 2 then animator.playSound("stage1") end
	if timerValue == 3 then animator.playSound("stage2") end
	if timerValue == 4 then animator.playSound("stage3") end
end

function stages(enabled0, enabled1, enabled2)
	animator.setParticleEmitterOffsetRegion("stage0", mcontroller.boundBox())
	animator.setParticleEmitterOffsetRegion("stage1", mcontroller.boundBox())
	animator.setParticleEmitterOffsetRegion("stage2", mcontroller.boundBox())
	animator.setParticleEmitterActive("stage0", enabled0)
	animator.setParticleEmitterActive("stage1", enabled1)
	animator.setParticleEmitterActive("stage2", enabled2)
end

function uninit()
	
end

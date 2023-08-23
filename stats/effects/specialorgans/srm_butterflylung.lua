function init()
	script.setUpdateDelta(1)
	powerStatGroup = effect.addStatModifierGroup({{stat = "jumpModifier", amount = 0.00}})
	effect.addStatModifierGroup({{stat = "fallDamageMultiplier", effectiveMultiplier = 0.33}})
	timerValue = 0
	jumpValue = 1.00
	countdown = 0
	mercyFrames = 0.05
end

function update(dt)
	if mcontroller.crouching() then
		if ( timerValue < 1 ) then
			stages(0.00, false, false, false, false)
			jumpValue = 1.00
			countdown = 0
		elseif ( timerValue >= 1 and timerValue < 2 ) then
			stages(0.40, true, false, false, false)
			jumpValue = 1.40
			countdown = 0
		elseif ( timerValue >= 2 and timerValue < 3 ) then
			stages(0.80, false, true, false, false)
			jumpValue = 1.80
			countdown = 0
		elseif ( timerValue >= 3 and timerValue < 4 ) then
			stages(1.20, false, false, true, false)
			jumpValue = 2.20
			countdown = 0
		elseif ( timerValue >= 4 ) then
			stages(1.60, false, false, false, true)
			jumpValue = 2.60
			countdown = 0
		end
		timerValue = timerValue + dt
	end
	 
	if (mcontroller.onGround() == false) then
		countdown = 0
	end
	 
	if ((mcontroller.onGround() == true) and (mcontroller.crouching() == false)) then
		if countdown > mercyFrames then
			timerValue = 0
			stages(0.00, false, false, false, false)
			jumpValue = 1.00
		end
		countdown = countdown + dt
	end
	 
	if timerValue == 1 then animator.playSound("stage0") end
	if timerValue == 2 then animator.playSound("stage1") end
	if timerValue == 3 then animator.playSound("stage2") end
	if timerValue == 4 then animator.playSound("stage3") end	 
	 
	mcontroller.controlModifiers({airJumpModifier = jumpValue})
	mcontroller.controlModifiers({speedModifier = jumpValue})	 
	mcontroller.controlParameters({airForce = 190.00})
end

function stages(jumpMultiplier, enabled0, enabled1, enabled2, enabled3)
	effect.setStatModifierGroup(powerStatGroup, {{stat = "jumpModifier", amount = jumpMultiplier}})
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

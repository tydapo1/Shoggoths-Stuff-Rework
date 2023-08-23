function init()
	 effect.addStatModifierGroup({{stat = "fallDamageMultiplier", effectiveMultiplier = 0.33}})

	 script.setUpdateDelta(1)
	 
	 countdown = 0
	 speedMultiplier = 1.00
	 --sb.logInfo("%s",mcontroller.baseParameters())
end

function update(dt)
	 mcontroller.controlParameters({airForce = 190.00})
	 mcontroller.controlParameters({gravityMultiplier = 1.90})
	 mcontroller.controlParameters({airFriction = 0.00})
	 mcontroller.controlParameters({airJumpProfile = {autoJump = true, jumpSpeed = 38, jumpInitialPercentage = 1.45}})
	 --mcontroller.controlParameters({jumpSpeed = 38.00})
	 --mcontroller.controlParameters({jumpInitialPercentage = 1.45})
	 --mcontroller.controlParameters({autoJump = true})
	 if not mcontroller.onGround() then
		 speedMultiplier = speedMultiplier + 0.02
	 countdown = 0
	 elseif mcontroller.onGround() then
	 countdown = countdown + dt
	 end
	 
	 if ((mcontroller.xVelocity() > -13) and (mcontroller.xVelocity() < 13)) then
		 speedMultiplier = 1.00
	 end
	 
	 if countdown >= 0.1 then
		 speedMultiplier = 1.00
	 end
	 mcontroller.controlModifiers({speedModifier = speedMultiplier})
end

function uninit()
	
end

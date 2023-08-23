function init()
	effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = 1.30}})
	effect.addStatModifierGroup({{stat = "fallDamageMultiplier", effectiveMultiplier = 0.33}})

	script.setUpdateDelta(1)
end

function update(dt)
	mcontroller.controlParameters({walkSpeed = 12.00})
	mcontroller.controlParameters({runSpeed = 36.00})
	mcontroller.controlParameters({normalGroundFriction = -50.00})
	mcontroller.controlParameters({airForce = 360.00})
	mcontroller.controlParameters({airJumpProfile = {jumpHoldTime = 0.25, jumpSpeed = 32.00, jumpInitialPercentage = 1.20}})
	mcontroller.controlParameters({liquidForce = 45.00})
	mcontroller.controlParameters({groundForce = 25.00})
	mcontroller.controlParameters({gravityMultiplier = 1.75})
end

function uninit()
	
end

function init()
    script.setUpdateDelta(1)
	
	timer = 0
	energyBoost = 2*effect.duration()
	mmmOnce = true
	
	effect.addStatModifierGroup({
		{stat = "jumpModifier", amount = 0.1},
		{stat = "protection", amount = config.getParameter("protection", 20)},
		{stat = "grit", amount = config.getParameter("grit", 0.2)},
		{stat = "powerMultiplier", effectiveMultiplier = 1.1}
	})
  effect.addStatModifierGroup({
  })
end

function update(dt)
	if ((timer >= 1) and (mmmOnce)) then
		mmmOnce = false
		animator.playSound("mmm")
	end
	
	if (energyBoost > 0) then
		energyBoost = status.giveResource("energy", energyBoost)
	end
	
	timer = timer + dt
	
	mcontroller.controlModifiers({
		airJumpModifier = 1.1
    })
	mcontroller.controlModifiers({
		speedModifier = 1.1
	})
end

function uninit()
end
function init()
	effect.setParentDirectives("fade=FFFFFF=0.5")
	effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = 0}})
	effect.addStatModifierGroup({{stat = "invulnerable", amount = 1}})

	script.setUpdateDelta(0)
end

function update(dt)

end

function uninit()
	
end

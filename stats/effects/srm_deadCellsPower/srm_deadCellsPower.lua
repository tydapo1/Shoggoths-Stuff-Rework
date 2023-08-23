function init()
	powerStatGroup = effect.addStatModifierGroup({{stat = "powerMultiplier", effectiveMultiplier = 1.0}})
end

function update(dt)
	effect.setStatModifierGroup(powerStatGroup, {{stat = "powerMultiplier", effectiveMultiplier = status.statusProperty("deadCellsPowerLevel", 1.0)}})	 
end

function uninit()
end

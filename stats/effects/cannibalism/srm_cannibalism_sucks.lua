function init()
    script.setUpdateDelta(1)
	
	timerMax = 0.2
	timer = timerMax
end

function update(dt)
	if (timer >= timerMax) then
		timer = 0
		status.removeEphemeralEffect("wellfed")
		status.setResourceLocked("energy", true)
		status.modifyResource("health", -1)
		status.modifyResource("food", -1)
	end
	timer = timer + dt
	status.setResource("energy", 0)
end

function uninit()
end
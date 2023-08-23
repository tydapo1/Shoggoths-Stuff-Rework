function init()
	script.setUpdateDelta(1)
end

function update(dt)
	if ( status.resource("health") < status.resourceMax("health") ) then
		if ( ( status.resource("energy") > 0 ) and ( not status.resourceLocked("energy") ) ) then
			status.giveResource("health", 1)
			status.overConsumeResource("energy", 9)
		end
	end
end

function uninit()
	
end

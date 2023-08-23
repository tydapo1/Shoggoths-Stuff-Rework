function init()
	script.setUpdateDelta(1)
end

function update(dt)
	if ( status.resource("energy") < ( status.resourceMax("energy") / 2) ) then
		if status.resource("health") > 1 then
			status.consumeResource("health", 1)
			status.giveResource("energy", 12)
		end
	end
end

function uninit()
	
end

function init()
	script.setUpdateDelta(2)
end

function update(dt)
	status.modifyResource("energy",1)
end

function uninit()
	
end

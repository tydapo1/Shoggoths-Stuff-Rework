function init()
	status.modifyResource("health", config.getParameter("healAmount", 25))
	effect.expire()
end

function uninit()
	
end

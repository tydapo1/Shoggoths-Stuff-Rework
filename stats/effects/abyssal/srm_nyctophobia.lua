function init()
	
end

function update(dt)
	local number = 1 - (effect.duration() * 2.5)
	effect.setParentDirectives("fade=000000=" .. number)
end

function uninit()

end

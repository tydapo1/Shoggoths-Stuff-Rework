rotateUtil = {}
function rotateUtil.getRelativeAngle(angle1, angle2) -- angle1 is target, angle2 is entity
	local diff = angle1 - angle2
	diff = (diff + math.pi) % (math.pi * 2) - math.pi
	return diff
end

function rotateUtil.slowRotate(rot, amount, speed)
	if math.abs(amount) < speed then
		return rot + amount
	elseif amount > 0 then
		return rot + speed
	else
		return rot - speed
	end
end 

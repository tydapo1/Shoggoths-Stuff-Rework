require "/scripts/status.lua"

function init()
	-- Generic Values
	cursePool = {}
	script.setUpdateDelta(1)
	mercyTimer = 5
	
	-- Loading curses
	local curses = config.getParameter("curses", {})
	--sb.logInfo(sb.printJson(curses))
	for k,v in pairs(curses) do
		cursePool[#cursePool+1] = k
	end
	-- Chosing curse
	local currentCurse = cursePool[math.random(1,#cursePool)]
	--sb.logInfo(sb.printJson(curses[currentCurse]))
	require(curses[currentCurse])
end

function update(dt)
	-- Timer update
	if mercyTimer>0 then 
		mercyTimer = mercyTimer - dt
	else
		update_ready(dt)
	end
end

function update_ready(dt)
end

function uninit()
end
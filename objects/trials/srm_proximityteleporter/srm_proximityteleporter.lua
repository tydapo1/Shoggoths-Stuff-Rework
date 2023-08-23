require "/scripts/vec2.lua"

function init()
	location = config.getParameter("location")
	preventMultipleMessages = {}
end

function update(dt)
	local playerIds = world.playerQuery(entity.position(), 5)
	if #preventMultipleMessages > 0 then
		for k,v in ipairs(preventMultipleMessages) do
			for k2,v2 in ipairs(playerIds) do
				if (v == v2) then
					playerIds[k2] = nil
				end
			end
		end
	end
	if #playerIds > 0 then
		for k,v in ipairs(playerIds) do
			world.sendEntityMessage(v, "srm_warp", location)
			preventMultipleMessages[#preventMultipleMessages+1] = v
		end
	end
end
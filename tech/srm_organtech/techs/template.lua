local oldUpdate = update
update = function(args,dt)
	if oldUpdate then oldUpdate(args,dt) end
	
	if (hasStatus("insertstatuseffecthere")) then 
		update_template(args,dt)
	end
end

-- Init for the Template
function init_template()
	if not template_setup then
		template_setup = true
		
		-- Values go here
	end
end

-- Update for the Template
function update_template(args)
	local dt = args.dt
	init_template()
	
	-- Code goes here
end
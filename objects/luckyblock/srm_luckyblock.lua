require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
	local kind = config.getParameter("luckyBlockKind", "default")
	blockConfig = {}
	if not root.assetJson("/config/srm_lucky.config")[kind] then 
		blockConfig = root.assetJson("/config/srm_lucky.config")["default"]
	else
		blockConfig = root.assetJson("/config/srm_lucky.config")[kind]
	end
end

function die()
	if (not ((world.type() == "unknown") and (not world.terrestrial()))) then
		animator.burstParticleEmitter("burst")
		local index = ""
		if config.getParameter("debugOutcome", "none") == "none" then
			index = figureOutEvent()
		else
			index = config.getParameter("debugOutcome", "none")
		end
		local outcome = blockConfig[index].outcomeEvents
		for k,v in pairs(outcome) do
			world.spawnStagehand(object.position(), outcome[k].type, { parameters = outcome[k].parameters })
		end
		for i=1,25 do
			world.spawnItem("money", entity.position(), 1, {}, {((math.random()-0.5)*15),(30-(math.random()*10))})
		end
	else
		world.spawnItem("srm_luckyblock", entity.position(), 1)
	end
end

function figureOutEvent()
	local luck = config.getParameter("luck", 0)
	local outcomePositionArray = {}
	local outcomeKeyArray = {}
	for k,v in pairs(blockConfig) do
		outcomePositionArray[#outcomePositionArray+1] = blockConfig[k].outcomeLuckPosition
		outcomeKeyArray[#outcomePositionArray] = k
	end
	--sb.logInfo(sb.printJson(outcomePositionArray))
	--sb.logInfo(sb.printJson(outcomeKeyArray))
	
	local outcomeChanceArray = {}
	for i=1,#outcomePositionArray do
		local offset = math.abs(outcomePositionArray[i] - luck)
		outcomeChanceArray[i] = (200 - offset) + 2
		-- the +1 is to prevent the impossibility of an outcome
		-- could potentially be increased to improve minimum chance to get an outcome
		-- at +2, equal a minimum of 1%
	end
	
	local outcomeMax = 0
	for i=1,#outcomeChanceArray do
		outcomeMax = outcomeMax + outcomeChanceArray[i]
	end
	
	local selectedOutcome = math.random() * outcomeMax
	local outcomeIndex = -1
	for i=1,#outcomeChanceArray do
		selectedOutcome = selectedOutcome - outcomeChanceArray[i]
		if selectedOutcome <= 0 then outcomeIndex = i break end
	end
	return outcomeKeyArray[outcomeIndex]
end
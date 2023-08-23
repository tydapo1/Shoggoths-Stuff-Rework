require "/scripts/vec2.lua"
require "/scripts/util.lua"

function init()
	hasKey = false
	waiting = true
	playerId = nil
	message.setHandler("srm_hasKeyAnswer", function(_, isItMine, doesHaveKey) 
		hasKey = doesHaveKey
		waiting = false
	end)
	if storage.triggered then
		animator.setAnimationState("burstState", "open")
	end
	object.setInteractive(not storage.triggered)
	parameters = config.getParameter("projectileParameters", {})
end

function update(dt)
	if not waiting then
		if hasKey then
			if not storage.triggered then
				storage.triggered = true
				object.setInteractive(false)

				animator.setAnimationState("burstState", "burst")
				animator.playSound("burst")
				animator.burstParticleEmitter("burst")

				local burstIntangibleTimeRange = config.getParameter("burstIntangibleTimeRange", {0, 0})
				local burstVelocityRange = config.getParameter("burstItemVelocityRange", {20, 40})
				local burstAngleVariance = config.getParameter("burstItemAngleVariance", 0.5)
				local burstOffset = config.getParameter("burstOffset", {0, 0})
				burstOffset[1] = burstOffset[1] * object.direction()
				local burstPosition = vec2.add(entity.position(), burstOffset)
				local burstTreasure = root.createTreasure(config.getParameter("burstTreasurePool"), world.threatLevel())
				for _, item in ipairs(burstTreasure) do
					local velocity = vec2.withAngle(sb.nrand(burstAngleVariance, math.pi / 2), util.randomInRange(burstVelocityRange))
					world.spawnItem(item, burstPosition, 1, nil, velocity, util.randomInRange(burstIntangibleTimeRange))
				end
				world.sendEntityMessage(playerId, "srm_consumeKey")
			end
		else
			animator.playSound("locked")
			world.spawnProjectile("invisibleprojectile", {entity.position()[1], entity.position()[2]+2}, entity.id(), {0,0}, false, parameters)
		end
		waiting = true
	end	
end

function onInteraction(args)
	world.sendEntityMessage(args.sourceId, "srm_hasKey", entity.id())
	playerId = args.sourceId
end

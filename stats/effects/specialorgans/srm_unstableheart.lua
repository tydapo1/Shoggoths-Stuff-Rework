require "/scripts/status.lua"

function init()
	queryDamageSince = 0
	maxPositionHistory = 180
	statsArray = nil
end

function update(dt)
	if not statsArray then
		statsArray = {}
		for i=1, maxPositionHistory do
			local stats = {}
			stats.health = status.resource("health")
			stats.position = world.entityPosition(entity.id())
			statsArray[i] = stats
		end
	else
		for i=maxPositionHistory, 2, -1 do
			statsArray[i] = statsArray[(i-1)]
		end
		local stats = {}
		stats.health = status.resource("health")
		stats.position = world.entityPosition(entity.id())
		statsArray[1] = stats
	end
	
	local damageNotifications, nextStep = status.damageTakenSince(queryDamageSince)
	queryDamageSince = nextStep
	for _, notification in ipairs(damageNotifications) do
		if notification.healthLost > 0 and notification.sourceEntityId ~= notification.targetEntityId then
			animator.playSound("trigger", 0)
			animator.burstParticleEmitter("person")
			local stats = statsArray[maxPositionHistory]
			mcontroller.setPosition(stats.position)
			local hp = (status.resource("health") + stats.health) / 2
			status.setResource("health", hp)
			break
		end
	end
end

function uninit()
end
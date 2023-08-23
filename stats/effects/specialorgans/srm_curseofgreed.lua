function init()
	queryDamageSince = 0
	lastMoney = 999999999
	-- need player tables
end

function spawnMoney(player)
	if player.consumeCurrency("money", 1) then
		world.spawnProjectile("money", mcontroller.position(), entity.id(), {randomInteger(), randomInteger()})
	end
end

function randomInteger()
	return ( ( math.random() * 16 ) - 8 )
end

function update(dt)
	player = math.srm_player
	if lastMoney < player.currency("money") then
		status.giveResource("health", (player.currency("money")-lastMoney))
	end
	lastMoney = player.currency("money")
	local damageNotifications, nextStep = status.damageTakenSince(queryDamageSince)
	queryDamageSince = nextStep
	for _, notification in ipairs(damageNotifications) do
		if notification.sourceEntityId ~= notification.targetEntityId then
			for moneyCountdown = math.floor(notification.healthLost/2),0,-1 do
				spawnMoney(player)
			end
			break
		end
	end
end
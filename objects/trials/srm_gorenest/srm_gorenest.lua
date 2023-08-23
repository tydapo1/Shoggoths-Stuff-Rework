require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
	if config.getParameter("used", false) then
		object.setInteractive(false)
	else
		object.setInteractive(true)
	end
	
	portalClosing = false
	portalClosingFrame = 7
	portalTimer = 0
	portalTimerSpeed = 0.25
	portalTimerClosingSpeed = 0.13
	portalSwitch = true
	
	timer = 0
	timerStartDecay = 1.25
	timerExplode = timerStartDecay + 3.5
	onlyDecayOnce = true
	
	monsterSpawnTimer = 0
	monsterSpawnAmount = math.random(6, 10)
	--------------------- 3.5 - ()
	monsterSpawnPeriod = (timerExplode - timerStartDecay) - ((portalClosingFrame/60) * portalTimerClosingSpeed)
	monsterSpawnDelay = monsterSpawnPeriod / monsterSpawnAmount
	monsterTypes = {
		"smallflying",
		"largeflying",
		"smallbiped",
		"largebiped",
		"smallquadruped",
		"largequadruped"
	}
end

function update(dt)
	if config.getParameter("used", false) then
		timer = timer + dt
		if timer > timerStartDecay then
			if onlyDecayOnce then
				onlyDecayOnce = false
				animator.burstParticleEmitter("miniburst")
				animator.playSound("decay", 0)
				portalTimer = 0
				animator.setGlobalTag("goreframe", "inactive")
			end
			if monsterSpawnAmount > 0 then
				if monsterSpawnTimer <= 0 then
					monsterSpawnTimer = monsterSpawnDelay
					monsterSpawnAmount = monsterSpawnAmount - 1
					local x = object.direction()
					if x == -1 then	x = 0.25 else x = 0.75 end
					world.spawnProjectile("srm_monsterspawn", {entity.position()[1]+x,entity.position()[2]+4.25}, entity.id(), vec2.rotate({1,0}, (math.pi*math.random())), false, {
						actionOnReap = {
							{
								action = "spawnmonster",
								type = monsterTypes[math.random(1,#monsterTypes)],
								offset = {0, 0},
								arguments = { 
									aggressive = true,
									level = world.threatLevel(),
									dropPools = { { default = "deadcellsDrop" } }
								}
							}
						}
					})
				end
				monsterSpawnTimer = monsterSpawnTimer - dt
			else
				portalClosing = true
			end
		end
		if timer > timerExplode then
			world.spawnItem("srm_ruinkey", entity.position())
			object.smash(true)
		end
	end
	
	if not portalClosing then
		if portalTimer >= portalTimerSpeed then
			portalTimer = 0
			if portalSwitch then portalSwitch = false else portalSwitch = true end
		end
		local frame = 7
		if portalSwitch then frame = 7 else frame = 6 end
		animator.setGlobalTag("portalframe", tostring(frame))
		portalTimer = portalTimer + dt
	else
		if portalTimer >= portalTimerClosingSpeed then
			portalTimer = 0
			if portalClosingFrame > 0 then portalClosingFrame = portalClosingFrame - 1 end
		end
		animator.setGlobalTag("portalframe", tostring(portalClosingFrame))
		portalTimer = portalTimer + dt
	end
end

function onInteraction(args)
	if (not (config.getParameter("used", false))) then
		object.setConfigParameter("used", true)
		object.setInteractive(false)
		animator.playSound("pull", 0)
	end
end

function die()
	animator.burstParticleEmitter("burst")
end
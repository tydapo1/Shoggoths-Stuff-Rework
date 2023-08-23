require "/scripts/vec2.lua"
require "/scripts/util.lua"
require "/scripts/interp.lua"

function init()
	script.setUpdateDelta(1)
	
	stalkerTheme = config.getParameter("stalkerTheme")
	stalkerSpawnTimerMax = config.getParameter("stalkerSpawnTimer")
	stalkerSpawnOffset = config.getParameter("stalkerSpawnOffset")
	stalkerSpawnTimer = stalkerSpawnTimerMax
	stalkerCanSpawn = false
	messaged = false

	monsterUniqueId = string.format("%s-leviathan", world.entityUniqueId(entity.id()) or sb.makeUuid())
	findMonster = util.uniqueEntityTracker(monsterUniqueId, 0.2)
	
	lightUpdatesPerSecond = config.getParameter("lightUpdatesPerSecond")
	lightTimerMax = lightUpdatesPerSecond
	lightTimer = lightTimerMax
	lightThreshold = config.getParameter("lightThreshold")
	lightDamageReset = -5 * lightUpdatesPerSecond
	lightDamage = lightDamageReset
	
	animator.setLightActive("mercyLight", true)
	mercyLightTimerMax = config.getParameter("mercyLightTimerMax")
	mercyLightTimer = mercyLightTimerMax
end

function update(dt)
	if mercyLightTimer > 0 then
		local lightAmount = math.floor(255 * (mercyLightTimer / mercyLightTimerMax))
		animator.setLightColor("mercyLight", {lightAmount, lightAmount, lightAmount})
		animator.setLightActive("mercyLight", true)
		mercyLightTimer = mercyLightTimer - dt
	else
		animator.setLightActive("mercyLight", false)
	end
	
	if lightTimer >= lightTimerMax then
		lightTimer = 0
		local lightLevel = world.lightLevel(world.entityPosition(entity.id()))
		if lightLevel < lightThreshold then
			lightDamage = lightDamage + 1
			status.addEphemeralEffect("srm_nyctophobia", 1)
		else
			lightDamage = lightDamageReset
			status.removeEphemeralEffect("srm_nyctophobia")
		end
		if lightDamage > 0 then
			status.applySelfDamageRequest({
				damageType = "IgnoresDef",
				damage = lightDamage,
				damageSourceKind = "hunger",
				sourceEntityId = entity.id()
			})
		end
	end
	lightTimer = lightTimer + dt
	
	if world.entityPosition(entity.id())[2] <= 1400 and world.entityPosition(entity.id())[2] >= 800 then
		stalkerCanSpawn = true
	else
		stalkerCanSpawn = false

		stalkerSpawnTimer = stalkerSpawnTimerMax 
		local monsterPosition = findMonster()
		if monsterPosition then
			world.sendEntityMessage(monsterUniqueId, "despawn")
			world.sendEntityMessage(entity.id(), "stopAltMusic")
		end
	end
  
	if stalkerCanSpawn and stalkerSpawnTimer > 0 then
		stalkerSpawnTimer = stalkerSpawnTimer - dt
	end

	local monsterPosition = findMonster()
	if monsterPosition then
		if not messaged then
			world.sendEntityMessage(entity.id(), "queueRadioMessage", "srm_abyssalstalker")
			messaged = true
		end
	elseif monsterPosition == nil then
		stalkedThemeSwitch = false 

		if stalkerSpawnTimer <= 0 then
			local parameters = {
				level = world.threatLevel(),
				target = entity.id(),
				aggressive = true,
				uniqueId = monsterUniqueId,
				keepAlive = true
			}
			world.spawnMonster("srm_ghostleviathanhead", vec2.add(mcontroller.position(), stalkerSpawnOffset), parameters)
			world.sendEntityMessage(entity.id(), "playAltMusic", stalkerTheme, 0.3)
			animator.playSound("roar", 0)
			stalkerSpawnTimer = stalkerSpawnTimerMax
		end
	end
end

function uninit()
end

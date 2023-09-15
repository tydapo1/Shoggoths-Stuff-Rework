require "/scripts/behavior.lua"
require "/scripts/pathing.lua"
require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/poly.lua"
require "/scripts/drops.lua"
require "/scripts/status.lua"
require "/scripts/tenant.lua"
require "/scripts/actions/movement.lua"
require "/scripts/actions/animator.lua"

local ownerId
local life
local initialized
local headId
local size
local childId
local lastHealth
local segmentSize
local maxBend
local isFirst = false
local segmentOverrides = {}
local totalSize
-- optimized worm body and tail segment, for when you're not using behaviours
-- Engine callback - called on initialization of entity
function init()
    self.pathing = {}
ownerId = 1
life = 0
initialized = false
headId = 0
  targetId = nil
  queryRange = 100
  keepTargetInRange = 250
  targets = {}
    outOfSight = {}
size = 0
childId = 0
targetCheckTPS = 80
targetCheckTime = config.getParameter("segmentsLeft") % targetCheckTPS
totalSize = config.getParameter("size", 0)
lastHealth = 0
monster.setAggressive(true)
segmentOverrides = config.getParameter("segmentOverrides", {})
segmentSize = config.getParameter("segmentSize") * -1
maxBend = config.getParameter("maxBend", 180) * math.pi / 180
lastHealth = status.resourcePercentage("health")
setHealth(config.getParameter("ownerHealth"))

    message.setHandler("healthOwner", function(_,_,health)
        setHealth(health)
        sendHealthOwner(health)
  end)
    message.setHandler("healthChild", function(_,_,health)
        setHealth(health)
        sendHealthChild(health)
  end)
  message.setHandler("damageTeam", function(_,_,team)
        monster.setDamageTeam(team)
        setVariables(config.getParameter("ownerId"), config.getParameter("segmentsLeft"), config.getParameter("headId"))
  end)
    message.setHandler("update", function(_, _, angle)
        if not initialized then
            return
        end
        followOwner(angle)
        if world.entityExists(childId) then
            world.sendEntityMessage(childId, "update", mcontroller.rotation())
        end
  end)
  self.shouldDie = true
  self.notifications = {}
  storage.spawnTime = world.time()
  if storage.spawnPosition == nil or config.getParameter("wasRelocated", false) then
    local position = mcontroller.position()
    local groundSpawnPosition
    if mcontroller.baseParameters().gravityEnabled then
      groundSpawnPosition = findGroundPosition(position, -20, 3)
    end
    storage.spawnPosition = groundSpawnPosition or position
  end

  --self.behavior = behavior.behavior(config.getParameter("behavior"), sb.jsonMerge(config.getParameter("behaviorConfig", {}), skillBehaviorConfig()), _ENV)
  --self.board = self.behavior:blackboard()
  --self.board:setPosition("spawn", storage.spawnPosition)

  self.collisionPoly = mcontroller.collisionPoly()

  if animator.hasSound("deathPuff") then
    monster.setDeathSound("deathPuff")
  end
  if config.getParameter("deathParticles") then
    monster.setDeathParticleBurst(config.getParameter("deathParticles"))
  end

  script.setUpdateDelta(config.getParameter("initialScriptDelta", 1))
  mcontroller.setAutoClearControls(false)
  --self.behaviorTickRate = config.getParameter("behaviorUpdateDelta", 2)
  --self.behaviorTick = math.random(1, self.behaviorTickRate)

  animator.setGlobalTag("flipX", "")
  --self.board:setNumber("facingDirection", mcontroller.facingDirection())

  -- Listen to damage taken
  damageTaken = damageListener("damageTaken", function(notifications)
    for _,notification in pairs(notifications) do
      if notification.healthLost > 0 then
        self.damaged = true
        --self.board:setEntity("damageSource", notification.sourceEntityId)
        sendHealthOwner(status.resourcePercentage("health"))
        sendHealthChild(status.resourcePercentage("health"))
        lastHealth = status.resourcePercentage("health")
      end
    end
  end)

  self.debug = true

  message.setHandler("notify", function(_,_,notification)
      return notify(notification)
    end)
  message.setHandler("despawn", function()
    end)

  local deathBehavior = config.getParameter("deathBehavior")
  if deathBehavior then
    --self.deathBehavior = behavior.behavior(deathBehavior, config.getParameter("behaviorConfig", {}), _ENV, self.behavior:blackboard())
  end

  self.forceRegions = ControlMap:new(config.getParameter("forceRegions", {}))
  self.damageSources = ControlMap:new(config.getParameter("damageSources", {}))
  self.touchDamageEnabled = false

  if config.getParameter("damageBar") then
    monster.setDamageBar(config.getParameter("damageBar"));
  end

  monster.setInteractive(config.getParameter("interactive", false))

  monster.setAnimationParameter("chains", {})
  
  mcontroller.controlFace(1)
end
function updateMove(angle)
    followOwner(angle)
    if world.entityExists(childId) then
        world.callScriptedEntity(childId, "updateMove", mcontroller.rotation())
    end
end
function update(dt)
     life = life + 1
     if life > 15 then
         if life < 30 then
            monster.setDamageOnTouch(true)
         end
         if not world.entityExists(ownerId) then
             status.setResourcePercentage("health", 0) 
         end
     end
  
  damageTaken:update()
  
  if lastHealth ~= status.resourcePercentage("health") then
      lastHealth = status.resourcePercentage("health")
      sendHealthOwner(lastHealth)
      sendHealthChild(lastHealth)
  end
  
  if config.getParameter("bodySegment") or config.getParameter("tailSegment") then
    if childId then
      if not world.entityExists(childId) then
          if status.resourcePercentage("health") > 0 then
              spawnSegment(size, headId)
          end
      end
    end
  end
end

function skillBehaviorConfig()
  local skills = config.getParameter("skills", {})
  local skillConfig = {}
  for _,skillName in pairs(skills) do
    local skillHostileActions = root.monsterSkillParameter(skillName, "hostileActions")
    if skillHostileActions then
      construct(skillConfig, "hostileActions")
      util.appendLists(skillConfig.hostileActions, skillHostileActions)
    end
  end

  return skillConfig
end

function interact(args)
end

function shouldDie()
    
    return (self.shouldDie and status.resource("health") <= 0)
end

function die()
  sendHealthChild(0)
  sendHealthOwner(0)
end
function followOwner(ownerDir)
  if world.entityExists(ownerId) then
        local ownerPos = world.entityPosition(ownerId)
        if isFirst then
            local ownerVel = world.entityVelocity(ownerId)
            ownerPos = vec2.add(ownerPos, vec2.mul(ownerVel, script.updateDt()))
        end
        local newAngle = vec2.angle(world.distance(ownerPos, mcontroller.position()))
        mcontroller.setPosition(vec2.add(ownerPos, vec2.withAngle(newAngle, segmentSize)))
        mcontroller.setVelocity({0, 0})
        mcontroller.setRotation(newAngle)
        if config.getParameter("flip") then
          animator.resetTransformationGroup("flip")
          local flip = mcontroller.rotation() > 1.5708 and mcontroller.rotation() < 4.71239 
          if flip then
              animator.scaleTransformationGroup("flip", {1, -1}) -- flip the body sprite
          end
        end
        animator.resetTransformationGroup("body")
        animator.rotateTransformationGroup("body", newAngle)
  else
     if life < 100 then
         mcontroller.setPosition({0, 0})
     end
      status.setResourcePercentage("health", 0) 
  end
end
function setVariables(newownerId, count, newheadId)
    ownerId = newownerId
    headId = newheadId
    if headId == ownerId then
        isFirst = true
    end
    size = count
    initialized = true
    
    if config.getParameter("bodySegment") or config.getParameter("tailSegment") then
      spawnSegment(count, headId)
    end
    status.setStatusProperty("headId", headId)
    message.setHandler("pet.attemptCapture", function(_,_,...)
                        return world.callScriptedEntity(headId, "capturable.attemptCapture", ...)
                         end)
end
function sendHealthOwner(health)
    --world.sendEntityMessage(ownerId, "healthOwner", health)
end
function sendHealthChild(health)
    world.sendEntityMessage(childId, "healthChild", health)
end
function setHealth(health)
    lastHealth = health
    status.setResourcePercentage("health", health)
end
function spawnSegment(count, tempHeadId)
    local tempownerId = entity.id()
    local params = { level = monster.level(),ownerHealth = status.resourcePercentage("health"),ownerId = tempownerId, segmentsLeft = count - 1, headId = tempHeadId, size = totalSize}
    local segmentType = config.getParameter("bodySegment")
    if count > 0 then
    else
        segmentType = config.getParameter("tailSegment")
    end
    if segmentOverrides then
        for _,o in pairs(segmentOverrides) do
            if o.num == totalSize - count then
                segmentType = o.type
            end
        end
    end
    local segmentId = world.spawnMonster(segmentType,mcontroller.position(), params)
    childId = segmentId
    world.sendEntityMessage(segmentId, "damageTeam", entity.damageTeam())
    return segmentId
end

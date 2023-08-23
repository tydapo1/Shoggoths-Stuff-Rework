require "/scripts/vec2.lua"
require "/tech/srm_extraarmstech/techchain.lua"

function init()
  script.setUpdateDelta(1)
  chains = {}
  -- This complicated doohickey loads all the scripts located in the tech config and procedurally adds them to the tech.
  extraarmstech_leftStateArray = config.getParameter("extraarmstech_leftOrder")
  extraarmstech_leftFistArray = config.getParameter("extraarmstech_leftOptions")
  for k,v in pairs(extraarmstech_leftFistArray) do
	local requ = "" .. v
	require(requ)
	local funct = "left_" .. k .. "_init"
	_ENV[funct]()
  end
  extraarmstech_rightStateArray = config.getParameter("extraarmstech_rightOrder")
  extraarmstech_rightFistArray = config.getParameter("extraarmstech_rightOptions")
  for k,v in pairs(extraarmstech_rightFistArray) do
	local requ = "" .. v
	require(requ)
	local funct = "right_" .. k .. "_init"
	_ENV[funct]()
  end
  --for i=1,#extraarmstech_leftStateArray do
  --  sb.logInfo(extraarmstech_leftStateArray[i])
  --end
  --for i=1,#extraarmstech_rightStateArray do
  --  sb.logInfo(extraarmstech_rightStateArray[i])
  --end
  ---------------------------------------------------------- End of section
  extraarmstech_lastLeftState = "fist"
  extraarmstech_lastRightState = "fist"
  extraarmstech_switchLeftLock = false
  extraarmstech_switchRightLock = false
  
  extraarmstech_leftAngle = 0
  extraarmstech_rightAngle = 0
  extraarmstech_defaultVec = {5,0}
  
  extraarmstech_activated = true
  extraarmstech_preventToggleSpam = false
  
  --status.addEphemeralEffect("srm_extrafuel", 5)
  animator.setAnimationState("leftFistState", "fist")
  animator.setAnimationState("rightFistState", "fist")
  animator.setAnimationState("leftArm1State", "activate")
  animator.setAnimationState("leftArm2State", "activate")
  animator.setAnimationState("leftArm3State", "activate")
  animator.setAnimationState("leftArm4State", "activate")
  animator.setAnimationState("rightArm1State", "activate")
  animator.setAnimationState("rightArm2State", "activate")
  animator.setAnimationState("rightArm3State", "activate")
  animator.setAnimationState("rightArm4State", "activate")
end

-- This solely calls the right functions at the right time, mister Freeman
function update(args)
  player = math.srm_player
  localAnimator = math.srm_localAnimator
  if (not (player.getProperty("extraarms_unlock_fist", false))) then
    player.setProperty("extraarms_unlock_fist", true)
  end
  fetchMechDirectives()
  extraarmstech(args,args.dt)
  update_chainList(args.dt)
end

function uninit()
  --status.removeEphemeralEffect("srm_extrafuel")
  animator.setAnimationState("leftFistState", "off")
  animator.setAnimationState("rightFistState", "off")
  animator.setAnimationState("leftArm1State", "deactivate")
  animator.setAnimationState("leftArm2State", "deactivate")
  animator.setAnimationState("leftArm3State", "deactivate")
  animator.setAnimationState("leftArm4State", "deactivate")
  animator.setAnimationState("rightArm1State", "deactivate")
  animator.setAnimationState("rightArm2State", "deactivate")
  animator.setAnimationState("rightArm3State", "deactivate")
  animator.setAnimationState("rightArm4State", "deactivate") 
end

-- extraarmstech set
function extraarmstech(args,dt)
  -- The part where we add the functionality
  if ((args.moves["run"] == false) and (args.moves["primaryFire"] == true) and (extraarmstech_switchLeftLock == false)) then
    local indexToFind = 1
	for i=1,#extraarmstech_leftStateArray do
      if extraarmstech_leftStateArray[i] == animator.animationState("leftFistState") then
        indexToFind = i + 1
        break
      end	  
	end
	if (indexToFind > #extraarmstech_leftStateArray) then indexToFind = 1 end
	local preventLeftOverlooping = #extraarmstech_rightStateArray * 2
	while (not (player.getProperty("extraarms_enabled_left_" .. extraarmstech_leftStateArray[indexToFind], false))) do
	  if (player.getProperty("extraarms_enabled_left_" .. extraarmstech_leftStateArray[indexToFind], false)) then break end
	  indexToFind = indexToFind + 1
	  if (indexToFind > #extraarmstech_leftStateArray) then indexToFind = 1 end
	  if preventLeftOverlooping <= 0 then indexToFind = 1 break end
	  preventLeftOverlooping = preventLeftOverlooping - 1
	end
	animator.setAnimationState("leftFistState", "" .. extraarmstech_leftStateArray[indexToFind])
	animator.playSound("armSwitch", 0)
    extraarmstech_switchLeftLock = true
  end
  if ((args.moves["run"] == false) and (args.moves["altFire"] == true) and (extraarmstech_switchRightLock == false)) then
    local indexToFind = 1
	for i=1,#extraarmstech_rightStateArray do
      if extraarmstech_rightStateArray[i] == animator.animationState("rightFistState") then
        indexToFind = i + 1
        break
      end	  
	end
	if (indexToFind > #extraarmstech_rightStateArray) then indexToFind = 1 end
	local preventRightOverlooping = #extraarmstech_rightStateArray * 2
	while (not (player.getProperty("extraarms_enabled_right_" .. extraarmstech_rightStateArray[indexToFind], false))) do
	  if (player.getProperty("extraarms_enabled_right_" .. extraarmstech_rightStateArray[indexToFind], false)) then break end
	  indexToFind = indexToFind + 1
	  if (indexToFind > #extraarmstech_rightStateArray) then indexToFind = 1 end
	  if preventRightOverlooping <= 0 then indexToFind = 1 break end
	  preventRightOverlooping = preventRightOverlooping - 1
	end
	animator.setAnimationState("rightFistState", "" .. extraarmstech_rightStateArray[indexToFind])
	animator.playSound("armSwitch", 0)
    extraarmstech_switchRightLock = true
  end
  if ((args.moves["primaryFire"] == false) and (extraarmstech_switchLeftLock == true)) then
    extraarmstech_switchLeftLock = false
  end
  if ((args.moves["altFire"] == false) and (extraarmstech_switchRightLock == true)) then
    extraarmstech_switchRightLock = false
  end
  
  if ((args.moves["run"] == false) and (args.moves["down"] == true) and (not extraarmstech_preventToggleSpam)) then
    extraarmstech_preventToggleSpam = true
	if (extraarmstech_activated) then 
	  extraarmstech_activated = false
	  animator.playSound("armDeactivate", 0)
	else 
	  extraarmstech_activated = true 
	  animator.playSound("armActivate", 0)
	end
  end
  if ((args.moves["run"] == true) or (args.moves["down"] == false) and (extraarmstech_preventToggleSpam)) then
    extraarmstech_preventToggleSpam = false
  end
  
  -- Calling the right uninit functions
  if (not (extraarmstech_lastLeftState == animator.animationState("leftFistState"))) then
    local funct = "left_" .. extraarmstech_lastLeftState .. "_uninit"
	_ENV[funct]()
  end
  extraarmstech_lastLeftState = animator.animationState("leftFistState")
  if (not (extraarmstech_lastRightState == animator.animationState("rightFistState"))) then
    local funct = "right_" .. extraarmstech_lastRightState .. "_uninit"
	_ENV[funct]()
  end
  extraarmstech_lastRightState = animator.animationState("rightFistState")
  
  if (extraarmstech_activated) then
    animator.setGlobalTag("isHidden", "?scalenearest=1")
  else
    animator.setGlobalTag("isHidden", "?scalenearest=0")
  end
  
  -- Calling the right update functions
  --sb.logInfo(extraarmstech_lastLeftState)
  --sb.logInfo(extraarmstech_lastRightState)
  if (extraarmstech_activated) then
    if (not extraarmstech_switchLeftLock) then
      local leftFunct = "left_" .. extraarmstech_lastLeftState .. "_update"
      _ENV[leftFunct](args, dt)
	end
    if (not extraarmstech_switchRightLock) then
      local rightFunct = "right_" .. extraarmstech_lastRightState .. "_update"
      _ENV[rightFunct](args, dt)
	end
  end
  
  -- Now's where the garbage begins to give the player the mech shit animation wise
  --sb.logInfo(sb.print((animator.partPoint("leftArm1", "shoulderJoint"))))
  --sb.logInfo(sb.print((animator.partPoint("rightArm1", "shoulderJoint"))))
  local subAimToEntity = world.distance(tech.aimPosition(),entity.position())
  if (subAimToEntity[1] < 0) then
    mcontroller.controlFace(-1)
  else
    mcontroller.controlFace(1)
  end
  
  local leftShoulderPos = (animator.partPoint("leftArm1", "shoulderJoint"))
  leftShoulderPos = vec2.add(leftShoulderPos, entity.position())
  extraarmstech_leftAngle = vec2.angle(world.distance(tech.aimPosition(),leftShoulderPos))
  
  local rightShoulderPos = (animator.partPoint("rightArm1", "shoulderJoint"))
  rightShoulderPos = vec2.add(rightShoulderPos, entity.position())
  extraarmstech_rightAngle = vec2.angle(world.distance(tech.aimPosition(),rightShoulderPos))
  
  animator.resetTransformationGroup("leftArm1")
  animator.resetTransformationGroup("rightArm1")
  animator.resetTransformationGroup("leftArm2")
  animator.resetTransformationGroup("rightArm2")
  animator.resetTransformationGroup("leftArm3")
  animator.resetTransformationGroup("rightArm3")
  animator.resetTransformationGroup("leftArm4")
  animator.resetTransformationGroup("rightArm4")
  animator.resetTransformationGroup("leftFist")
  animator.resetTransformationGroup("rightFist")
  if (mcontroller.crouching()) then
    animator.translateTransformationGroup("leftArm1", {0,-1})
    animator.translateTransformationGroup("rightArm1", {0,-1})
    animator.translateTransformationGroup("leftFist", {0,-1})
    animator.translateTransformationGroup("rightFist", {0,-1})
  end
  if (mcontroller.facingDirection() == -1) then
    --flip
	local extraarmstech_flipLeftAngle = (math.pi*2 - extraarmstech_leftAngle) + math.pi
	local extraarmstech_flipRightAngle = (math.pi*2 - extraarmstech_rightAngle) + math.pi
	animator.setFlipped(true)
    animator.rotateTransformationGroup("leftArm1", extraarmstech_flipLeftAngle, animator.partPoint("leftArm1", "shoulderJointFlip"))
    animator.rotateTransformationGroup("rightArm1", extraarmstech_flipRightAngle, animator.partPoint("rightArm1", "shoulderJointFlip"))
    animator.rotateTransformationGroup("leftFist", extraarmstech_flipLeftAngle, animator.partPoint("rightArm1", "shoulderJoint"))
    animator.rotateTransformationGroup("rightFist", extraarmstech_flipRightAngle, animator.partPoint("leftArm1", "shoulderJoint"))
    local leftArm2Pos = vec2.add(
	  vec2.mul(animator.partPoint("leftArm1", "shoulderJoint"), 0.75), 
	  vec2.mul(animator.partPoint("leftFist", "limbJoint"), 0.25)
	)
	leftArm2Pos[1] = -leftArm2Pos[1]
    local leftArm3Pos = vec2.add(
	  vec2.mul(animator.partPoint("leftArm1", "shoulderJoint"), 0.50), 
	  vec2.mul(animator.partPoint("leftFist", "limbJoint"), 0.50)
	)
	leftArm3Pos[1] = -leftArm3Pos[1]
    local leftArm4Pos = vec2.add(
	  vec2.mul(animator.partPoint("leftArm1", "shoulderJoint"), 0.25), 
	  vec2.mul(animator.partPoint("leftFist", "limbJoint"), 0.75)
	)
	leftArm4Pos[1] = -leftArm4Pos[1]
    local rightArm2Pos = vec2.add(
	  vec2.mul(animator.partPoint("rightArm1", "shoulderJoint"), 0.75), 
	  vec2.mul(animator.partPoint("rightFist", "limbJoint"), 0.25)
	)
	rightArm2Pos[1] = -rightArm2Pos[1]
    local rightArm3Pos = vec2.add(
	  vec2.mul(animator.partPoint("rightArm1", "shoulderJoint"), 0.50), 
	  vec2.mul(animator.partPoint("rightFist", "limbJoint"), 0.50)
	)
	rightArm3Pos[1] = -rightArm3Pos[1]
    local rightArm4Pos = vec2.add(
	  vec2.mul(animator.partPoint("rightArm1", "shoulderJoint"), 0.25), 
	  vec2.mul(animator.partPoint("rightFist", "limbJoint"), 0.75)
	)
	rightArm4Pos[1] = -rightArm4Pos[1]
    animator.translateTransformationGroup("leftArm2", leftArm2Pos)
    animator.translateTransformationGroup("leftArm3", leftArm3Pos)
    animator.translateTransformationGroup("leftArm4", leftArm4Pos)
    animator.translateTransformationGroup("rightArm2", rightArm2Pos)
    animator.translateTransformationGroup("rightArm3", rightArm3Pos)
    animator.translateTransformationGroup("rightArm4", rightArm4Pos)
  else
    --no flip
	animator.setFlipped(false)
    animator.rotateTransformationGroup("leftArm1", extraarmstech_leftAngle, animator.partPoint("leftArm1", "shoulderJoint"))
    animator.rotateTransformationGroup("rightArm1", extraarmstech_rightAngle, animator.partPoint("rightArm1", "shoulderJoint"))
    animator.rotateTransformationGroup("leftFist", extraarmstech_leftAngle, animator.partPoint("leftArm1", "shoulderJoint"))
    animator.rotateTransformationGroup("rightFist", extraarmstech_rightAngle, animator.partPoint("rightArm1", "shoulderJoint"))
    local leftArm2Pos = vec2.add(
	  vec2.mul(animator.partPoint("leftArm1", "shoulderJoint"), 0.75), 
	  vec2.mul(animator.partPoint("leftFist", "limbJoint"), 0.25)
	)
    local leftArm3Pos = vec2.add(
	  vec2.mul(animator.partPoint("leftArm1", "shoulderJoint"), 0.50), 
	  vec2.mul(animator.partPoint("leftFist", "limbJoint"), 0.50)
	)
    local leftArm4Pos = vec2.add(
	  vec2.mul(animator.partPoint("leftArm1", "shoulderJoint"), 0.25), 
	  vec2.mul(animator.partPoint("leftFist", "limbJoint"), 0.75)
	)
    local rightArm2Pos = vec2.add(
	  vec2.mul(animator.partPoint("rightArm1", "shoulderJoint"), 0.75), 
	  vec2.mul(animator.partPoint("rightFist", "limbJoint"), 0.25)
	)
    local rightArm3Pos = vec2.add(
	  vec2.mul(animator.partPoint("rightArm1", "shoulderJoint"), 0.50), 
	  vec2.mul(animator.partPoint("rightFist", "limbJoint"), 0.50)
	)
    local rightArm4Pos = vec2.add(
	  vec2.mul(animator.partPoint("rightArm1", "shoulderJoint"), 0.25), 
	  vec2.mul(animator.partPoint("rightFist", "limbJoint"), 0.75)
	)
    animator.translateTransformationGroup("leftArm2", leftArm2Pos)
    animator.translateTransformationGroup("leftArm3", leftArm3Pos)
    animator.translateTransformationGroup("leftArm4", leftArm4Pos)
    animator.translateTransformationGroup("rightArm2", rightArm2Pos)
    animator.translateTransformationGroup("rightArm3", rightArm3Pos)
    animator.translateTransformationGroup("rightArm4", rightArm4Pos)
  end
end


-- Utility functions

-- Fetches mech directives
function fetchMechDirectives()
  local getColorIndexesMessage = world.sendEntityMessage(entity.id(), "getMechColorIndexes")
  if getColorIndexesMessage:finished() and getColorIndexesMessage:succeeded() then
    local res = getColorIndexesMessage:result()
    self.primaryColorIndex = res.primary
    self.secondaryColorIndex = res.secondary
  --else
    --sb.logError("Mech assembly interface unable to fetch player mech paint colors!")
  end
  local directives = ""
  if (self.primaryColorIndex) then
    local paletteConfig = root.assetJson("/vehicles/modularmech/mechpalettes.config")
    local toColors = paletteConfig.swapSets[self.primaryColorIndex]
    for i, fromColor in ipairs(paletteConfig.primaryMagicColors) do
	  if (toColors == nil) then 
	    directives = string.format("%s?replace=%s=%s", directives, fromColor, fromColor)
      else
	    directives = string.format("%s?replace=%s=%s", directives, fromColor, toColors[i])
	  end
    end
    --`directives` would be ?replace=111=222?replace=333=444...
  end
  if (self.secondaryColorIndex) then
    local paletteConfig = root.assetJson("/vehicles/modularmech/mechpalettes.config")
    local toColors = paletteConfig.swapSets[self.secondaryColorIndex]
    for i, fromColor in ipairs(paletteConfig.secondaryMagicColors) do
	  if (toColors == nil) then 
	    directives = string.format("%s?replace=%s=%s", directives, fromColor, fromColor)
      else
	    directives = string.format("%s?replace=%s=%s", directives, fromColor, toColors[i])
	  end
    end
    --`directives` would be ?replace=111=222?replace=333=444...
  end
  animator.setGlobalTag("metalDirectives", directives)
end

-- Finds a status, returns true if it is found
function hasStatus(theStatusInQuestion)
  effects = status.activeUniqueStatusEffectSummary()
    if (#effects > 0) then
      for i=1, #effects do
		if (effects[i][1] == theStatusInQuestion) then
		  return true
		end
	  end     
	end
  return false
end

-- Used for the arm scripts, to make life easier
function extraarmstech_soundFunction(soundBool, arbitraryBool, soundName, loopAmount)
  if (soundBool) then
	if (not arbitraryBool) then animator.playSound(soundName, loopAmount) end
    arbitraryBool = true
  else
    animator.stopAllSounds(soundName)
    arbitraryBool = false
  end
end
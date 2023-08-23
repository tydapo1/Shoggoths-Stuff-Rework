function left_shotgun_init()
	left_shotgun_ammoMax = math.ceil(6 * (status.stat("maxEnergy") / 100))
	left_shotgun_ammo = left_shotgun_ammoMax
	left_shotgun_recoil = {-66.0,0}
	left_shotgun_preventAutofire = false
	left_shotgun_idleTimerMax = 1.5
	left_shotgun_idleTimer = 0
	left_shotgun_firstReload = true
	left_shotgun_firstBullet = true
	left_shotgun_frameArray = {"idle", 1, 2, 3, 4, 5}
	left_shotgun_currentFrame = 1
	left_shotgun_animationTimerDelay = 3
	left_shotgun_animationTimer = 0
	left_shotgun_totaldamage = 25 * status.stat("powerMultiplier")
	left_shotgun_bulletsperclick = 25
	left_shotgun_damageperbullet = left_shotgun_totaldamage / left_shotgun_bulletsperclick
end

function left_shotgun_update(args, dt)
	if ((args.moves["primaryFire"]) and (not left_shotgun_preventAutofire)) then
		if (left_shotgun_ammo > 0) then
			animator.playSound("leftshotgunshoot", 0)
			left_shotgun_ammo = left_shotgun_ammo - 1
			left_shotgun_spawnBullets()
			-- recoil
			local finalVector = vec2.div((vec2.rotate(left_shotgun_recoil, extraarmstech_leftAngle)), 2)
			mcontroller.addMomentum(finalVector)
		else
			animator.playSound("leftshotgunempty", 0)
		end
		animator.setGlobalTag("leftFrame", "idle")
		left_shotgun_preventAutofire = true
		left_shotgun_idleTimer = 0
		left_shotgun_animationTimer = left_shotgun_animationTimerDelay
		left_shotgun_firstReload = true
		left_shotgun_firstBullet = true
	end
	if ((not args.moves["primaryFire"]) and (left_shotgun_preventAutofire)) then
		left_shotgun_preventAutofire = false
	end
	if ((not args.moves["primaryFire"]) and (not left_shotgun_preventAutofire)) then
		if (not (left_shotgun_ammo >= left_shotgun_ammoMax)) then
			if (left_shotgun_idleTimer < left_shotgun_idleTimerMax) then
				left_shotgun_idleTimer = left_shotgun_idleTimer + dt
			else
				if (left_shotgun_animationTimer <= 0) then
					left_shotgun_animationTimer = left_shotgun_animationTimerDelay
					if (left_shotgun_currentFrame == 1) then
						if (left_shotgun_firstReload) then
							animator.playSound("leftshotgunreloadfirst", 0)
							left_shotgun_firstReload = false
							left_shotgun_animationTimer = left_shotgun_animationTimer + 10
						--else
							--animator.playSound("leftshotgunreload", 0)
						end
					end
					if ((left_shotgun_currentFrame == 6) and (not left_shotgun_firstBullet)) then
						left_shotgun_ammo = left_shotgun_ammo + 1
						animator.playSound("leftshotgunreload", 0)
					end
					if ((left_shotgun_currentFrame == 6) and (left_shotgun_firstBullet)) then
						left_shotgun_firstBullet = false
					end
					local nextFrame = left_shotgun_currentFrame + 1
					if (nextFrame > #left_shotgun_frameArray) then
						nextFrame = 1
					end
						animator.setGlobalTag("leftFrame", "active." .. left_shotgun_frameArray[nextFrame])
						left_shotgun_currentFrame = nextFrame
				else
					left_shotgun_animationTimer = left_shotgun_animationTimer - 1
				end
			end
		end
	end
end

function left_shotgun_uninit()
	animator.setGlobalTag("leftFrame", "idle")
	left_shotgun_ammo = 0
end

function left_shotgun_spawnBullets()
	for i=1,left_shotgun_bulletsperclick do
		left_shotgun_spawnBullet()
	end
	local pos = vec2.add(animator.partPoint("leftFist", "limbTip"),entity.position())
	local direction = vec2.rotate(extraarmstech_defaultVec,extraarmstech_leftAngle)
	world.spawnProjectile("srm_extraarms_muzzleflash", pos, entity.id(), direction, true)
end

function left_shotgun_spawnBullet()
	local pos = vec2.add(animator.partPoint("leftFist", "bulletSpawn"),entity.position())
	local direction = vec2.rotate(extraarmstech_defaultVec,extraarmstech_leftAngle)
	local spread = (math.random() - 0.5) * 0.1 * math.pi
	direction = vec2.rotate(direction, spread)
	world.spawnProjectile("bullet-1", pos, entity.id(), direction, false, {knockback=50,piercing=false,power=left_shotgun_damageperbullet})
end
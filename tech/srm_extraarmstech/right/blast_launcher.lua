function right_blast_launcher_init()
	right_blast_launcher_ammoMax = math.ceil(5 * (status.stat("maxEnergy") / 100))
	right_blast_launcher_ammo = right_blast_launcher_ammoMax
	right_blast_launcher_recoil = {-200.0,0}
	right_blast_launcher_preventAutofire = false
	right_blast_launcher_damage = 10
	right_blast_launcher_projectileParameters = {
		knockback=right_blast_launcher_damage*5,
		power=right_blast_launcher_damage*status.stat("powerMultiplier"),
		piercing=true,
		timeToLive=0.0,
		damageKind="hidden",
		damageTeam={type="friendly"},
		actionOnReap={{action="config",file="/projectiles/explosions/regularexplosion2/regularexplosionknockback.config"}}
	}
end

function right_blast_launcher_update(args, dt)
	if (mcontroller.onGround() or mcontroller.zeroG()) then right_blast_launcher_ammo = right_blast_launcher_ammoMax end
	if ((args.moves["altFire"]) and (not right_blast_launcher_preventAutofire)) then
		if (right_blast_launcher_ammo > 0) then
			animator.playSound("rightblast_launchershoot", 0)
			right_blast_launcher_ammo = right_blast_launcher_ammo - 1
			-- recoil
			local pos = vec2.add(animator.partPoint("rightFist", "limbTip"),entity.position())
			local direction = vec2.rotate(extraarmstech_defaultVec,extraarmstech_rightAngle)
			world.spawnProjectile("invisibleprojectile", pos, entity.id(), direction, false, right_blast_launcher_projectileParameters)
			local finalVector = vec2.div((vec2.rotate(right_blast_launcher_recoil, extraarmstech_rightAngle)), 2)
			--mcontroller.setVelocity(finalVector)
			mcontroller.controlApproachVelocity(finalVector, 5000)
		else
			animator.playSound("rightblast_launcherempty", 0)
		end
		right_blast_launcher_preventAutofire = true
		right_blast_launcher_idleTimer = 0
		right_blast_launcher_firstReload = true
		right_blast_launcher_firstBullet = true
	end
	if ((not args.moves["altFire"]) and (right_blast_launcher_preventAutofire)) then
		right_blast_launcher_preventAutofire = false
	end
end

function right_blast_launcher_uninit()
	right_blast_launcher_ammo = 0
end
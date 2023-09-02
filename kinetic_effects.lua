








function fire(gun,barrelCoords)
    if(gun.mouseDownSound and getPlayerMouseDown())then
    	if(not gun.loopSoundFile)then 
			PlaySound(gun.mouseDownSound, barrelCoords.pos, 50, false)
		end
    elseif(not gun.tailOffSound or not getPlayerMouseDown())then
    	PlaySound(gun.sound, barrelCoords.pos, 50, false)
    	-- PlaySound(explosion_sounds[math.random(1,#explosion_sounds)],barrelCoords.pos, 400, false)
		
    end


	if(not oldShoot)then
		if(gun.weaponType =="special") then 
			pushSpecial(barrelCoords,gun)
		--	DebugWatch("USING",gun.name)
		else
			pushProjectile(barrelCoords,gun)
		end
	else 
		local cannonLoc=  barrelCoords--rectifyBarrelCoords(gun)
			QueryRejectBody(vehicle.body)
			QueryRejectShape(gun.id)
			local fwdPos = TransformToParentPoint(cannonLoc, Vec(0,  maxDist * -1),1)
		    local direction = VecSub(fwdPos, cannonLoc.pos)
		    direction = VecNormalize(direction)
		    QueryRequire("physical")
		    hit, dist = QueryRaycast(cannonLoc.pos, direction, maxDist)
		    -- utils.printStr(dist)

		    if hit then
				hitPos = TransformToParentPoint(cannonLoc, Vec(0, dist * -1,0))
			else
				hitPos = TransformToParentPoint(cannonLoc, Vec(0,  maxDist * -1,0))
			end
		      	p = cannonLoc.pos

				d = VecNormalize(VecSub(hitPos, p))
				spread = 0.03
				d[1] = d[1] + ((math.random()-0.5)*2*spread)*dist/maxDist
				d[2] = d[2] + ((math.random()-0.5)*2*spread)*dist/maxDist
				d[3] = d[3] + ((math.random()-0.5)*2*spread)*dist/maxDist
				d = VecNormalize(d)
				p = VecAdd(p, VecScale(d, 0.5))
				

				-- if(gun.highVelocityShells)then
						-- utils.printStr(gun.loadedMagazine)--type(munitions[gun.magazines[gun.loadedMagazine].name]))
					-- if (gun.magazines[gun.loadedMagazine].CfgAmmo.maxPenDepth and hit) then
							
					-- 	cannonLoc.pos = hitPos
					-- 	pushShell(gun,hitPos,dist,(maxDist-dist),cannonLoc)

					-- else

					-- 	pushShell(gun,hitPos,dist)
					-- end
				-- else
					Shoot(p, d,0)
				-- end		
	end

	

end


---



----

---- specials

-----

function pushSpecial(barrelCoords,gun)
	fireFoam(barrelCoords,gun)
end



function fireFoam(cannonLoc,gun)

	local fwdPos = TransformToParentPoint(cannonLoc, Vec(0,-1,0))
	local direction = VecSub(fwdPos, cannonLoc.pos)
	local p = cannonLoc.pos

	local shellType = gun.magazines[gun.loadedMagazine].CfgAmmo
	local predictedBulletVelocity = VecScale(direction,shellType.velocity)

	local q = 1.0 
	for i=1, 64 do
		
		local v = VecAdd(VecScale(predictedBulletVelocity,rnd(7,14)/10),rndVec(shellType.velocity/5))---VecNormalize(direction)--rndVec(projectile.weaponClass.ammo.caliber*0.3)
		local radius = 1
		radius = rnd(radius/2,radius*2) *0.01
		local stretch = rnd(-1,1)
		local endStretch = rnd(-1,1)
		local life = rnd(0.2, 0.7)*30
		life = 0.5 + life*life*life * 0.7

		local w = 0.8-q*0.6
		local w2 = 1.0
		local r = 0.5 *(0.5 + 0.5*q)
		ParticleReset()
		ParticleTile(2)
		ParticleType("smoke")
		ParticleCollide(0.1, 1)
		ParticleFlags(256)
		ParticleColor(w*(rnd(3,6)/10), w*(rnd(3,6)/10), w, w2*(rnd(4,6)/10), w2*(rnd(4,6)/10), w2)
		ParticleRadius(0.5*r, r)
		ParticleGravity(rnd(-2,-20))
		ParticleDrag(0.01)
		ParticleSticky(0.02)
		ParticleAlpha(q, q, "constant", 0, 0.5)
		SpawnParticle(p, v, rnd(3,5))

	end
end





----- payload handlers


	--- @payload_tank_he

----


function payload_tank_he(shell,hitPos,hitTarget,test,custom_explosion_size,non_penetration)

	--Explosion(VecLerp(shell.last_flight_pos,hitPos,0.8),0.3)

	local explosion_size = shell.shellType.explosionSize
	if(custom_explosion_size~=nil ) then 
		explosion_size = custom_explosion_size
	end
	impact_size = explosion_size
	if(non_penetration ~= nil) then
		impact_size = impact_size
		explosion_size = impact_size*.25
	end
	local hard_damage = 0.2
	if(globalConfig.shrapnel_hard_damage_coef[shell.shellType.payload]~= nil ) then 
		hard_damage = hard_damage * globalConfig.shrapnel_hard_damage_coef[shell.shellType.payload] 
	end
	MakeHole(hitPos,explosion_size*1.5,explosion_size*1,explosion_size*hard_damage)

	-- DebugWatch("EXPLOSION SIZE",explosion_size)
	Paint(hitPos,explosion_size*(1+math.random()) , "explosion")
	if shell.shellType.explosionSize >0.5 then 
		local coef_explosion  = explosion_size--/clamp(math.log(shell.gun_RPM),1,100))
		-- DebugWatch("EXPLOSION COEF",coef_explosion)
		explosionController:pushExplosion(hitPos,coef_explosion)
	end
	-- if(shell.shellType.explosionSize>1) then 
		-- shell.shellType.explosionSize
		-- DebugPrint("test: ".. 130*shell.shellType.explosionSize)
		-- DebugWatch("test",IsHandleValid(explosion_sounds[math.random(1,#explosion_sounds)]))
		
		PlaySound(explosion_sounds[math.random(1,#explosion_sounds)], hitPos, 15*(explosion_size*explosion_size), false)
			

	-- end 

	-- DebugWatch("EXPLOSION SIZE1",explosion_size)

	-- hurt player if needed
	local hurt_dist = explosion_size*2.1
	local toPlayer = VecSub(GetPlayerCameraTransform().pos, hitPos)
	local distToPlayer = VecLength(toPlayer)
	local distScale = clamp(1.0 - distToPlayer / hurt_dist, 0.0, 1.0)
	if distScale > 0 then
		local hit = QueryRaycast(hitPos, toPlayer, distToPlayer)
		if(not hit) then 
			local regular_damage = explosion_size*100
			local expected_damage = math.random((regular_damage*.75),regular_damage*1.25)/100
			local player_damage = 
				SetPlayerHealth(GetPlayerHealth() - expected_damage*distScale)
			end
	end

	--- create a series of firethreshold
	local firePos = Vec(0,0,0)
	local unitVec = Vec(0,0,0)
	local maxDist = explosion_size*1.5
	shell.shellType.caliber = shell.shellType.caliber
	pushshrapnel(shell.cannonLoc,shell,test,hitTarget)

	-- DebugWatch("EXPLOSION SIZE2",explosion_size)
	for i = 1,math.max(math.random(5,15)*explosion_size,1) do
		for xyz = 1,3 do 
			unitVec[xyz] = (math.random()*2)-1 
		end
		-- QueryRejectShape(hitTarget)
		local hit, dist = QueryRaycast(hitPos,VecNormalize(unitVec),maxDist)
		if hit and (math.random()>globalConfig.fire_chance_thres) then
			firePos = VecAdd(hitPos, VecScale(unitVec, dist))
			SpawnFire(firePos)
			-- DebugPrint(dist)

		end
	end

	-- DebugWatch("EXPLOSION SIZE3",explosion_size)

end




---- 

---- PROJECTILE HANDLING

---

function pushProjectile(cannonLoc,gun)
	local fwdPos = TransformToParentPoint(cannonLoc, Vec(0,-1,0))

	local direction = VecSub(fwdPos, cannonLoc.pos)

	local point1 = cannonLoc.pos
	local point1 = VecAdd(point1,
						VecScale(
							GetBodyVelocity(
								GetVehicleBody(vehicle.id)),GetTimeStep()))	
	---
				-- local predictedBulletVelocity = VecScale(direction,velocity)

	projectileHandler.shells[projectileHandler.shellNum] = deepcopy(projectileHandler.defaultShell)

	loadedShell 				= projectileHandler.shells[projectileHandler.shellNum] 
	loadedShell.active 			= true
	loadedShell.shellType = gun.magazines[gun.loadedMagazine].CfgAmmo
	loadedShell.cannonLoc 			= cannonLoc
	loadedShell.point1			= point1
	loadedShell.lastPos 		= point1
	loadedShell.predictedBulletVelocity = VecScale(direction,loadedShell.shellType.velocity)
	loadedShell.originVehicle = vehicle.id
	loadedShell.originPos 	  = GetShapeWorldTransform(gun.id)
	loadedShell.originGun	  = gun.id
	loadedShell.originGun_data	 = deepcopy(gun)
	loadedShell.timeToLive	  = loadedShell.shellType.timeToLive
	loadedShell.gun_RPM 	  = gun.RPM 
	if(gun.dispersion) then 
		loadedShell.dispersion 	  = gun.dispersion
	else
		loadedShell.dispersion 	  = 1
	end
	local loadedMagazine =  gun.magazines[gun.loadedMagazine]
	local currentMagazine =	loadedMagazine.magazinesAmmo[gun.magazines[gun.loadedMagazine].currentMagazine]
	if (loadedShell.shellType.tracer and 
		 gun.magazines[gun.loadedMagazine].magazinesAmmo[gun.magazines[gun.loadedMagazine].currentMagazine].AmmoCount % loadedShell.shellType.tracer ==0)
	then
		loadedShell.tracer = true
	end
	--[[

		Distance values
		
	]]

	loadedShell.distance_travelled 	  = 0 
	loadedShell.optimum_distance 	  = 100
	if(loadedShell.shellType.optimum_distance~=nil) then 
		loadedShell.optimum_distance = loadedShell.shellType.optimum_distance
	end 


	loadedShell.pen_dist_coef= 1

	--[[
		Penetration values
	]]

	loadedShell.penDepth = loadedShell.shellType.maxPenDepth
	if(globalConfig.penCheck>=loadedShell.shellType.maxPenDepth)then
		loadedShell.maxChecks  =1
	else
		loadedShell.maxChecks = loadedShell.shellType.maxPenDepth/globalConfig.penCheck
	end
	projectileHandler.shellNum = (projectileHandler.shellNum%#projectileHandler.shells) +1

end

function initClusterBomblets(parentProjectile)

	for i=1,math.random(5,10) do
		pushClusterProjectile(parentProjectile.flightPos,parentProjectile)
		
	end
end


function pushClusterProjectile(bombletPos,parentProjectile)
	local fwdPos = TransformToParentPoint(bombletPos, Vec(0,-1,0))
	local direction = VecSub(fwdPos, bombletPos.pos)
	local point1 = bombletPos.pos
	projectileHandler.shells[projectileHandler.shellNum] = deepcopy(projectileHandler.defaultShell)

	local fwdPos = TransformToParentPoint(bombletPos, Vec(math.random(-10,10),-10,math.random(-10,10)))
	local direction = VecSub( fwdPos,bombletPos.pos)
	local point1 = bombletPos.pos
	projectileHandler.shells[projectileHandler.shellNum] = deepcopy(projectileHandler.defaultShell)
	local currentBomblet				= projectileHandler.shells[projectileHandler.shellNum] 
	currentBomblet.active 			= true 
	currentBomblet.shellType = deepcopy(parentProjectile.shellType)
	--- bomblet specific
	currentBomblet.shellType.payload = currentBomblet.shellType.bomblet.payload
	currentBomblet.shellType.explosionSize = currentBomblet.shellType.bomblet.explosionSize  
	currentBomblet.shellType.gravityCoef = currentBomblet.shellType.bomblet.gravityCoef
	---
	currentBomblet.cannonLoc 			= bombletPos
	currentBomblet.point1			= point1 
	currentBomblet.lastPos 			= point1

	local predictedBulletVelocity = VecScale(parentProjectile.predictedBulletVelocity,0.7)

	predictedBulletVelocity = VecAdd(
				predictedBulletVelocity,
				VecScale(rndVec(currentBomblet.shellType.bomblet.dispersion),
				math.log(parentProjectile.shellType.velocity)))
	currentBomblet.predictedBulletVelocity = predictedBulletVelocity
	currentBomblet.originVehicle = parentProjectile.originVehicle
	currentBomblet.originPos 	  = bombletPos 
	currentBomblet.originGun = parentProjectile.originGun
	currentBomblet.timeToLive	  = parentProjectile.timeToLive
	currentBomblet.dispersion 	  = 1
	currentBomblet.penDepth = parentProjectile.penDepth
	currentBomblet.maxChecks = parentProjectile.maxChecks
	currentBomblet.bomblet = true
	currentBomblet.shellType.airburst = false
	currentBomblet.shellType.shellWidth = math.max(math.random() * 
				(currentBomblet.shellType.shellWidth * 1),0.1 )
	currentBomblet.shellType.shellHeight = math.max(math.random() * 
				(currentBomblet.shellType.shellWidth * 1),0.1) 
		

	projectileHandler.shellNum = (projectileHandler.shellNum%#projectileHandler.shells) +1
end


--[[ @pop_projectile

		CODE TO RUN ON PROJECTILE IMPACT

		CONTROLS SHELL PENTRATION AND ALL SORTS

]]

function popProjectile(shell,hitTarget)


		if(shell.shellType.payload=="cluster") then
			if(VecLength(VecSub(shell.flightPos.pos,shell.originPos.pos))>10) then 
				Explosion(shell.flightPos.pos,shell.shellType.explosionSize)


			end
			PlaySound(explosion_sounds[math.random(1,#explosion_sounds)], shell.point1, 20*(shell.shellType.explosionSize*shell.shellType.explosionSize), false)

			initClusterBomblets(shell)
			shell.penDepth = 0
			
		end
		local penetration,passThrough,test,penDepth,dist,spallValue =  getProjectilePenetration(shell,hitTarget)
		local holeModifier = math.random(-15,15)/100
		impactEffect(shell,test.pos,hitTarget)
		if(debug_combat_stuff) then 
			DebugWatch("shell damage",shell.shellType.bulletdamage[1])

			DebugWatch("penDepth",shell.penDepth)
		end

		local pos = test.pos
		local impact_factor = 1
		if(shell.penDepth >0) then 
			impact_factor = 0.2
		end

		apply_impact_impulse(pos,shell,hitTarget,impact_factor)
		
		-- DebugPrint("hit target")
		if ((HasTag(hitTarget,"component") and 
			(GetTagValue(hitTarget,"component") == "ERA" or
			GetTagValue(hitTarget,"component") == "cage"  or
			GetTagValue(hitTarget,"component") == "spaced"))  or
			(shell.penDepth<=0 and  shell.shellType.payload == "HEAT")) then
			if(debug_special_armour) then 
				DebugPrint("hit armour with shell : "..shell.shellType.payload)
				DebugPrint("hit ERA_test")
			end
			if(shell.shellType.payload and (shell.shellType.payload == "HEAT" or 
												shell.shellType.payload == "HESH") and shell.shellType.chargeType==nil)  then
				local explosionPos = TransformToParentPoint(Transform(shell.point1,test.rot), Vec(0,-.1,0))
				--Explosion(explosionPos,0.5)
				if(debug_special_armour) then 
					DebugPrint("hit armour with shell : "..shell.shellType.payload)
				end
				-- shell.shellType.payload = "HE"
				shell.penDepth = shell.penDepth *.5
				local explosive_payload = math.random(5,40)/10
				payload_tank_he(shell,explosionPos,hitTarget,test,explosive_payload,true)
				PlaySound(explosion_sounds[math.random(1,#explosion_sounds)], explosionPos, 15*shell.shellType.explosionSize, false)
				if((HasTag(hitTarget,"component") and 
						(GetTagValue(hitTarget,"component") == "ERA" or
						GetTagValue(hitTarget,"component") == "cage"  or
						GetTagValue(hitTarget,"component") == "spaced"))) 
				then 
					if(debug_special_armour) then 
						DebugPrint("hit special armour, confirmed armour hit: "..GetTagValue(hitTarget,"component") )
					end
					explosionController:pushExplosion(shell.point1,.75)
				end
			-- 	DebugPrint("armor too thick")
				
				shell.active = false
				for key,val in ipairs( shell ) do 
					val = nil

				end
				shell = deepcopy(projectileHandler.defaultShell)
				return false
			elseif(shell.shellType.payload and (shell.shellType.payload == "HEAT" or 
												shell.shellType.payload == "HESH") and shell.shellType.chargeType=='tandem') then 
				 shell_passthrough_penetration(shell,test,spallValue,holeModifier)
				if(debug_special_armour) then 
						DebugPrint("hit special armour, confirmed armour hit: "..GetTagValue(hitTarget,"component").." and hit with Tandem warhead" )
				end
				shell.penDepth = shell.penDepth *.6
					explosionController:pushExplosion(shell.point1,1.75)
					shell.shellType.chargeType = nil
				return false
			elseif(shell.penDepth>0 and shell.shellType.payload and (shell.shellType.payload == "AP" or
												shell.shellType.payload == "APHE")) then
				shell.penDepth = shell.penDepth *.8
			elseif(shell.penDepth>0 and shell.shellType.payload and (shell.shellType.payload == "kinetic" or
												shell.shellType.payload == "APSDF")) then
				shell.penDepth = shell.penDepth *.9
			end
		

		elseif(shell.shellType.caliber>30) then 
			local coef_explosion = 200--/shell.gun_RPM
			explosionController:pushExplosion(pos,shell.shellType.caliber/coef_explosion )
		

		end


		SpawnParticle("smoke", shell.point1, Vec(0,1,0), (math.log(shell.shellType.caliber)/2)*(1+holeModifier), math.random(1,3))
		SpawnParticle("fire", shell.point1, Vec(0,1,0), (math.log(shell.shellType.caliber)/4)*(1+holeModifier) , .25)



		if(shell.shellType.payload and shell.penDepth>0 and 
			(shell.shellType.payload == "HEAT" or shell.shellType.payload == "HEAT-MP"))  then

			PlaySound(explosion_sounds[math.random(1,#explosion_sounds)],shell.point1, 15*shell.shellType.explosionSize, false)
		
			--	MakeHole(shell.point1,shell.shellType.bulletdamage[1]*(1+holeModifier),shell.shellType.bulletdamage[2]*(1+holeModifier), shell.shellType.bulletdamage[3]*(1+holeModifier))
			--	MakeHole(test.pos,shell.shellType.bulletdamage[1]*(1+holeModifier),shell.shellType.bulletdamage[2]*(1+holeModifier), shell.shellType.bulletdamage[3]*(1+holeModifier))
			
			if(dist > globalConfig.HEATRange or dist == 0) then
				dist = ((shell.shellType.caliber/100)*2)*1.5
			elseif dist <1 then
				dist=(shell.shellType.caliber/100)*1.25
			end
			


			local explosionPos = VecCopy(test.pos)
			-- DebugPrint(dist)
			-- DebugPrint((shell.shellType.caliber/100)*2)
			local explosionPos_initial = TransformToParentPoint(Transform(shell.point1,test.rot), Vec(0,1,0))
			payload_tank_he(shell,explosionPos_initial,hitTarget,test)
			-- create penetration explosions and spalling, starting just a little deeper inside.
			local start_dist = 1 
			local heat_pen_force = (dist*1.5)/0.75
			local pen_increment = 0.75
			for i=start_dist,(dist*1.0)+start_dist,pen_increment  do

				explosionPos = TransformToParentPoint(test, Vec(0,i-0.25,0))

	    		-- explosionPos = VecAdd(explosionPos, test.pos)
	    		-- if(i < (dist*1.5)/2) then 
					-- Explosion(explosionPos,0.5)
					payload_tank_he(shell,explosionPos,hitTarget,test,0.25*(start_dist/i))

				-- end

	    		-- projectileShrapnel(shell,Transform(explosionPos,test.rot),spallValue/(heat_pen_force) )

				explosive_penetrator_effect(shell,explosionPos)



			end
			-- DebugPrint("start  explostion pos  "..vec2str(test.pos))
			explosionPos = TransformToParentPoint(test, Vec(0,dist*.7+0.25,0))
			-- DebugPrint("end explostion pos  "..vec2str(explosionPos))

			for i=1,math.random(3,10) do 

	    		projectileShrapnel(shell,Transform(explosionPos,test.rot),spallValue/(heat_pen_force) )
	    	end

			-- if(shell.shellType.payload == "HEAT-MP") then
			-- 	local mp_blast = TransformToParentPoint(Transform(shell.point1,test.rot), Vec(0,-.8,0))
			-- 	explosion(mp_blast0.7)
			-- end
		
			shell.active = false
			for key,val in ipairs( shell ) do 
				val = nil

			end
			shell = deepcopy(projectileHandler.defaultShell)

		elseif(shell.shellType.payload and shell.shellType.payload == "HESH") then
			local explosionPos = TransformToParentPoint(Transform(shell.point1,test.rot), Vec(0,-.45,0))
			Explosion(explosionPos,0.5)

			PlaySound(explosion_sounds[math.random(1,#explosion_sounds)],explosionPos, 15*shell.shellType.explosionSize, false)
		
			explosionPos = TransformToParentPoint(test, Vec(0,.35,0))
			MakeHole(explosionPos,shell.shellType.bulletdamage[1]*((1.4+holeModifier)*.5),
						shell.shellType.bulletdamage[2]*((1.2+holeModifier)*.5), 
						shell.shellType.bulletdamage[3]*((1.2+holeModifier)*0.5))

			projectileShrapnel(shell,test,spallValue)
	
			shell.active = false
			for key,val in ipairs( shell ) do 
				val = nil

			end
			shell = deepcopy(projectileHandler.defaultShell)


		elseif(shell.penDepth>0) then		
			-- DebugPrint("2".." "..shell.penDepth)
					-- Explosion(shell.point1,0.5)
					-- MakeHole(shell.point1,1,.7,.5)
					-- gun.magazines[i].CfgAmmo
  				
					-- shellPenetration(shell,test,dist)
					shell.point1 = test.pos
					-- if shell.shellType.hit and shell.shellType.hit <3 then
					-- 	if(shell.shellType.hit ==1)then
					-- 		MakeHole(shell.point1,shell.shellType.bulletdamage[1]*(1.4+holeModifier))
					-- 	else
					-- 		MakeHole(shell.point1,shell.shellType.bulletdamage[1]*(1.4+holeModifier),shell.shellType.bulletdamage[2]*(1.2+holeModifier))
					-- 	end

					-- else
					-- 	MakeHole(shell.point1,shell.shellType.bulletdamage[1]*(1.4+holeModifier),shell.shellType.bulletdamage[2]*(1.2+holeModifier), shell.shellType.bulletdamage[3]*(1.2+holeModifier))
					-- end
					MakeHole(shell.point1,shell.shellType.bulletdamage[1]*(1.4+holeModifier),shell.shellType.bulletdamage[2]*(1.2+holeModifier), shell.shellType.bulletdamage[3]*(1.2+holeModifier))
					projectileShrapnel(shell,test,spallValue)
					explosive_penetrator_effect(shell,test.pos)


					shell.predictedBulletVelocity = VecAdd(shell.predictedBulletVelocity,rndVec(shell.shellType.velocity/(shell.penDepth*10)))
					
					-- SpawnParticle("darksmoke",test.pos, Vec(0, -.1, 0), shell.shellType.bulletdamage[2], 2)
					-- SpawnParticle("darksmoke",test.pos, Vec(0, -.1, 0), shell.shellType.bulletdamage[2], 2)
		else
			-- DebugPrint("3 ".." "..shell.penDepth)
			local shell_hole = deepcopy(shell.shellType.bulletdamage)
			for i = 1,3 do 
				shell_hole[i] = shell_hole[i] +shell.penDepth 
			end

			holeModifier = holeModifier *(1-math.random(1,50)/100)
			if(not penetration) then 
				holeModifier = clamp(-1,0,(-(math.random(50,150)/100))+(shell.penDepth*100))
				--DebugWatch("non pen val hole modifier",holeModifier)
				-- DebugWatch("shell pen depth",shell.penDepth*100)
			end
			if(shell.shellType.payload) then

				if(shell.shellType.payload == "high-explosive") then
					Explosion(test.pos,shell.shellType.explosionSize)
				elseif(shell.shellType.payload == "explosive" or shell.shellType.payload == "HE" or shell.shellType.payload == "APHE") then 
					-- local explosion_pos = VecLerp(shell.last_flight_pos, test.pos,0.8)
					local explosion_pos = TransformToParentPoint(Transform(test.pos,test.rot), Vec(0,-0.25,0))
					payload_tank_he(shell,explosion_pos ,hitTarget,test)
				elseif(shell.shellType.payload == "incendiary") then
					if shell.shellType.hit and shell.shellType.hit <3 then
						if(shell.shellType.hit ==1)then
							MakeHole(shell.point1,shell_hole[1]*(1+holeModifier))
						else

							MakeHole(shell.point1,shell_hole[1]*(1+holeModifier),shell_hole[2]*(1+holeModifier))
						end

					else
						MakeHole(shell.point1,
							shell_hole[1]*(1+holeModifier),
							shell_hole[2]*(1+holeModifier), 
							shell_hole[3]*(1+holeModifier))
					end


					local fireChance = math.random()
					if(fireChance>globalConfig.fire_chance_thres)then
						SpawnFire(test.pos)
					end
				elseif(shell.shellType.payload == "incendiary") then
					if shell.shellType.hit and shell.shellType.hit <3 then
						if(shell.shellType.hit ==1)then
							MakeHole(shell.point1,
								shell_hole[1]*(1+holeModifier))
						else

							MakeHole(shell.point1,shell_hole[1]*(1+holeModifier),
								shell_hole[2]*(1+holeModifier))
						end

					else
						MakeHole(shell.point1,shell_hole[1]*(1+holeModifier),
							shell_hole[2]*(1+holeModifier),
							shell_hole[3]*(1+holeModifier))
					end


					local fireChance = math.random()
					if(fireChance>globalConfig.fire_chance_thres)then
						SpawnFire(test.pos)
					end
					-- DebugWatch("fire change: ",fireChance)
				elseif(shell.shellType.payload == "HE-I") then

						MakeHole(shell.point1,
							shell_hole[1]*(1+holeModifier),
							shell_hole[2]*(1+holeModifier), 
							shell_hole[3]*(1+holeModifier))
					
					SpawnFire(test.pos)
				elseif(shell.shellType.payload == "smoke") then
					-- MakeHole(shell.point1,1,.7,.5)
					local ShellSmoke = math.log(shell.shellType.caliber*2) 
					if( shell.smokeFactor) then
						ShellSmoke = shell.smokeFactor
					end
					for i =1,5 do 
					SpawnParticle("smoke",test.pos, Vec(math.random(-1,1), math.random(-2,1), math.random(-1,1)), ShellSmoke, 10)
					end
				elseif(shell.shellType.payload == "kinetic" or shell.shellType.payload == "AP") then
					if(shell.shellType.caliber>30) then 
						explosionController:pushExplosion(pos,shell.shellType.caliber/200)
					end

					if shell.shellType.hit and shell.shellType.hit <3 then
						if(shell.shellType.hit ==1)then
							MakeHole(shell.point1,
								shell_hole[1]*(1+holeModifier))
						else

							MakeHole(shell.point1,
								shell_hole[1]*(1+holeModifier),
								shell_hole[2]*(1+holeModifier))
						end

					else
						MakeHole(shell.point1,
							shell_hole[1]*(1+holeModifier),
							shell_hole[2]*(1+holeModifier), 
							shell_hole[3]*(1+holeModifier))
					end
				end
				
			end
			shell.active = false
			for key,val in ipairs( shell ) do 
				val = nil

			end
			shell = deepcopy(projectileHandler.defaultShell)
			-- utils.printStr("penetration  explosion")
		-- shellPenetration(shell)
		-- shell = deepcopy(artilleryHandler.defaultShell)
		end


end


function shell_passthrough_penetration(shell,test,spallValue,holeModifier)
	shell.point1 = test.pos
	MakeHole(shell.point1,shell.shellType.bulletdamage[1]*(1.4+holeModifier),
		shell.shellType.bulletdamage[2]*(1.2+holeModifier), 
		shell.shellType.bulletdamage[3]*(1.2+holeModifier))
	projectileShrapnel(shell,test,spallValue)
	explosive_penetrator_effect(shell,test.pos)
	shell.predictedBulletVelocity = VecAdd(shell.predictedBulletVelocity,rndVec(shell.shellType.velocity/(shell.penDepth*10)))
	
end



function projectileShrapnel(projectile,test,spallValue)


			local projectile_vel = 80
			local projectile_caliber = 20
			
			if(projectile.shellType.velocity) then
				projectile_vel = projectile.shellType.velocity

			end
			if(projectile.shellType.caliber) then
				projectile_caliber =projectile.shellType.caliber

			end
			local strength = math.log(projectile_vel)*math.log(projectile_caliber )	--Strength of blower
			local maxMass = 2400	--The maximum mass for a body to be affected
			local maxDist = 1	--The maximum distance for bodies to be affected
				--Get all physical and dynamic bodies in front of camera
			
			local t = test
			
			local t1 = TransformToParentPoint(t, Vec(0,  maxDist/2,0))
			local c = TransformToParentPoint(t, Vec(0, -maxDist/2, 0))
			local mi = VecAdd(c, Vec(-maxDist/2, -maxDist/2, -maxDist/2))
			local ma = VecAdd(c, Vec(maxDist/2, maxDist/2, maxDist/2))
			QueryRequire("physical dynamic")
			
			local bodies = QueryAabbBodies(mi, ma)

			--Loop through bodies and push them
			for i=1,#bodies do
				local b = bodies[i]


				--Compute body center point and distance
				local bmi, bma = GetBodyBounds(b)
				local bc = VecLerp(bmi, bma, 0.5)
				local dir = VecSub(t1, bc )
				local dist = VecLength(dir)
				dir = VecScale(dir, 1.0/dist)

				--Get body mass
				local mass = GetBodyMass(b)
				
				--Check if body is should be affected
				if dist < maxDist and mass < maxMass then
					--Make sure direction is always pointing slightly upwards
					dir[2] = 0.1
					dir = VecNormalize(dir)
			
					--Compute how much velocity to add
					local massScale = 1 - math.min(mass/maxMass, 1.0)
					local distScale = 1 - math.min(dist/maxDist, 1.0)
					local add = VecScale(dir, strength * massScale * distScale)
					
					--Add velocity to body
					local vel = GetBodyVelocity(b)
					vel = VecAdd(vel, add)
					SetBodyVelocity(b, vel)
				end
			end

			pushSpalling(projectile.cannonLoc,projectile,test,spallValue)
end



----

------ SPALLING and SHRAPNAL HANDLING

function pushSpalling(spallingLoc,spallShell,test,spallValue)

	---			kinetic = 0.8,
			-- AP 		= 0.3,
			-- APHE    = 0.3,
			-- HESH 	= 2,
			-- HEI 	= 1,

	local spallFactor = 0.25
	if(spallShell.shellType.payload) then
		local spallPayload = spallShell.shellType.payload
		if(spallShell.shellType.payload =="AP") then
			spallFactor = globalConfig.spallFactor.AP
		elseif(spallShell.shellType.payload =="APHE") then
			spallFactor = globalConfig.spallFactor.APHE
		elseif(spallShell.shellType.payload =="HESH") then
			spallFactor = globalConfig.spallFactor.HESH
		elseif(spallShell.shellType.payload =="HEAT") then
			spallFactor = globalConfig.spallFactor.HESH
		elseif(spallShell.shellType.payload =="HEI" or spallShell.shellType.payload =="HE-I") then
			spallFactor = globalConfig.spallFactor.HEI
		elseif(spallShell.shellType.payload =="kinetic") then
			spallFactor = globalConfig.spallFactor.kinetic	
		end


	end
	local spall_num = spallValue*spallFactor
	spall_num = math.max(spall_num,1)*math.random(3,9)--3
--	DebugWatch("spall num ",spall_num)
	-- DebugWatch("spall_num",spall_num)
	for i=1,math.random(spall_num*.5,spall_num*1.5) do 

		local spallingSizeCoef = math.random(1,4)/10

		if(spallShell.shellType.payload == "HESH")then
			spallingSizeCoef = spallingSizeCoef * globalConfig.spallFactor.HESH
		end

		-- test.rot = QuatLookAt(spallShell.lastPos,test)
		local spallPos = TransformCopy(test)
		-- spallPos.pos = TransformToParentPoint(spallPos, 0,-16,0)

		local fwdPos = TransformToParentPoint(spallPos, Vec(math.random(-10,10),-10,math.random(-10,10)))
		local direction = VecSub( fwdPos,spallPos.pos)
		local point1 = spallPos.pos
					
		spallHandler.shells[spallHandler.shellNum] = deepcopy(spallHandler.defaultShell)

		local currentSpall 				= spallHandler.shells[spallHandler.shellNum] 
		currentSpall.active 			= true 
		currentSpall.shellType = deepcopy(spallShell.shellType) 
		currentSpall.isSpall = true
		currentSpall.cannonLoc 			= spallPos
		currentSpall.point1			= point1 
		if(spallShell.shellType.payload =="HEAT") then 
			
			currentSpall.predictedBulletVelocity = get_heat_jet(spallPos)--= VecScale(spallShell.predictedBulletVelocity,0.9)
		else
			currentSpall.predictedBulletVelocity = VecScale(spallShell.predictedBulletVelocity,0.8)
		end
		currentSpall.initial_speed = VecCopy(currentSpall.predictedBulletVelocity)
		-- currentSpall.predictedBulletVelocity = VecScale(
		-- 												VecAdd(
		-- 													VecScale(spallShell.predictedBulletVelocity,0.8),fwdPos),0.5)
		--VecScale(direction,currentSpall.shellType.velocity*.2)
		currentSpall.originPos 	  = spallPos 
		currentSpall.timeToLive	  = math.random()*(spallingSizeCoef+0.2)--(currentSpall.shellType.timeToLive *(spallingSizeCoef+0.2))*(math.random(50,100)/100)
		--DebugWatch("spall coef ttl",math.random()*(spallingSizeCoef+0.2))
		if(spallShell.shellType.payload =="HEAT") then 
			currentSpall.timeToLive	 = math.random()/3
		end

		if(spallShell.dispersion) then 
			currentSpall.dispersion 	  = 300--spallShell.dispersion*(spallShell.dispersion*10)
		elseif(spallShell.shellType.payload =="HEAT") then 
			currentSpall.dispersion = 5--70
		else
			currentSpall.dispersion 	  = 200 
		end

		-- DebugPrint("velocity: "..VecStr(currentSpall.predictedBulletVelocity).."  | pos = "..VecStr(TransformToParentPoint(spallPos, 0,-16,0)).." | "..VecStr(test.pos))
		currentSpall.shellType.bulletdamage = VecScale(currentSpall.shellType.bulletdamage,0.25)
		currentSpall.shellType.bulletdamage[1] = currentSpall.shellType.bulletdamage[1] * spallingSizeCoef
		currentSpall.shellType.bulletdamage[2] = currentSpall.shellType.bulletdamage[2] * spallingSizeCoef
		currentSpall.shellType.bulletdamage[3] = currentSpall.shellType.bulletdamage[3] * spallingSizeCoef
		currentSpall.shellType.caliber = currentSpall.shellType.caliber * spallingSizeCoef
		currentSpall.shellType.shellWidth = currentSpall.shellType.shellHeight * (spallingSizeCoef*spallingSizeCoef) 
		currentSpall.shellType.shellHeight = currentSpall.shellType.shellHeight * (spallingSizeCoef*spallingSizeCoef)
		currentSpall.penDepth = (currentSpall.shellType.maxPenDepth/2)*spallingSizeCoef
		if(globalConfig.penCheck>=currentSpall.shellType.maxPenDepth)then
			currentSpall.maxChecks  =1
		else
			currentSpall.maxChecks = currentSpall.shellType.maxPenDepth/globalConfig.penCheck
		end
		-- currentSpall.maxChecks  =2

		currentSpall.shellType.r = 1 + (math.random(0,5)/10)
		currentSpall.shellType.g = 0.7 + (math.random(0,5)/10)
		currentSpall.shellType.b = 1


		spallHandler.shellNum = (spallHandler.shellNum%#spallHandler.shells) +1
	end
	-- DebugPrint("test")

end

function get_heat_jet(spallPos)
	local weapon_jet_vel = math.random(125,200)
  	local launch_dir = TransformCopy(spallPos)
  	local z = rnd(2,6)
  	local cone = (z*.9) * math.sin(90)
    local x = rnd(-cone,cone)
    local y = rnd(-cone,cone)
    --weapon.jet_vel*.7,weapon.jet_vel*1.3)
    local jet_vel = Vec(x,-z,y)
	-- DebugWatch("jet_vel",jet_vel)

	-- DebugWatch("cone",cone)
    jet_vel  =  VecNormalize(VecSub(launch_dir.pos,TransformToParentPoint(launch_dir, jet_vel)))
    local predictedBulletVelocity = VecScale(jet_vel,rnd(weapon_jet_vel *.7,weapon_jet_vel *1.3))

    return predictedBulletVelocity

end

function popSpalling(shell,hitTarget)


		local penetration,passThrough,test,penDepth,dist,spallValue =  getProjectilePenetration(shell,hitTarget)
		-- shell.penDepth = shell.penDepth - penDepth

		local holeModifier = math.random(-15,15)/100


		-- local daamge_coef = VecLength(shell.predictedBulletVelocity)/VecLength(shell.initial_speed)
		-- DebugWatch("shell damage",shell.shellType.bulletdamage[1])
		-- DebugWatch("prior damage",shell.shellType.bulletdamage)
		-- if(VecLength(shell.initial_speed)<VecLength(shell.predictedBulletVelocity)) then 
		-- 	DebugPrint("strange occurance of more speed occured")
		-- end
	if(VecLength(shell.initial_speed))>0 and
		VecLength(shell.initial_speed)>VecLength(shell.predictedBulletVelocity) then 
	    shell.shellType.bulletdamage = VecScale(shell.shellType.bulletdamage,
	                                		VecLength(shell.predictedBulletVelocity)/
	                                		VecLength(shell.initial_speed))
	else
		shell.shellType.bulletdamage = VecScale(shell.shellType.bulletdamage,0)
	end
    -- DebugWatch("post damage",shell.shellType.bulletdamage)
	local fireChance = math.random()
	local firethreshold = globalConfig.fire_chance_thres
	if(shell.shellType.payload) then
		if(shell.shellType.payload == "incendiary") then
			firethreshold = 0.8
		elseif(shell.shellType.payload == "HESH") then
				firethreshold = 0.11 * firethreshold
		elseif(shell.shellType.payload == "HEAT") then
				firethreshold = 0.34 * firethreshold
		elseif(shell.shellType.payload == "HE-I") then
				firethreshold = 0.55 * firethreshold
		elseif(shell.shellType.payload == "kinetic") then
				firethreshold = 0.08 * firethreshold
		elseif(shell.shellType.payload == "AP") then
				firethreshold = 0.04 * firethreshold
		end
		if(fireChance<firethreshold)then
			SpawnFire(shell.point1)
		end
		
	end

	if(shell.penDepth>0) then
		if shell.shellType.hit and shell.shellType.hit <3 then
			if(shell.shellType.hit ==1)then
				MakeHole(test.pos,shell.shellType.bulletdamage[1]*1.4)
			else
				MakeHole(test.pos,shell.shellType.bulletdamage[1]*1.4,shell.shellType.bulletdamage[2]*1.2)
			end
		else
			MakeHole(test.pos,shell.shellType.bulletdamage[1]*1.4,shell.shellType.bulletdamage[2]*1.2, shell.shellType.bulletdamage[3]*1.2)
		end
	
	else	
		local shell_hole = deepcopy(shell.shellType.bulletdamage)
		for i = 1,3 do 
			shell_hole[i] = shell_hole[i] +shell.penDepth 
		end

		if(not penetration) then 
			holeModifier = clamp(-1,0,(-(math.random(50,150)/100))+(shell.penDepth*100))
			--DebugWatch("non pen val hole modifier",holeModifier)
			-- DebugWatch("shell pen depth",shell.penDepth*100)
		end
		-- if shell.shellType.hit and shell.shellType.hit <3 then
		-- 	if(shell.shellType.hit ==1)then
		-- 		MakeHole(shell.point1,shell.shellType.bulletdamage[1]*1.4)
		-- 	else
		-- 		MakeHole(shell.point1,shell.shellType.bulletdamage[1]*1.4,shell.shellType.bulletdamage[2]*1.2)
		-- 	end

		-- else
		-- 	MakeHole(shell.point1,shell.shellType.bulletdamage[1]*1.4,shell.shellType.bulletdamage[2]*1.2, shell.shellType.bulletdamage[3]*1.2)
		-- end
		if shell.shellType.hit and shell.shellType.hit <3 then
			if(shell.shellType.hit ==1)then
				MakeHole(shell.point1,
					shell_hole[1]*(1+holeModifier))
			else

				MakeHole(shell.point1,
					shell_hole[1]*(1+holeModifier),
					shell_hole[2]*(1+holeModifier))
			end

		else
			MakeHole(shell.point1,
				shell_hole[1]*(1+holeModifier),
				shell_hole[2]*(1+holeModifier), 
				shell_hole[3]*(1+holeModifier))
		end
	-- 	Explosion(shell.point1)
		shell.active = false
		for key,val in ipairs( shell ) do 
			val = nil

		end
		shell = deepcopy(spallHandler.defaultShell)
	end

end

function spallingOperations(projectile,dt )
		projectile.cannonLoc.pos = projectile.point1
		local shellHeight = projectile.shellType.shellHeight
		local shellWidth = projectile.shellType.shellWidth
		local r = projectile.shellType.r
		local g = projectile.shellType.g
		local b = projectile.shellType.b


		--- sprite drawing
		DrawSprite(projectile.shellType.Spallingsprite, projectile.cannonLoc,projectile.shellType.shellWidth,shellHeight , r, g, b, 1, 0, false)
		local altloc = projectile.cannonLoc
		altloc.rot = QuatRotateQuat(altloc.rot,QuatEuler(0, 90,0))
		DrawSprite(projectile.shellType.Spallingsprite, altloc, projectile.shellType.shellWidth, shellHeight, r, g, b, 1, 0, false)
		altloc.rot = QuatRotateQuat(projectile.cannonLoc.rot,QuatEuler(90, 0,0))
		DrawSprite(projectile.shellType.Spallingsprite, altloc, projectile.shellType.shellWidth, projectile.shellType.shellWidth, r, g, b, 1, 0, false)
		

		projectile.predictedBulletVelocity = VecScale(projectile.predictedBulletVelocity,0.9)


		---
		---

			--- PROJECTILE MOTION

		---


		---  ADDING DISPERSION
		local dispersion = Vec(math.random(-1,1)*projectile.dispersion,math.random(-1,1)*projectile.dispersion,math.random(-1,1)*projectile.dispersion)
		if(projectile.shellType.dispersionCoef) then
			dispersion=VecScale(dispersion,dispersionCoef)
		end
		projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(dispersion,dt)))



		-- --- applying drag 
		-- local spallDrag = VecScale(
		-- 	VecSub(
		-- 		TransformToParentPoint(
		-- 			Transform(projectile.point1,projectile.cannonLoc.rot),
		-- 			Vec(0,0,50)),projectile.point1),
		-- 		dt)
		-- projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,spallDrag)
		--- APPLYING GRAVITY
		-- if(projectile.shellType.gravityCoef) then
		-- 	local shellGravity = VecScale(globalConfig.gravity,projectile.shellType.gravityCoef)
		-- 	projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(shellGravity,dt)))
		-- else

			projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(globalConfig.gravity,dt)))
		-- end

	
		local point2 = VecAdd(projectile.point1,VecScale(projectile.predictedBulletVelocity,dt))
		QueryRequire("physical")
		local hit, dist1,norm1,shape1 = QueryRaycast(projectile.point1, VecNormalize(VecSub(point2,projectile.point1)),VecLength(VecSub(point2,projectile.point1)))
		
		projectile.cannonLoc.rot = QuatRotateQuat(QuatLookAt(point2,projectile.point1),QuatEuler(00, 90, 90))
		

		local hit_player =  inflict_player_damage(projectile,point2)

			if(hit or hit_player)then 
				hitPos = VecAdd(projectile.point1, VecScale(VecNormalize(VecSub(point2,projectile.point1)),dist1))
				projectile.point1 = hitPos
				-- if(projectile.hit_npc ==nil  or not projectile.hit_npc) then  
				-- 	mors_longa_damage(projectile, shape1,hitPos)
				-- end
				 popSpalling(projectile,shape1)
				-- Explosion(hitPos,2)
			else
				projectile.point1 = point2
				if(projectile.hit_npc) then 
					projectile.hit_npc = false
				end
			end
		
end


function pushshrapnel(spallingLoc,spallShell,test,hitTarget)

	local spallValue = math.random(5,10)
	local spall_calibre_coef = spallShell.shellType.caliber / globalConfig.optimum_spall_shell_calibre_size 
	spall_calibre_coef  = spall_calibre_coef  * spall_calibre_coef 
	if(spallShell.shellType.explosionSize) then 
		spallValue = spallShell.shellType.explosionSize*5
	end
	local spallQuant = math.random(1,spallValue*3)
---			kinetic = 0.8,
			-- AP 		= 0.3,
			-- APHE    = 0.3,
			-- HESH 	= 2,
			-- HEI 	= 1,
	-- DebugPrint(spallValue)
	if(globalConfig.shrapnel_coefs[spallShell.shellType.payload]~= nil ) then 
		spallQuant = spallQuant * globalConfig.shrapnel_coefs[spallShell.shellType.payload] * spall_calibre_coef
	end
	for i=1, spallQuant do 

		local spallingSizeCoef = math.random(10,40)/100
		if(spallShell.shellType.payload == "HESH")then
			spallingSizeCoef = spallingSizeCoef * globalConfig.spallFactor.HESH
		end

		-- test.rot = QuatLookAt(spallShell.lastPos,test)
		local spallPos = TransformCopy(test)
		-- spallPos.pos = TransformToParentPoint(spallPos, 0,-16,0)
		
		local direction = rndVec(math.random(1,spallValue))
		local point1 = spallPos.pos
					
		spallHandler.shells[spallHandler.shellNum] = deepcopy(spallHandler.defaultShell)
		local currentSpall 				= spallHandler.shells[spallHandler.shellNum] 
		currentSpall.active 			= true 
		currentSpall.shellType = deepcopy(spallShell.shellType) 
		currentSpall.cannonLoc 			= spallPos
		currentSpall.point1			= point1 
		currentSpall.predictedBulletVelocity = rndVec(math.random() * math.random(15,35))
		if(globalConfig.shrapnel_speed_coefs[spallShell.shellType.payload]~= nil ) then 
			currentSpall.predictedBulletVelocity = VecScale(currentSpall.predictedBulletVelocity,globalConfig.shrapnel_speed_coefs[spallShell.shellType.payload]*spall_calibre_coef)
		end		

		currentSpall.initial_speed= VecCopy(currentSpall.predictedBulletVelocity)
		currentSpall.shrapnel = true
		currentSpall.hitTarget = hitTarget
		-- currentSpall.predictedBulletVelocity = VecScale(
		-- 												VecAdd(
		-- 													VecScale(spallShell.predictedBulletVelocity,0.8),fwdPos),0.5)
		--VecScale(direction,currentSpall.shellType.velocity*.2)
		currentSpall.originPos 	  = spallPos 
		currentSpall.maxTimeToLive = (currentSpall.shellType.timeToLive *(spallingSizeCoef+0.2))*(math.random(50,100)/100)
		currentSpall.timeToLive	  = currentSpall.maxTimeToLive
		if(spallShell.dispersion) then 
			currentSpall.dispersion 	  = 20 
			else
			currentSpall.dispersion 	  = 10 
		end
		-- DebugPrint("velocity: "..VecStr(currentSpall.predictedBulletVelocity).."  | pos = "..VecStr(TransformToParentPoint(spallPos, 0,-16,0)).." | "..VecStr(test.pos))
		-- currentSpall.shellType.bulletdamage = VecScale(currentSpall.shellType.bulletdamage,0.9)
		
		spall_damage_coef = math.max(math.random(),0.1)
		currentSpall.shellType.bulletdamage[1] = (currentSpall.shellType.bulletdamage[1] * spallingSizeCoef)*spall_damage_coef
		currentSpall.shellType.bulletdamage[2] = (currentSpall.shellType.bulletdamage[2] * spallingSizeCoef)*spall_damage_coef
		currentSpall.shellType.bulletdamage[3] = (currentSpall.shellType.bulletdamage[3] * spallingSizeCoef)*spall_damage_coef
		if(globalConfig.shrapnel_hard_damage_coef[spallShell.shellType.payload]~= nil ) then 
			currentSpall.shellType.bulletdamage[3] = currentSpall.shellType.bulletdamage[3] * globalConfig.shrapnel_hard_damage_coef[spallShell.shellType.payload] 
		end
		local spall_caliber_size = math.max((currentSpall.shellType.caliber * spallingSizeCoef)*0.3,0.01)
		currentSpall.shellType.caliber =  math.random()*spall_caliber_size
		currentSpall.shellType.shellWidth = math.max(math.random() * (math.random() * (currentSpall.shellType.shellWidth * spallingSizeCoef)),0.1 )
		currentSpall.shellType.shellHeight = math.max(math.random() * (currentSpall.shellType.shellWidth * spallingSizeCoef),0.1) 
		currentSpall.penDepth = ((currentSpall.shellType.maxPenDepth/2)*spallingSizeCoef)*spall_damage_coef
		if(globalConfig.shrapnel_pen_coef[spallShell.shellType.payload]~= nil ) then 
			currentSpall.penDepth = currentSpall.penDepth * globalConfig.shrapnel_pen_coef[spallShell.shellType.payload] 
		end

		if(globalConfig.penCheck>=currentSpall.shellType.maxPenDepth)then
			currentSpall.maxChecks  =1
		else
			currentSpall.maxChecks = currentSpall.shellType.maxPenDepth/globalConfig.penCheck
		end
		-- currentSpall.maxChecks  =2

		currentSpall.shellType.r = math.max((2 + (math.random(0,5)/10)) *spall_damage_coef,0.3)
		currentSpall.shellType.g = math.max((1.7 + (math.random(0,5)/10))*spall_damage_coef,0.3)
		currentSpall.shellType.b = math.max((1 + (math.random(0,10)/10)) *spall_damage_coef,0.3)


		spallHandler.shellNum = (spallHandler.shellNum%#spallHandler.shells) +1

	end
	-- DebugPrint("test")

end


function shrapnelOperations(projectile,dt )
		projectile.cannonLoc.pos = projectile.point1
		local shellHeight = projectile.shellType.shellHeight
		local shellWidth = projectile.shellType.shellWidth
		-- local spallDecay =  math.random()* (currentSpall.maxTimeToLive / currentSpall.timeToLive	)
		local spallDecay = math.random()
		local r = projectile.shellType.r * spallDecay
		local g = projectile.shellType.g * spallDecay
		local b = projectile.shellType.b * spallDecay


		--- sprite drawing
		DrawSprite(projectile.shellType.Spallingsprite, projectile.cannonLoc,projectile.shellType.shellWidth,shellHeight , r, g, b, 1, 0, false)
		local altloc = projectile.cannonLoc
		altloc.rot = QuatRotateQuat(altloc.rot,QuatEuler(0, 90,0))
		DrawSprite(projectile.shellType.Spallingsprite, altloc, projectile.shellType.shellWidth, shellHeight, r, g, b, 1, 0, false)
		altloc.rot = QuatRotateQuat(projectile.cannonLoc.rot,QuatEuler(90, 0,0))
		DrawSprite(projectile.shellType.Spallingsprite, altloc, projectile.shellType.shellWidth, projectile.shellType.shellWidth, r, g, b, 1, 0, false)
		


		---
		---

			--- PROJECTILE MOTION

		---


		---  ADDING DISPERSION

		projectile.predictedBulletVelocity = VecScale(projectile.predictedBulletVelocity,0.98)

		local dispersion = Vec(math.random(-1,1)*projectile.dispersion,math.random(-1,1)*projectile.dispersion,math.random(-1,1)*projectile.dispersion)
		if(projectile.shellType.dispersionCoef) then
			dispersion=VecScale(dispersion,dispersionCoef)
		end
		projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(dispersion,dt)))



		-- --- applying drag 
		-- local spallDrag = VecScale(
		-- 	VecSub(
		-- 		TransformToParentPoint(
		-- 			Transform(projectile.point1,projectile.cannonLoc.rot),
		-- 			Vec(0,0,50)),projectile.point1),
		-- 		dt)
		-- projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,spallDrag)
		--- APPLYING GRAVITY
		-- if(projectile.shellType.gravityCoef) then
		-- 	local shellGravity = VecScale(globalConfig.gravity,projectile.shellType.gravityCoef)
		-- 	projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(shellGravity,dt)))
		-- else

			projectile.predictedBulletVelocity = VecAdd(projectile.predictedBulletVelocity,(VecScale(globalConfig.gravity,dt)))
		-- end

	
		local point2 = VecAdd(projectile.point1,VecScale(projectile.predictedBulletVelocity,dt))
		QueryRequire("physical")
		local hit, dist1,norm1,shape1 = QueryRaycast(projectile.point1, VecNormalize(VecSub(point2,projectile.point1)),VecLength(VecSub(point2,projectile.point1)))
		
		projectile.cannonLoc.rot = QuatRotateQuat(QuatLookAt(point2,projectile.point1),QuatEuler(00, 90, 90))
		
			if(hit)then 
				hitPos = VecAdd(projectile.point1, VecScale(VecNormalize(VecSub(point2,projectile.point1)),dist1))
				projectile.point1 = hitPos
				if(projectile.hit_npc ==nil  or not projectile.hit_npc) then  
					mors_longa_damage(projectile, shape1,hitPos)
				end
				 popSpalling(projectile,shape1)
				-- Explosion(hitPos,2)
			else

				projectile.point1 = point2
				if(projectile.hit_npc) then 
					projectile.hit_npc = false
				end
			end
		
end

function spallingTick(dt)
		if unexpected_condition then error() end
			local activeShells = 0
			for key,shell in ipairs( spallHandler.shells  )do
			 	if(shell.active)then
			 		if(shell.timeToLive > 0) then 
			 			if(shell.shrapnel) then 
			 				shrapnelOperations(shell,dt)
			 				
			 			else
				 			spallingOperations(shell,dt)
				 		end
			 			shell.timeToLive = shell.timeToLive - dt
			 		else
			 			shell.active = false
			 		end
			 	end
		end
end


-----



----

----- SHELL HANDLING

----


function pushShell(gun,t_hitPos,dist,t_distance,t_cannon,t_penDepth)
	-- utils.printStr("pushing shell")
	if(dist <=0)then
		dist = maxDist
	end

	artilleryHandler.shells[getShellNum()].active = true
	artilleryHandler.shells[getShellNum()].hitPos = t_hitPos
	artilleryHandler.shells[getShellNum()].timeToTarget = dist*shellSpeed
	artilleryHandler.shells[getShellNum()].shellType = gun.magazines[gun.loadedMagazine].CfgAmmo

	if(t_cannon) then
		
		artilleryHandler.shells[getShellNum()].distance = t_distance
		artilleryHandler.shells[getShellNum()].t_cannon = t_cannon
		if(not t_penDepth ) then
				artilleryHandler.shells[getShellNum()].penDepth = gun.magazines[gun.loadedMagazine].CfgAmmo.maxPenDepth
				if(globalConfig.penCheck>=gun.magazines[gun.loadedMagazine].CfgAmmo.maxPenDepth)then
					artilleryHandler.shells[getShellNum()].maxChecks  =1
				else
					artilleryHandler.shells[getShellNum()].maxChecks = gun.magazines[gun.loadedMagazine].CfgAmmo.maxPenDepth/globalConfig.penCheck
				end
				-- utils.printStr("1")
		end
		-- SetString("hud.notification",artilleryHandler.shells[getShellNum()].penetrations.."\n"..artilleryHandler.shells[getShellNum()].timeToTarget)
	-- utils.printStr("3")
	end

	if (t_penDepth) then
				
				artilleryHandler.shells[getShellNum()].penDepth = t_penDepth
				-- artilleryHandler.shells[getShellNum()].shellType.explosionSize =1.5

				-- utils.printStr(gun.explosionSize.." | "..t_penDepth.." | "..dist)
	end
	-- else
		artilleryHandler.shells[getShellNum()].explosionSize = artilleryHandler.shells[getShellNum()].shellType.explosionSize
	-- end

	incrementShellNum()
	-- utils.printStr(4)
end

function pushShell2(shell,t_hitPos,dist,t_distance,t_cannon)
	-- utils.printStr("pushing shell")
	if(dist <=0)then
		dist = maxDist
	end

	artilleryHandler.shells[getShellNum()].active = true
	artilleryHandler.shells[getShellNum()].hitPos = t_hitPos
	artilleryHandler.shells[getShellNum()].timeToTarget = dist*shellSpeed
	artilleryHandler.shells[getShellNum()].shellType = shell.shellType

	if(t_cannon) then
		
		artilleryHandler.shells[getShellNum()].distance = t_distance
		artilleryHandler.shells[getShellNum()].t_cannon = t_cannon
				artilleryHandler.shells[getShellNum()].penDepth = shell.penDepth

				artilleryHandler.shells[getShellNum()].maxChecks = shell.maxChecks
				artilleryHandler.shells[getShellNum()].explosionSize = artilleryHandler.shells[getShellNum()].shellType.explosionSize
				-- utils.printStr("1")
		-- SetString("hud.notification",artilleryHandler.shells[getShellNum()].penetrations.."\n"..artilleryHandler.shells[getShellNum()].timeToTarget)
	-- utils.printStr("3")
	end

	incrementShellNum()
	-- utils.printStr(4)
end

function popShell(shell)
	-- utils.printStr(1)
	if(shell.penDepth) then
		-- utils.printStr(2)
		-- utils.printStr(shell.penDepth)
		local penetration,passThrough,test,penDepth,dist =  getPenetration(shell) 
		-- utils.printStr(3)
		shell.penDepth = shell.penDepth - penDepth
		-- and shell.penetrations>0)
		-- utils.printStr(dist)
		if( passThrough and shell.penDepth>0) then
					
				if(shell.hitPos ~= nil)then
					-- utils.printStr(type(shell.hitPos))
					-- utils.printStr(utils.explodeTable(shell.hitPos).." "..shell.hitPos[1])
					-- utils.printLoc(shell.hitPos)

					Explosion(shell.hitPos,0.5)

					shellPenetration(shell,test,dist)
					-- utils.printStr(shell.penDepth)
					
				else
					utils.printStr("no shell hitPos")
				end


		else

			Explosion(test.pos,shell.explosionSize)
			-- utils.printStr("penetration  explosion")
		-- shellPenetration(shell)
		-- shell = deepcopy(artilleryHandler.defaultShell)
		end
	else
		-- utils.printStr("normal explosion")
		Explosion(shell.hitPos,shell.explosionSize)
	end
	shell.active = false
	shell = deepcopy(artilleryHandler.defaultShell)
end

function getShellNum()
	return artilleryHandler.shellNum
	
end

function incrementShellNum()
	artilleryHandler.shellNum = ((artilleryHandler.shellNum+1) % #artilleryHandler.shells)+1
end




function kill_shell(shell)

	shell.active = false
	for key,val in ipairs( shell ) do 
		val = nil

	end
	shell = deepcopy(projectileHandler.defaultShell)

		end


function artilleryTick(dt)
	local activeShells = 0
		for key,shell in ipairs( artilleryHandler.shells  )do
			 if(shell.active==true)then
			 	if(type(shell.hitPos)~= "table")then
			 		shell.active = false
			 	else
				 	activeShells= activeShells+1
				 	if shell.timeToTarget <0 then
				 		popShell(shell)
				 	else
				 		shell.timeToTarget = shell.timeToTarget-dt
				 	end
			 	end
			 end
		end
	-- utils.printStr(activeShells)
end





 -- check left right, if number then explode, if 0 then fly on.
function getPenetration(shell)
	local cannonLoc = shell.t_cannon
	local penetration = false
	local passThrough = true  
	local test= cannonLoc	
	local outstring =""
	local penDepth =0
	local dist1 = 0
	local hit1=false
	local penDepth = 0
	for i =1,shell.maxChecks do 
		local fwdPos = TransformToParentPoint(test, Vec(0, globalConfig.penCheck * -1,0))
	    local direction = VecSub(fwdPos, test.pos)
	     -- printloc(direction)
	    direction = VecNormalize(direction)
	    QueryRequire("physical")
    	hit1, dist1 = QueryRaycast(test.pos, direction, maxDist)
	    	local tstStrn = ""
	    	-- if(dist1 == 0 and hit1) then
	    	-- 	tstStrn = ("penetrated")
	    	-- elseif (dist1 == 0 ) then
	    	-- 	tstStrn = ("passThrough")
	    	-- else
	    	-- 	tstStrn = ("penetrated + possible next penetration")
	    	-- end
	    	outstring= outstring.."check: "..i.." : "..dist1.." "..tstStrn.."\n"--.."\n1: "..dist2.."\n1.5: "..dist3)	
	    	-- utils.printStr("2_3_5 "..outstring)
		
		if(dist1>0)then
			penDepth = globalConfig.penCheck*i
			penetration=true
			break
		end
		test = rectifyPenetrationVal(test)
	end
	-- utils.printStr("2_4")
	-- utils.printStr(outstring)
	if(dist1 ==0) then

		passThrough = not hit1

		-- passThrough,checks = didPassThrough(cannonLoc)
		-- checks=""
		-- if(not passThrough) then
		-- 	printStr("hitWall, stuck in object\nPrimaryChecks:\n"..outstring.."\nReversechecks:\n"..checks.."\nDidn't pass Through")
		-- else
		-- 	printStr("PrimaryChecks:\n"..outstring.."\nReversechecks:\n"..checks.."\nPassed Through")
		-- end
	end
	return penetration,passThrough,test,penDepth,dist1
end

function shellPenetration(shell,cannonLoc,dist)

	if(dist == 0) then
		dist = maxDist
	end

		hitPos = TransformToParentPoint(cannonLoc, Vec(0, dist * -1,0))

      	p = cannonLoc.pos

		d = VecNormalize(VecSub(hitPos, p))
		spread = 0.03
		d[1] = d[1] + ((math.random()-0.5)*2*spread)*dist/shell.distance
		d[2] = d[2] + ((math.random()-0.5)*2*spread)*dist/shell.distance
		d[3] = d[3] + ((math.random()-0.5)*2*spread)*dist/shell.distance
		d = VecNormalize(d)
		p = VecAdd(p, VecScale(d, 0.1))
		
			if (dist<maxDist) then
				cannonLoc.pos = hitPos
				pushShell2(shell,hitPos,dist,(maxDist-dist),cannonLoc)
				-- pushShell(shell,hitPos,dist,(maxDist-dist),cannonLoc,shell.penDepth)
				--pushShell(gun,t_hitPos,dist,t_distance,t_cannon,t_penDepth)
			end
		-- utils.printStr("test")
		Shoot(p, d,0)
	

	-- body
end

function rectifyPenetrationVal(t_cannonLoc)
		-- utils.printStr("fixingpen")
	local y = 0
	local x = 0 
	local z = globalConfig.penCheck


	local fwdPos = TransformToParentPoint(t_cannonLoc, Vec(x, z,y))

	local direction = VecSub(fwdPos, t_cannonLoc.pos)

	t_cannonLoc.pos = VecAdd(t_cannonLoc.pos, direction)
	return t_cannonLoc
end
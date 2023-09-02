#include "script/common.lua"


--[[
**********************************************************************
*
* FILEHEADER: Elboydo's  Immersive Tanks Script for AVF tanks
*
* FILENAME :        immersive_Tank.lua             
*
* DESCRIPTION :

		Adds functionality for ammo cookoff, engine failure, fuel burn, and lots of fun

		simple to implement and provides high impact effects

**********************************************************************
]]


DEBUG =false

tank_found = true
tank = {}

cook_off_intensity = 1
cook_off_value = 0
cook_off_pulse = 0
cook_off_blast_min_strength = 120
cook_off_blast_max_strength =750

min_cook_off = 0.5

max_cook_off = 30

min_burn_off = 2

max_burn_off = 20

burn_off_value = 1

upward_force = 40
hatch_size = 0.4


cook_off_sounds = {}
tank_explode_sounds = {}

tank_explode_sound_vol = 60
cook_off_sound_vol = 40
burn_off_sound_vol =5


function init()
	local scene_tank = FindVehicle("cfg")
	hole_force = math.random(5,50)/10

	if(IsHandleValid(scene_tank)) then 
		tank_found = true
		tank.id = scene_tank

		tank.ammo_racks = FindShapes("ammo_rack")

		tank.ammo_rack_state = {}
		-- if(tank.ammo_racks) then
			for i=1,#tank.ammo_racks do
				tank.ammo_rack_state[i] = true
			end
		-- end

		tank.fuel_tanks = FindShapes("fuel_tank")

		tank.engines = FindShapes("engine")
		tank.engine_states = {}
		if(tank.engines) then 
			for i = 1,#tank.engines do 
				tank.engine_states[i] = false 
			end
		end
		tank.damaged_engines = 0
		tank.engine_okay = true


		tank.tracks = FindShapes("tracks")


		local cook_off_loc = FindLocation("cook_off")

	--	DebugPrint(cook_off_loc)
	--	DebugPrint("scene tank: "..scene_tank)
		if(IsHandleValid(cook_off_loc)) then
			tank.cook_off_loc = cook_off_loc 

			tank.cook_off_origin =TransformToLocalTransform(GetVehicleTransform(scene_tank), GetLocationTransform(cook_off_loc))
			if(HasTag(cook_off_loc,"max_force") and (GetTagValue(cook_off_loc,"max_force"))) then
				cook_off_blast_max_strength = (GetTagValue(cook_off_loc,"max_force"))
			end
			if(HasTag(cook_off_loc,"min_force") and (GetTagValue(cook_off_loc,"min_force"))) then
				cook_off_blast_min_strength = (GetTagValue(cook_off_loc,"min_force"))
				
			end			
		end


		breakable_joints = FindJoints("break_joint")


		local blow_out_locs = FindLocations("blow_out")
		tank.blow_out_locs = {}
		tank.blow_out_origins = {}
		for i=1,#blow_out_locs do
		local blow_out_loc = blow_out_locs[i] 
			if(IsHandleValid(blow_out_loc )) then
				local j = #tank.blow_out_locs+1 

				tank.blow_out_locs[j] = blow_out_loc 
				tank.blow_out_origins[j] =TransformToLocalTransform(GetVehicleTransform(scene_tank), GetLocationTransform(blow_out_loc))
			
				-- DebugPrint("blow out #"..i.." at pos: "..VecStr(tank.blow_out_origins[j].pos))
				-- DebugPrint("blow out world location"..VecStr(GetLocationTransform(blow_out_loc).pos).." from: "..VecStr(GetLocationTransform(blow_out_locs[i] ).pos).."target:"..VecStr(TransformToLocalTransform(GetVehicleTransform(scene_tank), GetLocationTransform(blow_out_loc)).pos)) 
			end
		end
		local burn_off_locs = FindLocations("burn_off")
		tank.burn_off_locs = {}
		tank.burn_off_origins = {}
		for i=1,#burn_off_locs do
		local burn_off_loc = burn_off_locs[i] 
			if(IsHandleValid(burn_off_loc )) then
				tank.burn_off_locs[i] = burn_off_loc 
				tank.burn_off_origins[i] =TransformToLocalTransform(GetVehicleTransform(scene_tank), GetLocationTransform(burn_off_loc))
			end
		end


		tank.hatches_blown = 0

		fireLoop = LoadLoop("tools/blowtorch-loop.ogg")

		for i=1, 7 do
			cook_off_sounds[i] = LoadSound("MOD/avf/snd/cook_off_0"..i..".ogg")
			tank_explode_sounds[i] = LoadSound("MOD/avf/snd/tank_explode_0"..i..".ogg")
		end

		cook_off_loop = LoadLoop("MOD/avf/snd/cook_off_loop.ogg")

	end



end



function tick()

	if(not tank.dead) then
		if(DEBUG) then 
			DebugWatch("cook_off_value: ",cook_off_value)
			DebugWatch("cook_off_pulse: ",cook_off_pulse)

			DebugWatch("burn_off_value: ",burn_off_value)
		end
		if(tank.ammo_racks and #tank.ammo_racks>0) then 
			check_ammo_stability()
		end
		if(tank.engines) then 
			check_engine_state()
		end
	elseif(tank.burning_off and not tank.burned_off) then 
		burn_off()
	end


end

function check_engine_state()
	-- if(#tank.engines>0) then 
	-- 	DebugWatch("engne_state",tank.engine_okay)
	-- end
	for i = 1,#tank.engines do 
		if(not tank.engine_states[i] and IsShapeBroken(tank.engines[i])) then 
			tank.engine_okay = false
			explosionSmall(GetShapeWorldTransform(tank.engines[i]))
			tank.engine_states[i] = true
			tank.damaged_engines = tank.damaged_engines +1
		end
	end

	if(not tank.engine_okay) then 

		if(math.random()>0.8) then 
			for i =1,#tank.engines do 
				if(tank.engine_states[i]) then
					local engine_pos = GetShapeWorldTransform(tank.engines[i]) 
					engine_sparks(engine_pos,math.random(2,15),math.random(2,5))
					local hit, hitp,hitn,hitshape = QueryClosestPoint(engine_pos.pos,0.6)
					if(hit) then
							SpawnFire(hitp)
							-- hitLocations[i] = hitshape
					else
							SpawnFire(engine_pos.pos)
					end
				end
			end
		end
		DriveVehicle(tank.id,0,0,true)
	end
end

function engine_sparks(engine_pos,count, vel)
	for i=1, count do
		local v = VecAdd(Vec(0, vel, 0 ), rndVec(rnd(vel*0.5, vel*1.5)))
		local life = rnd(0, 1)
		life = life*life * 5
		ParticleReset()
		ParticleEmissive(5, 0, "easeout")
		ParticleGravity(-10)
		ParticleRadius(0.03, 0.0, "easein")
		ParticleCollide(1, 1, "constant", 0.05)
		ParticleColor(1, 0.4, 0.3)
		ParticleTile(4)
		SpawnParticle(engine_pos.pos, v, life)
	end
end

function check_ammo_stability()
	if(not tank.cooking_off and #tank.ammo_racks>0) then 
		local stable_ammo = #tank.ammo_racks 
		for i=1,#tank.ammo_racks do
			local ammo_rack = tank.ammo_racks[i]
			if(tank.cooking_off) then 
				SpawnFire(GetShapeWorldTransform(ammo_rack).pos)
			elseif(not tank.ammo_rack_state[i]) then 
				stable_ammo = stable_ammo-1
			end
			local hit, pos =QueryClosestFire(GetShapeWorldTransform(ammo_rack).pos, 0.25)
			-- if( hit) then
			-- 	DebugPrint("ammo rack on fire")
			-- end
			if(tank.ammo_rack_state[i] and IsShapeBroken(ammo_rack) or 
				(tank.ammo_rack_state[i] and hit) or (DEBUG and InputPressed("y"))) then 

				tank.ammo_rack_state[i] = false
				local tag_value = GetTagValue(ammo_rack,"ammo_rack")
				local explosionChance = math.random()
				if(DEBUG) then 
					DebugWatch("tank engines exist","maybe")
					DebugWatch("tank engines # ",#tank.engines )
				end
				if(#tank.engines>0) then 
					if(DEBUG) then
						DebugWatch("old explosion chance",explosionChance)
					end
					explosionChance = explosionChance - (tank.damaged_engines/#tank.engines )
					if(DEBUG) then
						DebugWatch("new explosion chance",explosionChance)
					end
				end
				-- [ big boom mode ]
					--explosionChance  = 0
			--	DebugPrint("ammo rack 	destroyed!")
				if(tag_value=="" or tonumber(tag_value)>explosionChance) then 
					tank.cooking_off = true
					break_all_breakable_joints()


				--	DebugPrint("ammo rack destroyed! cooking off")

					SetValue("cook_off_value", 1, "easein", math.random(min_cook_off,max_cook_off))
					cook_off_intensity = math.random(1,10)
					if(not IsHandleValid(tank.cook_off_loc)) then 
						tank.cook_off_origin =TransformToLocalTransform(GetVehicleTransform(scene_tank), GetShapeWorldTransform(ammo_rack))
					end
				end
			end
		end
		if(stable_ammo<=0) then 
			tank.cooking_off = true
			break_all_breakable_joints()
		--	DebugPrint("ammo rack destroyed! cooking off")

			SetValue("cook_off_value", 1, "easein", math.random(min_cook_off,max_cook_off))
			cook_off_intensity = math.random(1,2)

			if(not IsHandleValid(tank.cook_off_loc)) then 
				local i = math.random(1,#tank.ammo_racks)
				tank.cook_off_origin =TransformToLocalTransform(GetVehicleTransform(scene_tank), GetShapeLocalTransform(tank.ammo_racks[i]))
				
			end
		elseif(#tank.ammo_rack_state>1 and (stable_ammo < #tank.ammo_rack_state/2)) then 
			break_all_breakable_joints()
		end
	else 
		cook_off()
	end
end



function break_all_breakable_joints()
	for i=1,#breakable_joints do 
		-- DebugPrint("i"..i)
		if(IsHandleValid(breakable_joints[i])) then 
			local tag_value = GetTagValue(breakable_joints[i],"break_joint")
			local break_chance = math.random()
			if(tag_value=="" or tonumber(tag_value)>break_chance) then 		
				Delete(breakable_joints[i])	
				if(DEBUG) then
					DebugWatch("break chance",break_chance)

					DebugWatch("tag value ",tag_value)
				end
			end
		
		end
		-- DebugPrint("gone: "..i)
	end

end

function cook_off()
	local dt = GetTimeStep()
	local transform = TransformToParentTransform(GetVehicleTransform(tank.id),tank.cook_off_origin)
	local pos = transform.pos
	-- for i=1,10 do
	-- 	local holePos = TransformToParentPoint(transform, Vec(0,i/5,0)) 
	-- 	DebugCross(holePos)
	-- 	DebugWatch("holepos",holePos)

	-- end	
	PlayLoop(cook_off_loop, pos, cook_off_sound_vol*cook_off_value)
	if(cook_off_value<1) then 
		EmitFire(cook_off_pulse*5, transform,math.max(0.2,cook_off_value*1.5),1)
		if(cook_off_pulse<=0) then 
			PlaySound(cook_off_sounds[math.random(1,#cook_off_sounds)], pos, cook_off_sound_vol*cook_off_value, false)
			if(cook_off_value<=1) then
				tank_ignition(transform)
				
				for i=1,#tank.burn_off_origins do 
					local ignition_pos = TransformToParentTransform(GetVehicleTransform(tank.id),tank.burn_off_origins[i])
					tank_ignition(ignition_pos)
				end

				for i=1,15 do
					local holePos = TransformToParentPoint(transform, Vec(0,i/5,0))
					local holesize = math.min(hatch_size * (cook_off_value*hole_force),hatch_size) 
					MakeHole(holePos, holesize, holesize,holesize)

				end

			end 
			local cook_off_frequency = math.random(10,10+(60*(1.1-cook_off_value)))/100
			SetValue("cook_off_pulse", 1, "linear", cook_off_frequency)
			local strength = cook_off_value
			local pos =transform.pos
			if strength >= 0.95 and cook_off_intensity>1 then
				explosionLarge(pos)
			elseif strength >= 0.7 then
				explosionMedium(pos)
			else
				explosionSmall(pos)
				
				
			end





			if(tank.hatches_blown<3 and  cook_off_value>0.2) then 
				apply_impulse(transform)
				
				for i=1,#tank.blow_out_origins do 
					if(math.random()>0.5) then 
						apply_impulse(tank.blow_out_origins[i])
					end
				end
				tank.hatches_blown =tank.hatches_blown +1
			end

			



		elseif(cook_off_pulse>=1) then
			cook_off_pulse=0
		end
		
		flashTick(explosionPos, dt)
		lightTick(explosionPos, dt)
	elseif(not tank.dead) then
		if( cook_off_intensity>2) then 
			cook_off_blast()
			Explosion(pos, math.random(5,17)/10)
			PlaySound(tank_explode_sounds[math.random(1,#tank_explode_sounds)], pos, tank_explode_sound_vol*cook_off_value, false)
			max_burn_off = max_burn_off /2
		end
		-- else
			SetValue("burn_off_value", 0, "easeout", math.random(min_burn_off,max_burn_off))
			tank.burning_off = true
		-- end
		kill_tracks()
		
		SetTag(tank.id, "nodrive")
	--	DebugPrint("Did something go boom?")
		tank.dead=true
	end

end


function tank_ignition(transform)
	local hitLocations = {nil,nil,nil}
	for i=1,3 do 
		local queryPos = VecAdd(transform.pos,Vec(math.random()*math.random(-1,1),math.random()*math.random(-1,1),math.random()*math.random(-1,1)))
		for j=1,3 do
			if(hitLocations[j])then 
				QueryRejectShape(hitLocations[j])
			end
		end
		local hit, hitp,hitn,hitshape = QueryClosestPoint(queryPos,1.4)
		if(hit) then
				SpawnFire(hitp)
				hitLocations[i] = hitshape
		else
				SpawnFire(pos)
		end
	end
end


function burn_off()

	local dt = GetTimeStep()
	local transform = TransformToParentTransform(GetVehicleTransform(tank.id),tank.cook_off_origin)
	local pos = transform.pos
	EmitFire(cook_off_pulse*5, transform,math.max(0.2,burn_off_value*1.5),burn_off_value)
	if(cook_off_pulse<=0) then 
			if(burn_off_value<=1) then
				local hitLocations = {nil,nil,nil}
				for i=1,3 do 
					local queryPos = VecAdd(holePos,Vec(math.random()*math.random(-1,1),math.random()*math.random(-1,1),math.random()*math.random(-1,1)))
					for j=1,3 do
						if(hitLocations[j])then 
							QueryRejectShape(hitLocations[j])
						end
					end
					local hit, hitp,hitn,hitshape = QueryClosestPoint(queryPos,1.4)
					if(hit) then
							SpawnFire(hitp)
							hitLocations[i] = hitshape
					else
							SpawnFire(pos)
					end
				end
			end 
			local burn_off_frequency = math.random(10,10+(60*(1.1-burn_off_value)))/100
			SetValue("cook_off_pulse", 1, "linear", burn_off_frequency)
			local strength = burn_off_value
			local pos =transform.pos
			if strength >= 0.95 and cook_off_intensity>1 then
				explosionLarge(pos)
			elseif strength >= 0.7 then
				explosionMedium(pos)
			else
				explosionSmall(pos)
			end


	elseif(cook_off_pulse>=1) then
		cook_off_pulse=0
	end

	if(burn_off_value <=0) then 
		tank.burned_off = true
	end
end

function cook_off_blast()
	local joints = FindJoints("component")
	for i=1,#joints do 
		local joint = joints[i]
		local tag_value = GetTagValue(joint,"component")
		if(tag_value == "turretJoint") then 
			Delete(joint)

		--	DebugPrint("bye bye joint")
		end

	end


	local strength = math.random(cook_off_blast_min_strength,cook_off_blast_max_strength)	--Strength of blower
	local maxMass = 5000	--The maximum mass for a body to be affected
	local maxDist = 7	--The maximum distance for bodies to be affected
		--Get all physical and dynamic bodies in front of camera
	local t =  TransformToParentTransform(GetVehicleTransform(tank.id),tank.cook_off_origin)
	local c = TransformToParentPoint(t, Vec(0, .5,0))
	local mi = VecAdd(c, Vec(-maxDist, -maxDist/4, -maxDist/2))
	local ma = VecAdd(c, Vec(maxDist, 0, maxDist/2))
	QueryRequire("physical dynamic")
	QueryRejectVehicle(tank.id)
	local bodies = QueryAabbBodies(mi, ma)

	--Loop through bodies and push them
	for i=1,#bodies do
		local b = bodies[i]


		--Compute body center point and distance
		local bmi, bma = GetBodyBounds(b)
		local bc = VecLerp(bmi, bma, 0.5)
		local dir = VecSub(bc, t.pos)
		local dist = VecLength(dir)
		dir = VecScale(dir, 1.0/dist)

		--Get body mass
		local mass = GetBodyMass(b)
		
		--Check if body is should be affected
		if dist < maxDist and mass < maxMass then
			--Make sure direction is always pointing slightly upwards
			dir[2] = 0.5
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


end 

function kill_tracks()
	for i=1,#tank.tracks do 
		if(math.random()>0.75) then
			Delete(tank.tracks[i])
		end

	end
end


function EmitFire(strength, t, amount,force)
	local p = TransformToParentPoint(t, Vec(0, 0,0))
	local d = TransformToParentVec(t, Vec(math.random()/5, 1, math.random()/5))
	for i=1,5 do 

		ParticleReset()
		ParticleTile(5)
		ParticleColor(1, 1, 0.5, 1, 0, 0)
		ParticleRadius(0.05*amount, 1*amount)
		ParticleEmissive(10, 0)
		ParticleDrag(0.1)
		ParticleGravity(math.random()*20)
		PointLight(p, 1, 0.8, 0.2, 2*amount)
		PlayLoop(fireLoop, t.pos, (amount*burn_off_sound_vol )*force)
		SpawnParticle(p, VecScale(d, 12*force), 0.5 * (amount*3))
	end
	if amount > 0.0 then
		--Spawn fire
		if not spawnFireTimer then
			spawnFireTimer = 0
		end
		if spawnFireTimer > 0 then
			spawnFireTimer = math.max(spawnFireTimer-0.01667, 0)
		else
			
			local hit, dist = QueryRaycast(p, d, 3)
			if hit then
				local wp = VecAdd(p, VecScale(d, dist))
				SpawnFire(wp)
				spawnFireTimer = 1
			end
		end
		
		--Hurt player
		local toPlayer = VecSub(GetPlayerCameraTransform().pos, t.pos)
		local distToPlayer = VecLength(toPlayer)
		local distScale = clamp(1.0 - distToPlayer / 5.0, 0.0, 1.0)
		-- DebugWatch("dist scale",distScale)
		if distScale > 0 then
			toPlayer = VecNormalize(toPlayer)
			-- DebugWatch("toplayer ",toPlayer)

			-- DebugWatch("d",d)
			-- DebugWatch("dot prod",VecDot(d, toPlayer))
			if VecDot(d, toPlayer) > 0.8 or distToPlayer < 0.5 then
				
				local hit = QueryRaycast(p, toPlayer, distToPlayer)
				if not hit or distToPlayer < 0.5 then
					SetPlayerHealth(GetPlayerHealth() - 0.015 * strength * amount * distScale)
				end
			end	
		end
	end
end


function apply_impulse(transform )


	local strength = math.random(10,250)	--Strength of blower
	local maxMass = 500	--The maximum mass for a body to be affected
	local maxDist = 4	--The maximum distance for bodies to be affected
		--Get all physical and dynamic bodies in front of camera
	local t =  TransformToParentTransform(GetVehicleTransform(tank.id),transform)
	local c = TransformToParentPoint(t, Vec(0, .5,0))
	local mi = VecAdd(c, Vec(-maxDist, -maxDist/4, -maxDist/2))
	local ma = VecAdd(c, Vec(maxDist, 0, maxDist/2))
	QueryRequire("physical dynamic")
	QueryRejectVehicle(tank.id)
	local bodies = QueryAabbBodies(mi, ma)

	--Loop through bodies and push them
	for i=1,#bodies do
		local b = bodies[i]


		--Compute body center point and distance
		local bmi, bma = GetBodyBounds(b)
		local bc = VecLerp(bmi, bma, 0.5)
		local dir = VecSub(bc, t.pos)
		local dist = VecLength(dir)
		dir = VecScale(dir, 1.0/dist)

		--Get body mass
		local mass = GetBodyMass(b)
		
		--Check if body is should be affected
		if dist < maxDist and mass < maxMass then
			--Make sure direction is always pointing slightly upwards
			dir[2] = 0.5
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
end



function burn_down()



end



function rnd(mi, ma)
	return math.random(1000)/1000*(ma-mi) + mi
end

function rndVec(t)
	return Vec(rnd(-t, t), rnd(-t, t), rnd(-t, t))
end

explosionPos = Vec()

trails = {}

function trailsAdd(pos, vel, life, size, damp, gravity)
	t = {}
	t.pos = VecCopy(pos)
	t.vel = VecAdd(Vec(0, vel*0.7, 0 ), rndVec(vel))
	t.size = size
	t.age = 0
	t.damp = damp
	t.gravity = gravity
	t.life = rnd(life*0.5, life*1.5)
	t.nextSpawn = 0
	trails[#trails+1] = t
end

function trailsUpdate(dt)
	for i=#trails,1,-1 do
		local t = trails[i]
		t.vel[2] = t.vel[2] + t.gravity*dt
		t.vel = VecScale(t.vel, t.damp)
		t.pos = VecAdd(t.pos, VecScale(t.vel, dt))
		t.age = t.age + dt
		local q = 1.0 - t.age / t.life
		if q > 0.1 then
			local r = t.size * q + 0.05
			local spawnRate = 0.8*r/VecLength(t.vel)
			while t.nextSpawn < t.age do
				local w = 0.8-q*0.5
				local w2 = 0.9
				local v = VecScale(t.vel, 0.25)
				ParticleReset()
				ParticleType("smoke")
				ParticleColor(w, w*0.95, w*0.9, w2, w2*0.95, w2*0.9)
				ParticleRadius(r)
				ParticleAlpha(q, 0)
				ParticleDrag(2.0)
				SpawnParticle(t.pos, v, rnd(0.5, 2.0))
				t.nextSpawn = t.nextSpawn + spawnRate
			end
		else
			trails[i] = trails[#trails]
			trails[#trails] = nil
		end
	end
end

smoke = {}
smoke.age = 0
smoke.size = 0
smoke.life = 0
smoke.next = 0
smoke.vel = 0
smoke.gravity = 0
smoke.amount = 0
function smokeUpdate(pos, dt)
	smoke.age = smoke.age + dt
	if smoke.age < smoke.life then
		local q = 1.0 - smoke.age / smoke.life
		for i=1, smoke.amount*q do
			local w = 0.8-q*0.6
			local w2 = 1.0
			local r = smoke.size*(0.5 + 0.5*q)
			local v = VecAdd(Vec(0, 1*q+q*smoke.vel, 0), rndVec(1*q))
			local p = VecAdd(pos, rndVec(r*0.3))
			ParticleReset()
			ParticleType("smoke")
			ParticleColor(w, w*0.95, w*0.9, w2, w2*0.95, w2*0.9)
			ParticleRadius(0.5*r, r)
			ParticleGravity(rnd(0,smoke.gravity))
			ParticleDrag(1.0)
			ParticleAlpha(q, q, "constant", 0, 0.5)
			SpawnParticle(p, v, rnd(3,5))
		end
	end
end


fire = {}
fire.age = 0
fire.life = 0
fire.size = 0
function fireUpdate(pos, dt)
	fire.age = fire.age + dt
	if fire.age < fire.life then
		local q = 1.0 - fire.age / fire.life
		for i=1, 16 do
			local v = rndVec(fire.size*10*q)
			v[2] = v[2] * math.random(1,upward_force)
			local p = pos
			local life = rnd(0.2, 0.7)
			life = 0.5 + life*life*life * 1.5
			ParticleReset()
			ParticleColor(1, 0.6, 0.4, 1, 0.3, 0.2)
			ParticleAlpha(1, 0)
			ParticleRadius(fire.size*q, 0.5*fire.size*q)
			ParticleGravity(1, rnd(1, 10))
			ParticleDrag(0.6)
			ParticleEmissive(rnd(2, 5), 0, "easeout")
			ParticleTile(5)
			SpawnParticle(p, v, life)
		end
	end
end


flash = {}
flash.age = 0
flash.life = 0
flash.intensity = 0
function flashTick(pos, dt)
	flash.age = flash.age + dt
	if flash.age < flash.life then
		local q = 1.0 - flash.age / flash.life
		PointLight(pos, 1, 0.5, 0.2, flash.intensity*q) 
	end
end


light = {}
light.age = 0
light.life = 0
light.intensity = 0
function lightTick(pos, dt)
	light.age = light.age + dt
	if light.age < light.life then
		local q = 1.0 - light.age / light.life
		local l = q * q
		local p = VecAdd(pos, rndVec(0.5*l))
		PointLight(p, 1, 0.4, 0.1, light.intensity*l)
	end
end

function explosionSparks(count, vel)
	for i=1, count do
		local v = VecAdd(Vec(0, vel, 0 ), rndVec(rnd(vel*0.5, vel*1.5)))
		local life = rnd(0, 1)
		life = life*life * 5
		ParticleReset()
		ParticleEmissive(5, 0, "easeout")
		ParticleGravity(-10)
		ParticleRadius(0.03, 0.0, "easein")
		ParticleColor(1, 0.4, 0.3)
		ParticleTile(4)
		SpawnParticle(explosionPos, v, life)
	end
end

function explosionDebris(count, vel)
	for i=1, count do
		local r = rnd(0, 1)
		life = 0.5 + r*r*r*3
		r = (0.4 + 0.6*r*r*r)
		local v = VecAdd(Vec(0, r*vel*0.5, 0), VecScale(rndVec(1), r*vel))
		local radius = rnd(0.03, 0.05)
		local w = rnd(0.2, 0.5)
		ParticleReset()
		ParticleColor(w, w, w)
		ParticleAlpha(1)
		ParticleGravity(-10)
		ParticleRadius(radius, radius, "constant", 0, 0.2)
		ParticleSticky(0.2)
		ParticleStretch(0.0)
		ParticleTile(6)
		ParticleRotation(rnd(-20, 20), 0.0, "easeout")
		SpawnParticle(explosionPos, v, life)
	end
end

function explosionSmall(pos)
	explosionPos = pos
	explosionSparks(10, 2)
	explosionDebris(25, 6)

	trails = {}
	for i=1, 8 do
		trailsAdd(pos, 5, 0.4, 0.1, 0.99, -10)
	end

	flash.age = 0
	flash.life = 0.1
	flash.intensity = 200
	
	light.age = 0
	light.life = 0.8
	light.intensity = 15
	
	fire.age = 0
	fire.life = 0.5
	fire.size = 0.2
	
	smoke.age = 0
	smoke.life = 1
	smoke.size = 0.5
	smoke.vel = 1
	smoke.gravity = 3
	smoke.amount = 2
end


function explosionMedium(pos)
	explosionPos = pos
	explosionSparks(30, 3)
	explosionDebris(50, 7)

	trails = {}
	for i=1, 16 do
		trailsAdd(pos, 12, 0.4, 0.15, 0.97, -10)
	end

	flash.age = 0
	flash.life = 0.2
	flash.intensity = 500
	
	light.age = 0
	light.life = 1.0
	light.intensity = 30
	
	fire.age = 0
	fire.life = 0.6
	fire.size = 0.5

	smoke.age = 0
	smoke.life = 1.5
	smoke.size = 0.7
	smoke.vel = 1
	smoke.gravity = 2
	smoke.amount = 2
end


function explosionLarge(pos)
	explosionPos = pos
	explosionSparks(50, 5)
	explosionDebris(100, 10)

	trails = {}
	for i=1, 8 do
		trailsAdd(pos, 12, 0.5, 0.2, 0.97, -10)
	end

	flash.age = 0
	flash.life = 0.4
	flash.intensity = 1000
	
	light.age = 0
	light.life = 1.2
	light.intensity = 50
	
	fire.age = 0
	fire.life = 0.7
	fire.size = 0.8
	
	smoke.age = 0
	smoke.life = 3
	smoke.size = 1.0
	smoke.gravity = -1
	smoke.vel = 8
	smoke.amount = 6
	
	--Sideways fast cloud
	ParticleReset()
	ParticleColor(0.8, 0.75, 0.7)
	ParticleRadius(0.3, 1.0)
	ParticleAlpha(1, 0, "easeout")
	ParticleDrag(0.2)
	for a=0, math.pi*2, 0.05 do
		local x = math.cos(a)*1
		local y = rnd(-0.1, 0.1)
		local z = math.sin(a)*1
		local d = VecNormalize(Vec(x, y, z))
		SpawnParticle(VecAdd(pos, d), VecScale(d, rnd(8,12)), rnd(0.5, 1.5))
	end
end


function update(dt)
	trailsUpdate(dt)
	fireUpdate(explosionPos, dt)
	smokeUpdate(explosionPos, dt)
end



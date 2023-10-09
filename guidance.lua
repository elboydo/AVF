
test_distance = 30 
scale_modifier = 1

t_test_distance = 7

t_guidance_peak_dist = 50



DEBUG_GUIDANCE_FUNCTIONALITY =false



guidance_peak_dist = 100

guidance_peak_height = 30
guidance_height_ratio = .8--0.32 

guidance_time_since_fly = 0
guidance_drop_dist = 0

guidance_start_y = 1
guidance_start_y_2 = 0.95

-- y = np.sin(2*np.pi*freq*t)




function follow_guidance(projectile)


end


function guidance_tick(dt)
	if(DEBUG_GUIDANCE_FUNCTIONALITY) then 
		guidance_peak_height = t_guidance_peak_dist * guidance_height_ratio
		test_distance = t_test_distance * scale_modifier

		guidance_peak_dist = t_guidance_peak_dist *scale_modifier

		guidance_peak_height = guidance_peak_height  *scale_modifier

		guidance_drop_dist = guidance_peak_dist * 1.5
		DebugWatch("guidance being run",dt)
		DebugPrint("------------------ guidance being run -----------------")

		debug_top_down_generation()

		-- for i =1 , 50 do 
		-- 	 reworked_top_down(dt,i*test_distance,i)
		-- end

		-- basic_sin(dt)
	end


end


function debug_top_down_generation()
	local target_shape = FindShape("avf_guidance_target",true) 
	local target_body = GetShapeBody(target_shape)
	DebugWatch("target_body fgound",target_body)
	DebugWatch("target_body",GetBodyTransform(target_body))
	if(target_body) then
		local projectile = {
			cannonLoc = Vec(0,0,0),
			shellType = {
				guidance_peak_dist = t_guidance_peak_dist,
				guidance_height_ratio = guidance_height_ratio

			},
			target_body = target_body,


		}

		 generate_top_down_pattern(projectile)
	end

end

function generate_top_down_pattern(projectile)
	local target = projectile.target_body
	local target_pos =  GetBodyTransform(target).pos
	local target_x_y = Vec(target_pos[1],0,target_pos[3])
	local projectie_x_y = Vec(projectile.cannonLoc[1],0,projectile.cannonLoc[3])
	local target_dist = VecLength(VecSub(target_x_y,projectie_x_y)) 
	local guidance_peak_dist =  projectile.shellType.guidance_peak_dist
	-- DebugWatch("guidance_peak_dist",guidance_peak_dist)
	local guidance_height_ratio =  projectile.shellType.guidance_height_ratio 
	local guidance_peak_height = guidance_peak_dist * guidance_height_ratio
	local guidance_drop_dist = guidance_peak_dist * 1.5
	local flight_pattern = {}
	local flight_keypoints = {}
	flight_pattern,flight_index,flight_keypoints = top_down_computation(
		projectile,
		guidance_peak_dist,
		guidance_peak_height,
		guidance_drop_dist,
		flight_pattern,
		flight_keypoints,
		target_dist
		)



	return flight_pattern,flight_keypoints



end


function top_down_computation(
	projectile,
	guidance_peak_dist,
	guidance_peak_height,
	guidance_drop_dist,
	flight_pattern,
	flight_keypoints,
	target_dist)


	local z = 1
	local flight_index = 1



	local expected_guidance_drop_dist = guidance_drop_dist


	if(DEBUG_GUIDANCE_FUNCTIONALITY) then 
		DebugCross(Vec(target_dist,guidance_start_y,z),0,2,0)
		DebugLine(Vec(0,guidance_start_y_2 ,z),Vec(target_dist,guidance_start_y_2 ,z),0,2,0)
	end
	-- # sampling rate
	local sr = 100.0
	local true_sample = sr/2
	-- # sampling interval
	local ts = 1.0/sr
	

	-- # frequency of the signal
	local freq = 0.5
	local last = 0
	local x_pos = 0
	local y_pos = 0
	local last_x_pos = 0
	local last_y_pos = guidance_start_y
	local t = 0 

	local expected_guidance_climb_dist = guidance_peak_dist
	local expected_guidance_climb_height = guidance_peak_height

	local tick_cutoff = 0.99
	if(expected_guidance_drop_dist >=target_dist) then 
		expected_guidance_drop_dist = target_dist *.75
	end
	local total_travel = expected_guidance_climb_dist + expected_guidance_drop_dist
	local overcompensation = 1.1
	if(total_travel > target_dist) then 
		local climb_coef = (target_dist -  expected_guidance_drop_dist) /  expected_guidance_climb_dist
		expected_guidance_climb_dist = expected_guidance_climb_dist * climb_coef
		expected_guidance_climb_height = expected_guidance_climb_height * climb_coef
		overcompensation = 1.0
	end


	local hit_apex = false
	
	local cutoff_y = 0

	local flight_distance = 0


	local x_move = 0
	local drop_offset = 0

	for i = 1,sr do 
		t = ts * (i-1)
		y = math.sin(2*math.pi*freq*t)

		x_move = ((expected_guidance_climb_dist*2) * t)

		if(not hit_apex) then 
			x_pos = x_move +flight_distance
			y_pos = ((expected_guidance_climb_height * y) ) +  guidance_start_y
		else
			x_pos = (((expected_guidance_drop_dist*2) * t)-drop_offset) +flight_distance 
			y_pos = ((expected_guidance_climb_height * y) ) +  guidance_start_y
			
			if(DEBUG_GUIDANCE_FUNCTIONALITY) then 
				DrawLine(Vec(x_pos, y_pos, z), Vec(x_pos, y_pos+0.5, z), 0, 1, 1)
			end
		end
		if(not hit_apex and y> tick_cutoff) then 
			hit_apex = true
			drop_offset =  ((expected_guidance_drop_dist*2) * t) * overcompensation 
			flight_keypoints[1] = {
				Target_Point = Vec(0,y_pos,x_pos),
				target_type = "pos",
				completed = false
			}
			if(DEBUG_GUIDANCE_FUNCTIONALITY) then 
				
				DrawLine(Vec(x_pos, y_pos, z), Vec(x_pos, y_pos+2, z), 0, 0, 1)
				DebugPrint(x_pos - expected_guidance_drop_dist )
			end
			if((target_dist- x_pos ) - expected_guidance_drop_dist > 0) then 
				flight_distance,flight_pattern,flight_index = stable_flight(
					x_pos,
					y_pos,
					z,
					expected_guidance_drop_dist,
					target_dist,
					flight_pattern,
					flight_index
					)
			else
				flight_distance = x_pos
			end
				flight_keypoints[2] = {
					Target_Point = Vec(0,y_pos, x_move +flight_distance),
					target_type = "pos",
					completed = false
				}


			if(DEBUG_GUIDANCE_FUNCTIONALITY) then 
				DrawLine(Vec(flight_distance, y_pos, z), Vec(flight_distance, y_pos-2, z), 0, 1, 1)
			end
			


		end


		if(DEBUG_GUIDANCE_FUNCTIONALITY) then 
	
			DrawLine(Vec(last_x_pos, last_y_pos, z), Vec(x_pos, y_pos, z), 1, 0, 0)
			DrawLine(Vec(x_pos, y_pos, z), Vec(x_pos, y_pos, z+1), 1, 0.5, 0.5)
		end
		flight_pattern[flight_index] = Vec(0,y_pos,x_pos)
		flight_index = flight_index + 1
		last_y_pos = y_pos
		last_x_pos = x_pos
	end

	flight_keypoints[3] = {
		Target_Point = flight_pattern[flight_index-1],
		target_type = "target_object",
		completed = false
	}

	return flight_pattern,flight_index,flight_keypoints

end

function stable_flight(x_pos,y_pos,z,expected_guidance_drop_dist,target_dist,flight_pattern,flight_index)
	local last_x_pos = x_pos
	local last_y_pos = y_pos
	local expected_fight_distance = (target_dist - (guidance_drop_dist)) - x_pos
	local flight_distance = x_pos
	local increment_size = math.max(expected_fight_distance / 10,1)
	for i=1,expected_fight_distance/increment_size do
		flight_distance = flight_distance + increment_size
		x_pos = last_x_pos + increment_size

		if(DEBUG_GUIDANCE_FUNCTIONALITY) then 
		
			DrawLine(Vec(x_pos, last_y_pos, z), Vec(x_pos, y_pos- 0.5, z), 1, 1, 0)
		end
		flight_pattern[flight_index] = Vec(0,y_pos,x_pos)
		flight_index = flight_index + 1

		last_x_pos = x_pos


		if (x_pos > (target_dist-expected_guidance_drop_dist)) then
			break
		end
	end


	return flight_distance,flight_pattern,flight_index


	
end



--[[


	proNav functions 
]]
function TruProNav()

	control_effector_commmand = Vec(0,0,0)


--[[ 


	REMOVED

]]

end



function init_missile_behaviours(projectile)
	local target_vel = GetBodyVelocity(projectile.target_body)
	local tgt_pos = GetBodyTransform(projectile.target_body).pos
	if(not(projectile.shellType.guidance_N)) then 
		projectile.shellType.guidance_N = 3.5
	end
	if(not(projectile.shellType.guidance_Nt)) then 
		projectile.shellType.guidance_Nt = 9.5*1
	end
	if(not(projectile.shellType.kinematic_sim)) then 
		projectile.shellType.kinematic_sim = 4
	end
	if(not(projectile.shellType.guidance_frequency)) then 
		projectile.shellType.guidance_frequency = 30
	end
	if(not (projectile.shellType.missile_ramp_speed)) then 

		projectile.shellType.missile_ramp_speed = 0.45
	end
	if(projectile.flight_keypoints) then 
		local origin_loc = Transform(
			projectile.point1,
			QuatLookAt(
				VecNormalize(
					VecSub(
						tgt_pos,
						projectile.point1
						
						)
					)
				)
			)
		-- TransformToParentPoint(cannonLoc, Vec(0,-1,0))

		for i = 1, #projectile.flight_keypoints do
			if(projectile.flight_keypoints[i].target_type == "pos") then
				local new_target_point = projectile.flight_keypoints[i].Target_Point
				new_target_point = TransformToParentPoint(origin_loc, projectile.flight_keypoints[i].Target_Point)
				projectile.flight_keypoints[i].Target_Point = new_target_point
			end
		end
	end

	projectile.guidance_system = {
		target_body = projectile.target_body,
		msl_pos = projectile.cannonLoc.pos ,
		msl_pos_previous = nil ,
		missile_vel = projectile.predictedBulletVelocity,
		missile_max_vel = projectile.shellType.velocity,
		missile_min_vel = projectile.shellType.velocity/3,
		missile_manuever_speed = 0.45,
		missile_ramp_speed = projectile.shellType.missile_ramp_speed,
		tgt_pos = tgt_pos ,
		tgt_pos_previous = nil,
		target_vel = target_vel,
		last_target_vel = target_vel,
		target_range = 9999,
		N = projectile.shellType.guidance_N,
		Nt = projectile.shellType.guidance_Nt, 
		tc = 1/projectile.shellType.guidance_frequency ,
		kin_sim = projectile.shellType.kinematic_sim,
		guidance_time = 0,
		keypoint_index = 1,
		flight_keypoints = projectile.flight_keypoints,


	}
end


function compute_CED(dt,projectile) 
	-- missile.msl_pos
	projectile.guidance_system.msl_pos = VecCopy(projectile.cannonLoc.pos)
	-- DebugWatch("attack pattern", projectile.shellType.attack_pattern)
	if(projectile.shellType.attack_pattern and projectile.shellType.attack_pattern == "top_down") then 

		projectile.guidance_system =homing_guidance_top_down(dt,projectile.guidance_system)
	else
		projectile.guidance_system =homing_guidance_direct(dt,projectile.guidance_system)
	end 
	projectile.predictedBulletVelocity = projectile.guidance_system.missile_vel
end

function homing_guidance_top_down(dt,missile)
				-- flight_keypoints[2] = {
				-- 	Target_Point = Vec(0,y,flight_distance),
				-- 	target_type = "pos",
				-- 	completed = true
				-- }

	-- for i = 1, #missile.flight_keypoints do
	-- 	if(missile.flight_keypoints[i].target_type == "pos") then
	-- 		DebugCross(missile.flight_keypoints[i].Target_Point,0,1,0)

	-- 		DebugLine(missile.flight_keypoints[i].Target_Point,VecAdd(missile.flight_keypoints[i].Target_Point,Vec(0,1,0)),0,1,0)
	-- 	end
	-- end

	local target_vel = Vec(0,0,0)
	local current_keypoint = missile.flight_keypoints[missile.keypoint_index]

	if (current_keypoint.completed) then
		missile.keypoint_index = missile.keypoint_index +1
	elseif (
		missile.keypoint_index < 3 and 
		VecLength(
			VecSub(
				missile.msl_pos, 
				current_keypoint.Target_Point
				)
			)
			<VecLength(missile.missile_vel)*.35) then 
		current_keypoint.completed = true
	else
		if(current_keypoint.target_type == "pos") then 
			missile.tgt_pos  = current_keypoint.Target_Point
		else
			target_vel = GetBodyVelocity(missile.target_body)
			local min, max = GetBodyBounds(missile.target_body)
			local variabiity = 0.6
			local boundsSize = VecSub(max, min)
			local center = VecLerp(min, max, 0.5+((variabiity *math.random())-variabiity*.5))
			missile.tgt_pos  = VecAdd(GetBodyTransform(missile.target_body).pos,TransformToLocalPoint(GetBodyTransform(missile.target_body),center))
		end
	end 


	-- local target_vel = GetBodyVelocity(missile.target_body)

	-- local min, max = GetBodyBounds(missile.target_body)
	-- local variabiity = 0.25
	-- local boundsSize = VecSub(max, min)
	-- local center = VecLerp(min, max, 0.5+((variabiity *math.random())-variabiity*.5))
	-- missile.tgt_pos  = VecAdd(GetBodyTransform(missile.target_body).pos,TransformToLocalPoint(GetBodyTransform(missile.target_body),center))

	-- missile.tgt_pos = GetBodyTransform(missile.target_body).pos
	-- DebugWatch("guidance target_body:",missile.target_body)
	missile = guidance_pattern_0903(
		dt,
		missile,
		target_vel
		)
	return missile

end

function homing_guidance_direct(dt,missile)
	local target_vel = GetBodyVelocity(missile.target_body)

	local min, max = GetBodyBounds(missile.target_body)
	local boundsSize = VecSub(max, min)
	local variabiity = 0.6
	-- local center = VecLerp(min, max, 0.5)

	local center = VecLerp(min, max, 0.5+((variabiity *math.random())-variabiity*.5))
	missile.tgt_pos  = VecAdd(GetBodyTransform(missile.target_body).pos,TransformToLocalPoint(GetBodyTransform(missile.target_body),center))

	-- missile.tgt_pos = GetBodyTransform(missile.target_body).pos
	-- DebugWatch("guidance target_body:",missile.target_body)
	missile = guidance_pattern_0903(
		dt,
		missile,
		target_vel
		)
	return missile

end

function guidance_pattern_0903(
	dt,
	missile,
	target_vel)


	-- missile = {
	-- 	missile_body = msl_body ,
	-- 	target_body = target_body,
	-- 	msl_pos = msl_pos ,
	-- 	msl_pos_previous = msl_pos ,
	-- 	missile_vel = missile_vel,
	-- 	tgt_pos = target_pos ,
	-- 	tgt_pos_previous = target_pos ,
	-- 	target_vel = target_vel
	-- last_target_vel = target_vel
		-- N = 3.0,
		-- nt = 664, 


	-- }
	if(not guidance_info_printed) then 

		guidance_method  = "STG-0903"
	DebugPrint("using guidance approach: "..guidance_method)
		guidance_info_printed = true
	end

	sim_scalar = 1

	chaser_colour = Vec(0,1,0)
	impact_colour = Vec(1,0,0)

	missile_vel = missile.missile_vel --VecScale(Vec(5,0,10),sim_scalar)

	missile_max_vel = missile.missile_max_vel --60 * sim_scalar

	local RTM_old = nil 
	local RTM_new = nil 

	local tgt_pos = missile.tgt_pos
	time = 0

	local last_target_vel = target_vel
	-- Nt = 664 * dt

	if(missile.tc < missile.guidance_time) then 
		missile.guidance_time = 0
		for i = 1,missile.kin_sim do 

			local target_start_pos = missile.tgt_pos

			target_vel_change = VecScale(Vec(10 * math.sin(time), 0, 0 ),.5)
			time = time+dt
			
			target_vel = VecAdd(target_vel,target_vel_change)
			
			missile = autopilot_x(dt,missile)

			local range = missile.target_range
			
			local new_msl_pos = VecAdd(missile.msl_pos,missile.missile_vel )
			local print_colour =VecLerp(chaser_colour,impact_colour,clamp(0,1,range/50))


			--- draw lines for trajectory planning
			-- DrawLine(missile.tgt_pos, VecAdd(missile.tgt_pos,target_vel), 0, 0, 1)
			-- DrawLine(VecAdd(missile.tgt_pos,target_vel), missile.msl_pos, 0, 1, 1)
			-- DrawLine(missile.msl_pos,new_msl_pos, print_colour[1], print_colour[2], print_colour[3])
			-- DrawLine(missile.msl_pos, VecAdd(missile.msl_pos,Vec(0,1,0)), print_colour[1], print_colour[2], print_colour[3])
			missile.msl_pos = new_msl_pos	

			missile.last_target_vel = target_vel
			
			missile.tgt_pos = VecAdd(missile.tgt_pos,target_vel)
			
		end
	else
		missile.guidance_time = missile.guidance_time +dt
	end
	return missile

end


function autopilot_x(dt,missile)


	-- missile = {
	-- 	missile_body = msl_body ,
	-- 	target_body = target_body,
	-- 	msl_pos = msl_pos ,
	-- 	msl_pos_previous = msl_pos ,
	-- 	missile_vel = missile_vel,
	-- 	tgt_pos = target_pos ,
	-- 	tgt_pos_previous = target_pos ,
	-- 	target_vel = target_vel
	-- last_target_vel = target_vel
		-- N = 3.0,
		-- nt = 664, 


	-- }

	latax = base_pronav(
		missile.msl_pos, 
		missile.tgt_pos, 
		missile.msl_pos_previous, 
		missile.tgt_pos_previous, 
		missile.N , 
		missile.Nt*dt )
	local new_msl_vel  = flight_controller_X(
		missile.missile_vel, 
		VecScale(latax,-1), 
		missile.missile_min_vel,
		missile.missile_max_vel,
		missile.Nt*missile.missile_ramp_speed
		)			
	missile.missile_vel =  new_msl_vel
	--# Update positions to feed forward to next frame.
	missile.msl_pos_previous = missile.msl_pos
	missile.tgt_pos_previous = missile.tgt_pos
	return missile


end



function base_pronav(
	msl_pos,
	tgt_pos,
	msl_pos_previous, 
	tgt_pos_previous, 
	N , 
	Nt 
	)
	local LOS_Delta = Vec()
	local LOS_Rate = 0
	local latax = Vec()
	if (msl_pos_previous  and tgt_pos_previous ) then 
			local RTM_new =  VecSub(tgt_pos, msl_pos )
			local RTM_old =  VecSub( tgt_pos_previous,msl_pos_previous )	
			--# normalize RTM vectors
			RTM_new = VecNormalize(RTM_new)
			RTM_old = VecNormalize(RTM_old)
			
			if VecLength(RTM_old) == 0 then 
				LOS_Delta = Vec( 0, 0, 0 )
				LOS_Rate = 0.0
			else
				LOS_Delta = VecSub(RTM_new, RTM_old)
				LOS_Rate = VecLength(LOS_Delta)
			end
			--# range closing rate
			local Vc = -LOS_Rate
		--	# Now, calculate the final lateral acceleration required for our missile
		--	# to home into our target.
			latax =  VecAdd(VecScale(RTM_new, N * Vc * LOS_Rate) , VecScale(LOS_Delta, Nt * ( 0.5 * N )))
		end
	return latax		
end


function flight_controller_X(current_vel, adjustment_vel,min, max,Nt)
	if(VecLength(current_vel)<max)then 

		current_vel = VecScale(current_vel,clamp(max/VecLength(current_vel),0,Nt))
	end

	-- DebugWatch("max vel",max)
	-- DebugWatch("current vel",current_vel)
	-- DebugWatch("vel legth ",VecLength(current_vel) )
	-- DebugWatch("adjustment_vel",adjustment_vel)

	adjustment_vel = VecScale(adjustment_vel,clamp(Nt/VecLength(adjustment_vel),0,1))
	-- if(VecLenth(adjustment_vel)

	current_vel = VecAdd(current_vel,adjustment_vel)
	if(VecLength(current_vel) >max) then

		current_vel = VecScale(current_vel,clamp(max/VecLength(current_vel),0,1))

	end
	return current_vel
end




function reworked_top_down(dt,target_dist,z)
	local expected_guidance_drop_dist = guidance_drop_dist
	DebugPrint("TARGET:"..target_dist)

	DebugCross(Vec(target_dist,guidance_start_y,z),0,2,0)
	DebugLine(Vec(0,guidance_start_y_2 ,z),Vec(target_dist,guidance_start_y_2 ,z),0,2,0)

	-- # sampling rate
	local sr = 10
	local true_sample = sr/2
	-- # sampling interval
	local ts = 1.0/sr
	

	-- # frequency of the signal
	local freq = 0.5
	local last = 0
	local x_pos = 0
	local y_pos = 0
	local last_x_pos = 0
	local last_y_pos = guidance_start_y
	local t = 0 

	local expected_guidance_climb_dist = guidance_peak_dist
	local expected_guidance_climb_height = guidance_peak_height

	local tick_cutoff = 0.99
	if(expected_guidance_drop_dist >=target_dist) then 
		expected_guidance_drop_dist = target_dist *.75
	end
	local total_travel = expected_guidance_climb_dist + expected_guidance_drop_dist
	local overcompensation = 1.1
	if(total_travel > target_dist) then 
		local climb_coef = (target_dist -  expected_guidance_drop_dist) /  expected_guidance_climb_dist
		expected_guidance_climb_dist = expected_guidance_climb_dist * climb_coef
		expected_guidance_climb_height = expected_guidance_climb_height * climb_coef
		overcompensation = 1.0
	end


	local hit_apex = false
	
	local cutoff_y = 0

	local flight_distance = 0


	local x_move = 0
	local drop_offset = 0

	for i = 1,sr do 
		t = ts * (i-1)
		y = math.sin(2*math.pi*freq*t)

		x_move = ((expected_guidance_climb_dist*2) * t)

		if(not hit_apex) then 
			x_pos = x_move +flight_distance
			y_pos = ((expected_guidance_climb_height * y) ) +  guidance_start_y
		else
			x_pos = (((expected_guidance_drop_dist*2) * t)-drop_offset) +flight_distance 
			y_pos = ((expected_guidance_climb_height * y) ) +  guidance_start_y
			DrawLine(Vec(x_pos, y_pos, z), Vec(x_pos, y_pos+0.5, z), 0, 1, 1)
		end
		if(not hit_apex and y> tick_cutoff) then 
			DebugPrint("apex"..y)
			hit_apex = true

			drop_offset =  ((expected_guidance_drop_dist*2) * t) * overcompensation 

			DrawLine(Vec(x_pos, y_pos, z), Vec(x_pos, y_pos+2, z), 0, 0, 1)
			DebugPrint(x_pos - expected_guidance_drop_dist )
			if((target_dist- x_pos ) - expected_guidance_drop_dist > 0) then 
				flight_distance = continue_flight(x_pos,y_pos,z,expected_guidance_drop_dist,target_dist)
			else
				flight_distance = x_pos
			end

		end
		-- if(hit_apex) then 

			DrawLine(Vec(last_x_pos, last_y_pos, z), Vec(x_pos, y_pos, z), 1, 0, 0)

			DrawLine(Vec(x_pos, y_pos, z), Vec(x_pos, y_pos, z+1), 1, 0.5, 0.5)
		-- end
		-- DebugPrint(x_pos)
		last_y_pos = y_pos
		last_x_pos = x_pos



	end

end


function continue_flight(x_pos,y_pos,z,expected_guidance_drop_dist,target_dist)
	local last_x_pos = x_pos
	local last_y_pos = y_pos
	local expected_fight_distance = (target_dist - (guidance_drop_dist)) - x_pos
	local flight_distance = x_pos
	local increment_size = math.max(expected_fight_distance / 10,1)
	for i=1,expected_fight_distance/increment_size do
		flight_distance = flight_distance + increment_size
		x_pos = last_x_pos + increment_size


		-- DebugPrint("xpos "..x_pos)
		DrawLine(Vec(x_pos, last_y_pos, z), Vec(x_pos, y_pos-0.5, z), 1, 1, 0)

		last_x_pos = x_pos
		if (x_pos > (target_dist-expected_guidance_drop_dist)) then
			break
		end
	end


	return flight_distance


	
end



	-- 	if(y>tick_cutoff or  x_pos > (target_dist-guidance_drop_dist) ) then 
	-- 		if(y<0.99) then 
	-- 			for j = i, true_sample do 
	-- 				t = ts * (i-1)
	-- 				y = math.sin(2*math.pi*freq*t)
	-- 				if
	-- 		else
	-- 			cutoff_y = i
	-- 		end
	-- 		cutoff_x = x_pos
	-- 		guidance_drop_height = guidance_peak_height
	-- 		 DebugPrint(y>tick_cutoff)
	-- 		-- DebugPrint("condition 1 "..(y>tick_cutoff) .." condition 2"..  x_pos > (target_dist-guidance_drop_dist))
	-- 		break
	-- 	end

	-- end



	-- for i=1,target_dist do
	-- 	flight_distance = flight_distance + 1
	-- 	x_pos = last_x_pos + 1 


	-- 	-- DebugPrint("xpos "..x_pos)
	-- 	DrawLine(Vec(last_x_pos, last_y_pos, z), Vec(x_pos, y_pos, z), 1, 0, 0)

	-- 	last_x_pos = x_pos
	-- 	if (x_pos > (target_dist-guidance_drop_dist)) then
	-- 		break
	-- 	end
	-- end


	-- flight_distance = x_pos
	-- DebugWatch("custoff",cutoff_y)
	-- DebugWatch("true sampe",true_sample)
	-- for i = cutoff_y,true_sample,1 do 

	-- 	t = ts * (i-1)
	-- 	y = math.sin(2*math.pi*freq*t)
	-- 	x_pos = ((guidance_drop_dist*2) * t ) + flight_distance
	-- 	y_pos = ((guidance_drop_height * y) ) +  guidance_start_y

	-- DebugWatch("true saddddse",flight_distance)

	-- 	DrawLine(Vec(last_x_pos, last_y_pos, z), Vec(x_pos, y_pos, z), 1, 0, 0)

	-- 	last_y_pos = y_pos
	-- 	last_x_pos = x_pos

	-- end


	-- -- for i = 1,sr/2 do 
	-- -- 	t = ts * (i-1)
	-- -- 	y = math.sin(2*math.pi*freq*t)
	-- -- 	DebugPrint(ts)
	-- -- 	x_pos = (guidance_peak_dist*2) * t 
	-- -- 	y_pos = ((guidance_peak_height * y) ) +  guidance_peak_height


	-- -- 	DrawLine(Vec(last_x_pos, last_y_pos, 0), Vec(x_pos, y_pos, 0), 1, 0, 0)

	-- -- 	last_y_pos = y_pos
	-- -- 	last_x_pos = x_pos

	-- -- end



-- end







function basic_top_down(dt,target_dist,z)

	DebugPrint("TARGET:"..target_dist)

	local guidance_drop_dist = guidance_peak_dist * 1.5
	-- # sampling rate
	local sr = 100.0
	local true_sample = sr/2
	-- # sampling interval
	local ts = 1.0/sr
	

	-- # frequency of the signal
	local freq = 1
	local last = 0
	local x_pos = 0
	local y_pos = 0
	local last_x_pos = 0
	local last_y_pos = guidance_peak_height
	local t = 0 


	local tick_cutoff = 0.99
	if(guidance_peak_dist + guidance_drop_dist > target_dist) then 
		tick_cutoff = (target_dist -  guidance_drop_dist / guidance_peak_dist)
	end
	
	local cutoff_y = 0

	local flight_distance = 0

	for i = 1,true_sample do 
		t = ts * (i-1)
		y = math.sin(2*math.pi*freq*t)
		x_pos = ((guidance_peak_dist) * t) +flight_distance
		y_pos = ((guidance_peak_height * y) ) +  guidance_peak_height


		DrawLine(Vec(last_x_pos, last_y_pos, z), Vec(x_pos, y_pos, z), 1, 0, 0)
		-- DebugPrint(x_pos)
		last_y_pos = y_pos
		last_x_pos = x_pos
		if(y>tick_cutoff or  x_pos > (target_dist-guidance_drop_dist) ) then 
			cutoff_y = i
			cutoff_x = x_pos
			 DebugPrint(y>tick_cutoff)
			-- DebugPrint("condition 1 "..(y>tick_cutoff) .." condition 2"..  x_pos > (target_dist-guidance_drop_dist))
			break
		end

	end



	for i=1,target_dist do
		flight_distance = flight_distance + 1
		x_pos = last_x_pos + 1 


		-- DebugPrint("xpos "..x_pos)
		DrawLine(Vec(last_x_pos, last_y_pos, z), Vec(x_pos, y_pos, z), 1, 0, 0)

		last_x_pos = x_pos
		if (x_pos > (target_dist-guidance_drop_dist)) then
			break
		end
	end


	flight_distance = x_pos
	DebugWatch("custoff",cutoff_y)
	DebugWatch("true sampe",true_sample)
	for i = cutoff_y,true_sample,1 do 

		t = ts * (i-1)
		y = math.sin(2*math.pi*freq*t)
		x_pos = ((guidance_drop_dist*2) * t ) + flight_distance
		y_pos = ((guidance_peak_height * y) ) +  guidance_peak_height

	DebugWatch("true saddddse",flight_distance)

		DrawLine(Vec(last_x_pos, last_y_pos, z), Vec(x_pos, y_pos, z), 1, 0, 0)

		last_y_pos = y_pos
		last_x_pos = x_pos

	end


	-- for i = 1,sr/2 do 
	-- 	t = ts * (i-1)
	-- 	y = math.sin(2*math.pi*freq*t)
	-- 	DebugPrint(ts)
	-- 	x_pos = (guidance_peak_dist*2) * t 
	-- 	y_pos = ((guidance_peak_height * y) ) +  guidance_peak_height


	-- 	DrawLine(Vec(last_x_pos, last_y_pos, 0), Vec(x_pos, y_pos, 0), 1, 0, 0)

	-- 	last_y_pos = y_pos
	-- 	last_x_pos = x_pos

	-- end



end



function basic_sin(dt)


	-- # sampling rate
	local sr = 100.0
	-- # sampling interval
	local ts = 1.0/sr
	
	local heigt = 5

	-- # frequency of the signal
	local freq = 2
	local last = 0
	local x_pos = 0
	local y_pos = 0
	local last_x_pos = 0
	local last_y_pos = heigt
	local t = 0 

	
	local dist = 10
	for i = sr/2,sr do 
		t = ts * (i-1)
		y = math.sin(2*math.pi*freq*t)
		DebugPrint(ts)
		x_pos = (dist*2) * t 
		y_pos = ((heigt * y) ) +  heigt


		DrawLine(Vec(last_x_pos, last_y_pos, 0), Vec(x_pos, y_pos, 0), 1, 0, 0)

		last_y_pos = y_pos
		last_x_pos = x_pos

	end



end




-- function guidance_tick(dt)
-- 	DebugWatch("guidance being run",dt)

-- 	local target_dist =  100

-- 	local guidance_drop_dist = guidance_peak_dist * 1.5
-- 	-- # sampling rate
-- 	local sr = 100.0
-- 	local true_sample = sr/2
-- 	-- # sampling interval
-- 	local ts = 1.0/sr
	

-- 	-- # frequency of the signal
-- 	local freq = 1
-- 	local last = 0
-- 	local x_pos = 0
-- 	local y_pos = 0
-- 	local last_x_pos = 0
-- 	local last_y_pos = guidance_peak_height
-- 	local t = 0 

-- 	local tick_cutoff = 0.99

	
-- 	local cutoff_y = 0

-- 	local flight_distance = 0

-- 	for i = 1,true_sample do 
-- 		t = ts * (i-1)
-- 		y = math.sin(2*math.pi*freq*t)
-- 		x_pos = ((guidance_peak_dist*2) * t) +flight_distance
-- 		y_pos = ((guidance_peak_height * y) ) +  guidance_peak_height


-- 		DrawLine(Vec(last_x_pos, last_y_pos, 0), Vec(x_pos, y_pos, 0), 1, 0, 0)

-- 		last_y_pos = y_pos
-- 		last_x_pos = x_pos
-- 		if(y>tick_cutoff or x_pos > (target_dist-guidance_drop_dist) ) then 
-- 			cutoff_y = i
-- 			cutoff_x = x_pos
-- 			break
-- 		end

-- 	end
-- 	DebugPrint(1)
-- 	for i=1,target_dist do
-- 		DebugPrint(2)
-- 		flight_distance = flight_distance + 1
-- 		x_pos = last_x_pos + 1 


-- 		DebugPrint(x_pos)
-- 		DrawLine(Vec(last_x_pos, last_y_pos, 0), Vec(x_pos, y_pos, 0), 1, 0, 0)

-- 		last_x_pos = x_pos
-- 		if (flight_distance < target_dist - (cutoff_x)) then
-- 			break
-- 		end
-- 	end


-- 	flight_distance = x_pos
-- 	DebugWatch("custoff",cutoff_y)
-- 	DebugWatch("true sampe",true_sample)
-- 	for i = cutoff_y,true_sample,1 do 

-- 		DebugPrint("i "..i.." f "..cutoff_y.." x"..true_sample)
-- 		t = ts * (i-1)
-- 		y = math.sin(2*math.pi*freq*t)
-- 		x_pos = ((guidance_drop_dist*2) * t ) + flight_distance
-- 		y_pos = ((guidance_peak_height * y) ) +  guidance_peak_height

-- 	DebugWatch("true saddddse",flight_distance)

-- 		DrawLine(Vec(last_x_pos, last_y_pos, 0), Vec(x_pos, y_pos, 0), 1, 0, 0)

-- 		last_y_pos = y_pos
-- 		last_x_pos = x_pos

-- 	end


-- 	-- for i = 1,sr/2 do 
-- 	-- 	t = ts * (i-1)
-- 	-- 	y = math.sin(2*math.pi*freq*t)
-- 	-- 	DebugPrint(ts)
-- 	-- 	x_pos = (guidance_peak_dist*2) * t 
-- 	-- 	y_pos = ((guidance_peak_height * y) ) +  guidance_peak_height


-- 	-- 	DrawLine(Vec(last_x_pos, last_y_pos, 0), Vec(x_pos, y_pos, 0), 1, 0, 0)

-- 	-- 	last_y_pos = y_pos
-- 	-- 	last_x_pos = x_pos

-- 	-- end



-- end

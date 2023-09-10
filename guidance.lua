
test_distance = 30 
scale_modifier = 1

t_test_distance = 7

t_guidance_peak_dist = 50



DEBUG_GUIDANCE_FUNCTIONALITY =true



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
	local guidance_height_ratio =  projectile.shellType.guidance_height_ratio 
	local guidance_peak_height = guidance_peak_dist * guidance_height_ratio
	local guidance_drop_dist = guidance_peak_dist * 1.5
	local flight_pattern = {}
	flight_pattern,flight_index = top_down_computation(
		projectile,
		guidance_peak_dist,
		guidance_peak_height,
		guidance_drop_dist,
		flight_pattern,
		target_dist
		)
	return flight_pattern,flight_index



end


function top_down_computation(
	projectile,
	guidance_peak_dist,
	guidance_peak_height,
	guidance_drop_dist,
	flight_pattern,
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
	return flight_pattern,flight_index

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

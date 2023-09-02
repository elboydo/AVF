





local vehicle_weight = GetIntParam("weight", 1)


pathing_vehicle_id = 0

last_ai = -1

--This is the maximum time in seconds before aborting a path query
--Increasing this will handle more complex scenarios
MIN_THINK_TIME = 2.0
MAX_THINK_TIME = 2.0
ULTIMATE_THINK_TIME = 15.0


AVF_PATHFINDING_STEP = 3.23
path_step =2--2
avoidance_size = 3.5
max_steer = 3
PATH_NODE_TOLERANCE = 4.1


path_update_timer_max = 3
path_update_timer = 0  
static_timeout = 0
static_timeout_max = 5
timeout_pos = Vec()

goalPos = nil

function init_pathing()	
	path_step = AVF_PATHFINDING_STEP
	path_update_timer = path_update_timer_max
	PATH_NODE_TOLERANCE = path_step*(avoidance_size*1.3)
	max_steer = path_step * 2
	
end



function pathing_tick(dt,ai_state)
	--Get the current position of start and goal bodies
	get_target_input()

	if(VecLength(goalPos)~= 0) then 
		-- DebugWatch("goalpos",VecLength(goalPos))
		SpawnParticle("smoke", goalPos, Vec(0,5,0), 0.5, 1)
	end
	if(ai_state.pathing.goal_pos ~= nil) then 
		pathfinding()
		if(IsHandleValid(vehicle)and #lastPath>0) then 
			navigationPrunePath(lastPath,GetVehicleTransform(vehicle))
			controlVehicle(lastPath)
		end
	end
end

function get_target_input()
	
	if InputPressed("g") then

		local camera = GetCameraTransform()
		local aimpos = TransformToParentPoint(camera, Vec(0, 0, -300))
		local hit, dist,normal = QueryRaycast(camera.pos,  VecNormalize(VecSub(aimpos, camera.pos)), 200,0)
		if hit then
			
			goalPos = TransformToParentPoint(camera, Vec(0, 0, -dist))

		end 	
	end
end


function pathfinding()
	local dt = GetTimeStep()
	local startPos = GetVehicleTransform(vehicle).pos--GetBodyTransform(startBody).pos
--	local goalPos = GetBodyTransform(goalBody).pos


	if((VecLength(GetBodyVelocity(GetVehicleBody(vehicle))) < 5 and  
		path_update_timer > path_update_timer_max) or path_update_timer > path_update_timer_max*1.5) then 
		handle_path_plotting(startPos,goalPos,dt)
	else
		path_update_timer = path_update_timer + dt
	end
	--Draw last computed path and a red cross at the end of it in case it didn't reach the goal.
	drawPath()
	if failed then
		DebugCross(lastPath[#lastPath], 1, 0, 0)
	end
end


--[[ check if pathfinding system idle. ]]
function pathfinding_system_idle()
	local state = GetPathState()
	if state == "idle" then
		--Path finding system is not in use. Start a new query.
		return true
	else
		return false
	end
end


--[[
		
		This function will only ever fire for the active AI at the top of the list. 
		Returns false if no path, returns path if path found. 

]]
function handle_path_plotting(startPos,goalPos,dt,ai,vehicle_body_parts)
	if(MAX_THINK_TIME<ULTIMATE_THINK_TIME) then 
		MAX_THINK_TIME = math.min(math.max((GetTime()/ULTIMATE_THINK_TIME),MIN_THINK_TIME),ULTIMATE_THINK_TIME)
	end
	-- DebugWatch("MAX THINK TIME",MAX_THINK_TIME)
	local recalc = false
	local state = GetPathState()
	local found_path = false
	-- DebugWatch("path plotting current state ",state)
	-- DebugWatch("path plotting current ai id ",ai.id)
	if state == "idle" then
		--Path finding system is not in use. Start a new query.
		recalc = true
	elseif state == "done" then
		--Path finding system has completed a path query
		--Store the result and doesn't start new query, next ai will start query
		recalc = true
		thinkTime= 0
		if(last_ai == ai.id) then
			found_path = retrievePath(ai,vehicle_body_parts)
			path_update_timer = 0
		end
	elseif state == "fail" then
		--Path finding system has failed to find a valid path
		--It is still possible to retrieve a result (path to closest point found)
		--Store the result and start a new query.
		recalc = true
		found_path = retrievePath(ai,vehicle_body_parts)
		path_update_timer = 0
	else
		--Path finding system is currently busy. If it has been thinking for more than the 
		--allowed time, abort current query and store the best result
		thinkTime = thinkTime + dt
		if thinkTime > MAX_THINK_TIME then
			-- DebugPrint("AVORTING PATH")
			AbortPath()
			recalc = true
			found_path = retrievePath(ai,vehicle_body_parts)

			path_update_timer = 0
		end
	end

	if recalc and state ~= "busy" then
		--Compute path from startPos to goalPos but exclude startBody and goalBody from the query.
		--Set the maximum path length to 100 and let any point within 0.5 meters to the goal point
		--count as a valid path.
		local vehicle_transform = GetVehicleTransform(ai.id)
		for j =1,#vehicle_body_parts do 
			QueryRejectBody(vehicle_body_parts[j])
			local vehicle_shapes = GetBodyShapes(vehicle_body_parts[j])
			for i = 1,#vehicle_shapes do 
				QueryRejectShape(vehicle_shapes[i])
			end
		end

		local target_pos = TransformToParentPoint(GetVehicleTransform(ai.id),
			VecScale(
				VecNormalize(
						TransformToLocalPoint(vehicle_transform,goalPos)
						),
				avoidance_size*1.5
				))--Vec(0,0,-5))
		-- Explosion(target_pos)
		-- QueryRequire("physical large")
		QueryPath(target_pos, goalPos, 600.0, 5,"standard")
		last_ai = ai.id
		thinkTime = 0
	end
	return found_path
end


--This function retrieves the most recent path and stores it in lastPath
function retrievePath(ai,vehicle_body_parts)
	local lastPath = {}
	local length=GetPathLength()

	if GetPathLength() > 0.5 then
		for l=0.5, GetPathLength(), path_step  do
			local newPoint = GetPathPoint(l)
			if(VecLength(VecSub(newPoint,lastPath[#lastPath]))>path_step*.9) then 
				lastPath[#lastPath+1] = newPoint
				lastPath[#lastPath] = simple_obstacle_avoidance(lastPath[#lastPath],ai,vehicle_body_parts)
			end
		end
	end			
	return lastPath
	-- local l=0
	-- while l < length do
	-- 	lastPath[#lastPath+1] = GetPathPoint(l)
	-- 	l = l + 0.2
	-- end
end


--Prune path backwards so robot don't need to go backwards
function navigationPrunePath(path,ai)
	local vehicle_transform = GetVehicleTransform(ai.id)
	-- DebugWatch("navigating path for ai "..ai.id.."  at pos",vehicle_transform)
	if #path > 0 then
		for i=#path, 1, -1 do
			local p = path[i]
			local dv = VecSub(p, vehicle_transform.pos)
			local d = VecLength(dv)
			if d < PATH_NODE_TOLERANCE then
				-- DebugWatch("pruning path of length "..#path.." d value",d)
				--Keep everything after this node and throw out the rest
				local newPath = {}
				for j=i, #path do
					newPath[#newPath+1] = path[j]
				end
				return newPath
			end
		end
	end
	return path
end


--This function will draw the content of lastPath as a line
function drawPath(lastPath)
	DebugWatch("last path length",#lastPath)
	for i=1, #lastPath-1 do
		DrawLine(lastPath[i], lastPath[i+1])
		DebugCross(lastPath[i],1,0,0)
	end
end


function get_path_deviation(vehicle_transform,path,map_vel) 
	local lookAhead = 2
	local total_deviation = Vec()

	for i = 1, lookAhead do 
		local current_pos = path[math.min(#path,  i)]
		local next_pos = path[math.min(#path,  i+1)]
		local goalPos = path[math.min(#path,  i+2)]
		local current_transform = Transform(current_pos,
									 QuatLookAt(current_pos, next_pos))
		local next_deviation = TransformToLocalPoint(current_transform,goalPos)
		--local nextPos_deviation = VecSub(,goalPos) 
		--total_deviation = VecAdd(total_deviation,nextPos_deviation)
		total_deviation[1] = total_deviation[1]+next_deviation[1]
		-- DebugPrint(i.. " | "..VecStr(next_deviation))
	end
	
	-- DebugWatch("total_deviation_1",total_deviation)
	total_deviation = VecScale(total_deviation,(1/lookAhead))

	-- DebugWatch("total_deviation_2",total_deviation)
	total_deviation[1] = total_deviation[1]

	-- VecScale(total_deviation,)

	return total_deviation
end


function simple_obstacle_avoidance(pos,ai,vehicle_body_parts)
	local size = avoidance_size 

	local testPoint = VecAdd(pos,Vec(0,size,0))
	for j =1,#vehicle_body_parts do 
		QueryRejectBody(vehicle_body_parts[j])
		local vehicle_shapes = GetBodyShapes(vehicle_body_parts[j])
		for i = 1,#vehicle_shapes do 
			QueryRejectShape(vehicle_shapes[i])
		end
	end
	local hit, p, n, s = QueryClosestPoint(testPoint,size)
	if(hit) then 

		local newVec = VecSub(testPoint,p)
		for i =1,#newVec do 
			newVec[i] = (size-math.abs(newVec[i])) *math.sign(newVec[i])

		end
		newVec[2] = 0
		pos = VecAdd(pos,newVec)
	end

	return pos
end

function controlVehicle(path,ai)
	local vel = GetBodyVelocity(GetVehicleBody(ai.id))
	local map_vel = math.floor(VecLength(vel)/path_step*.25)+1

	local map_vel_steer = math.floor(VecLength(vel)/(path_step*.5))+1
	-- DebugWatch("vel",VecLength(vel))
	-- DebugWatch("adjusted vel",VecLength(vel)%path_step)
	-- DebugWatch("adjusted vel 2",math.floor(VecLength(vel)/path_step)+1)
	
	local goalPos =path[math.min(#path, map_vel)]
	local goalPos_steer =path[math.min(#path, 3)] 
	local vehicle_transform = GetVehicleTransform(ai.id)
	local deviation =get_path_deviation(vehicle_transform,path,map_vel)
	local target_pos = TransformToLocalPoint(vehicle_transform,goalPos)--VecAdd(goalPos,VecScale(deviation,-1)) --TransformToLocalPoint(vehicle_transform,goalPos)
	local target_pos_steer = TransformToLocalPoint(vehicle_transform,goalPos_steer)--VecAdd(goalPos,VecScale(deviation,-1)) --TransformToLocalPoint(vehicle_transform,goalPos)
	 
	DebugWatch("ai "..ai.id.." vehicle_transform ",vehicle_transform) 
	DebugWatch("ai "..ai.id.." goalpos ",goalPos)
	-- DebugWatch("ai: "..ai.id.." x",target_pos[1])
	-- DebugWatch("z",target_pos[3])
	-- DebugWatch("time",GetTime())
	local steer_force = (-(math.abs(target_pos_steer[1]/path_step)*math.sign(target_pos_steer[1])))

	local acceleration= -(((math.abs(target_pos[3])/map_vel	))*math.sign(target_pos[3]))
	acceleration=clamp(acceleration,-1,1)
	if(acceleration<0.1) then 
		acceleration = acceleration*5
	end
	if(target_pos[1]>path_step*2) then
		acceleration = -acceleration
	end 
	steer_force = steer_force-deviation[1]
	-- DebugWatch("pre acceleration",acceleration)
	acceleration = acceleration * (math.max(1-
				
				(math.max(
						VecLength(deviation),
						math.abs(target_pos_steer[1]))
				/max_steer),0.1 ))
	-- acceleration = acceleration * (math.max(1-(math.abs(VecLength(deviation))/max_steer),0.1 ))
	-- DebugWatch("speed scale",(math.max(
	-- 					VecLength(deviation),
	-- 					math.abs(target_pos_steer[1]))
	-- 			/max_steer))
	DebugWatch("ai: "..ai.id.." post acceleration",acceleration)
	DebugWatch("ai: "..ai.id.." STEER FORCE",steer_force)

	
	-- DebugWatch("timeout",static_timeout)
	if(VecLength(
			VecSub(
				path[#path],
				vehicle_transform.pos))
		>path_step*2 and VecLength(vel)<0.5 ) then 
		static_timeout = static_timeout+GetTimeStep()
		timeout_pos = vehicle_transform.pos
	else
		if(VecLength(VecSub(timeout_pos,vehicle_transform.pos))>path_step*2) then
			static_timeout = 0
		end
		-- static_timeout = math.max(static_timeout-GetTimeStep()*.5,0)
	end
	if(static_timeout>static_timeout_max*1) then 
		acceleration = -math.sign(acceleration)

		if(static_timeout>static_timeout_max*1.5) then 
			static_timeout = 0
		end
	end

	steer_force = steer_force * math.sign(acceleration)
	-- DebugWatch("remaining lentgh ",VecLength(
	-- 		VecSub(
	-- 			path[#path],
	-- 			vehicle_transform.pos))
	-- 	)
	-- DebugWatch("acceleration pre",acceleration)
	acceleration = acceleration* math.min(VecLength(vehicle_transform.pos,path[#path]) / path_step*4,1)
	-- DebugWatch("acceleration",acceleration)
	-- DebugWatch("path length ",#path)
	if(VecLength(
			VecSub(
				path[#path],
				vehicle_transform.pos))
		>path_step*2) then 
		DriveVehicle(ai.id, acceleration,steer_force, false)
	else
		DriveVehicle(ai.id, 0,0, true)
	end

end


function clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function math.sign(x) 
	if(x<0) then 
		return -1
	else
		return 1
	end

end



function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--[[





local vehicle_weight = GetIntParam("weight", 1)

--This is the maximum time in seconds before aborting a path query
--Increasing this will handle more complex scenarios
MAX_THINK_TIME = 1.0

path_step =2
avoidance_size = 3
max_steer = 3
PATH_NODE_TOLERANCE = 2.5


path_update_timer_max = 3
path_update_timer = 0  
static_timeout = 0
static_timeout_max = 5
timeout_pos = Vec()

goalPos = nil

function init_pathing()	
	path_update_timer = path_update_timer_max
	vehicle = FindVehicle("ai_testbed")
	PATH_NODE_TOLERANCE = path_step*(avoidance_size*1.3)
	max_steer = path_step * 2
	vehicle_shapes = FindShapes(vehicle,true)
	vehicle_bodies = {}
	for i=1,#vehicle_shapes do 
		body = GetShapeBody(vehicle_shapes[i])
		local body_exists = false
		for j =1,#vehicle_bodies do 
			if(body == vehicle_bodies[j]) then 
				body_exists = true
				break
			end
		end
		if(not body_exists) then 
			vehicle_bodies[#vehicle_bodies+1] = body
		end

	end	
	--Find handles to start and goal bodies
	startBody = GetVehicleBody(vehicle)
	goalBody = FindBody("goal",true)
	
	--Table to hold all points of the last computed path
	lastPath = {}
end


--This function retrieves the most recent path and stores it in lastPath
function retrievePath()
	lastPath = {}
	local length=GetPathLength()

	if GetPathLength() > 0.5 then
		for l=0.5, GetPathLength(), path_step  do
			local newPoint = GetPathPoint(l)
			if(VecLength(VecSub(newPoint,lastPath[#lastPath]))>path_step*.9) then 
				lastPath[#lastPath+1] = newPoint
				lastPath[#lastPath] = simple_obstacle_avoidance(lastPath[#lastPath])
			end
		end
	end			

	-- local l=0
	-- while l < length do
	-- 	lastPath[#lastPath+1] = GetPathPoint(l)
	-- 	l = l + 0.2
	-- end
end


--Prune path backwards so robot don't need to go backwards
function navigationPrunePath(path,vehicle_transform)
	if #path > 0 then
		for i=#path, 1, -1 do
			local p = path[i]
			local dv = VecSub(p, vehicle_transform.pos)
			local d = VecLength(dv)
			if d < PATH_NODE_TOLERANCE then
				--Keep everything after this node and throw out the rest
				local newPath = {}
				for j=i, #path do
					newPath[#newPath+1] = path[j]
				end
				lastPath= newPath
				return 
			end
		end
	end
end


--This function will draw the content of lastPath as a line
function drawPath()
	DebugWatch("last path elngth",#lastPath)
	for i=1, #lastPath-1 do
		DrawLine(lastPath[i], lastPath[i+1])
		DebugCross(lastPath[i],1,0,0)
	end
end




function tick(dt)
	--Get the current position of start and goal bodies
	get_target_input()

	if(VecLength(goalPos)~= 0) then 
		-- DebugWatch("goalpos",VecLength(goalPos))
		SpawnParticle("smoke", goalPos, Vec(0,5,0), 0.5, 1)
	end
	if(goalPos~=nil) then 
		pathfinding()
		if(IsHandleValid(vehicle)and #lastPath>0) then 
			navigationPrunePath(lastPath,GetVehicleTransform(vehicle))
			controlVehicle(lastPath)
		end
	end
end

function get_target_input()
	
	if InputPressed("g") then

		local camera = GetCameraTransform()
		local aimpos = TransformToParentPoint(camera, Vec(0, 0, -300))
		local hit, dist,normal = QueryRaycast(camera.pos,  VecNormalize(VecSub(aimpos, camera.pos)), 200,0)
		if hit then
			
			goalPos = TransformToParentPoint(camera, Vec(0, 0, -dist))

		end 	
	end
end

function pathfinding()
	local dt = GetTimeStep()
	local startPos = GetVehicleTransform(vehicle).pos--GetBodyTransform(startBody).pos
--	local goalPos = GetBodyTransform(goalBody).pos


	if((VecLength(GetBodyVelocity(GetVehicleBody(vehicle))) < 5 and  
		path_update_timer > path_update_timer_max) or path_update_timer > path_update_timer_max*1.5) then 
		handle_path_plotting(startPos,goalPos,dt)
	else
		path_update_timer = path_update_timer + dt
	end
	--Draw last computed path and a red cross at the end of it in case it didn't reach the goal.
	drawPath()
	if failed then
		DebugCross(lastPath[#lastPath], 1, 0, 0)
	end
end


function handle_path_plotting(startPos,goalPos,dt)
	
	local recalc = false
	local state = GetPathState()
	DebugWatch("path plotting ",state)
	if state == "idle" then
		--Path finding system is not in use. Start a new query.
		recalc = true
	elseif state == "done" then
		--Path finding system has completed a path query
		--Store the result and start a new query.
		recalc = true
		failed = false
		retrievePath()
		path_update_timer = 0
	elseif state == "fail" then
		--Path finding system has failed to find a valid path
		--It is still possible to retrieve a result (path to closest point found)
		--Store the result and start a new query.
		recalc = true	
		failed = true
		retrievePath()

		path_update_timer = 0
	else
		--Path finding system is currently busy. If it has been thinking for more than the 
		--allowed time, abort current query and store the best result
		thinkTime = thinkTime + dt
		if thinkTime > MAX_THINK_TIME then
			AbortPath()
			recalc = true
			failed = true
			retrievePath()

			path_update_timer = 0
		end
	end

	if recalc then
		--Compute path from startPos to goalPos but exclude startBody and goalBody from the query.
		--Set the maximum path length to 100 and let any point within 0.5 meters to the goal point
		--count as a valid path.
		QueryRejectBody(startBody)
		QueryRejectBody(goalBody)
		local vehicle_transform = GetVehicleTransform(vehicle)
		for j =1,#vehicle_bodies do 
			QueryRejectBody(vehicle_bodies[j])

		end
		for i = 1,#vehicle_shapes do 
			QueryRejectShape(vehicle_shapes[i])
		end
		local target_pos = TransformToParentPoint(GetVehicleTransform(vehicle),
			VecScale(
				VecNormalize(
						TransformToLocalPoint(vehicle_transform,goalPos)
						),
				avoidance_size*1.5
				))--Vec(0,0,-5))
		-- Explosion(target_pos)
		-- QueryRequire("physical large")
		QueryPath(target_pos, goalPos, 150.0, 1,"standard")
		thinkTime = 0
	end

end

function get_path_deviation(vehicle_transform,path,map_vel) 
	local lookAhead = 2
	local total_deviation = Vec()

	for i = 1, lookAhead do 
		local current_pos = path[math.min(#path,  i)]
		local next_pos = path[math.min(#path,  i+1)]
		local goalPos = path[math.min(#path,  i+2)]
		local current_transform = Transform(current_pos,
									 QuatLookAt(current_pos, next_pos))
		local next_deviation = TransformToLocalPoint(current_transform,goalPos)
		--local nextPos_deviation = VecSub(,goalPos) 
		--total_deviation = VecAdd(total_deviation,nextPos_deviation)
		total_deviation[1] = total_deviation[1]+next_deviation[1]
		-- DebugPrint(i.. " | "..VecStr(next_deviation))
	end
	
	DebugWatch("total_deviation_1",total_deviation)
	total_deviation = VecScale(total_deviation,(1/lookAhead))

	DebugWatch("total_deviation_2",total_deviation)
	total_deviation[1] = total_deviation[1]

	-- VecScale(total_deviation,)

	return total_deviation
end


function simple_obstacle_avoidance(pos)
	local size = avoidance_size 

	local testPoint = VecAdd(pos,Vec(0,size,0))
	for j =1,#vehicle_bodies do 
		QueryRejectBody(vehicle_bodies[j])

	end
	for i = 1,#vehicle_shapes do 
		QueryRejectShape(vehicle_shapes[i])
	end
	local hit, p, n, s = QueryClosestPoint(testPoint,size)
	if(hit) then 

		local newVec = VecSub(testPoint,p)
		for i =1,#newVec do 
			newVec[i] = (size-math.abs(newVec[i])) *math.sign(newVec[i])

		end
		newVec[2] = 0
		pos = VecAdd(pos,newVec)
	end

	return pos
end

function controlVehicle(path)
	local vel = GetBodyVelocity(GetVehicleBody(vehicle))
	local map_vel = math.floor(VecLength(vel)/path_step*.25)+1

	local map_vel_steer = math.floor(VecLength(vel)/(path_step*.5))+1
	-- DebugWatch("vel",VecLength(vel))
	-- DebugWatch("adjusted vel",VecLength(vel)%path_step)
	-- DebugWatch("adjusted vel 2",math.floor(VecLength(vel)/path_step)+1)
	
	local goalPos =path[math.min(#path, map_vel)] 

	goalPos_steer =path[math.min(#path, 3)] 
	local vehicle_transform = GetVehicleTransform(vehicle)
	local deviation =get_path_deviation(vehicle_transform,path,map_vel)
	local target_pos = TransformToLocalPoint(vehicle_transform,goalPos)--VecAdd(goalPos,VecScale(deviation,-1)) --TransformToLocalPoint(vehicle_transform,goalPos)
	local target_pos_steer = TransformToLocalPoint(vehicle_transform,goalPos_steer)--VecAdd(goalPos,VecScale(deviation,-1)) --TransformToLocalPoint(vehicle_transform,goalPos)
	DebugWatch("x",target_pos[1])
	DebugWatch("z",target_pos[3])
	DebugWatch("time",GetTime())
	local steer_force = (-(math.abs(target_pos_steer[1]/path_step)*math.sign(target_pos_steer[1])))

	local acceleration= -(((math.abs(target_pos[3])/map_vel	))*math.sign(target_pos[3]))
	acceleration=clamp(acceleration,-1,1)
	if(acceleration<0.1) then 
		acceleration = acceleration*5
	end
	if(target_pos[1]>path_step*2) then
		acceleration = -acceleration
	end 
	steer_force = steer_force-deviation[1]
	DebugWatch("pre acceleration",acceleration)
	acceleration = acceleration * (math.max(1-
				
				(math.max(
						VecLength(deviation),
						math.abs(target_pos_steer[1]))
				/max_steer),0.1 ))
	-- acceleration = acceleration * (math.max(1-(math.abs(VecLength(deviation))/max_steer),0.1 ))
	DebugWatch("speed scale",(math.max(
						VecLength(deviation),
						math.abs(target_pos_steer[1]))
				/max_steer))
	DebugWatch("post acceleration",acceleration)
	DebugWatch("STEER FORCE",steer_force)

	
	DebugWatch("timeout",static_timeout)
	if(VecLength(
			VecSub(
				path[#path],
				vehicle_transform.pos))
		>path_step*2 and VecLength(vel)<0.5 ) then 
		static_timeout = static_timeout+GetTimeStep()
		timeout_pos = vehicle_transform.pos
	else
		if(VecLength(VecSub(timeout_pos,vehicle_transform.pos))>path_step*2) then
			static_timeout = 0
		end
		-- static_timeout = math.max(static_timeout-GetTimeStep()*.5,0)
	end
	if(static_timeout>static_timeout_max*1) then 
		acceleration = -math.sign(acceleration)

		if(static_timeout>static_timeout_max*1.5) then 
			static_timeout = 0
		end
	end

	steer_force = steer_force * math.sign(acceleration)
	-- DebugWatch("remaining lentgh ",VecLength(
	-- 		VecSub(
	-- 			path[#path],
	-- 			vehicle_transform.pos))
	-- 	)
	DebugWatch("acceleration pre",acceleration)
	acceleration = acceleration* math.min(VecLength(vehicle_transform.pos,path[#path]) / path_step*4,1)
	DebugWatch("acceleration",acceleration)
	DebugWatch("path length ",#path)
	if(VecLength(
			VecSub(
				path[#path],
				vehicle_transform.pos))
		>path_step*2) then 
		DriveVehicle(vehicle, acceleration,steer_force, false)
	else
		DriveVehicle(vehicle, 0,0, true)
	end

end


function clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function math.sign(x) 
	if(x<0) then 
		return -1
	else
		return 1
	end

end



function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

]]
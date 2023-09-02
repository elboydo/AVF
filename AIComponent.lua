--[[

#include "common.lua"
#include "pathfinding.lua"
#include "AVF_AI_ACS.lua"

]]

--[[
**********************************************************************
*
* FILEHEADER: Elboydo's Armed Vehicles Framework (AVF) 
*
* FILENAME :        AiComponent.lua             
*
* DESCRIPTION :
*       File that manages AI operations and teams 
*
*		Controls here manage AI aiming, weapon systems and other behaviors
*		
*



sides 

0= neutral
1= blufor
2= opfor
3= inde

]]


ai_locations = {
	ai_commander = {
		x = nil,
		y = nil,
		z = nil,
	}

}

_AI_DEBUG_PATHING = false


AIM_FORWARDS_POS = Vec(0,0,-20)


AVF_ai = {
	phases = 32,
	current_phase = 1,
	assignment_phase = 1,

	pathing_phase = 0,

	-- if they register then they get seen to, refresh register every n time stamps AIHOLDS TAGTO SAY IN LIST 
    -- IF DEAD THEN IGNORED,THEN REMOVED ON REFERESH
	pathing_queue = 

	 	{},

	 pathing_template = {
	 	id = 0, 
	 	finished = 0, 


	 },

	OPFOR = 1,
	BLUFOR = 2,
	INDEP = 3,


	sides = {
		[1] = "blueForAI",
		[2] = "opForAI",
		[3] = "indepAI",
	},


	vehicles = {

	},

	blueForAI = {


	},
	opForAI = {


	},
	indepAI = {


	},
	templateVehicle = {
		id = nil,
		alive = true,
		info = nil, 
		features = nil, 
		side = nil,
		range = 100,
		precision = 1,
		persistance = 0.3,
		optics_range = 200,
		behaviors = {
			state = "safe",
			last_spotted = 0,
			spotted_memory = 1.5,
			target = nil,
		},
		optics_pos = Transform(Vec(0,0.85,0),Quat()),
		custom_optics = false,
		optics_range = 200,
		proximity_threshold = 0.9,
		pathing = {
			active = false,
			has_path = false,
			current_path = {},
			lastPath = {},
			vehicle_bodies = {},
			goal_pos = {},
			target_node = {},
		},
		current_priority = 1,
		current_priority_score = 0,
		pathing_priorities= {
			[1] = {
					name = "patrol",
					actionable = false, 
					impulse = 1,
					score = 0.01,
					target = 0,
					target_type = "location",
					target_location = {0,0,0},
					origin = {},
					action_desc = "moves around locations with no clear goal",
			},
			[2] = {
					name = "capture",
					actionable = false,  
					impulse = 1,
					preference = 1,
					score = -1,
					target = nil,
					target_type = "point",
					target_location = {0,0,0},
					origin = {},
					action_desc = "move to capture a point",
			},
			[3] = {
					name = "attack",
					actionable = false,  
					impulse = 1,
					score = -1,
					target = 0,
					target_type = "",
					target_location = {0,0,0},
					origin = {},
					action_desc = "move to attack a vehicle",
			},
			[4] = {
					name = "defend",
					actionable = false,  
					impulse = 1,
					score = -1,
					target = 0,
					target_type = "",
					target_location = {0,0,0},
					origin = {},
					action_desc = "move to defend a point",
			},
			[5] = {
					name = "follow",
					actionable = false,  
					impulse = 1,
					score = -1,
					target = 0,
					target_type = "",
					target_location = {0,0,0},
					origin = {},
					action_desc = "follow a nearby ally",
			},
		},
		ACS = {}
	},
}



function AVF_ai:initAi()
	self.assignment_phase = (self.assignment_phase%self.phases) +1

	index = #self.vehicles+1
 	self.vehicles[index] = deepcopy(self.templateVehicle)
 	self.vehicles[index].id = vehicle.id
 	self.vehicles[index].info = vehicle
 	self.vehicles[index].entity_type = vehicle.entity_type
 	self.vehicles[index].features = vehicleFeatures
 	local side = tonumber(GetTagValue(vehicle.id,"avf_ai"))
 	
 	-- DebugPrint("side: "..tostring(side))
 	
 	SetTag(vehicle.id, "avf_side",tostring(side))
	 	
 	self.vehicles[index].side = side
 		
 	if(side~=nil) then 
 	 	local allied_side = self[self.sides[side]]
 		local allied_side_name = self.sides[side]
 		if(allied_side_name ~= nil) then 
 	 		-- DebugPrint("allied side: "..allied_side_name)
	 		allied_side[#allied_side+1] = index
	 		SetDescription(vehicle.id, allied_side_name)
 	 	end
	 end
	 self.vehicles[index].phase = self.assignment_phase

	 AVF_ai:init_custom_ai_behaviours(self.vehicles[index])

 end


--[[

	ai_locations = {
		[1] = "ai_commander",

	}

ai_locations = {
	ai_commander = {
		x = nil,
		y = nil,
		z = nil,
	}

}

]]

function AVF_ai:init_custom_ai_behaviours(ai)
	for key, val in pairs(ai_locations) do 
		if(type(val)== 'table') then 
			for subKey,subVal in pairs(val) do 
				if(HasTag(vehicle.id,"avf_ai".."_"..key.."_"..subKey)) then 
					if(key == "ai_commander") then 
						ai.optics_pos.pos[subKey] = GetTagValue(vehicle.id,"avf_ai".."_"..key.."_"..subKey)
						ai.custom_optics = true
					end
				end
			end
		else
			if(HasTag(vehicle.id,"avf_ai"..key)) then 

			end
		end
	end
	ai.pathing_priorities[2].preference = 0.9 - math.random() 
	AVF_ai:init_AI_ACS(ai)

end

function AVF_ai:init_AI_ACS(ai)
	ai.ACS = deepcopy(AVF_AI_ACS)
	ai.ACS:initVehicle(ai) 
end


 --- function that operates through ai behaviors


 	--[[

		GENERIC AI BEHAVIORS

			moves to goal pos

			sees if a target in range

			opts to stop to stop + engage target, move to goal, or relocate to better engage

				Each of the above are linked with "apply stealth" aka - perhaps not engage if unlikely to be seen

				This needs code to work out if both are detected. 

		simple first run: 
			move to target pos, engage on the way for each possible target. 

				move to closest target pos

				find closest visible taget and engage


 	]]
 function AVF_ai:aiTick(dt)
 	-- DebugWatch("time",dt)
 	self.current_phase = (self.current_phase%self.phases) +1
 	-- DebugWatch("avf ai vehicles",#self.vehicles)
 	for key,ai in ipairs(self.vehicles) do
 		-- self:targetSelection(ai)
 		
 		-- DebugWatch("AVF_ai "..ai.id,ai.phase)
 		if(ai.alive)  then 
 			if(HasTag(ai.id,"avf_vehicle_disabled")) then 
 				ai.alive = false
 			elseif(HasTag(ai.id,"avf_vehicle_cooking_off")) then 
 				ai.cooking_off = true
 			else
		 		vehicle = ai.info
		 		vehicleFeatures = ai.features
		 		self:ai_behaviors(ai)
	 		end
	 	end
 	end

	--[[
		Below will be logic forpathing and those behaviours 

	

		in testing we just assume capture. 
			
		Pathing takes place after all AI have evaluated their activities and lodged interest. 
		
	]]
	DebugWatch("pathing queue length",#self.pathing_queue)
	if(#self.pathing_queue>0) then 
		self:pathing_tick(dt)
	end
	

 end


--[[


		pathing = {
			current_path = {},
			lastPath = {},
			vehicle_bodies = {},
			goal_pos = {},
			target_node = {},
		},



]]

--[[

function AVF_ai:reject_current_entity_parts(ai)
	local body_parts = self:get_entity_body_parts(ai)
	for i=1,#body_parts do 
		QueryRejectBody(body_parts[i])
	end
end
		current_priority = 1,
		current_priority_score = 0,
		pathing_priorities= {

]]
 function AVF_ai:pathing_tick(dt)
 	local active_ai = self.pathing_queue[1]
 	if(active_ai.alive) then
 		local body_parts = self:get_entity_body_parts(active_ai)
 		local ai_priority = active_ai.pathing_priorities[active_ai.current_priority] 
 		local start_pos = GetVehicleTransform(active_ai.id).pos
 		local end_pos = ai_priority.target_location
	 	local path_found = handle_path_plotting(start_pos,end_pos,dt,active_ai,body_parts)
	 	-- DebugWatch("launching pathing for ai to ",end_pos)
	 	-- DebugWatch("launching pathing for ai from ",start_pos)
	 	if(path_found) then 
	 		active_ai.pathing.lastPath = deepcopy(active_ai.pathing.current_path)
	 		active_ai.pathing.current_path = deepcopy(path_found)
	 		active_ai.pathing.active = false
	 		active_ai.pathing.has_path = true
	 		self:pop_queue()
	 	end

	else
		self:pop_queue()
	end

 end

 function AVF_ai:push_queue(ai)
 		self.pathing_queue[#self.pathing_queue+1] = ai 


 end

 function AVF_ai:pop_queue()
 	if(#self.pathing_queue>1) then
 		local temp_queue = {} 
 		for i = 2,#self.pathing_queue do
 			temp_queue[#temp_queue+1] = self.pathing_queue[i]
 		end
 		self.pathing_queue = temp_queue
 	else
 		self.pathing_queue = {}
 	end


 end

 --[[

	Ai behaviours follow this pattern 

	if turn then detect targets. 

	If target found then attempt fire on target. 

	Search for points to capture. 

	Advance on uncaptured points. 

	Alternative AI behaviours may focus on 
		guarding points
		stopping to engage detected target. 
		Changing path to advance on detected target. 


 ]]

 function AVF_ai:ai_behaviors(ai)
 	-- DebugWatch("ai"..ai.id.." state: ",ai.id)
 	-- self:move_to_pos(ai)
 	if(not HasTag(ai.id,"avf_vehicle_cooking_off") or math.random()>0.8) then 
	 	if(ai.phase == self.current_phase) then 
		 	self:find_target(ai)
		 end
	 	-- if(ai.behaviors.target ~= nil) then 
	 	-- 	self:highlight_target(ai,ai.behaviors.target)
	 	-- end
		 
	 	if(ai.behaviors.target ) then 
			self:weaponAiming(ai)
		
		else
			self:aim_forwards(ai)
		end

		--[[

		decide if any activities exist that need pathing and act on them 

		]]

		self:manage_priorities(ai)


		
	end
	self:navigate_pathing(ai)

 end


--[[		current_priority = 1,
		pathing_priorities= {
			[1] = {
					name = "patrol",
					actionable = false, 
					score = 0.01,
					target = 0,
					target_type = "location",
					target_location = {0,0,0},
					origin = {},
					action_desc = "moves around locations with no clear goal",
			},
			[2] = {
					name = "capture",
					actionable = false, 
					score = -1,
					target = 0,
					target_type = "point",
					target_location = {0,0,0},
					origin = {},
					action_desc = "move to capture a point",
			},
			[3] = {
					name = "attack",
					actionable = false, 
					score = -1,
					target = 0,
					target_type = "",
					target_location = {0,0,0},
					origin = {},
					action_desc = "move to attack a vehicle",
			},
			[4] = {
					name = "defend",
					actionable = false, 
					score = -1,
					target = 0,
					target_type = "",
					target_location = {0,0,0},
					origin = {},
					action_desc = "move to defend a point",
			},
			[5] = {
					name = "follow",
					actionable = false, 
					score = -1,
					target = 0,
					target_type = "",
					target_location = {0,0,0},
					origin = {},
					action_desc = "follow a nearby ally",
			},
		},]]

function AVF_ai:manage_priorities(ai)
	--[[  
			first run looks for flag then later i'll add target approach or patrol. 
	

		score is >0 and lowest score wins. 


	]]
	ai.current_priority_score = 0

	self:get_capture_priority(ai,ai.pathing_priorities[2])
	self:get_attack_priority(ai,ai.pathing_priorities[3])
	self:get_defend_priority(ai,ai.pathing_priorities[4])
	self:get_follow_priority(ai,ai.pathing_priorities[5])
	for i =1, #ai.pathing_priorities do 
		if(ai.pathing_priorities[i].score>ai.current_priority_score ) then 
			ai.current_priority_score  = ai.pathing_priorities[i].score
			ai.current_priority = i 
		end

	end

	if(ai.current_priority>0 and not ai.pathing.active) then
		self:push_queue(ai)
		ai.pathing.active = true
	end 
	-- DebugWatch("ai "..ai.id.."priority name",ai.pathing_priorities[ai.current_priority].name)
	-- DebugWatch("ai priority score",ai.current_priority_score)


end

--[[
	below handles major ai priorities for higher level functions
			[2] = {
					name = "capture",
					actionable = false, 
					score = -1,
					target = 0,
					target_type = "point",
					target_location = {0,0,0},
					origin = {},
					action_desc = "move to capture a point",
			},

		ORIGINAL FOCUS: GET DISTANCE, FIND LOWEST DISTANCE
		NEW FOCUS: GET DISTANCE, CALCULATE AGAINST 400 (THEORETICAL INGAME MAX, NORMALIZE BETWEEN 0 AND 1,
		HIGHEST VALUE WINS)
]]


function AVF_ai:get_capture_priority(ai,priority)
	capture_points = FindTriggers("avf_conquest_point",true)
	local vehicle_pos = Transform(self:get_entity_main_centre(ai)) 
	local target_point = nil
	local last_target = priority.target
	-- ideal target value is closest to 1
	local target_score = 0--9999
	local point_pos = nil
	local distance_value = 9999
	local distance_max = 400
	local distance_score = 0
	--[[
			calculate capture points and their distance to ai.
	]]
	local capture_side = -1
	local capture_state = "false"
	for i=1, #capture_points do 

		capture_side  = tonumber(GetTagValue(capture_points[i],"capture_side"))
		capture_state  = GetTagValue(capture_points[i],"captured")  == "true"
			
		-- check if point not captured, and if it is then side is not the current side
		if(capture_side>=0 and  (not(capture_state and capture_side==ai.side)) or capture_side~=ai.side) then 
				
			-- DebugWatch("capture_point "..i.." info test_case_01",capture_side>=0 )

			-- DebugWatch("capture_point "..i.." info test_case_02",capture_side ~= ai.side)
				
			-- DebugWatch("capture_point "..i.." info test_case_03",(capture_state and capture_side==ai.side))
			

			capture_point_pos = GetTriggerTransform(capture_points[i]).pos
			distance_value = VecLength(TransformToLocalPoint(vehicle_pos , capture_point_pos))

			-- DebugWatch("capture_point "..i.." info test_case_0.1: ai post",vehicle_pos)
			-- DebugWatch("capture_point "..i.." info test_case_0.2: distance_value",distance_value)
			-- DebugWatch("capture_point "..i.." info test_case_0.3: capture_point_pos",capture_point_pos)
			distance_score = (1-((distance_value/distance_max)*priority.preference)) * priority.impulse
			-- DebugWatch("target_dist  "..i,distance_value)
			-- DebugWatch("target_side "..i,ai.side)
			-- DebugWatch("capture_point "..i.." info test_case_1.1: score",distance_score)
			if(capture_points[i] == last_target) then 
				distance_score =distance_score * 10
			end
			if(distance_score>target_score) then 
				target_point = capture_point_pos
				target_score = distance_score
				-- DebugPrint("target_score "..distance_value)
				priority.target_location = capture_point_pos
				priority.score = target_score
				priority.target = capture_points[i]
			end
		end

	end
	if(target_point == nil) then 
				priority.target_location = -1
				priority.score = -1
	end
end


function AVF_ai:get_attack_priority(ai)
	return -1

end


function AVF_ai:get_defend_priority(ai)
-- 	capture_points = FindTriggers("avf_conquest_point",true)
-- 	local vehicle_pos = self:get_entity_main_centre(ai) 
-- 	local target_point = nil
-- 	local target_score = 9999
-- 	local point_pos = nil
-- 	local distance_value = 9999
-- 	--[[
-- 			calculate capture points and their distance to ai.
-- 	]]
-- 	local capture_side = -1
-- 	local capture_state = "false"
-- 	for i=1, #capture_points do 

-- 		capture_side  = tonumber(GetTagValue(capture_points[i],"capture_side"))
-- 		capture_state  = GetTagValue(capture_points[i],"captured")  == "true"
-- 		DebugWatch("target_state"..i,capture_state)
			

-- 		if(capture_side>=0  capture_side == ai.side and capture_state) then 
-- 			capture_point_pos = GetTriggerTransform(capture_points[i]).pos
-- 			distance_value = VecLength(TransformToLocalPoint(vehicle_pos , capture_point_pos))
			
-- 			DebugWatch("target_score "..i,distance_value)
-- 			DebugWatch("target_score "..i,ai.side)
			
-- 			if(distance_value<target_score) then 
-- 				target_point = capture_point_pos
-- 				target_score = distance_value
-- 				DebugPrint("target_score "..distance_value)
-- 				priority.target_location = capture_point_pos
-- 				priority.score = target_score
-- 			end
-- 		end
-- 	end

-- end

		-- if(capture_side>=0 and capture_side ~= ai.side and capture_state) then 

	return -1

end


function AVF_ai:get_follow_priority(ai)
	return -1

end


--[[

	NAVIGATE PATHING

	handles pathing for any AVF vehicle that has been given a path and is now following it

	This is where microbehaviours can / will trigger


		pathing = {
			active = false,
			has_path = false,
			current_path = {},
			lastPath = {},
			vehicle_bodies = {},
			goal_pos = {},
			target_node = {},
		},
]]

function AVF_ai:navigate_pathing(ai)
	if(ai.pathing.has_path and ai.pathing.current_path ~=nil and  #ai.pathing.current_path>0) then

		-- DebugWatch("ai id: "..ai.id.." pathing",#ai.pathing.current_path) 
		ai.pathing.current_path = navigationPrunePath(deepcopy(ai.pathing.current_path),ai)

		-- DebugWatch("ai id: "..ai.id.." pathing_post prune",ai.pathing.current_path == nil or #ai.pathing.current_path) 
		if(ai.pathing.current_path ~=nil and  #ai.pathing.current_path>0) then 
			if(_AI_DEBUG_PATHING)then 
				drawPath(ai.pathing.current_path)
			end
			self:control_vehicle(ai)
		end

	end


end


function AVF_ai:control_vehicle(ai)
	local current_path = ai.pathing.current_path
	local pathfinding_look_ahead = 3 / AVF_PATHFINDING_STEP
	local vel = VecLength(GetBodyVelocity(GetVehicleBody(ai.id)))
	pathfinding_look_ahead = math.max(1,pathfinding_look_ahead * (vel/3))
	-- local path_step =2
	-- local avoidance_size = 3
	-- local max_steer = 3
	-- local PATH_NODE_TOLERANCE = 2.5
	-- local vel = GetBodyVelocity(GetVehicleBody(ai.id))
	-- local map_vel = math.floor(VecLength(vel)/path_step*.25)+1

	if(current_path~= nil and #current_path>0) then
		ai.ACS.targetNode = ai.pathing.current_path[math.min(math.floor(pathfinding_look_ahead),#ai.pathing.current_path)] 
		-- DebugWatch("ai "..ai.id.." target node: ",ai.ACS.targetNode)
		
		if(not ai.cooking_off) then 
			ai.ACS:controlActions(GetTimeStep(),ai)
		else 
			ai.ACS.controller.accelerationValue = ai.ACS.controller.accelerationValue *(math.random()*25)
			ai.ACS.controller.steeringValue = ai.ACS.controller.steeringValue *(math.random()*25)
		end
		ai.ACS:vehicleController()
	end
	-- DebugWatch("steer force for ai "..ai.id,steer_force)
	-- DebugWatch("aceleration force for ai "..ai.id,acceleration)

	-- if(VecLength(
	-- 		VecSub(
	-- 			path[#path],
	-- 			vehicle_transform.pos))
	-- 	>path_step*2) then 
	-- 	DriveVehicle(ai.id, acceleration,steer_force, false)
	-- else
	-- 	DriveVehicle(ai.id, 0,0, true)
	-- end


end



--[[

		considerations for ai behaviors
		ai = 
		{
			behaviors = {
				state = "safe",
				last_spotted = 0,
				spotted_memory = 3,
				target = nil,
			},
		}
]]

 function AVF_ai:find_target(ai)


 	local target = self:targetSelection(ai)


 	ai.behaviors.target = target
 end


function AVF_ai:targetSelection(ai)
	local ai_pos = AVF_ai:getPos(ai)
	local assumed_target_dist = ai.optics_range 
	if(ai.behaviors.target ~= nil and not ai.behaviors.target.alive) then 
		ai.behaviors.target  = nil
	elseif(ai.behaviors.target~=nil ) then 
		assumed_target_dist = AVF_ai:dist_to_target(ai_pos,self:getPos(ai.behaviors.target )) * 1.45
	end
	
	local closestTarget = nil
	local closestDistance = assumed_target_dist
	for side = 1,#self.sides do 
		if(ai.side~=side) then 
			for _,val in ipairs(self[self.sides[side]]) do 
				local other_ai = self.vehicles[val]
				if(other_ai.alive) then 
					local target_pos = self:getPos(other_ai)
					if(AVF_ai:dist_to_target(ai_pos,target_pos) <= closestDistance) then 

						local hit_target, dist = self:canSee(ai,ai_pos,other_ai,target_pos)
						if(ai.behaviors.target ~= nil and other_ai.id == ai.behaviors.target.id) then 
							dist = dist *ai.proximity_threshold 
						end
						if(hit_target and dist <closestDistance) then 
							closestTarget = other_ai
							closestDistance = dist
						end
					end
				end
			end
		end 
	end
	if(ai.behaviors.target ~= nil and closestTarget == nil) then 
		self:target_not_spotted(ai)
	end
	-- DebugWatch("side: ",ai.side)
	if(closestTarget~=nil) then

		-- DebugWatch("AVF_ai "..ai.id,closestTarget.id)
	else 
		-- DebugWatch("AVF_ai "..ai.id,"no target")
	end
	return closestTarget
end

function AVF_ai:target_not_spotted(ai)
	ai.behaviors.last_spotted = ai.behaviors.last_spotted + GetTimeStep()
	if(ai.behaviors.last_spotted > ai.behaviors.spotted_memory) then 
		ai.behaviors.target = nil
	end 
end


function AVF_ai:dist_to_target(ai_pos,target_pos)
	return VecLength(VecSub(ai_pos.pos,target_pos.pos))
end

function AVF_ai:canSee(ai,ai_pos,other_ai,target_pos)
	local commanderPos = ai_pos
	commanderPos.pos = self:get_entity_main_centre(ai) 
	commanderPos.pos = TransformToParentPoint(commanderPos,ai.optics_pos.pos)
	target_pos.pos = self:get_entity_main_centre(other_ai) 

	local fwdPos = VecSub(target_pos.pos,commanderPos.pos)
	local dir = VecNormalize(fwdPos)


	self:reject_current_entity_parts(ai)
	local scan_range = math.min(VecLength(fwdPos) *1.15,ai.optics_range)
	
	local hit, dist,normal, shape = QueryRaycast(commanderPos.pos, dir ,scan_range  ,0,true)


	local hit_body = GetShapeBody(shape)
	local hitVehicle = self:hit_ai_body_parts(other_ai,hit_body)


	return hitVehicle,dist
end

function AVF_ai:aim_forwards(ai)

				-- self:gunAiming(ai,targetPos,Vec(0,0,0),AIM_FORWARDS_POS fwdPos)
	local commanderPos = GetVehicleTransform(vehicle.id)
	local targetPos = TransformToParentTransform(commanderPos,Transform(AIM_FORWARDS_POS))
	local target_vel =  Vec(0,0,0)
	commanderPos.pos = self:get_entity_main_centre(ai) --TransformToParentPoint(commanderPos,Vec(0,3,0))

	commanderPos.pos = TransformToParentPoint(commanderPos,ai.optics_pos.pos)
	local fwdPos = VecSub(targetPos.pos,commanderPos.pos)
	local dir = VecNormalize(fwdPos)



	self:gunAiming(ai,targetPos,target_vel,fwdPos,false)
	return hitVehicle

end

function AVF_ai:weaponAiming(ai)

	local target =  ai.behaviors.target 

	local targetPos = self:getPos(target)
	targetPos.pos = self:get_entity_main_centre(target) 
	local target_vel =  GetBodyVelocity(self:get_entity_main_body(target))
	-- targetPos.pos = VecAdd(targetPos.pos,VecScale(GetPlayerVelocity(),GetTimeStep()*2))
	local commanderPos = GetVehicleTransform(vehicle.id)
	commanderPos.pos = self:get_entity_main_centre(ai) --TransformToParentPoint(commanderPos,Vec(0,3,0))

	commanderPos.pos = TransformToParentPoint(commanderPos,ai.optics_pos.pos)
	local fwdPos = VecSub(targetPos.pos,commanderPos.pos)
	local dir = VecNormalize(fwdPos)

	self:reject_current_entity_parts(ai)
	self:reject_current_entity_parts(target)
	
	local hit, dist,normal, shape = QueryRaycast(commanderPos.pos, dir , VecLength(fwdPos)*0.95,0,true)
		-- DebugLine(commanderPos.pos,VecAdd(commanderPos.pos,fwdPos))
	-- DebugWatch("hit",shape)
	DebugCross(targetPos.pos,1,0,0)
	DebugCross(commanderPos.pos,0,1,0)

	if(hit==nil) then 
		hit = false
	end
	local hitVehicle = not hit
	--for _,shape2 in ipairs(vehicle.shapes) do 

	-- DebugWatch("no blockers? ",hitVehicle)
	-- DebugWatch("target pos",targetPos)
	--end
		-- DebugWatch("hit vehicle",hitVehicle)
	if(hitVehicle or ai.behaviors.last_spotted>0) then
		if(not hitVehicle) then 
			ai.behaviors.last_spotted =  ai.behaviors.last_spotted - GetTimeStep()
		else
			ai.behaviors.last_spotted =  ai.behaviors.spotted_memory
		end
		-- for key,turretGroup in pairs(vehicleFeatures.turrets) do
		-- 	for key2,turret in ipairs(turretGroup) do
		-- 		self:turretRotatation(ai,turret,turret.turretJoint,targetPos)
				
		-- 	end
		-- end

		self:gunAiming(ai,targetPos,target_vel,fwdPos,true)
	end
	return hitVehicle
end

function AVF_ai:gunAiming(ai,targetPos,target_vel,fwdPos,in_combat)
	for key,gunGroup in pairs(vehicleFeatures.weapons) do
		
		-- utils.printStr(#gunGroup)
			for key2,gun in ipairs(gunGroup) do

				-- vehicleFeatures.weapons[group][index].turretJoint = turretJoint
				-- vehicleFeatures.weapons[group][index].base_turret = attatchedShape


				local previouslyAimed = gun.aimed
				if(DEBUG_AI) then 
					DebugWatch("pre aim",targetPos)
				end
				local target_dist_modifier,time_to_impact = get_target_range(gun,fwdPos)
				local predicted_target_pos =  TransformCopy(targetPos)
				predicted_target_pos.pos = VecAdd(predicted_target_pos.pos,VecScale(target_vel,time_to_impact*(math.random(75,200)/100))) 
				if(gun.base_turret) then 
					self:turretRotatation(ai,gun.base_turret,gun.turretJoint,predicted_target_pos)
				end
				targetPos.pos[2] = targetPos.pos[2]+ target_dist_modifier
				if(DEBUG_AI) then
					DebugWatch("post aim",targetPos)
				end
				self:gunLaying(ai,gun,targetPos)	
				if(in_combat and not gun.reloading and gun.persistance ~= nil and gun.persistance>0) then 
					-- DebugWatch("gun firing",gun.persistance)
					if(not gun.aimed and (previouslyAimed or (gun.persistance and gun.persistance>0))) then 
						gun.persistance = gun.persistance - GetTimeStep()
					end
					
				 	if(gun.persistance>0) then 
				 		self:gunFiring(gun)
				 	elseif(gun.firing) then
				 		self:gunFiring(gun)
				 		gun.firing = false
				 	end
				end


				-- test_player_damage(gun)
			end
	end			

end


function get_target_range(gun,fwdPos)
		local shellType = gun.magazines[gun.loadedMagazine].CfgAmmo
		if(DEBUG_AI) then
			DebugWatch("vel",shellType.velocity)
		end
		local time_to_impact = VecLength(fwdPos)/shellType.velocity
		if(DEBUG_AI) then
			DebugWatch("dist",VecLength(fwdPos))
			DebugWatch("tti",time_to_impact)
		end
		local target_dist_modifier = 
					math.max(
						0,
						time_to_impact
							*math.abs(globalConfig.gravity[2]*.25))
		if(shellType.gravityCoef~= nil) then 
			target_dist_modifier = target_dist_modifier * shellType.gravityCoef
		end
		if(DEBUG_AI) then
			DebugWatch("target dist modifier",target_dist_modifier)
		end
		local uncertainty = (math.random(-250,350)/100) * (VecLength(fwdPos)/100)
		target_dist_modifier = target_dist_modifier + uncertainty

		if(DEBUG_AI) then
			DebugWatch("final target dist ",target_dist_modifier) 
		end
		return target_dist_modifier,time_to_impact

end

---- must handle multiple guns
---- if gun angle up > 0 then gun goes down and vice versa, with bias to control
function AVF_ai:gunLaying(ai,gun,targetPos)
	local up = self:gunAngle(0,0,-1,gun,targetPos)
	local down = self:gunAngle(0,0,1	,gun,targetPos)
	local left = self:gunAngle(1,0,0,gun,targetPos)
	local right = self:gunAngle(-1,0,0	,gun,targetPos)
	local forward = self:gunAngle(0,-1,0	,gun,targetPos)
	local bias = 0.1
	gun.aimed = false

	-- DebugWatch("gun up: ",
	-- 		up)
	-- DebugWatch("gun down: ",
	-- 		down)
	-- DebugWatch("gun left: ",
	-- 		left)
	-- DebugWatch("gun right: ",
	-- 		right)
	-- DebugWatch("gun forward: ",
	-- 		forward)
	local dir = 0
	if(up < down-bias*0.1)then  -- and up-bias*.5>0) then 
		dir = -1
	elseif(up > down+bias*0.2 )then  --and down-bias*.5>0) then
		dir = 1
	end
	if(left >right-bias and left<right+bias and forward-bias <0) then 

		gun.persistance = ai.persistance
		gun.aimed = true
		gun.firing = true
		

	end 

	-- bias = bias * math.random(-1,1)/5
	SetJointMotor(gun.gunJoint, dir*bias)
	
end

function AVF_ai:gunFiring(gun)
	dt = GetTimeStep()
	
	local firing = false
	if(gun.persistance<=0)then
		
		if( not gun.reloading and gun.tailOffSound and gun.rapidFire)then
			local cannonLoc = GetShapeWorldTransform(gun.id)
			PlaySound(gun.tailOffSound, cannonLoc.pos, 5)
			gun.rapidFire = false
		end
	else 
		firing = true
	end

	
	if( not gun.reloading and not (IsJointBroken(gun.gunJoint)or (gun.turretJoint and IsJointBroken(gun.turretJoint))  ))then	---not IsShapeBroken(gun.id) and
		if(not gun.magazines[gun.loadedMagazine].outOfAmmo and gun.magazines[gun.loadedMagazine].magazinesAmmo[gun.magazines[gun.loadedMagazine].currentMagazine]) then
			local currentMagazine = gun.magazines[gun.loadedMagazine].magazinesAmmo[gun.magazines[gun.loadedMagazine].currentMagazine]
			if(currentMagazine.AmmoCount > 0) then  
			    if( gun.loopSoundFile)then
			    	if not gun.rapidFire then
			    		
			    		gun.rapidFire = true

			    	end
					local cannonLoc = GetShapeWorldTransform(gun.id)

					PlayLoop(gun.loopSoundFile, cannonLoc.pos, 5)
					
				end
				
				if (gun.timeToFire <=0) then
				 	if (firing) then
				 		
				 		if (gun.cycleTime < dt) then
				 			local firePerFrame =1
				 		
				 			firePerFrame = (math.floor((dt/gun.cycleTime)+0.5))
					 		for i =1, firePerFrame do 
								fireControl(dt,gun)

					 			eject_shell_casing(gun,gun.cycleTime,gun.timeToFire)
								
								currentMagazine.AmmoCount =currentMagazine.AmmoCount -1
								if(currentMagazine.AmmoCount <= 0) then
									break
								end
							end
							
						else
								
							fireControl(dt,gun)

							if(currentMagazine.magazineCapacity >1) then
					 			eject_shell_casing(gun,gun.cycleTime,gun.timeToFire)
					 		end
							currentMagazine.AmmoCount =currentMagazine.AmmoCount -1

						end
						if(currentMagazine.AmmoCount <= 0) then
							reloadGun(gun)
							
							
						end
						
					end
				elseif (gun.timeToFire) then
					gun.timeToFire = gun.timeToFire - dt
					
		 			eject_shell_casing(gun,gun.cycleTime,gun.timeToFire)
				end

			end

		end
	end

end



function AVF_ai:turretRotatation(ai,turret,turretJoint,targetPos)

	if(turret)then 

		local turret = turret.id
		local forward = self:turretAngle(0,1,0,turret,targetPos)
		local back 	  = self:turretAngle(0,-1,0,turret,targetPos) 
		local left 	  = self:turretAngle(-1,0,0,turret,targetPos)
		local right   = self:turretAngle(1,0,0,turret,targetPos)
		local up 	  = self:turretAngle(0,0,1,turret,targetPos)
		local down 	  = self:turretAngle(0,0,-1,turret,targetPos)

		-- DebugWatch("angles",
		-- 	"forward: "..
		-- 	forward..
		-- 	"\nback: "..
		-- 	back..
		-- 	"\nleft: "..
		-- 	left..
		-- 	"\nright: "..
		-- 	right..
		-- 	"\nup: "..
		-- 	up..
		-- 	"\ndown: "..
		-- 	down)		
		local bias = 0.05 * ai.precision
		bias = bias * math.random(-1,1)
		if(forward<(1-bias)) then
			if(left>right+bias) then
				SetJointMotor(turretJoint, 0.1+1*left)
			elseif(right>left+bias) then
				SetJointMotor(turretJoint, -.1+(-1*right))
			else
				SetJointMotor(turretJoint, 0)
			end
		else
			SetJointMotor(turretJoint, 0)
		end 

	end
end

function AVF_ai:turretAngle(x,y,z,turret,targetPos)


	 	-- DebugWatch("avf ai turret test ",1)
	local turretTransform = GetShapeWorldTransform(turret)
	turretTransform=GetShapeWorldTransform(vehicleFeatures.commanderPos) 
	local fwdPos = targetPos.pos
	local toPlayer = VecNormalize(VecSub(turretTransform.pos,fwdPos))
	local forward = TransformToParentVec(turretTransform, Vec(x,  y, z))
	local orientationFactor = clamp(VecDot(forward, toPlayer) * 0.7 + 0.3, 0.0, 1.0)
	
	return orientationFactor
end


function AVF_ai:gunAngle(x,y,z,gun,targetPos)

	 	-- DebugWatch("avf ai turret test ",1)
	local gunTransform = GetShapeWorldTransform(gun.id)
	 
	local fwdPos = targetPos.pos
	
	---fwdPos = {fwdPos[1],fwdPos[3],fwdPos[2]}
	local toPlayer = VecNormalize(VecSub(gunTransform.pos,fwdPos))
	local forward = TransformToParentVec(gunTransform, Vec(x,  y, z))
	local orientationFactor = clamp(VecDot(forward, toPlayer) * 0.7 + 0.3, 0.0, 1.0)
	-- DebugLine(gunTransform.pos,fwdPos,1,0,0,1)
	return orientationFactor
end




function AVF_ai:getPos(ai)
	local pos = nil
	if(ai.entity_type == "shape") then 
		pos = GetShapeWorldTransform(ai.id)
	elseif(ai.entity_type == "body") then 
		pos = GetBodyTransform(ai.id)
	elseif(ai.entity_type == "vehicle") then
		pos = GetVehicleTransform(ai.id) 
	end
	return pos
end




function AVF_ai:hit_ai_body_parts(ai,hit_body)
	local body_parts = self:get_entity_body_parts(ai)
	for i=1,#body_parts do 
		if(hit_body==body_parts[i]) then 
			return true
		end
	end
	return false
end


function AVF_ai:reject_current_entity_parts(ai)
	local body_parts = self:get_entity_body_parts(ai)
	for i=1,#body_parts do 
		QueryRejectBody(body_parts[i])
	end
end


function AVF_ai:get_entity_body_parts(ai)
	local body = nil 
	if(ai.entity_type == "shape") then 
		body  = GetShapeBody(ai.id)
	elseif(ai.entity_type == "vehicle") then
		body = GetVehicleBody(ai.id) 
	end
	if(body~=nil) then 
		return GetJointedBodies(body)
	else
		DebugPrint("couldn't get entity of type "..ai.entity_type)
		return nil
	end

end


function AVF_ai:get_entity_main_body(entity)
	
	local mass = 0
	local largest_body =nil
	local all = self:get_entity_body_parts(entity)
	for i=1,#all do
		local test_mass = GetBodyMass(all[i])
		if(test_mass>mass) then
			mass = test_mass
			largest_body = all[i]
		end
	end
	return largest_body,mass
end

function AVF_ai:get_entity_main_centre(entity)
	local main_body = self:get_entity_main_body(entity)
	local pos = self:get_body_center(main_body)
	return pos
end

function AVF_ai:get_body_center (body)
	
	local min, max = GetBodyBounds(body)
	local boundsSize = VecSub(max, min)
	local center = VecLerp(min, max, 0.5)
	return center
end

function AVF_ai:highlight_target(spotting_ai,entity)
	local body_parts = self:get_entity_body_parts(entity)
	for i=1,#body_parts do 
		if(spotting_ai.side ==1) then 
			DrawBodyOutline(body_parts[i], 0, 0, 1, 1)

		elseif(spotting_ai.side ==2) then 
			DrawBodyOutline(body_parts[i], 1, 0, 0, 1)
		elseif(spotting_ai.side ==3) then 
			DrawBodyOutline(body_parts[i], 0, 1, 0, 1)
		end
	end

end
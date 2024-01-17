

--[[



		Allows setting of AVF vehicles to teams

		Teams are : bluefor | opfor | indfor 





]]



AVF_TAK_COMMANDER = {
	current_side = 1,
	sides = {
		[1] = "BLUFOR",
		[2] = "OPFOR",
		[3] = "INDFOR",
	},


	current_target = nil,
	last_target = nil,
	target_lock_time = 0,
	target_lock_max = 2,
	accepted_colour = Vec(0,1,0),
	unmatched_colour = Vec(1,0,0),

	view_target = Transform(),

	camera_view = Vec(50,50,50),

	COMMANDER_CAM_ACTIVE = false,

	SMOOTHING_FACTOR =5,
	MOVE_SPEED  = 15,
	ROTATE_SPEED = 7 ,
}


function AVF_TAK_INIT()
	RegisterTool("avf_tak", "AVF-TAK", "MOD/vox/ATAK.vox",5)
	SetBool("game.tool.avf_tak.enabled", true)
end

function AVF_TAK_TICK()
	vehicle_command_controller()
end

function vehicle_command_controller()
	if GetString("game.player.tool") == "avf_tak" then
		--Tool is selected. Tool logic goes here.
		local current_target_side = AVF_TAK_COMMANDER['sides'][AVF_TAK_COMMANDER['current_side']]
		if  not InputDown("lmb") and InputPressed("rmb") then
			AVF_TAK_COMMANDER['current_side'] = (AVF_TAK_COMMANDER['current_side']%#AVF_TAK_COMMANDER['sides'])+1
		end
		if(AVF_TAK_COMMANDER.current_target) then 
			DrawBodyOutline(AVF_TAK_COMMANDER.current_target, 0, 1, 0, 1)
		end
		local t = GetPlayerCameraTransform()
		DebugWatch("cam pos as string", table.concat(t.pos, ","))
		local hit, dist, normal, shape  = QueryRaycast(t.pos, TransformToParentVec(t,Vec(0, 0, -1)), 100)
		if hit then
			if GetBool("game.player.canusetool") and InputPressed("lmb") then 
				
				if(AVF_TAK_COMMANDER.current_target) then 
					local target_pos = VecAdd(t.pos, TransformToParentVec(t,Vec(0, 0, -1)), dist)

					AVF_TAK_COMMANDER.current_target = nil
				else

					local tracked_body = GetShapeBody(shape)
					tracked_body,mass = get_largest_body(tracked_body)
					local vehicle = GetBodyVehicle(tracked_body)
					if(vehicle and HasTag(vehicle,"avf_ai")) then 
						AVF_TAK_COMMANDER.current_target = tracked_body
					end
				end
			end
		end
		local b = GetToolBody()
		if b ~= 0 then
			local shapes = GetBodyShapes(b)
			local used_tool_pos = GetShapeLocalTransform(shapes[4])
			local unused_tool_pos = TransformCopy(used_tool_pos)
			unused_tool_pos.pos = Vec(-400,-400,-400)
			SetShapeLocalTransform(shapes[1], unused_tool_pos)
			SetShapeLocalTransform(shapes[2], unused_tool_pos)
			SetShapeLocalTransform(shapes[3], unused_tool_pos)
			if(current_target_side == "BLUFOR") then 
				SetShapeLocalTransform(shapes[1], used_tool_pos)
			elseif(current_target_side == "OPFOR") then 
				SetShapeLocalTransform(shapes[2], used_tool_pos)
			else
				SetShapeLocalTransform(shapes[3], used_tool_pos)
			end
			SetShapeLocalTransform(shapes[4], used_tool_pos)
		end

	end

end

function AVF_TAKteam_allocator_weapon()
	if GetString("game.player.tool") == "avf_tak" then
		--Tool is selected. Tool logic goes here.
		local current_target_side = AVF_TAK_COMMANDER['sides'][AVF_TAK_COMMANDER['current_side']]
		if  not InputDown("lmb") and InputPressed("rmb") then
			AVF_TAK_COMMANDER['current_side'] = (AVF_TAK_COMMANDER['current_side']%#AVF_TAK_COMMANDER['sides'])+1
		end
		if GetBool("game.player.canusetool") and InputDown("lmb") then 
			


			local t = GetPlayerCameraTransform()
			local hit, dist, normal, shape  = QueryRaycast(t.pos, TransformToParentVec(t,Vec(0, 0, -1)), 100)
			if hit then
				local tracked_body = GetShapeBody(shape)
				tracked_body,mass = get_largest_body(tracked_body)
				if(IsBodyDynamic(tracked_body) and not HasTag(tracked_body,"avf_ai_commander_set")) then 
					if(tracked_body ==AVF_TAK_COMMANDER.current_target) then 
						AVF_TAK_COMMANDER.target_lock_time =  AVF_TAK_COMMANDER.target_lock_time + GetTimeStep()
						local track_percentage =  clamp(AVF_TAK_COMMANDER.target_lock_time  / AVF_TAK_COMMANDER.target_lock_max,0,1)
						if AVF_TAK_COMMANDER.target_lock_time  < AVF_TAK_COMMANDER.target_lock_max  then
							--Draw white outline at 50% transparency

							local track_colour = VecLerp(AVF_TAK_COMMANDER.unmatched_colour,AVF_TAK_COMMANDER.accepted_colour,track_percentage)
							DrawBodyOutline(
								tracked_body,track_colour[1],track_colour[2],track_colour[3] ,0.5)
						else
							--Draw green outline, fully opaque
							DrawBodyOutline(tracked_body, 0, 1, 0, 1)
							local vehicle = GetBodyVehicle(tracked_body)
							if(vehicle and not HasTag(vehicle,"avf_ai")) then 
								if (HasTag(vehicle,"avf_initialized")) then 
									SetTag(vehicle,"new_avf_ai")
								end
								SetTag(vehicle,"avf_ai",AVF_TAK_COMMANDER['current_side'])

							elseif(not HasTag(tracked_body,"avf_ai")) then 
								SetTag(tracked_body,"avf_ai",AVF_TAK_COMMANDER['current_side'])
								
							end
							SetTag(tracked_body,"avf_ai_commander_set")
						end
					else
						AVF_TAK_COMMANDER.current_target = tracked_body
					end
				else
					AVF_TAK_COMMANDER.target_lock_time=0
				end
			else

				AVF_TAK_COMMANDER.target_lock_time=0
			end		
		elseif(AVF_TAK_COMMANDER.target_lock_time>0) then 
			AVF_TAK_COMMANDER.target_lock_time=0
		end

		local b = GetToolBody()
		if b ~= 0 then
			local shapes = GetBodyShapes(b)
			local used_tool_pos = GetShapeLocalTransform(shapes[4])
			local unused_tool_pos = TransformCopy(used_tool_pos)
			unused_tool_pos.pos = Vec(-400,-400,-400)
			SetShapeLocalTransform(shapes[1], unused_tool_pos)
			SetShapeLocalTransform(shapes[2], unused_tool_pos)
			SetShapeLocalTransform(shapes[3], unused_tool_pos)
			if(current_target_side == "BLUFOR") then 
				SetShapeLocalTransform(shapes[1], used_tool_pos)
			elseif(current_target_side == "OPFOR") then 
				SetShapeLocalTransform(shapes[2], used_tool_pos)
			else
				SetShapeLocalTransform(shapes[3], used_tool_pos)
			end
			SetShapeLocalTransform(shapes[4], used_tool_pos)
		end

	end

end

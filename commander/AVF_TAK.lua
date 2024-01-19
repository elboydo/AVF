

--[[



		Allows setting of AVF vehicles to teams

		Teams are : bluefor | opfor | indfor 





]]

AVF_TAK_SERVER = {
	assets = {
		BLUFOR = {},
		OPFOR = {},
		INDFOR ={}


	}



}


AVF_TAK_CONTROLLER = {
	current_side = 1,
	sides = {
		[1] = "BLUFOR",
		[2] = "OPFOR",
		[3] = "INDFOR",
	},


	selected_vehicles = {

	},
	SELECTING_REGION =false,
	SELECTED_REGION_START_BOUNDS = {0,0},

	current_target = nil,
	last_target = nil,
	target_lock_time = 0,
	target_lock_max = 2,
	accepted_colour = Vec(0,1,0),
	unmatched_colour = Vec(1,0,0),

	cam_source = Transform(),

	camera_view = Vec(50,50,50),

	COMMANDER_CAM_ACTIVE = false,

	SMOOTHING_FACTOR =2,
	MOVE_SPEED  = 1,
	ZOOM_SPEED  = 200,
	ROTATE_SPEED = 45 ,

	MIN_ZOOM = 5 ,
	MAX_ZOOM = 150 ,
	AVG_ZOOM = 60 ,

	BORDER = .05,

	cam_target_x = 0,

	cam_target_y = 0,

	cam_rotate = 0,
	cam_zoom_target = 80 ,
}


function AVF_TAK_INIT()
	RegisterTool("avf_tak", "AVF-TAK", "MOD/vox/ATAK.vox",5)
	SetBool("game.tool.avf_tak.enabled", true)
	local player_trans = Transform(GetPlayerPos(),QuatEuler(0,45,0))
	AVF_TAK_CONTROLLER.cam_source = player_trans
	AVF_TAK_CONTROLLER.camera_view = TransformCopy(player_trans)
	AVF_TAK_CONTROLLER.camera_view.rot = QuatRotateQuat(AVF_TAK_CONTROLLER.camera_view.rot,QuatEuler(-45,0,0))
	local cam_start_pos= Vec(0, 0, AVF_TAK_CONTROLLER.cam_zoom_target)
	AVF_TAK_CONTROLLER.camera_view.pos = TransformToParentPoint(AVF_TAK_CONTROLLER.camera_view, cam_start_pos)

end

function AVF_TAK_TICK(dt)
	AVF_TAK_CORE_CONTROL(dt)
	-- DebugWatch("selected assets",#AVF_TAK_CONTROLLER['selected_vehicles'] )
end

function AVF_TAK_CORE_CONTROL(dt)
	if GetString("game.player.tool") == "avf_tak" then
		--Tool is selected. Tool logic goes here.
		local current_target_side = AVF_TAK_CONTROLLER['sides'][AVF_TAK_CONTROLLER['current_side']]
		if not AVF_TAK_CONTROLLER.COMMANDER_CAM_ACTIVE and  not InputDown("lmb") and InputPressed("rmb") then
			
				local player_trans = Transform(GetPlayerPos())
				local start_transform= TransformToLocalTransform(AVF_TAK_CONTROLLER.cam_source,AVF_TAK_CONTROLLER.camera_view)
	
				AVF_TAK_CONTROLLER.cam_source = player_trans
				AVF_TAK_CONTROLLER.camera_view = TransformToParentTransform(AVF_TAK_CONTROLLER.cam_source,start_transform)
			AVF_TAK_CONTROLLER.COMMANDER_CAM_ACTIVE = not AVF_TAK_CONTROLLER.COMMANDER_CAM_ACTIVE
			-- AVF_TAK_CONTROLLER['current_side'] = (AVF_TAK_CONTROLLER['current_side']%#AVF_TAK_CONTROLLER['sides'])+1
		elseif(AVF_TAK_CONTROLLER.COMMANDER_CAM_ACTIVE and InputDown('c')) then 
			AVF_TAK_CONTROLLER.COMMANDER_CAM_ACTIVE = not AVF_TAK_CONTROLLER.COMMANDER_CAM_ACTIVE
		end
		if(AVF_TAK_CONTROLLER.COMMANDER_CAM_ACTIVE) then 
			AVF_TAK_CAM_MOVEMENT(dt)

			AVF_TAK_FIND_ASSETS(dt)
		else
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

end
--[[
AVF_TAK_SERVER = {
	assets = {
		BLUFOR = {},
		OPFOR = {},
		INDEFOR ={}
	}
}

]]
function AVF_TAK_FIND_ASSETS()
	local asset_list = FindVehicles("avf_ai",true)
	local asset_side = 0
	-- DebugWatch("assets found",#asset_list)
	for i=1, #asset_list do
		asset = asset_list[i]
		if(not HasTag(asset,"AVF_TAK_TRACKED")) then 
			asset_side = tonumber(GetTagValue(asset,"avf_ai"))

			-- DebugWatch("assets side",asset_side)
			if(asset_side ==1) then 
				AVF_TAK_SERVER['assets']['BLUFOR'][#AVF_TAK_SERVER['assets']['BLUFOR']+1] = asset
			elseif asset_side ==2 then 
				AVF_TAK_SERVER['assets']['OPFOR'][#AVF_TAK_SERVER['assets']['OPFOR']+1] = asset
			elseif asset_side ==3 then 
				AVF_TAK_SERVER['assets']['INDFOR'][#AVF_TAK_SERVER['assets']['INDFOR']+1] = asset
			end
			SetTag(asset,"AVF_TAK_TRACKED")
		end
	end

end


function AVF_TAK_CAM_MOVEMENT(dt)
	

	-- if InputPressed("q") or InputDown("q") then 
	-- 	AVF_TAK_CONTROLLER.cam_rotate = AVF_TAK_CONTROLLER.ROTATE_SPEED
	-- elseif InputPressed("e") or InputDown("e") then  
	-- 	AVF_TAK_CONTROLLER.cam_rotate = -AVF_TAK_CONTROLLER.ROTATE_SPEED
	-- else
	-- 	AVF_TAK_CONTROLLER.cam_rotate = 0
	-- end
	AVF_TAK_CONTROLLER.cam_rotate =  AVF_TAK_get_arrow_key_movement('e','q')*AVF_TAK_CONTROLLER.ROTATE_SPEED

	-- handle cam cam_zoom
	local tarAVF_TAK_get_zoom_rate = -AVF_TAK_get_zoom_rate()
	-- DebugWatch("AVF_TAK_get_zoom_rate",tarAVF_TAK_get_zoom_rate)
	tarAVF_TAK_get_zoom_rate = tarAVF_TAK_get_zoom_rate*AVF_TAK_CONTROLLER.ZOOM_SPEED	
	tarAVF_TAK_get_zoom_rate = clamp(AVF_TAK_CONTROLLER.cam_zoom_target + tarAVF_TAK_get_zoom_rate, AVF_TAK_CONTROLLER.MIN_ZOOM, AVF_TAK_CONTROLLER.MAX_ZOOM)
	tarAVF_TAK_get_zoom_rate = tarAVF_TAK_get_zoom_rate - VecLength(VecSub(AVF_TAK_CONTROLLER.camera_view.pos,AVF_TAK_CONTROLLER.cam_source.pos)) 
	local target_cam_zoom = Vec(0,0,tarAVF_TAK_get_zoom_rate)
	-- DebugWatch("target_cam_zoom",target_cam_zoom)		 
	local target_pos =TransformToParentPoint(AVF_TAK_CONTROLLER.camera_view,target_cam_zoom) 
	target_cam_zoom = VecLerp(AVF_TAK_CONTROLLER.camera_view.pos,target_pos,AVF_TAK_CONTROLLER.SMOOTHING_FACTOR*dt*2) 
	
	AVF_TAK_CONTROLLER.camera_view.pos = target_cam_zoom 	
	AVF_TAK_CONTROLLER.cam_zoom_target = VecLength(VecSub(AVF_TAK_CONTROLLER.camera_view.pos,AVF_TAK_CONTROLLER.cam_source.pos))		

	-- DebugWatch("CAM POS",AVF_TAK_CONTROLLER.camera_view)
	-- DebugWatch("cam_zoom",VecLength(VecSub(AVF_TAK_CONTROLLER.camera_view.pos,AVF_TAK_CONTROLLER.cam_source.pos)))
	-- DebugWatch("cam_zoom_target",AVF_TAK_CONTROLLER.cam_zoom_target)
	
	-- start affine transform
	local start_transform= TransformToLocalTransform(AVF_TAK_CONTROLLER.cam_source,AVF_TAK_CONTROLLER.camera_view)
	
-- handle rotation of cam
	local rotate_rate = QuatSlerp(
		AVF_TAK_CONTROLLER.cam_source.rot,
		QuatRotateQuat(
			AVF_TAK_CONTROLLER.cam_source.rot,
			QuatEuler(
				0,
				AVF_TAK_CONTROLLER.cam_rotate,
				0
				)
			),
			AVF_TAK_CONTROLLER.SMOOTHING_FACTOR*dt
		)
	AVF_TAK_CONTROLLER.cam_source.rot = rotate_rate 

	local zoom_coef = clamp(AVF_TAK_CONTROLLER.cam_zoom_target/AVF_TAK_CONTROLLER.AVG_ZOOM,0.2,1)
-- handle cam rotation

	local key_x_move =AVF_TAK_get_arrow_key_movement('d','a')
	if(key_x_move~=0) then 
		AVF_TAK_CONTROLLER.cam_target_x = key_x_move
	end
	local key_y_move =AVF_TAK_get_arrow_key_movement('s','w')
	if(key_y_move~=0) then 
		AVF_TAK_CONTROLLER.cam_target_y = key_y_move
	end

	local target_cam_movement = Vec(AVF_TAK_CONTROLLER.cam_target_x,0,AVF_TAK_CONTROLLER.cam_target_y)
	target_cam_movement = VecScale(target_cam_movement,AVF_TAK_CONTROLLER.MOVE_SPEED*zoom_coef )
	local target_pos = VecLerp(AVF_TAK_CONTROLLER.cam_source.pos,target_pos,AVF_TAK_CONTROLLER.SMOOTHING_FACTOR*dt) 
	target_pos =TransformToParentPoint(AVF_TAK_CONTROLLER.cam_source,target_cam_movement) 
	AVF_TAK_CONTROLLER.cam_source.pos = target_pos

	AVF_TAK_CONTROLLER.camera_view = TransformToParentTransform(AVF_TAK_CONTROLLER.cam_source,start_transform)
	-- local start_offset= VecSub(AVF_TAK_CONTROLLER.cam_source.pos,AVF_TAK_CONTROLLER.camera_view.pos)
	-- local target_cam_movement = Vec(AVF_TAK_CONTROLLER.cam_target_x,0,AVF_TAK_CONTROLLER.cam_target_y)
	-- target_cam_movement = VecScale(target_cam_movement,AVF_TAK_CONTROLLER.MOVE_SPEED)
	-- local target_pos = VecLerp(AVF_TAK_CONTROLLER.cam_source.pos,target_pos,AVF_TAK_CONTROLLER.SMOOTHING_FACTOR*dt) 
	-- target_pos =TransformToParentPoint(AVF_TAK_CONTROLLER.cam_source,target_cam_movement) 
	-- AVF_TAK_CONTROLLER.cam_source.pos = target_pos
	-- local end_offset= VecSub(AVF_TAK_CONTROLLER.cam_source.pos,AVF_TAK_CONTROLLER.camera_view.pos)
	-- AVF_TAK_CONTROLLER.camera_view.pos = VecAdd(AVF_TAK_CONTROLLER.camera_view.pos,VecSub(start_offset,end_offset ))						
	SetCameraDof(12.5)
	SetCameraTransform(AVF_TAK_CONTROLLER.camera_view)


end


function AVF_TAK_ASSET_SELECT(assets)
	AVF_TAK_CONTROLLER['selected_vehicles'] = {}
	for i,asset in ipairs(assets) do
		AVF_TAK_CONTROLLER['selected_vehicles'][#AVF_TAK_CONTROLLER['selected_vehicles']+1] = asset
	end
end

function AVF_TAK_SELECT_REGION()
	UiPush()
		if(AVF_TAK_CONTROLLER.SELECTING_REGION) then 
			local start_pos = SELECTED_REGION_START_BOUNDS
			local x1,y1 = start_pos[1],start_pos[2]
			local x2, y2 = UiGetMousePos()
			if(InputDown('lmb')) then 
				-- UiAlign("left top")
				UiTranslate(x1,y1)
				local select_area_width = x2-x1
				local select_area_height = y2-y1
				UiColor(0,1,0)
				UiImageBox("MOD/gfx/select_region.png", select_area_width*1, select_area_height*1,0,1,0,1)
				UiTranslate()
			else
				local assets_in_range = (AVF_TAK_select_vehicles_in_region(x1,y1,x2,y2))
				-- DebugWatch("assets_in_range",#assets_in_range)
				AVF_TAK_ASSET_SELECT(assets_in_range)
				AVF_TAK_CONTROLLER.SELECTING_REGION = false 
			end
		elseif(not InputPressed('lmb') and  InputDown('lmb')) then 
			local x1, y1 = UiGetMousePos()
			SELECTED_REGION_START_BOUNDS ={x1,y1}
			AVF_TAK_CONTROLLER.SELECTING_REGION = true 
		end
	UiPop()
end

function AVF_TAK_select_vehicles_in_region(x1,y1,x2,y2)
	local assets_in_range = {}
	for faction_name,faction in pairs(AVF_TAK_SERVER.assets) do
		if(faction_name=="BLUFOR") then  
			for i,asset in ipairs(faction) do
				-- DebugWatch("assert num ",asset)
				if( not (
					HasTag(asset,"avf_vehicle_disabled") or 
					GetVehicleHealth(asset)<0.5 or 
					HasTag(asset,"avf_vehicle_cooking_off")
					)
				) then
					-- DebugWatch("asset is exist",true)
					local vehicleTransform = GetVehicleTransform(asset) 
					local x, y, dist = UiWorldToPixel(vehicleTransform.pos)
					-- DebugWatch("vehicle in range", AVF_TAK_check_vehicle_in_region(x,y,x1,x2,y1,y2))
					if dist > 0 and AVF_TAK_check_vehicle_in_region(x,y,x1,x2,y1,y2) then
						assets_in_range[#assets_in_range+1] = asset
					end
				end
			end
		end
	end
	return assets_in_range

	
end
--[[ check if vehicle x y is median ]]
function AVF_TAK_check_vehicle_in_region(x,y,x1,x2,y1,y2)

	-- DebugWatch("input values ",table.concat({x,y,x1,x2,y1,y2},','))
	x_in_range = (math.max(math.min(x1,x2), math.min(math.max(x1,x2),x))) == x
	y_in_range = (math.max(math.min(y1,y2), math.min(math.max(y1,y2),y))) == y
	return x_in_range and y_in_range
	
	-- local tru_x1 = min(x1,x2)
	-- local tru_x2 = max(x1,x2)
	-- local tru_y1 = min(y1,y2)
	-- local tru_y2 = max(y1,y2)
	-- if((x>tru_x1 and x<tru_x2) and y>tru_y1 and y<tru_y2):
		
end

function AVF_TAK_DRAW(dt)
	if(AVF_TAK_CONTROLLER.COMMANDER_CAM_ACTIVE) then 
		UiMakeInteractive()
		local width = UiWidth()
		local height = UiHeight()
		local border_width = width * AVF_TAK_CONTROLLER.BORDER
		local border_height = height * AVF_TAK_CONTROLLER.BORDER 
		local side_border_height = height - (border_height*2)
		-- draw ui borders
		local mouse_x, mouse_y = UiGetMousePos()
		AVF_TAK_CONTROLLER.cam_target_x = get_AVF_tak_movement(mouse_x,border_width,width)
		AVF_TAK_CONTROLLER.cam_target_y = get_AVF_tak_movement(mouse_y,border_height,height)  
		
		AVF_TAK_SELECT_REGION()
		AVF_TAK_DRAW_TRACKED_ASSETS()
		AVF_TAK_GIVE_COMMAND()

		-- DebugWatch("target move x,y",Vec(AVF_TAK_CONTROLLER.cam_target_x,0,AVF_TAK_CONTROLLER.cam_target_y))
		UiPush()
			-- UiColor(0, 0, 0,0.5)
			-- UiFont("regular.ttf", 26)

			-- UiImageBox("ui/common/box-solid-6.png", width, border_height, 1, 1)
			-- UiTranslate(0,border_height)
			-- UiImageBox("ui/common/box-solid-6.png", border_width,side_border_height  , 1, 1)
			-- UiTranslate(width-border_width,0)
			-- UiImageBox("ui/common/box-solid-6.png", border_width,side_border_height  , 1, 1)
			-- UiTranslate(-(width-border_width),side_border_height)
			-- UiImageBox("ui/common/box-solid-6.png", width, border_height, 1, 1)
		UiPop()

	end
end


function AVF_TAK_GIVE_COMMAND()

	if(#AVF_TAK_CONTROLLER['selected_vehicles']>0) then 
		if(InputPressed('rmb')) then 
			local x, y = UiGetMousePos()
			local dir = UiPixelToWorld(x, y)
			local pos = GetCameraTransform().pos
			local hit, dist = QueryRaycast(pos, dir, 300)
			if hit then
				local hitPos = VecAdd(pos , VecScale(dir, dist))
				for i=1,#AVF_TAK_CONTROLLER['selected_vehicles'] do 
					SetTag(
						AVF_TAK_CONTROLLER['selected_vehicles'][i],
						'AVF_TAK_MOVE',
						table.concat(hitPos, ","))
					SetTag(AVF_TAK_CONTROLLER['selected_vehicles'][i],'AVF_TAK_NEW_COMMAND')
					-- DebugWatch("TAGGING ASSET",AVF_TAK_CONTROLLER['selected_vehicles'][i])
				end
				-- DebugPrint("hit distance: " .. dist)
				-- DebugWatch("cam pos as string", table.concat(hitPos, ","))
			end
		elseif(InputPressed('lmb') and not AVF_TAK_CONTROLLER.SELECTING_REGION) then
			AVF_TAK_ASSET_SELECT({})
		end
	end

end



function AVF_TAK_DRAW_TRACKED_ASSETS()
	local displayRange = 350
	local uiScaleFactor = 0.4

	local rectScale = 30

	local colourW = 60
	local colourH = 60

	local namePlacardW = 170
	local namePlacardH = 30


	local letterSize = 11.8

	local maxDist = 0
	--[[
	AVF_TAK_SERVER = {
		assets = {
			BLUFOR = {},
			OPFOR = {},
			INDEFOR ={}
		}
	}

	]]
	UiPush()
	local faction_image = nil
	local faction_colour = {0,0,0}
		for faction_name,faction in pairs(AVF_TAK_SERVER.assets) do 
			if(faction_name =='BLUFOR') then 
				faction_image = "MOD/gfx/BLUFOR_CMA_NATO_APP_6C.png"
				faction_colour = {0,1,1} 
			elseif(faction_name =='OPFOR') then 
				faction_image = "MOD/gfx/OPFOR_CMA_NATO_APP_6C.png"
				faction_colour = {1,0,0} 
			elseif(faction_name =='INDFOR') then 
				faction_image = "MOD/gfx/INDFOR_CMA_NATO_APP_6C.png"
				faction_colour = {0,1,0} 
			end
			for i,asset in ipairs(faction) do
	 			if( not (HasTag(asset,"avf_vehicle_disabled") or GetVehicleHealth(asset)<0.5)) then 
	 				
					local vehicleTransform = GetVehicleTransform(asset)

					local distToPlayer = VecLength(VecSub(asset,GetCameraTransform().pos))
					if(distToPlayer <= displayRange) then  
						local body = GetVehicleBody(asset)
						local min, max = GetBodyBounds(body)
						local boundsSize = VecLength(VecSub(max, min))
						vehicleTransform.pos =VecAdd(vehicleTransform.pos,Vec(0,boundsSize*.5,0))
						UiPush()


							-- if vehicle visible on screen then display 
							local x, y, dist = UiWorldToPixel(vehicleTransform.pos)
								
							if dist > 0 then

								UiTranslate(x, y)
								-- UiText("Label")
								-- UiTranslate(x, y)
								-- UiRotate(GetTime())
								UiAlign("center middle")

								UiScale((displayRange/distToPlayer)*uiScaleFactor, (displayRange/distToPlayer)*uiScaleFactor)
								UiColor(1,1,1,1)
								-- UiTranslate(-(colourW *2), 0)
								
								UiFont("bold.ttf", 46)--math.floor(10* (displayRange/distToPlayer)))
								UiAlign("center middle")
								-- UiTranslate((colourW *0.25), 0)
																
								
								if(HasTag(asset,"avf_vehicle_cooking_off")) then
									UiColor(0.4,0.4,0.4,1)
									UiImageBox(faction_image, colourW , colourH, 6, 6)
								elseif(faction_name =='BLUFOR') then 
									local asset_currently_selected = false
									for i,selected_asset in ipairs(AVF_TAK_CONTROLLER['selected_vehicles']) do 
										if(selected_asset == asset) then 
											asset_currently_selected = true
											-- UiTranslate(-colourW*.1,-colourH*.1)
											UiImageBox("MOD/gfx/BLUFOR_CMA_NATO_APP_6C_bg.png", colourH*1.01, colourW*1.01,1,1,1,1)
											-- UiTranslate(colourW*.1,colourH*.1)
											
											UiColor(faction_colour[1]*2,faction_colour[2]*2,faction_colour[3]*2,1)	
											UiImageBox(faction_image, colourW , colourH, 6, 6)

										end
									end
									if(not asset_currently_selected) then 
										UiColor(faction_colour[1],faction_colour[2],faction_colour[3],1)	
										UiImageBox(faction_image, colourW , colourH, 6, 6)
									end

									UiButtonImageBox(faction_image, colourW, colourH,0,0,0,0)
									
									if UiTextButton("") and not AVF_TAK_CONTROLLER.SELECTING_REGION then
										AVF_TAK_ASSET_SELECT({[1]=asset})
									end
								else
									UiColor(faction_colour[1],faction_colour[2],faction_colour[3],1)	
									UiImageBox(faction_image, colourW , colourH, 6, 6)
								end
							end	

							UiPop()
						-- now draw the invisible vehicle selection bit 

						-- local x1, y1, dist1 = UiWorldToPixel(min)	
						-- local x2, y2, dist2 = UiWorldToPixel(max)	
						-- if dist1 > 0 and dist2 > 0 then

						-- end

			 		end
				end
			end
		end
	UiPop()


end

function  get_AVF_tak_movement(cursor_pos,border,window_size)
		if(cursor_pos<border) then
			return -1
		elseif(cursor_pos>window_size-border) then 
			return 1
		else
			return 0
		end
end

function AVF_TAK_get_arrow_key_movement(input_key_1,input_key_2)
	local input_a = InputPressed(input_key_1) or InputDown(input_key_1)
	local input_b = InputPressed(input_key_2) or InputDown(input_key_2)

	return (input_a  and 1) or (input_b   and -1) or 0 
end
function AVF_TAK_get_zoom_rate()
	local mouse_wheel_impulse = InputValue("mousewheel")

	return (mouse_wheel_impulse  > 0 and 1) or (mouse_wheel_impulse  == 0 and 0) or -1 
end




function clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end




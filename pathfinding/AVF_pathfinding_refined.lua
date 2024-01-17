

---PATHFINDING LINKED

#include "mapNode.lua"
#include "AStarSearch.lua"



--[[
**********************************************************************
*
* FILEHEADER: Elboydo's Armed Vehicles Framework (AVF) AI V3 - The Racing Edition 
*
* FILENAME :        AVF_AI_3.lua             
*
* DESCRIPTION :
*       File that implements racing AI inside teardown 2020, with PID controllers
* 		to ensure cars respond to coordinates in a good fashion and can handle high speed
*		Also includes simple goal achievement and collision avoidance 
*		Including "driver ai" to make them more / less aggressive with speed, cornering
*		overtaking, and driving. 
*		

*
* NOTES :
*       
*
* AUTHOR :    elboydo        START DATE   :    Jan  2021
* 							 Release Date :    29 Nov 2021 
*
]]

PATHSET = false

mapInitialized = false
DEBUG = false

map = {

  xIndex = 0,
  data = {

  },

  smoothingFactor = 3,
  validMaterials = {
  	[1] = {	
  		material = "masonry",


	  validSurfaceColours ={ 
				[1] = {
					r = 0.20,
					g = 0.20,
					b = 0.20,
					range = 0.2
				},
				[2] = {
					r = 0.80,
					g = 0.60,
					b = 0.60,
					range = 0.2
				},
				[3] = {
					r = 0.34,
					g = 0.34,
					b = 0.34,
					range = 0.2
				},
			},
		},
	},
}

-- negative grid pos is solved by simply showing 
mapSize = {
			x=400,
			y=400,
			grid =4,--6,
      gridHeight = 2.5,
      gridResolution = 3, -- seaches per grid square
      gridThres      = 0.6,

      scanHeight = 100,

      scanLength = 200,
      refresh_rate = 20,
      weights = {
          goodTerrain = 0.5,
          badTerrain   = 5,
          avoidTerrain = 25,
          impassableTerrain = 50,
      }
		}
    path = nil


--- AI LINKED

ai = {}

pathing_states = {
	current_state = 1,
	states = {
		[1] = 'READY',
		[2] = 'SEARCHING',
		[3] = 'EXPIRED'
	}


}


TARGET_POS =nil


function init()

	mapSize.gridResolution = mapSize.grid/mapSize.gridResolution
	initMapArr()

end


function initMapArr()
	for y= -mapSize.y/2,mapSize.y/2,mapSize.grid do
	    pos = posToInt(Vec(0,0,y))
	    map.data[pos[3]] = {}
	    for x= -mapSize.x,mapSize.x/2,mapSize.grid do
	        pos = posToInt(Vec(x,0,y))
	        map.data[pos[3]][pos[1]] = nil 
	    end
	end
end

function initMap( )
  local pos = Vec(0,0,0)
  local gridCost = 0
  local maxVal  = {math.modf((mapSize.x)/mapSize.grid),math.modf((mapSize.y)/mapSize.grid)}

	for y= -mapSize.y/2,mapSize.y/2,mapSize.grid do
    pos = posToInt(Vec(0,0,y))
    -- map.data[pos[3]] = {}
	    for x= -mapSize.x,mapSize.x/2,mapSize.grid do
	        pos = posToInt(Vec(x,0,y))
	        gridCost,validTerrain,avgHeight,grid_avg =  scanGrid(x,y) 
	        -- gridCost,validTerrain,avgHeight,grid_avg =  1,true,1,1,1
	        -- if(pos[3] ~= nil and pos[1]~= nil) then
	          
	          map.data[pos[3]][pos[1]] = deepcopy(mapNode) 
	          map.data[pos[3]][pos[1]]:push(x,grid_avg,y,gridCost,pos[3],pos[1],validTerrain,maxVal,0 )

	        -- end
	  		  -- DebugPrint(x.." | "..y)
	    end
	end


	mapInitialized = true
	

end

function get_pathing_state()
	pathing_state = pathing_states['states'][pathing_states['current_state']]
	return pathing_state

end

function init_pathfinding(startPos,goalPos)

	goalPos = posToInt(goalPos)
	startPos = posToInt(startPos)
	local goal = map.data[goalPos[3]][goalPos[1]]
	local start = map.data[startPos[3]][startPos[1]]
	AStar:init(map.data, start, goal  ) 

	pathing_states['current_state'] = 2

end
		
function perform_pathfinding()
	local search_result =  AStar:AStarSearch_2(map.data)

	if(search_result) then 
		if(search_result ~= -1) then

			DebugWatch("pathing outcome","SUCCESS")
			path = search_result
			PATHSET = true
		else 
			DebugWatch("pathing outcome","ERROR")
		end
		pathing_states['current_state'] = 1
		
	end
	

end



function tick(dt)
	if(not(mapInitialized)) then 
		initMap()
	end
	DebugWatch("game time",GetTime())
	DebugWatch("pathing_state",get_pathing_state())

	DebugWatch("PATHSET",PATHSET)
	if(PATHSET) then 
		 AStar:drawPath(map.data,path)
	  	if(DEBUG)then 

		    AStar:drawPath(map.data,path)

			local t = GetCameraTransform()
			local dir = TransformToParentVec(t, {0, 0, -1})

			local hit, dist, normal, shape = QueryRaycast(t.pos, dir, 10)
			DebugWatch("Hit", hit)
			if hit then
				--Visualize raycast hit and normal
				local hitPoint = VecAdd(t.pos, VecScale(dir, dist))
				local mat,r,g,b = GetShapeMaterialAtPosition(shape, hitPoint)
				DebugWatch("Raycast hit voxel made out of ", mat.." | r:"..r.."g:"..g.."b:"..b)
				DebugWatch("Terrain cost",checkIfTerrainValid(mat,r,g,b))
				DebugWatch("body mass",GetBodyMass(GetShapeBody(shape)))
			end

		end
	end



	---------------------
			---------- keypress stuff
	---------------
	-- DebugWatch("map_mode")
	if InputPressed("c") then 
		CAMMODE = not CAMMODE

	end
	if(InputPressed("y")) then
		local hitPos = perform_raycast()
		if(hitPos) then 
			TARGET_POS= hitPos
		end
	end
	DebugWatch("TARGET_POS",TARGET_POS)

	if(TARGET_POS and InputPressed("p")) then
		DebugWatch("map init",mapInitialized)

		if(get_pathing_state() =="READY") then 
			local hitPos = perform_raycast()
			if(hitPos) then 
				DebugWatch("start pos",hitPos)
				init_pathfinding(hitPos, TARGET_POS)
			end
		end
	end
	if(mapInitialized and get_pathing_state() == "SEARCHING") then 
		perform_pathfinding()
	end


end


function perform_raycast()


	local t = GetCameraTransform()
	local dir = TransformToParentVec(t, {0, 0, -1})

	local hit, dist, normal, shape = QueryRaycast(t.pos, dir, 200)
	DebugWatch("Hit", hit)
	if hit then
		--Visualize raycast hit and normal
		local hitPoint = VecAdd(t.pos, VecScale(dir, dist))
		return hitPoint
	end
	return nil
end

-- find euclidian distance of data to clusters and update centroid locations
function ai:clusteringCalculateClusters()
	local pos = Vec(0,0,0)
	local center = Vec(0,0,0)
	local dist = 0

	for i = 1,self.clustering.iterations do 
		for index = 1,self.clustering.clusters.current.index do 
			self.clustering.clusters.current.data[index]:resetMins()
			
			pos = self.clustering.clusters.current.data[index]:getPos()

			for i = 1,self.clustering.centroids do
				 self.clustering.clusters.current.data[index]:computeNodeDistance(i,self.clustering.clusters.centroids.data[i])
			end
		end
		self:clusteringUpdateCentroids()
	end

end

--- perform operations on clusters to extract target
function ai:clusteringOperations()
	
	self:clusteringCalculateClusters()


	self:pseudoSNN()

	for i = 1,self.clustering.centroids do
		 self.clustering.clusters.centroids.data[i]:showSprite()
		 -- DebugWatch("cluster - "..i,VecSub(self.clustering.clusters.centroids.data[i]:getPos(),
		 -- 	 GetVehicleTransform(self.id).pos))
		 --DebugWatch("cluster - "..i,self.clustering.clusters.centroids.data[i]:getPos())
	-- VecLength(self.clustering.clusters.centroids.data[i]:getPos(),Vec(0,0,0)))
	end

	self.targetNode = self.clustering.clusters.centroids.data[self.clustering.mode]

end


--- simulate an snn network slightly to get best node

-- if(SNNpspprev[j]<SNNpsp[i])
--  {
--      SNNweights[j][i]=tanh(gammaweights*SNNweights[j][i]+learningrateweights*SNNpspprev[j]*SNNpsp[i]);
--  }

function ai:pseudoSNN()
	local bestpsp = 100000000
	local mode = -1
	local inputData = nil
	local pos = Vec(0,0,0)
	local value = 0
	for index = 1,self.clustering.clusters.current.index do 
		inputData = self.clustering.clusters.current.data[index] 
		self.clustering.clusters.centroids.data[inputData:getMinID()]:growPulse(inputData.value)
	end
	local psp = 100000000
	local dist = 0
	for i = 1,self.clustering.centroids do
		if(VecLength(self.clustering.clusters.centroids.data[i]:getPos())>0) then
			self.clustering.clusters.centroids.data[i]:firePulse()
			psp =self.clustering.clusters.centroids.data[i].SNNstate 
			if(psp>self.clustering.clusters.centroids.data[i].outputthreshold) then 
				dist = self.clustering.clusters.centroids.data[i]:getDistance(self.goalpos)
				psp = dist * (1-psp)
				if(psp<bestpsp) then 
					bestpsp = psp
					mode = i
				end 
			end
		end
	--		if(self.clustering.clusters.centroids.data[i].SNNstate > self.clustering.clusters.centroids.data[i].threshold) then
	end
	if(mode == -1) then
		mode = self.clustering.previousOutput 
	else
		self.clustering.previousOutput = mode

	end
	self.clustering.mode = mode
	-- DebugPrint(mode)
	if(self.clustering.mode ~=-1) then
		self.clustering.clusters.centroids.data[self.clustering.mode].spriteColour={0,0,1}
	end
end

function ai:pushData(hit,dist,normal,shape,hitPos)
	local index = self.clustering.clusters.current.index 
	local hitValue = 0
	if(hit) then 
		local mat,r,g,b  = GetShapeMaterialAtPosition(shape, hitPos)
		if(mat =="masonry") then
			for colKey, validSurfaceColours in ipairs(self.validSurfaceColours) do 
				
				local validRange = validSurfaceColours.range
				if(inRange(validSurfaceColours.r-validRange,validSurfaceColours.r+validRange,r)
				 and inRange(validSurfaceColours.g-validRange,validSurfaceColours.g+validRange,g) 
				 and inRange(validSurfaceColours.b-validRange,validSurfaceColours.b+validRange,b)) then 
					hitValue = 1
				end
			end
		else

			hitValue = -1
		end
	end
	--DebugPrint((#self.clustering.clusters.current.data))
	
	--DebugPrint("values: index: "..index.."\nhitpos:"..VecStr(hitPos).."\nhitval: "..hitValue.."\nClusterPos = "..VecStr(self.clustering.clusters.current.data[index]:getPos()))
	self.clustering.clusters.current.data[index]:push(hitPos[1],hitPos[2],hitPos[3],hitValue) 


	self.clustering.clusters.current.index = (self.clustering.clusters.current.index%self.clustering.dataSize )+1
end


function ai:MAV(targetCost)
	self.targetMoves.targetIndex = (self.targetMoves.targetIndex%#self.targetMoves.list)+1 
	self.targetMoves.target = VecSub(self.targetMoves.target,self.targetMoves.list[self.targetMoves.targetIndex])
	self.targetMoves.target = VecAdd(self.targetMoves.target,targetCost)
	self.targetMoves.list[self.targetMoves.targetIndex] = targetCost
	return VecScale(self.targetMoves.target,(#self.targetMoves.list/100))

end



function ai:costFunc(testPos,hit,dist,shape,key)



	local cost = 10000 
	if(not hit) then
		cost = VecLength(VecSub(testPos,self.goalPos))*(1-self.weights[key])
	end
	return cost
end


------------------------------------------------


---- PATHFINDING


-----------------------------------------------------



---- 



---- use flood fill to comap[re to last neighbor  that was known and if neighbor foun and  track then 

---- compare the next based on known locations nd move outwards.]

----



function scanGrid(x,y)
  local pos = Vec(0,0,0)
  local gridScore = 1
  local spotScore = 0 
  local hitHeight = mapSize.scanHeight
  local heightOrigin = 1000000
  local minHeight = heightOrigin
  local maxHeight = -heightOrigin
  local validTerrain  = true
  local xLocal = 0
  local yLocal = 0
  for y1= 1, mapSize.grid, mapSize.gridResolution do
  	yLocal = (y+y1) - mapSize.grid/2
    for x1= 1, mapSize.grid, mapSize.gridResolution do
    	xLocal = (x+x1) - mapSize.grid/2
      spotScore,hitHeight,hit =  getMaterialScore3(xLocal, yLocal)
      if(hitHeight == mapSize.scanHeight or IsPointInWater(Vec(xLocal,hitHeight,yLocal))or not hit) then
        minHeight = -mapSize.scanLength
        maxHeight = mapSize.scanLength
        validTerrain = false
      elseif(minHeight == heightOrigin or maxHeight == heightOrigin) then
        minHeight = hitHeight
        maxHeight = hitHeight
      elseif(hitHeight < minHeight) then
        minHeight = hitHeight
      elseif(hitHeight > maxHeight) then
        maxHeight = hitHeight
      end

      -- local hit,height,hitPos, shape = getHeight(x,y)
      -- spotScore =  getMaterialScore2(hit,hitPos,shape)
      gridScore = gridScore + spotScore

    end
  end
  --DebugPrint("max: "..maxHeight.." min: "..minHeight.." sum: "..(((maxHeight - minHeight) / (mapSize.gridHeight*mapSize.gridThres)))  )  
  if(((maxHeight - minHeight) )>mapSize.gridHeight) then
    validTerrain = false
  end  
  if(((maxHeight) - (minHeight)) ~=0 ) then
    gridScore = gridScore + ((1+((maxHeight) - (minHeight))/100))
  end
  return gridScore,validTerrain, minHeight, ((minHeight+maxHeight)/2)
end



function getHeight(x,y)

  local probe = Vec(x,mapSize.scanHeight,y)
  local hit, dist,normal,shape = QueryRaycast(probe, Vec(0,-1,0), mapSize.scanLength)
  local hitHeight = 0
  if hit then
    hitHeight = mapSize.scanHeight - dist
  end 
  return hit,hitHeight,VecAdd(probe, VecScale(Vec(0,-1,0), dist)),shape

end

function getMaterialScore(x,z,y)
  local score = 0
  local probe = Vec(x,z+(mapSize.gridHeight/2),y)
  QueryRequire("physical static")
  local hit, dist,norm,shape = QueryRaycast(probe, Vec(0,-1,0), mapSize.gridHeight)
  if hit then
    local hitPoint = VecAdd(probe, VecScale(Vec(0,-1,0), dist))
    local mat,r,g,b  = GetShapeMaterialAtPosition(shape, hitPoint)
    if(mat =="masonry") then
      for colKey, validSurfaceColours in ipairs(map.validSurfaceColours) do 
        
        local validRange = validSurfaceColours.range
        if(inRange(validSurfaceColours.r-validRange,validSurfaceColours.r+validRange,r)
         and inRange(validSurfaceColours.g-validRange,validSurfaceColours.g+validRange,g) 
         and inRange(validSurfaceColours.b-validRange,validSurfaceColours.b+validRange,b))
          then 
            score = 0.1
        end
      end
    else

      score = 1
    end    
  else
    score = 10
  end

  return score

end

function getMaterialScore2(hit,hitPoint,shape)
  local score = 0
  if hit then
    local mat,r,g,b  = GetShapeMaterialAtPosition(shape, hitPoint)
    if(mat =="masonry") then
      for colKey, validSurfaceColours in ipairs(map.validSurfaceColours) do 
        
        local validRange = validSurfaceColours.range
        if(inRange(validSurfaceColours.r-validRange,validSurfaceColours.r+validRange,r)
         and inRange(validSurfaceColours.g-validRange,validSurfaceColours.g+validRange,g) 
         and inRange(validSurfaceColours.b-validRange,validSurfaceColours.b+validRange,b))
          then 
            score = 0.1
        end
      end
    else

      score = 1
    end    
  else
    score = 10
  end

  return score

end


function getMaterialScore3(x,y)
  local score = 0
  local probe = Vec(x,mapSize.scanHeight,y)
  QueryRequire("static")
  local hit, dist,normal,shape = QueryRaycast(probe, Vec(0,-1,0), mapSize.scanLength)
  if hit then
	    local hitPoint = VecAdd(probe, VecScale(Vec(0,-1,0), dist))
	    local mat,r,g,b  = GetShapeMaterialAtPosition(shape, hitPoint)
		for matKey, matBase in ipairs(map.validMaterials) do 
			if(score ~= mapSize.weights.goodTerrain ) then 
			    if(mat ==matBase.material) then
			      for colKey, validSurfaceColours in ipairs(matBase.validSurfaceColours) do 
			        
			        local validRange = validSurfaceColours.range
			        if(inRange(validSurfaceColours.r-validRange,validSurfaceColours.r+validRange,r)
			         and inRange(validSurfaceColours.g-validRange,validSurfaceColours.g+validRange,g) 
			         and inRange(validSurfaceColours.b-validRange,validSurfaceColours.b+validRange,b))
			          then 
			            score = mapSize.weights.goodTerrain
			        end
			      end
			      if(score ~= mapSize.weights.goodTerrain ) then 
			        score = mapSize.weights.badTerrain
			      end
			    else

			      score = mapSize.weights.badTerrain
			    end  
			end
	    end  
  else
    score = mapSize.weights.impassableTerrain
  end
  local hitHeight = mapSize.scanHeight - dist

  return score,hitHeight,hit

end

function posToInt(pos)
  local pos2 = VecCopy(pos)
  local pos3 = VecCopy(pos)
  for i=1,3 do 
    pos3[i] = math.modf((pos3[i]+200)/mapSize.grid)
    --math.floor(pos[i]))
    pos2[i] = (pos[i]*mapSize.grid)
    if(i == 1 or i == 3 ) then
      pos2[i] = pos2[i] + (mapSize.grid/2)
    end
    pos2[i] = pos2[i] -200
  end
  return pos3,pos2
end

function posToIndex(pos)
  local pos2 = VeC(0,0,0)
  for i=1,3 do 
    pos[i] = math.modf((pos[i]+200)/mapSize.grid)
    --math.floor(pos[i]))
    pos2[i] = (pos[i]*mapSize.grid)
    if(i == 1 or i == 3 ) then
      pos2[i] = pos2[i] + (mapSize.grid/2)
    end
    pos2[i] = pos2[i] -200
  end
  return pos,pos2
end


function Heuristic(a, b)
      return Math.Abs(a[1] - b[1]) + Math.Abs(a[3] - b[3]);
 end 





function checkIfTerrainValid(mat,r,g,b)
		local score = 0
		if(DEBUG) then
			DebugWatch("r",#map.validMaterials)
		end
		for matKey, matBase in ipairs(map.validMaterials) do 
			if(score ~= mapSize.weights.goodTerrain ) then 
			    if(mat ==matBase.material) then
			      for colKey, validSurfaceColours in ipairs(matBase.validSurfaceColours) do 
			        
			        local validRange = validSurfaceColours.range
			        if(inRange(validSurfaceColours.r-validRange,validSurfaceColours.r+validRange,r)
			         and inRange(validSurfaceColours.g-validRange,validSurfaceColours.g+validRange,g) 
			         and inRange(validSurfaceColours.b-validRange,validSurfaceColours.b+validRange,b))
			          then 
			            score = mapSize.weights.goodTerrain
			            if(DEBUG) then 
				            DebugWatch("r","goodTerrain")
				        end
			        end
			      end
			      if(score ~= mapSize.weights.goodTerrain ) then 
			        score = mapSize.weights.badTerrain
			      end
			    else

			      score = mapSize.weights.badTerrain
			    end  
			end
	    end 
	    return score
end







---------------------------------------------------------




-------------------------------------------------------


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


function inRange(min,max,value)
		if(tonumber(min) < tonumber(value) and tonumber(value)<=tonumber(max)) then 
			return true

		else
			return false
		end

end




function draw()


end




aiPresets = {
	
	EASY = 1,
	MEDIUM = 2,
	HARD = 3,
	INSANE = 4,	
	DGAF = 5,
	ROADRAGE = 6,

	difficulties = {
		[1] = {
			name =  "easy", 
			steeringThres = 0.1,
			speedSteeringThres = 0.1, 
			tenacity = 0.7,
			errorCoef = 0.4,

		}, 
		[2] = {
			name =  "medium", 
			steeringThres = 0.2,
			speedSteeringThres = 0.2, 
			tenacity = 0.8,
			errorCoef = 0.2,

		}, 
		[3] = {
			name =  "hard", 
			steeringThres = 0.4,
			speedSteeringThres = 0.4, 
			tenacity = 0.9,
			errorCoef = 0.1,

		}, 
		[4] = {
			name =  "insane", 
			steeringThres = 0.6,
			speedSteeringThres = 0.6, 
			tenacity = 0.94,
			errorCoef = 0.05,

		}, 
		[5] = {
			name =  "DGAF", 
			steeringThres = 0.9,
			speedSteeringThres = 0.9, 
			tenacity = 0.99,
			errorCoef = 0.1,

		}, 
		[6] = {
			name =  "road rage", 
			steeringThres = 1,
			speedSteeringThres = 0.2, 
			tenacity = 1.1,
			errorCoef = 0.1,

		}, 
		[7] = {
			name =  "Never Overtakes - gentle", 
			steeringThres = 0.1,
			speedSteeringThres = 0.25, 
			tenacity = 0.85,
			errorCoef = 0.1,

		}, 
		[8] = {
			name =  "Never Overtakes - speedDemon", 
			steeringThres = 0.1,
			speedSteeringThres = 0.9, 
			tenacity = 0.85,
			errorCoef = 0.1,

		}, 
		[9] = {
			name =  "Medium corners, overtakes", 
			steeringThres = 0.95,
			speedSteeringThres = 0.5, 
			tenacity = 0.9,
			errorCoef = 0.1,

		}, 

		[10] = {
			name =  "slower corners, overtakes", 
			steeringThres = 0.7,
			speedSteeringThres = 0.35, 
			tenacity = 0.9,
			errorCoef = 0.1,

		}, 

	},

	difficulty_ranged = {
		[1] = {
			name =  "easy", 
			steeringThres = {10,100},
			speedSteeringThres = {10,90}, 
			tenacity = {70,100},
			errorCoef = {1,40},

		}, 
		[2] = {
			name =  "medium", 
			steeringThres = {20,100},
			speedSteeringThres = {20,99}, 
			tenacity = {80,100},
			errorCoef = {1,20},

		}, 
		[3] = {
			name =  "competative_medium", 
			steeringThres = {60,100},
			speedSteeringThres = {20,99}, 
			tenacity = {80,100},
			errorCoef = {1,10},

		}, 
		[4] = {
			name =  "hard", 
			steeringThres = {40,100},
			speedSteeringThres = {40,100}, 
			tenacity = {90,100},
			errorCoef = {1,10},

		}, 
		[5] = {
			name =  "insane", 
			steeringThres = {60,110},
			speedSteeringThres = {60,110}, 
			tenacity = {90,110},
			errorCoef = {1,5},

		}, 
		[6] = {
			name =  "psycobilly_freakout", 
			steeringThres = {80,130},
			speedSteeringThres = {80,130}, 
			tenacity = {95,130},
			errorCoef = {0.5,2.5},

		}, 

		-- [7] = {
		-- 	name =  "texas_psycobilly_freakout", 
		-- 	steeringThres = {80,160},
		-- 	speedSteeringThres = {80,160}, 
		-- 	tenacity = {100,160},
		-- 	errorCoef = {0.25,2},

		-- }, 

	}

}


AVF_AI_ACS = {
	active = true,
	goalPos= Vec(0,0,0),

	min_path = 10,

	raceValues = {
		completedGoals  = 0,
		targetNode 		= 1,
		NextNode 		= 2,
		passedCheckPoints = 0,
		nextCheckpoint = 1,
		completionRange = 4.5,--4.5,
		lookAhead = 2,
		laps = 0 	,
		lastLap = 0,
		splits = {},

		bestLap = nil,

	},

	targetNode = nil,
	NextNode =nil,

	controller = {
		aiType = "default",

		accelerationValue = 0,
		steeringValue = 0,
		handbrake = false,

		steeringThres  = {60,110}, --0.4
		steeringForce  = 0.5,
		speedSteeringThres = {60,110},
		tenacity 			= 0.9,
		relativeThreshold = 0.8,
		minDist = 2--.5,--5,
	},

	reversingController = {
		reversing = false,
		minVelocity = 1,
		waitTime = 5.5,
		currentWait = 3,
		reverseTime = 2.5,
		currentReverseTime = 5.5,
	},


	detectRange = 3,
	commands = {
	[1] = Vec(0,0,-1),
	[2] = Vec(1*0.8,0,-1*1.5),
	[3] = Vec(-1*0.8,0,-1*1.5),
	[4] = Vec(-1,0,0),
	[5] = Vec(1,0,0),
	[6] = Vec(0,0,1),

	},

	weights = {

	[1] = 0.870,
	[2] = 0.86,
	[3] = 0.86,
	[4] = 0.84,
	[5] = 0.84,
	[6] = 0.80,

			} ,

	targetMoves = {
		list        = {},
		target      = Vec(0,0,0),
		targetIndex = 1
	},


	directions = {
		forward = Vec(0,0,1),

		back = Vec(0,0,-1),

		left = Vec(1,0,0),

		right = Vec(-1,0,0),
	},

	maxVelocity = 0,

	cornerCoef = 16,

	accelerationCoef = 0.75,
	steeringCoef = 2.55,

	pidState = {

			--- pid gain params
--		pGain = 0.765,
		pGain = 0.865,
		iGain = -0.04,
		dGain = -1.35,---1.3,

		intergralTime = 5,

		integralIndex = 1,
		integralSum = 0,
		integralData = {

		},
		lastCrossTrackError = 0,
		lastPnt = Vec(0,0,0),

			-- pid output value 
		controllerValue = 0,


			--- pid update and training params
			training = false,
		inputrate=0.0665,
		learningrateweights=0.009,
		learningrateThres = 0.02,
	    bestrate=0.05,
	    secondbestrate=0.01,
	    gammasyn=0.9,
	    gammaref=0.7,
	    gammapsp=0.9,
	},
	usingClustering = false,

	clustering = {
		pass = 1,
		maxPass = 10,
		centroids = 2,
		iterations = 5,
		prior = 1,
		dataSize = 100,
		mode = -1,
		previousOutput = -1,
		output = nil,
		clusters = {
			centroids = {
				pass = 1,
				index = 1,
				data = {},
			},
			current = {
				pass = 1,
				index = 1,
				data = {},


			},
			prior = {
				pass = 1,
				index = 1,
				data = {},


			},
		},

	},

	scanning = {
		numScans = 2,
		scanThreshold = 0.5,
		maxScanLength = 10,
		scanLength = 50,
		scanDepths = 2,
		vehicleHeight = 2,
		cones = {
			left   = {
				direction = "left",
				startVec = Vec(0.25,0,-1.5),
				size = 110,
				scanColour = {
					r = 1,
					g = 1, 
					b = 0,
				},
				weight = 0.5

			},
			centre = {
				direction = "centre",
				startVec = Vec(0,0,-1),
				size = 0.5,
				scanColour = {
					r = 0,
					g = 0, 
					b = 1,
				},
				weight = 0.6

			},
			right  = {
				direction = "right",
				size = 110,
				startVec = Vec(-0.25,0,-1.5),
				scanColour = {
					r = 0,
					g = 1, 
					b = 0,
				},
				weight = 0.5

			},
		},
		positions = {
			left   = {
				direction = "left",
				startVec = Vec(0.25,0,-1.5),
				size = 110,
				scanColour = {
					r = 1,
					g = 1, 
					b = 0,
				},
				weight = 0.5

			},
			sideL  = {
				direction = "sideL",
				size = 110,
				startVec = Vec(1.25,0,-1.5),
				scanColour = {
					r = 0,
					g = 1, 
					b = 0,
				},
				weight = 0.5

			},
			centre = {
				direction = "centre",
				startVec = Vec(0,0,-1),
				size = 0.5,
				scanColour = {
					r = 0,
					g = 0, 
					b = 1,
				},
				weight = 0.6

			},
			right  = {
				direction = "right",
				size = 110,
				startVec = Vec(-0.25,0,-1.5),
				scanColour = {
					r = 0,
					g = 1, 
					b = 0,
				},
				weight = 0.5

			},
			sideR  = {
				direction = "sideR",
				size = 110,
				startVec = Vec(-1.25,0,-1.5),
				scanColour = {
					r = 0,
					g = 1, 
					b = 0,
				},
				weight = 0.5

			},
		},

	},



	--altChecks = Vec(0.25,0.4,-0.6),
	altChecks = {
				[1] = -2,
				[2] =0.2,
				[3] = 0.4
			},
	altWeight ={
			[1] = 1,
			[2] =1,
			[3] = -1,
			[4] = -1,
	},


	validSurfaceColours ={ 
			[1] = {
				r = 0.20,
				g = 0.20,
				b = 0.20,
				range = 0.02
			},
			[2] = {
				r = 0.60,
				g = 0.60,
				b = 0.60,
				range = 0.02
			},
			[3] = {
				r = 0.34,
				g = 0.34,
				b = 0.34,
				range = 0.02
			},
		},
	hitColour = Vec(1,0,0),
	detectColour = Vec(1,1,0),
	clearColour = Vec(0,1,0),
}


function AVF_AI_ACS:initVehicle(ai) 

	self.id = ai.id
	self.body = GetVehicleBody(self.id)
	self.transform =  GetBodyTransform(self.body)
	self.shapes = GetBodyShapes(self.body)


	-- DebugPrint("[INFO] "..ai.id.." ACS setup begun")

	-- --- declare driver name 

	-- if(math.random(0,200)<=1) then
	-- 	self.driverName = uniqueNames[math.random(1,#uniqueNames)]
	-- else
	-- 	self.driverFName = fNames[math.random(1,#fNames)] 
	-- 	self.driverSName = sNames[math.random(1,#sNames)]
	-- 	self.driverName = self.driverFName.." "..self.driverSName
	-- end
		--- find largest shape and dclare that the main vehicle SpawnParticle

	local largestKey = 0
	local shapeVoxels = 0
	local largestShapeVoxels = 0
	for key,shape in ipairs(self.shapes) do
		shapeVoxels = GetShapeVoxelCount(shape)
		if(shapeVoxels> largestShapeVoxels) then
			largestShapeVoxels = shapeVoxels
			largestKey = key
		end
	end
	self.mainBody = self.shapes[largestKey]
	self.bodyXSize,self.bodyYSize ,self.bodyZSize  = GetShapeSize(self.mainBody)
	-- DebugPrint("body Size: "..self.bodyXSize.." | "..self.bodyYSize.." | "..self.bodyZSize)


	for i=1,3 do 
		self.targetMoves.list[i] = Vec(0,0,0)
	end

	self.raceCheckpoint = 1
	self.currentCheckpoint = nil

	-- for key,value in ipairs(checkpoints) do
	-- 	if(tonumber(GetTagValue(value, "checkpoint"))==self.raceCheckpoint) then 
	-- 		self.currentCheckpoint = value
	-- 	end
	-- end	

	for i = 1, self.pidState.intergralTime do
		self.pidState.integralData[i] = 0

	end


	self.hudColour = {math.random(0,100)/100,math.random(0,100)/100,math.random(0,100)/100}

--	local aiLevel = aiPresets.difficulties[math.random(1,#aiPresets.difficulties)]
	-- local aiLevel = aiPresets.difficulties[5]--math.random(3,5)]
	
	local aiLevel = deepcopy(aiPresets.difficulty_ranged[math.random(1,#aiPresets.difficulty_ranged)])--)])--#aiPresets.difficulty_ranged)])--aiPresets.difficulty_ranged[4])
	for key,val in pairs(aiLevel) do 
		if(type(val)=="table") then
			aiLevel[key] = math.random(val[1],val[2])/100 
		end
	end
	-- for key,val in pairs(aiLevel) do 
	-- 	if(type(val)=="table") then 
	-- 		DebugPrint(key..": "..val[1].."-"..val[2]) 
	-- 	else
	-- 		DebugPrint(key..": "..val)
	-- 	end


	-- end
	

	self.controller.aiLevel = aiLevel.name

	self.controller.steeringThres  = aiLevel.steeringThres --0.4

	self.controller.speedSteeringThres = aiLevel.speedSteeringThres
	self.controller.tenacity = aiLevel.tenacity

	self.controller.errorCoef = aiLevel.errorCoef


	self.scanning.maxScanLength = self.scanning.maxScanLength * (math.random(90,350)/100) 

	-- DebugPrint("[INFO] "..ai.id.." ACS setup complete")

end


	-- reversingController = {
	-- 	reversing = false,
	-- 	minVelocity = 1,
	-- 	waitTime = 3,
	-- 	currentWait = 3,
	-- 	reverseTime = 2,
	-- 	currentReverseTime = 2,
	-- },

function AVF_AI_ACS:controlActions(dt,ai)

	local path_length = #ai.pathing.current_path
	local path_length_modifier = path_length / math.max(self.min_path, path_length)
	-- DebugWatch("ai "..ai.id.." path modifier = ",path_length_modifier)
	if(not self.reversingController.reversing) then 
		if(VecLength(GetBodyVelocity(GetVehicleBody(self.id)))<self.reversingController.minVelocity) then
			if(self.reversingController.currentWait<0) then
				self.reversingController.reversing = true
			end
			self.reversingController.currentWait = self.reversingController.currentWait - GetTimeStep()
		elseif(self.reversingController.currentWait  ~= self.reversingController.waitTime) then
			self.reversingController.currentWait  = self.reversingController.waitTime
		end

		if(self.usingClustering) then
			self:scanPos()
		end
		local accelerationValue = 0
		local steeringValue = -self:pid()
		local accelerationValue_temp = self:accelerationError()
		if(accelerationValue_temp~=nil) then
			accelerationValue = accelerationValue_temp
		end
		
		-- DebugWatch("ai-"..ai.id.."pre acceletation: ",self.controller.accelerationValue)
		-- DebugWatch("ai-"..ai.id.."pre steering: ",self.controller.steeringValue)


		self.controller.steeringValue = steeringValue * self.steeringCoef
		self.controller.accelerationValue = accelerationValue*self.accelerationCoef

		self:controllerAugmentation()
		-- DebugWatch("post acceletation: ",self.controller.accelerationValue)
		-- DebugWatch("post steering: ",self.controller.steeringValue)

		self:obstacleAvoidance()



		self:applyError()
			
			--- apply reversing error

		local directionError =  self:directionError()
		self.controller.accelerationValue = self.controller.accelerationValue * directionError
		if(directionError < 0 )then
			self.controller.steeringValue =  self.controller.steeringValue*10
		end 
			--- slow when closeto end of path and handbrake if moving too fast
		if(self.controller.accelerationValue >0) then 
			local velocity =  VecLength(GetBodyVelocity(GetVehicleBody(self.id)))

			-- DebugWatch("ai "..ai.id.." speed: ",velocity)
			self.controller.accelerationValue  = self.controller.accelerationValue * path_length_modifier
			if(velocity>self.min_path and path_length_modifier<0.6) then 
					self.controller.handbrake = true
			end
		end
		    --- apply steering safety error
		if(self.controller.accelerationValue>0)then 
			local corneringErrorMagnitude = self:corneringError()
			self.controller.accelerationValue = self.controller.accelerationValue * corneringErrorMagnitude
		end
		self.controller.steeringValue = self.controller.steeringValue  * directionError
	else
		if(self.reversingController.currentReverseTime >0) then
			self.controller.accelerationValue = -1
			self.controller.steeringValue =  -self.controller.steeringValue -- -math.sign(self.controller.steeringValue)-- -self.controller.steeringValue --*2
			self.reversingController.currentReverseTime = self.reversingController.currentReverseTime - GetTimeStep()
		else
			self.reversingController.reversing = false
			self.reversingController.currentReverseTime = self.reversingController.reverseTime
			self.reversingController.currentWait = self.reversingController.waitTime
		end
		
	end
end




--[[

	calculate relative speed, if vehicle moving towards then stop / avoid. 

	if movng faster than gap between then stop, otherwise move proportionally to the distance between vehicles vs speed

]]

function AVF_AI_ACS:getRelativeSpeed(shape,hitPos)
	local otherShapeBody = GetShapeBody(shape)
	local otherShapeBodyPos = GetBodyTransform(otherShapeBody).pos
	local otherShapeVelocity =  GetBodyVelocity(otherShapeBody)
	local vehicleBody = GetVehicleBody(self.id)
	local vehicleBodyPos = GetBodyTransform(vehicleBody).pos
	local vehicleVelocity = GetBodyVelocity(vehicleBody) 

	local toPoint = VecSub(vehicleBodyPos,otherShapeBodyPos)
	local movingTowards = false
	---VecSub(vehicleVelocity,otherShapeVelocity)
	-- DebugWatch("otherShapeVelocity",VecLength(otherShapeVelocity))
	-- DebugWatch("vehicleVelocity",VecLength(vehicleVelocity))

	local adjustmentValue = 0 

	--[[
		if crash likely then set adjustment to -1 (GTFO mode)
		elseif speed greater than safe range then force slow down
			else adjust speed to maintain safe distance 
		else set to higher speed to get closer for overtaking
	]]
	local minDist = self.controller.minDist
	if(VecLength(vehicleVelocity) >0) then 
		 minDist = minDist / math.log(VecLength(vehicleVelocity))
	end

	
	if(VecDot(toPoint,otherShapeVelocity)>0) then 
		adjustmentValue = -1
		if(DEBUG_SAE) then 
			DebugWatch("slowing for safety",1)
		end
	elseif(VecLength(otherShapeVelocity)<VecLength(vehicleVelocity)) then 
		local relativeSpeed = VecLength(vehicleVelocity)-VecLength(otherShapeVelocity) 
		local relativeDistance = VecLength(VecSub(vehicleBodyPos,hitPos))
			--- set mindist to be math.log of relative speed, relative speed is negative if they are faster
			--- dist coef 
		if(relativeSpeed ~=0) then 
			 minDist =  math.log((relativeSpeed))*math.sign(relativeSpeed)
		end
		local distCoef = relativeDistance-minDist

		if((relativeSpeed) > distCoef) then
			adjustmentValue = -(distCoef/(relativeSpeed*2))
		else
			adjustmentValue = (relativeSpeed/distCoef)--(0.2) + relativeSpeed/(relativeDistance)--*self.controller.tenacity)
			-- adjustmentValue=1
		end
		
	else
		adjustmentValue=2
	end
	if(DEBUG_SAE) then
		DebugWatch("minDist",minDist)
		DebugWatch("adjusting",adjustmentValue)
	end
	return adjustmentValue

end

function AVF_AI_ACS:obstacleAvoidance()
	local scanResults = {centre=nil,left =nil,sideL =nil,sideR =nil,right = nil}
	local scanShapes = {centre=nil,left =nil,sideL =nil,sideR =nil,right = nil}
	local scanhitPos = {centre=nil,left =nil,sideL =nil,sideR =nil,right = nil}
	local scanDists = {centre=0,left =0, sideL =0 , sideR =0, right = 0}
	local vehicleTransform = GetVehicleTransform(self.id)

	local front = self.bodyYSize/4 
	local side = self.bodyXSize/4
	local height = self.bodyZSize /6
	-- DebugWatch("height",self.bodyZSize)
	-- DebugWatch("width",self.bodyXSize)
	-- DebugWatch("length",self.bodyYSize)
	vehicleTransform.pos = TransformToParentPoint(vehicleTransform,Vec(0,height/4	,-front/4))
	local testScanRot = nil
	local fwdPos = nil
	local direction = nil
	local scanStartPos = TransformToParentPoint(vehicleTransform,Vec(0,0,0))
	local scanEndPos = TransformToParentPoint(vehicleTransform,Vec(0,0,0))

	local scanLength = 2+ self.scanning.maxScanLength*((VecLength(GetBodyVelocity(GetVehicleBody(self.id))))/self.scanning.maxScanLength)

	for key,scan in pairs(self.scanning.positions) do 


		if(scan.direction == "centre") then 
			scanStartPos =VecCopy(vehicleTransform.pos)
		elseif(scan.direction =="left") then
			scanStartPos = TransformToParentPoint(vehicleTransform,Vec(side/6,0,front/8))
		elseif(scan.direction =="right") then
			scanStartPos = TransformToParentPoint(vehicleTransform,Vec(-side/6,0,front/8))
		elseif(scan.direction =="sideR") then
			scanStartPos = TransformToParentPoint(vehicleTransform,Vec(-side/5,0,front/4))
		elseif(scan.direction =="sideL") then
			scanStartPos = TransformToParentPoint(vehicleTransform,Vec(side/5,0,front/4))
		end

		scanEndPos = TransformToParentPoint(Transform(scanStartPos,vehicleTransform.rot),scan.startVec)
		testScanRot = QuatLookAt(scanEndPos,scanStartPos)

		fwdPos = TransformToParentPoint(Transform(scanStartPos,testScanRot),  
				Vec(0,0,-scanLength))---self.scanning.maxScanLength))
		direction = VecSub(scanStartPos,fwdPos)
		direction = VecNormalize(direction)
	    QueryRejectVehicle(self.id)
	    QueryRequire("dynamic large")

	    local hit,dist,normal, shape = QueryRaycast(scanStartPos, direction, scanLength)--self.scanning.maxScanLength)
	    scanResults[key] = hit
	    scanDists[key] = dist
	    scanShapes[key] = shape
	    scanhitPos[key]	= VecScale(direction,dist)
	    if(hit and DEBUGCARS) then

			 DrawLine(scanStartPos, VecAdd(scanStartPos, VecScale(direction, dist)), 1, 0, 0)
		elseif(DEBUGCARS) then
			DrawLine(scanStartPos, VecAdd(scanStartPos, VecScale(direction, dist)), 0, 1, 0)
		end
	end

	local turnBias = math.random()

	if(scanResults.centre ) then 
		-- DebugWatch("pre val:",self.controller.accelerationValue )
		self.controller.accelerationValue =self.controller.accelerationValue* (self:getRelativeSpeed(scanShapes.centre,scanhitPos.center))--/self.controller.tenacity)
		-- self.controller.accelerationValue = self.controller.accelerationValue    * self.controller.tenacity

		-- DebugWatch("post val:",self.controller.accelerationValue )
		-- DebugWatch("relative val:",relative )
		
	elseif(math.abs(self.controller.steeringValue) < self.controller.steeringThres and not scanResults.centre and  
				(scanResults.left or scanResults.right or scanResults.sideL or scanResults.sideR)	) then
		self.controller.accelerationValue = self.controller.accelerationValue    * 2

	end
	if(scanResults.left and scanResults.right) then 

		self.controller.accelerationValue = self.controller.accelerationValue    * 0.5

	elseif(math.abs(self.controller.steeringValue) < self.controller.steeringThres and scanResults.left) then

		self.controller.steeringValue = self.controller.steeringForce +(scanDists.left/(self.scanning.maxScanLength/2)/2)
	elseif(math.abs(self.controller.steeringValue) < self.controller.steeringThres and scanResults.right) then 

		self.controller.steeringValue = -self.controller.steeringForce - (scanDists.right/(self.scanning.maxScanLength/2)/2)
	

	--- handle sides 

	elseif(math.abs(self.controller.steeringValue) < self.controller.steeringThres and scanResults.sideL) then

		self.controller.steeringValue = self.controller.steeringForce +(scanDists.sideL/(self.scanning.maxScanLength/2)/4)

	elseif(math.abs(self.controller.steeringValue) < self.controller.steeringThres and scanResults.sideR) then

		
		self.controller.steeringValue = -self.controller.steeringForce - (scanDists.sideR/(self.scanning.maxScanLength/2)/4)

	elseif(math.abs(self.controller.steeringValue) < self.controller.steeringThres and scanResults.centre ) then 
		--- random moving vs best direction 

		 -- sign((Bx - Ax) * (Y - Ay) - (By - Ay) * (X - Ax))


		if turnBias <0.5 then
			self.controller.steeringValue = self.controller.steeringForce*2
		else
			self.controller.steeringValue = -self.controller.steeringForce*2
		end

	
	end
end


function AVF_AI_ACS:pid()
	
	--- perform computations
	local targetNode, crossTrackErrorValue = self:currentCrossTrackError()
	-- DebugWatch("cross track error: ",crossTrackErrorValue)
	local crossTrackErrorRate = self:calculateCrossTrackErrorRate(crossTrackErrorValue)
	-- DebugWatch("cross track error rate: ",(crossTrackErrorRate))
	local integralErrorValue = self:calculateSteadyStateError(crossTrackErrorValue)
	-- DebugWatch("cross track error rate: ",(crossTrackErrorRate))
	-- update values 
	self.pidState.lastCrossTrackError = crossTrackErrorValue
	self.pidState.lastPnt = targetNode
	-- calculate state 
	local output = (crossTrackErrorValue * self.pidState.pGain) + 
					(integralErrorValue * self.pidState.iGain) + 
					(crossTrackErrorRate * self.pidState.dGain)
	self.pidState.controllerValue = output
	-- DebugWatch("pid output: ",output)

	return output
end


function AVF_AI_ACS:currentCrossTrackError()
	local crossTrackErrorValue = 0
	local vehicleTransform = GetVehicleTransform(self.id)
	local targetNode = self.targetNode
	if(targetNode~=nil) then
		local pnt = targetNode
		crossTrackErrorValue,sign = self:crossTrackError(pnt,vehicleTransform)
	end	
	return targetNode, crossTrackErrorValue,sign
end

--- calculate distance to target direction and apply steering by force
--- fill in the gap here related to the distance ebtween the aprrelel lines of target nod3e to vehicle pos to solve it all
function AVF_AI_ACS:crossTrackError(pnt,vehicleTransform)


		
		vehicleTransform.pos[2] = pnt[2]
		
		local linePnt = vehicleTransform.pos
		local fwd = TransformToParentPoint(vehicleTransform, Vec(0,0,-100))
		local d = VecLength(VecScale( VecCross(
							VecSub(fwd,linePnt),VecSub(pnt,linePnt)),
										VecLength(VecNormalize(VecSub(fwd,linePnt)))))/1000
		pnt = VecSub(pnt,linePnt)
		fwd = VecSub(fwd,linePnt)
		linePnt = VecSub(linePnt,linePnt)
		local sign = (fwd[1]-linePnt[1])*(pnt[3]-linePnt[3])-(fwd[3]-linePnt[3])*(pnt[1]-linePnt[1])
		if(sign<0) then
			sign = -1
		elseif(sign>0) then
			sign = 1
		else
			sign = 0
		end


		return d*sign,sign

		-- Use the sign of the determinant of vectors (AB,AM), where M(X,Y) is the query point:	
		---position = sign((Bx - Ax) * (Y - Ay) - (By - Ay) * (X - Ax))

		---d=np.cross(p2-p1,p3-p1)/norm(p2-p1)

		-- local linePnt = vehizcleTransform.pos
		-- local lineDir = TransformToParentPoint(vehicleTransform, Vec(0,0,-1))
		-- lineDir = VecNormalize(VecSub(vehicleTransform.pos,fwd1	))

		-- local v = (VecSub(pnt,linePnt))
		-- local d = VecDot(v,lineDir)
		-- local out = VecAdd(linePnt,VecScale(lineDir,d))
		-- DebugWatch("point pos : ",pnt)
		-- DebugWatch("output pos : ",out)

		-- DebugWatch("output value: ",VecSub(out,pnt))







		-- local vehicleTransform = GetVehicleTransform(self.id)
		-- vehicleTransform.pos[2] = targetNode:getPos()[2]
		-- local fwd1 = TransformToParentPoint(vehicleTransform, Vec(0,0,-1))
		-- local norm = VecNormalize(VecSub(vehicleTransform.pos,fwd1	))
		-- local vBase =  VecSub(targetNode:getPos(),vehicleTransform.pos)
		-- local lineDir = VecSub(targetNode:getPos(),vehicleTransform.pos)
		-- local v1 = VecDot(vBase,norm)
		-- local pntDist = VecAdd(,VecScale(norm,v1))
		-- DebugWatch("distance to point: ",VecLength(pntDist))
		-- DebugWatch("V1 VAL: ",v1)
		-- local v = VecLength(VecSub(vehicleTransform.pos,fwd1))
		-- local d = VecLength(VecScale(VecSub(targetNode:getPos(),vehicleTransform.pos),v))
		-- -- DebugWatch("vector : ",v)
		-- DebugWatch("delta : ", d/10)
		-- DebugWatch("value from origin",VecSub(vehicleTransform.pos,fwd1))

end

function AVF_AI_ACS:calculateCrossTrackErrorRate(crossTrackErrorValue)
	local verifyCrossCheckErrorVal = 0
	local vehicleTransform = GetVehicleTransform(self.id)
	
	local pnt = self.pidState.lastPnt
	if(pnt) then
		
		verifyCrossCheckErrorVal = self:crossTrackError(pnt,vehicleTransform)
		verifyCrossCheckErrorVal = self.pidState.lastCrossTrackError - verifyCrossCheckErrorVal

	end	

	return verifyCrossCheckErrorVal
end


function AVF_AI_ACS:calculateSteadyStateError(crossTrackErrorValue)
	local index = self.pidState.integralIndex

	self.pidState.integralSum = self.pidState.integralSum - self.pidState.integralData[index]
	self.pidState.integralSum = self.pidState.integralSum + crossTrackErrorValue
	self.pidState.integralData[index] = crossTrackErrorValue

	self.pidState.integralIndex = (self.pidState.integralIndex%#self.pidState.integralData) +1

	return self.pidState.integralSum	
end

function AVF_AI_ACS:accelerationError()
	local accelerationErrorValue = 0
	local vehicleTransform = GetVehicleTransform(self.id)
	local targetNode = self.targetNode
	if(targetNode) then
		local pnt = targetNode
		vehicleTransform.pos[2] = pnt[2]
		local linePnt = vehicleTransform.pos
		local lineDir = TransformToParentPoint(vehicleTransform, Vec(0,0,-1))
		lineDir = VecNormalize(lineDir)	
		local v = (VecSub(pnt,linePnt))
		local d = VecDot(v,lineDir)

		local out = VecAdd(linePnt,VecScale(lineDir,d))
		-- DebugWatch("line distance: ",VecLength(VecSub(vehicleTransform.pos,out))/self.scanning.scanLength*self.scanning.scanDepths)
		
		--- random debugging, please ignore

		-- DebugWatch("d value: ",d)
		-- DebugWatch("out value: ",out)
		-- DebugWatch("error value: ",VecLength(VecSub(vehicleTransform.pos,out)))
		-- local fwd = VecNormalize(TransformToParentPoint(vehicleTransform, Vec(0,0,-1)))
		-- local relative = VecDot(VecNormalize(VecSub(pnt,linePnt)),fwd)
		-- DebugWatch("fwd",pnt)
		-- DebugWatch("direction : ",math.acos( relative))

		-- local forward_vec = TransformToParentPoint(vehicleTransform, Vec(0,0,-1))
		-- local is_forward = VecDot(forward_vec, VecSub(pnt, vehicleTransform.pos)) > 0
		-- DebugWatch("is forward",is_forward)
		-- DebugWatch("local point  forwar", TransformToLocalPoint(vehicleTransform, pnt)[3])


		return VecLength(VecSub(vehicleTransform.pos,out))
	end	
end


	-- thanks to  iaobardar for help on getting the vecdot to work
function AVF_AI_ACS:directionError()
	local vehicleTransform = GetVehicleTransform(self.id)
	local targetNode = self.targetNode
	if(targetNode) then
		local pnt = targetNode
		vehicleTransform.pos[2] = pnt[2]	
		-- local forward_vec = TransformToParentPoint(vehicleTransform, Vec(0,0,-1))
		-- local is_forward = VecDot(forward_vec, VecSub(pnt, vehicleTransform.pos)) > 0
		is_forward = TransformToLocalPoint(vehicleTransform, pnt)[3] <1 --(used to mbe -1, but wantto givebit more relaxation)
		-- DebugWatch("ai: "..self.id.." is forwardoutput",TransformToLocalPoint(vehicleTransform, pnt)[3])
		
		if(is_forward) then
			return 1
		else
			return -clamp(TransformToLocalPoint(vehicleTransform, pnt)[3]/4,0.1,1) --1
		end
	else
		return 0 
	end
			
			-- DebugWatch("local point  forwar", TransformToLocalPoint(vehicleTransform, pnt)[3])

end



function AVF_AI_ACS:controllerAugmentation()
	local velocity =  VecLength(GetBodyVelocity(GetVehicleBody(self.id)))

	if(math.abs(self.controller.accelerationValue)>1.5 and velocity>self.cornerCoef and self.controller.accelerationValue*0.8 ~=0
		and math.abs(self.controller.steeringValue) >= self.controller.speedSteeringThres) then
		
		self.controller.accelerationValue = (math.log(self.controller.accelerationValue*0.4)) - math.abs(self.controller.steeringValue*self.steeringCoef)
	else 
		self.controller.accelerationValue  = 1
	end
	
	
end


function AVF_AI_ACS:applyError()
	local errorCoef = self.controller.errorCoef--0.1
	local errorVal = math.random(-errorCoef,errorCoef) / 100
	self.steeringCoef = self.steeringCoef + errorVal
end

function AVF_AI_ACS:corneringError()
	local vehicleTransform = GetVehicleTransform(self.id)
	local targetNode = self.targetNode
	if(targetNode) then
		local pnt = targetNode
		vehicleTransform.pos[2] = pnt[2]	
		-- local forward_vec = TransformToParentPoint(vehicleTransform, Vec(0,0,-1))
		-- local is_forward = VecDot(forward_vec, VecSub(pnt, vehicleTransform.pos)) > 0
		local forward = TransformToLocalPoint(vehicleTransform, pnt)[3] 
		local angleToTarget = TransformToLocalPoint(vehicleTransform, pnt)[1]
		local angleError =  angleToTarget/forward
		if(DEBUGCONTROLLERS) then
			DebugWatch("angle error",angleError)
		end
		
		angleError = 1- clamp(math.abs(angleError), 0, 0.5)
		return angleError

		-- if(forward>1) then
		-- 	return 1
		-- else
		-- 	return -1
		-- end
	else
		return 0 
	end
			
			-- DebugWatch("local point  forwar", TransformToLocalPoint(vehicleTransform, pnt)[3])

end

 

function AVF_AI_ACS:vehicleController()
	DriveVehicle(self.id, 0.05+self.controller.accelerationValue,
							self.controller.steeringValue,
							 self.controller.handbrake)
	self.controller.handbrake = false
end
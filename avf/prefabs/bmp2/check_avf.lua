

--[[


A simple method that will check if AVF is running and inform the user if they are in an AVF vehicle without AVF active. 


]]
check_AVF = {}


function check_AVF:init(vehicle)
	self.maxTime = 1
	self.timer = 0
	self.vehicle = vehicle
	self.enabled = true
	self.hideKey = {[0]="ctrl",[1]="c"}


end

function check_AVF:tick()
	if(self.timer<self.maxTime) then
		self.timer = self.timer + GetTimeStep()

	end
end

function check_AVF:draw()
	if(self.enabled and GetPlayerVehicle() == self.vehicle and  not GetBool("level.avf.enabled")) then
		self:drawMessage()
		if((InputPressed(self.hideKey[0])or InputDown(self.hideKey[0])) and
			(InputPressed(self.hideKey[1])or InputDown(self.hideKey[1]))) then 
			self.enabled = false
		end
	elseif(GetBool("level.avf.enabled")) then 
		self.enabled = false
	end
	
end

function check_AVF:drawMessage()

		message = {
				[1] = "Armed Vehicle Framework (AVF)",
				[2] = "AVF not detected,",
				[3] = "Please ensure you have AVF downloaded",
				[4] = "from the steam workshop",
				[5] = "and enabled in the mod manager",
				[6] = "Otherwise this tank won't shoot",
				[7] = "press ctrl+c to hide",


		}
		header = "Armed Vehicle Framework (AVF)"
		message2 = [[AVF not detected, Please ensure you have AVF downloaded from the steam workshop and enabled it in the mod manager. 
		Otherwise this tank won't shoot or function properly

		press ctrl+c to hide this message]]

		UiPush()
		UiAlign("top left")
		local w = 350
		local h = #message*22 + 100
		UiTranslate(UiWidth()-w-20, UiHeight()-h-20 - 200) -- because I don't know how big the official vehicle UI will be
		UiColor(0,0,0,0.5)
		UiImageBox("ui/common/box-solid-6.png", w, h, 6, 6)
		UiTranslate(w, 32)
		UiColor(1,1,1)
		UiTranslate(-w, 0)

		UiFont("bold.ttf", 22)
		UiAlign("left")
		UiText(header)

		UiTranslate(0, 32)
		UiWordWrap(w)
		UiText(message2)
		UiPop()
end
local module = {}
module.__index = module

local controllerService = game:GetService("UserInputService")
local contextaction = game:GetService("ContextActionService")
local mouse = game:GetService("Players").LocalPlayer:GetMouse()

local eventType = {
	[Enum.KeyCode.ButtonA] = "Click",
	[Enum.KeyCode.ButtonB] = "Back",
	[Enum.UserInputType.Touch] = "Click",
	[Enum.UserInputType.MouseButton1] = "Click",
	[Enum.UserInputType.MouseButton2] = "RightClick",
	[Enum.UserInputType.MouseButton3] = "MiddleClick",
}

module.eventList = {}

function module.modifyEvent(inputName, inputClass : string)
	eventType[inputName] = inputClass
end

function module:getEvent(eventName : string)
	local eventInstance = self.eventList[eventName] or Instance.new("BindableEvent")
	self.eventList[eventName] = eventInstance
	return eventInstance
end

function module:startListening(eventName : string,functionality)
	return self:getEvent(eventName).Event:Connet(functionality)
end

function module.connected(inputObject,inputType)
	if inputObject == Enum.UserInputType.Touch and not game:GetService("UserInputService").TouchEnabled then
		return
	end
	if inputObject == Enum.UserInputType.Gamepad1 and not game:GetService("UserInputService").GamepadEnabled then
		return
	end
	local eventName = eventType[inputType or inputObject]
	if eventName then
		module:getEvent(eventName):Fire()
	end
end

mouse.Button1Up:Connect(function() 
	module.connected(Enum.UserInputType.MouseButton1)
end)
mouse.Button2Up:Connect(function() 
	module.connected(Enum.UserInputType.MouseButton2)
end)
controllerService.TouchEnded:Connect(function()
	module.connected(Enum.UserInputType.Touch)
end)
controllerService.InputBegan:Connect(function(object) 
	module.connected(object.UserInputType,object.UserInputType == Enum.UserInputType.Gamepad1 and object.KeyCode)
end)

module = setmetatable({},module)
return module

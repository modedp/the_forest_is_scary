
local module = {}
local tweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
local debris = game:GetService("Debris")
local players = game:GetService("Players")
local starterPlayer = game:GetService("StarterPlayer")
local localPlayer = players.LocalPlayer
local plrGui = localPlayer.PlayerGui
local mainGui = plrGui:FindFirstChild("TextEffect") or Instance.new("ScreenGui",plrGui)
local controller = require(script.Parent.controllerEffect)
local sounds = require(script.Parent.soundEffect)
local Reading = Instance.new("BoolValue",game:GetService("StarterPlayer"))
Reading.Name = "ReadingTextbox"
mainGui.Name = "TextEffect"
module.__index = module
module.currentPopupText = ""
module.readingCurrentLine = 0
module.linesToRead = 0
module.runningNow = false

function module:resetInstance(typeOf,parent,properties)
	local newInstance = parent and parent:FindFirstChild(properties["Name"]) or Instance.new(typeOf,parent)
	for index,value in pairs(properties) do
		newInstance[index] = value
	end
	return newInstance
end

function module:disablePlayer()
	localPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 0
	localPlayer.Character:WaitForChild("Humanoid").JumpPower = 0
end

function module:enablePlayer()
	localPlayer.Character:WaitForChild("Humanoid").WalkSpeed = starterPlayer.CharacterWalkSpeed
	localPlayer.Character:WaitForChild("Humanoid").JumpPower = starterPlayer.CharacterJumpPower
end

function module:getInstance(typeOf : string,renewal : boolean)
	if typeOf == "FrameHolder" then
		local frame = not renewal and mainGui:FindFirstChild("Frame") or self:resetInstance("Frame",mainGui,{
			Name = "Frame",
			Position = UDim2.fromScale(0.25,0.125),
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.fromRGB(0,0,0),
			Size = UDim2.fromScale(0.0,0.0),
			Rotation = -179.99,
			ClipsDescendants = true,
		})
		return frame
	elseif typeOf == "bottomText" then
		local scrollText = not renewal and self:getInstance("FrameHolder"):FindFirstChild("BottomText") or self:resetInstance("TextLabel",module:getInstance("FrameHolder"),{
			Name = "BottomText",
			Position = UDim2.fromScale(0.025,1.05),
			Size = UDim2.fromScale(0.95,0.9),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(255,255,255),
			FontFace = Font.fromName("Michroma"),
			TextScaled = true,
			TextXAlignment = "Left",
			TextYAlignment = "Top",
			Visible = false,
		})
		return scrollText
	elseif typeOf == "mainText" then
		local scrollText = not renewal and self:getInstance("FrameHolder"):FindFirstChild("MainText") or self:resetInstance("TextLabel",module:getInstance("FrameHolder"),{
			Name = "MainText",
			Position = UDim2.fromScale(0.025,0.05),
			Size = UDim2.fromScale(0.95,0.9),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(255,255,255),
			FontFace = Font.fromName("Michroma"),
			TextScaled = true,
			TextXAlignment = "Left",
			TextYAlignment = "Top",
		})
		return scrollText
	end
end

function module:resetObjects()
	self:getInstance("FrameHolder",true)
	self:getInstance("bottomText",true)
	self:getInstance("mainText",true)
end

function module:runNewPopup()
	local tweenInfo2 = TweenInfo.new(0.5,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out)
	local popupTween = tweenService:Create(self:getInstance("FrameHolder"),tweenInfo2,
		{Rotation = 0,Position = UDim2.fromScale(0.5,0.25),Size = UDim2.fromScale(0.45,0.25)})
	popupTween:Play()
	popupTween.Completed:Wait()
end

function module:undoPopup()
	local tweenInfo2 = TweenInfo.new(0.75,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out)
	local popupTween = tweenService:Create(self:getInstance("FrameHolder"),tweenInfo2,
		{Rotation = -179.99,Position = UDim2.fromScale(0.25,0.125),Size = UDim2.fromScale(0,0)})
	popupTween:Play()
	popupTween.Completed:Wait()
end

function module:getCurrentText()
	return module.currentPopupText
end

function module:getNextText()
	return string.split(self:getCurrentText(),"\n")[self.readingCurrentLine]
end

function module:getReadingLines(text : string)
	local countLines = #text:split("\n")
	self.linesToRead = countLines-1
	return self.linesToRead
end

function module:runNextText()
	local slideText = tweenService:Create(self:getInstance("mainText"),tweenInfo,
		{Position = UDim2.fromScale(0.025,-1.05)})
	local slideText2 = tweenService:Create(self:getInstance("bottomText"),tweenInfo,
		{Position = UDim2.fromScale(0.025,0.05)})
	self:getInstance("bottomText").Visible = true
	self:getInstance("bottomText").Text = self:getNextText()
	slideText:Play()
	slideText2:Play()
	slideText.Completed:Wait()
	self:getInstance("bottomText").Visible = false
	self:getInstance("mainText").Text = self:getInstance("bottomText").Text
	self:getInstance("bottomText").Text = self:getNextText() or ""
	self:getInstance("mainText").Position = UDim2.fromScale(0.025,0.05)
	self:getInstance("bottomText").Position = UDim2.fromScale(0.025,1.05)
end

function module:runText(text : string)
	if self.runningNow then return end
	game:GetService("StarterGui"):SetCore("ResetButtonCallback",false)
	Reading.Parent = localPlayer
	sounds:playSFX("Error")
	mainGui.Enabled = true
	self.runningNow = true
	self.readingCurrentLine = 1
	self.currentPopupText = text
	self:disablePlayer()
	self:resetObjects()
	self:getReadingLines(text)
	self:getInstance("mainText").Text = self:getNextText()
	self:runNewPopup()
	controller:getEvent("Click").Event:Wait()
	for i = 1, self.linesToRead do
		self.readingCurrentLine+=1
		self:runNextText()
		controller:getEvent("Click").Event:Wait()
	end
	self:undoPopup()
	self:enablePlayer()
	task.wait(5)
	self.runningNow = false
	Reading.Parent = starterPlayer
	mainGui.Enabled = false
	game:GetService("StarterGui"):SetCore("ResetButtonCallback",true)
end

module = setmetatable({},module)

return module


--[[Even More Barebones version of this Textbox script I made, I like making it more complicated for no reason :D ]]
--[[
local module = {}
local tweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
local debris = game:GetService("Debris")
local players = game:GetService("Players")
local starterPlayer = game:GetService("StarterPlayer")
local localPlayer = players.LocalPlayer
local plrGui = localPlayer.PlayerGui
local mainGui = plrGui:FindFirstChild("TextEffect") or Instance.new("ScreenGui",plrGui)
local controller = require(script.Parent:WaitForChild("controllerEffect"))
local sounds = require(script.Parent:WaitForChild("soundEffect"))
local Reading = Instance.new("BoolValue",game:GetService("StarterPlayer"))
Reading.Name = "ReadingTextbox"
mainGui.Name = "TextEffect"
module.__index = module
module.currentPopupText = ""
module.readingCurrentLine = 0
module.linesToRead = 0
module.runningNow = false
module.infoDefaults = {
	popupRatioSize = 0.25/3,
	popupOpen = {
		left = {
			Rotation = 0,Position = UDim2.fromScale(0.325,0.25)
		},
		middle = {
			Rotation = 0,Position = UDim2.fromScale(0.5,0.25)
		},
		right = {
			Rotation = 0,Position = UDim2.fromScale(0.675,0.25)
		},
	},
	popupClose = {
		left = {
			Rotation = -179.99,Position = UDim2.fromScale(0.075,0.125),Size = UDim2.fromScale(0,0)
		},
		middle = {
			Rotation = -179.99,Position = UDim2.fromScale(0.25,0.125),Size = UDim2.fromScale(0,0)
		},
		right = {
			Rotation = -179.99,Position = UDim2.fromScale(0.375,0.125),Size = UDim2.fromScale(0,0)
		},
	},
	sizeY = { --formula for y size: 0.125
		-- formula for y position: lines*((0.125/6)*2)
		[1] = 1/12, -- 0.166, 2/12 (0.1, 0.175)
		[2] = 2/12, -- 0.208, 2.5/12 0.229
		[3] = 3/12, -- 0.25, 3/12
		default = 0.25,
		[4] = 4/12, -- 0.292, 3.5/12, (0.3, 0.275)
		[5] = 5/12, --  0.33, 4/12
		[6] = 6/12, -- 0.375, 4.5/12, (0.5, 0.375)
		-- maximum is 6.
	},
}
module.readerSettings = {
	openingSequence = "middle",
	openingSize = "middle",
	linesMaximum = 1,
	inverseColor = false,
}

function module:resetInstance(typeOf,parent,properties)
	local newInstance = parent and parent:FindFirstChild(properties["Name"]) or Instance.new(typeOf,parent)
	for index,value in pairs(properties) do
		newInstance[index] = value
	end
	return newInstance
end

function module:disablePlayer()
	localPlayer.Character:WaitForChild("Humanoid").WalkSpeed = 0
	localPlayer.Character:WaitForChild("Humanoid").JumpPower = 0
	game:GetService("StarterGui"):SetCore("ResetButtonCallback",false)
end

function module:enablePlayer()
	localPlayer.Character:WaitForChild("Humanoid").WalkSpeed = starterPlayer.CharacterWalkSpeed
	localPlayer.Character:WaitForChild("Humanoid").JumpPower = starterPlayer.CharacterJumpPower
	game:GetService("StarterGui"):SetCore("ResetButtonCallback",true)
end

function module:getInstance(typeOf : string,renewal : boolean)
	if typeOf == "FrameHolder" then
		local frame = not renewal and mainGui:FindFirstChild("Frame") or self:resetInstance("Frame",mainGui,{
			Name = "Frame",
			Position = UDim2.fromScale(0.25,0.125),
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 0.5,
			BackgroundColor3 = Color3.fromRGB(0,0,0),
			Size = UDim2.fromScale(0.0,0.0),
			Rotation = -179.99,
			ClipsDescendants = true,
		})
		return frame
	elseif typeOf == "bottomText" then
		local scrollText = not renewal and self:getInstance("FrameHolder"):FindFirstChild("BottomText") or self:resetInstance("TextLabel",module:getInstance("FrameHolder"),{
			Name = "BottomText",
			Position = UDim2.fromScale(0.025,1.05),
			Size = UDim2.fromScale(0.95,0.9),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(255,255,255),
			FontFace = Font.fromName("Michroma"),
			TextScaled = true,
			TextXAlignment = "Left",
			TextYAlignment = "Top",
			Visible = false,
		})
		return scrollText
	elseif typeOf == "mainText" then
		local scrollText = not renewal and self:getInstance("FrameHolder"):FindFirstChild("MainText") or self:resetInstance("TextLabel",module:getInstance("FrameHolder"),{
			Name = "MainText",
			Position = UDim2.fromScale(0.025,0.05),
			Size = UDim2.fromScale(0.95,0.9),
			BackgroundTransparency = 1,
			TextColor3 = Color3.fromRGB(255,255,255),
			FontFace = Font.fromName("Michroma"),
			TextScaled = true,
			TextXAlignment = "Left",
			TextYAlignment = "Top",
		})
		return scrollText
	end
end

function module:resetObjects()
	self:getInstance("FrameHolder",true)
	self:getInstance("bottomText",true)
	self:getInstance("mainText",true)
end

function module:runNewPopup()
	local tweenInfo2 = TweenInfo.new(0.5,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out)
	local popupTween = tweenService:Create(self:getInstance("FrameHolder"),tweenInfo2,
		{Rotation = 0,Position = UDim2.fromScale(0.5,0.25),Size = UDim2.fromScale(0.45,0.25)})
	popupTween:Play()
	popupTween.Completed:Wait()
end

function module:undoPopup()
	local tweenInfo2 = TweenInfo.new(0.75,Enum.EasingStyle.Exponential,Enum.EasingDirection.Out)
	local popupTween = tweenService:Create(self:getInstance("FrameHolder"),tweenInfo2,
		{Rotation = -179.99,Position = UDim2.fromScale(0.25,0.125),Size = UDim2.fromScale(0,0)})
	popupTween:Play()
	popupTween.Completed:Wait()
end

function module:getCurrentText()
	return module.currentPopupText
end

function module:getNextText()
	return string.split(self:getCurrentText(),"\n")[self.readingCurrentLine]
end

function module:applyReaderSettings(heightMax: number, anchorPosition: string)
	self.readerSettings = {
		openingSequence = heightMax == 2 and "middle",
		openingSize = anchorPosition or "middle",
		linesMaximum = math.clamp(heightMax or 1,1,6),
	}
end

function module:getReadingLines(text : string)
	local countLines = math.ceil(#text:split("\n")/self.readerSettings.linesMaximum)
	self.linesToRead = countLines-1
	return self.linesToRead
end

function module:runNextText()
	local slideText = tweenService:Create(self:getInstance("mainText"),tweenInfo,
		{Position = UDim2.fromScale(0.025,-1.05)})
	local slideText2 = tweenService:Create(self:getInstance("bottomText"),tweenInfo,
		{Position = UDim2.fromScale(0.025,0.05)})
	self:getInstance("bottomText").Visible = true
	self:getInstance("bottomText").Text = self:getNextText()
	slideText:Play()
	slideText2:Play()
	slideText.Completed:Wait()
	self:getInstance("mainText").Text = self:getInstance("bottomText").Text
	self:getInstance("bottomText").Text = self:getNextText() or ""
	self:getInstance("mainText").Position = UDim2.fromScale(0.025,0.05)
	self:getInstance("bottomText").Position = UDim2.fromScale(0.025,1.05)
	self:getInstance("bottomText").Visible = false
end

function module:runText(text : string, ...)
	if self.runningNow then return end
	Reading.Parent = localPlayer
	sounds:playSFX("Error")
	mainGui.Enabled = true
	self.runningNow = true
	self.readingCurrentLine = 1
	self.currentPopupText = text
	self:disablePlayer()
	self:resetObjects()
	self:getReadingLines(text)
	self:getInstance("mainText").Text = self:getNextText()
	self:runNewPopup()
	controller:getEvent("Click").Event:Wait()
	for i = 1, self.linesToRead do
		self.readingCurrentLine+=self.readerSettings.linesMaximum
		self:runNextText()
		controller:getEvent("Click").Event:Wait()
	end
	self:undoPopup()
	self:enablePlayer()
	task.wait()
	self.runningNow = false
	Reading.Parent = starterPlayer
	mainGui.Enabled = false
end

module = setmetatable({},module)

return module
]]

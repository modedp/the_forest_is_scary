local module = {}
module.__index = module

local tween = game:GetService("TweenService")
local sounds = game:GetService("SoundService")

function module:fadeInSFX(soundName : string)
	sounds:FindFirstChild(soundName):Play()
	sounds:FindFirstChild(soundName).Volume -= 1
	local tweenOne = tween:Create(sounds:FindFirstChild(soundName),TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Volume = sounds:FindFirstChild(soundName).Volume+1})
	tweenOne:Play()
end

function module:playSFX(soundName : string)
	sounds:FindFirstChild(soundName):Play()
end

function module:fadeOutSFX(soundName : string)
	local tweenOne = tween:Create(sounds:FindFirstChild(soundName),TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Volume = sounds:FindFirstChild(soundName).Volume-1})
	tweenOne:Play()
	tweenOne.Completed:Connect(function() 
		sounds:FindFirstChild(soundName):Stop()
	end)
end

module = setmetatable({},module)
return module

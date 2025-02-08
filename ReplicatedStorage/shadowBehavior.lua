local module = {}
local players = game:GetService("Players")
local ws = game:GetService("Workspace")
local plr = players.LocalPlayer
if not plr or game:GetService("RunService"):IsServer() then
	return nil
end
module.__index = module

module.shadowVelocity = 1 -- studs per second 

function module:approachSymmetrical(shadow, object)
	local shadowVelocity = self.shadowVelocity
	
	shadow.CFrame = CFrame.new(shadow.Position,object.Position)
	
	local distance = shadow.CFrame.LookVector

	local newShadowPosition = Vector3.new(
		shadow.Position.X + distance.X * shadowVelocity, 
		shadow.Position.Y + distance.Y * shadowVelocity,
		shadow.Position.Z + distance.Z * shadowVelocity)
	
	local ray = Ray.new(shadow.Position, (newShadowPosition - shadow.Position).Unit * 2)
	local hitPart, hitPos = ws:FindPartOnRayWithIgnoreList(ray,{shadow.Parent,object,object.Parent:IsA("Model") and object.Parent})
	if not hitPart then
		shadow.Position = newShadowPosition
		return object
	end
end

function module:createShadow(object)
	task.spawn(function() 
		while true do
			self:approachSymmetrical(object, plr.Character:WaitForChild("HumanoidRootPart"))
			task.wait(0.05)
		end
	end)
end

return module

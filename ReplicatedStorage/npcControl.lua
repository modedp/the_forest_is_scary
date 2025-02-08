local npcs = game:GetService("Workspace"):WaitForChild("FakeNPC")
local plr = game:GetService("Players").LocalPlayer
local module = {}

module.__index = module

module.customAnimation = "rbxassetid://507770239"

function module:giveNPCAnimation(npc : Model)
	local humanoid = npc:WaitForChild("Humanoid")
	local animation = Instance.new("Animation",npc)
	animation.AnimationId = self.customAnimation
	
	local animationPlaying = humanoid:LoadAnimation(animation)
	animationPlaying:Play()
end

function module:checkMagnitudeToPlayer(npc : Model)
	local hRoot = plr.Character:WaitForChild("HumanoidRootPart")
	local modelRoot = npc:WaitForChild("HumanoidRootPart")
	
	return (hRoot.Position - modelRoot.Position).magnitude
end

function module:disappearNPC(npc : Model, transparencyValue : number)
	for _,basepart in pairs(npc:GetDescendants()) do
		if basepart:IsA("BasePart") then
			basepart.Transparency = transparencyValue
			basepart.CanCollide = false
		end
	end
end

function module:runNPCbehavior()
	task.spawn(function() 
		for _,NPC in pairs(npcs:GetChildren()) do
			if NPC:IsA("Model") then
				self:giveNPCAnimation(NPC)
			end
		end
		while task.wait() do
			for _,NPC in pairs(npcs:GetChildren()) do
				if NPC:IsA("Model") then
					self:disappearNPC(NPC,1.25-(self:checkMagnitudeToPlayer(NPC)*0.01))
				end
			end
		end
	end)
end

module = setmetatable({},module)

return module

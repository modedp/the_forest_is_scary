--LOCALSCRIPT STARTERPLAYER
local players = game:GetService("Players")
local badge = game:GetService("BadgeService")
local replicated = game:GetService("ReplicatedStorage")
local plr = players.LocalPlayer
local gui = plr.PlayerGui:WaitForChild("HintGUI")
local replicatedMain = replicated:WaitForChild("Main")
local event = game:GetService("ReplicatedStorage"):WaitForChild("It")
local text1 = gui:WaitForChild("LookUp")
local statue = game:GetService("Workspace"):WaitForChild("Statue"):WaitForChild("Statue")
local buttonstatue = statue:WaitForChild("Button"):WaitForChild("Clicker")
local fountain = game:GetService("Workspace"):WaitForChild("Fountain")
local effects = game:GetService("Workspace"):WaitForChild("TextEffect")
local barriers = game:GetService("Workspace"):WaitForChild("Barrier")
local warps = game:GetService("Workspace"):WaitForChild("Warp")
local textboxes = game:GetService("Workspace").TextBox
local tween = game:GetService("TweenService")
local textEffects = require(replicatedMain:WaitForChild("textEffect"))
local soundEffects = require(replicatedMain:WaitForChild("soundEffect"))
local npcController = require(replicatedMain:WaitForChild("npcControl"))
local shadowBehavior = require(replicatedMain:WaitForChild("shadowBehavior"))
local buttonDebounce = false
local chatboxDebounce = false
local badgeRequest = false
local hints = {}

function textQuickToggle(text,deb)
	text.Visible = true
	task.wait()
	task.wait(deb)
	task.wait()
	text.Visible = false
	task.wait()
	task.wait(deb)
	text.Visible = true
	task.wait()
	task.wait(deb)
	text.Visible = false
	task.wait()
	text.Visible = true
	task.wait()
	text.Visible = false
end

function crashGame()
	if game:GetService("RunService"):IsStudio() then
		return print("Wont crash yourself...")
	end
	while true do
		Instance.new("Frame",Instance.new("ScreenGui",plr.PlayerGui))
	end
end

function runHint(textLabel, text)
	textLabel = textLabel or text1
	soundEffects:playSFX("Shush")
	textLabel.Text = text
	if not table.find(hints,text) then
		table.insert(hints,text)
		event:FireServer(text)
	end 
	textQuickToggle(textLabel,0.1)
	task.wait()
	textQuickToggle(textLabel)
end

function buttonRunner()
	if buttonDebounce then return end
	buttonDebounce = true
	if table.find(hints,"MUST NOT SEEK") and table.find(hints,"DESTROY IT") and badge:UserHasBadgeAsync(plr.UserId,2121889816041781) then
		local colorTween = tween:Create(buttonstatue,TweenInfo.new(0.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Color = Color3.fromRGB(0,255,0)})
		colorTween:Play()
		buttonstatue.Movement:Play()
		barriers.WallFountain.CanCollide = false
		runHint(text1,"MUST NOT SEEK")
		return
	end
	runHint(text1,"UNWORTHY")
	buttonDebounce = false
end

function isBoundingInPlayer(part : BasePart)
	local character = plr.Character
	local bounding = false
	for _,bp in pairs(character:GetChildren()) do
		if table.find(game:GetService("Workspace"):GetPartsInPart(part,OverlapParams.new()),bp) then
			bounding = true
			break
		end
	end
	return bounding
end

function shadowWarp(part : BasePart)
	local lplr = players:GetPlayerFromCharacter(part and part.Parent)
	if (not lplr or plr ~= lplr) then
		return
	end
	lplr.Character:MoveTo(Vector3.new(-329.5, -42, 565.5))
	game:GetService("StarterGui"):SetCore("ResetButtonCallback",false)
	soundEffects:playSFX("Screech")
	soundEffects:fadeInSFX("Jumpscare")
	soundEffects:fadeInSFX("Wind")
	task.wait(1)
	shadowBehavior:createShadow(game:GetService("Workspace"):WaitForChild("FloatingShadow"):WaitForChild("Part"))
	game:GetService("Workspace"):WaitForChild("FloatingShadow"):WaitForChild("Part").Touched:Connect(crashGame)
end

function runChatbox(text : string)
	if chatboxDebounce or plr.Character:FindFirstChild("Crouching") then return end
	chatboxDebounce = true
	textEffects:runText(text)
	task.wait(1.5)
	chatboxDebounce = false
end

function chatCommands(txt)
	local command = false
	if txt:lower() == "\119\104\101\114\101" then
		return runHint(text1,"\67\76\79\83\69\83\84 \84\79 \77\69")
	end
	if txt:lower() == "\115\116\97\108\107\105\110\103" then
		return runHint(text1,"\76\79\79\75 \85\80")
	end
	if string.find(txt:lower(), "the eye is") then
		return runHint(text1,"NO, I MUST NOT")
	end
	if string.find(txt:lower(), "\122\101\110\117\117\120") then
		return runHint(text1,"HE IS GONE")
	end
	if string.find(txt:lower(), "moded") then
		return runHint(text1,"HE IS GONE")
	end
	if string.find(txt:lower(), "vchillq") then
		return runHint(text1,"CHEATER")
	end
	if string.find(txt:lower(), "core") then
		return runHint(text1,"DESTROY IT")
	end
	if (txt:lower() == "truth") then
		return runHint(text1,"MUST NOT SEEK")
	end
	if (txt:lower() == "is this real?") then
		return runHint(text1,"SEEING IS BELIEVING")
	end
	if (txt:lower() == "give me a hint") then
		return runHint(text1,"WHAT LIES AT THE CENTER?")
	end
	if (txt:lower() == "give me another hint") then
		return runHint(text1,"WHAT LIES AT THE PEAK?")
	end
	if (txt:lower() == "i do") and isBoundingInPlayer(game:GetService("Workspace").Areas.PeakMountain) then
		game:GetService("Workspace").Barrier.WallShadow.CanCollide = false
		return runHint(text1,"FIND THEM")
	end
end

local runEffect = false

function runWithinBoundingParameters(partBounded,partBounding,functionality)
	if runEffect then return end
	runEffect = true
	while table.find(game:GetService("Workspace"):GetPartsInPart(partBounded,OverlapParams.new()),partBounding) do
		functionality()
		task.wait()
	end
	runEffect = false
end

fountain:WaitForChild("EffectRadius").Touched:Connect(function(part) 
	local lplr = players:GetPlayerFromCharacter(part and part.Parent)
	if runEffect or (not lplr or plr ~= lplr) then
		return
	end
	soundEffects:fadeInSFX("Wind")
	runWithinBoundingParameters(fountain:WaitForChild("EffectRadius"),part,
		function()
			runHint(text1,math.random(1,2)==1 and "GET ME OUT" or "IT HURTS")
		end
	)
	soundEffects:fadeOutSFX("Wind")
end)

effects:WaitForChild("TurnBack").Touched:Connect(function(part) 
	local lplr = players:GetPlayerFromCharacter(part and part.Parent)
	if runEffect or (not lplr or plr ~= lplr) then
		return
	end
	runWithinBoundingParameters(effects:WaitForChild("TurnBack"),part,
		function()
			runHint(text1,"	")
		end
	)
end)

effects:WaitForChild("NotReal").Touched:Connect(function(part) 
	local lplr = players:GetPlayerFromCharacter(part and part.Parent)
	if runEffect or (not lplr or plr ~= lplr) then
		return
	end
	runWithinBoundingParameters(effects:WaitForChild("NotReal"),part,
		function()
			runHint(text1,"ITS NOT REAL")
		end
	)
end)

textboxes.FakeWall.Touched:Connect(function(part)
	local lplr = players:GetPlayerFromCharacter(part and part.Parent)
	if lplr ~= plr then
		return
	end
	runChatbox("YOU GET A BAD FEELING FROM THIS WALL.\nBEST TO JUST FORGET ABOUT IT.")
	if textboxes.FakeWall.CanCollide == true and (not badgeRequest and badge:UserHasBadgeAsync(plr.UserId,2121889816041781) and badge:UserHasBadgeAsync(plr.UserId,3480783045025516)) then
		textboxes.FakeWall.CanCollide = false
	end
	badgeRequest = true
	task.wait(10)
	badgeRequest = false
end)


textboxes.VentureWall.Touched:Connect(function(part)
	local lplr = players:GetPlayerFromCharacter(part and part.Parent)
	if lplr ~= plr then
		return
	end
	runChatbox("THE FOREST IS TOO DARK TO SEE.\nWITHOUT LIGHT, THERE WONT BE\nANY USE GOING FURTHER.")
	if part.Parent:FindFirstChild("Flashlight") and textboxes.VentureWall.CanCollide == true and (not badgeRequest and badge:UserHasBadgeAsync(plr.UserId,2121889816041781) and badge:UserHasBadgeAsync(plr.UserId,3480783045025516) and badge:UserHasBadgeAsync(plr.UserId,1024257738162747)) then
		--textboxes.VentureWall.CanCollide = false
	end
	badgeRequest = true
	task.wait(10)
	badgeRequest = false
end)

fountain:WaitForChild("Death").Touched:Connect(crashGame)

buttonstatue.ClickDetector.MouseClick:Connect(buttonRunner)

plr.Chatted:Connect(chatCommands)

npcController:runNPCbehavior()

warps.Shadow.Touched:Connect(shadowWarp)

replicated:WaitForChild("ReceiveHint").OnClientEvent:Connect(runHint)

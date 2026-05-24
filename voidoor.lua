--// <-- 🟪 VOIDOOR SCRIPTHUB 🟪 -->
--// FULL REBUILD V3
--// Modern Purple Transparent UI

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

--// CHARACTER

local function getChar()
	return player.Character or player.CharacterAdded:Wait()
end

local function getHum()
	return getChar():FindFirstChildOfClass("Humanoid")
end

local function getRoot()
	return getChar():FindFirstChild("HumanoidRootPart")
end

--// COLORS

local COLORS = {
	bg = Color3.fromRGB(16,16,22),
	top = Color3.fromRGB(22,22,30),
	card = Color3.fromRGB(30,30,42),
	accent = Color3.fromRGB(150,95,255),
	text = Color3.fromRGB(255,255,255),
	sub = Color3.fromRGB(180,180,210),
	on = Color3.fromRGB(160,100,255),
	off = Color3.fromRGB(60,60,75),
}

--// VARIABLES

local fly = false
local noclip = false
local infJump = false
local clickTP = false
local aimlock = false
local aiming = false
local spinbot = false
local bhop = false
local tracersEnabled = false
local autoSprint = false

local flySpeed = 75
local currentWalkspeed = 16

local tracers = {}
local espObjects = {}

--// GUI

local gui = Instance.new("ScreenGui")
gui.Name = "VOIDOOR_UI"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0,760,0,640)
main.Position = UDim2.new(0.5,-380,0.5,-320)
main.BackgroundColor3 = COLORS.bg
main.BackgroundTransparency = 0.08
main.BorderSizePixel = 0
main.Active = true

Instance.new("UICorner",main).CornerRadius = UDim.new(0,20)

local stroke = Instance.new("UIStroke")
stroke.Parent = main
stroke.Color = COLORS.accent
stroke.Transparency = 0.4
stroke.Thickness = 1.2

local gradient = Instance.new("UIGradient")
gradient.Parent = main
gradient.Rotation = 90
gradient.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0,Color3.fromRGB(40,30,70)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(16,16,22))
}

--// TOPBAR

local top = Instance.new("Frame")
top.Parent = main
top.Size = UDim2.new(1,0,0,56)
top.BackgroundColor3 = COLORS.top
top.BackgroundTransparency = 0.1
top.BorderSizePixel = 0

Instance.new("UICorner",top).CornerRadius = UDim.new(0,20)

local fix = Instance.new("Frame")
fix.Parent = top
fix.Position = UDim2.new(0,0,1,-20)
fix.Size = UDim2.new(1,0,0,20)
fix.BackgroundColor3 = COLORS.top
fix.BorderSizePixel = 0

local title = Instance.new("TextLabel")
title.Parent = top
title.BackgroundTransparency = 1
title.Position = UDim2.new(0,18,0,0)
title.Size = UDim2.new(1,-100,1,0)
title.Text = "<-- 🟪 VOIDOOR SCRIPTHUB 🟪 -->"
title.Font = Enum.Font.GothamBold
title.TextColor3 = COLORS.text
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton")
close.Parent = top
close.Size = UDim2.new(0,36,0,36)
close.Position = UDim2.new(1,-46,0.5,-18)
close.BackgroundColor3 = COLORS.accent
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextColor3 = Color3.new(1,1,1)
close.TextSize = 14
close.BorderSizePixel = 0

Instance.new("UICorner",close).CornerRadius = UDim.new(1,0)

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

--// DRAGGING

local dragging = false
local dragStart
local startPos

top.InputBegan:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

UIS.InputChanged:Connect(function(input)

	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then

		local delta = input.Position - dragStart

		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

--// TAB BAR

local tabScroll = Instance.new("ScrollingFrame")
tabScroll.Parent = main
tabScroll.Position = UDim2.new(0,14,0,74)
tabScroll.Size = UDim2.new(1,-28,0,46)
tabScroll.CanvasSize = UDim2.new(0,1200,0,0)
tabScroll.BackgroundTransparency = 1
tabScroll.ScrollBarThickness = 0
tabScroll.BorderSizePixel = 0
tabScroll.ScrollingDirection = Enum.ScrollingDirection.X

local tabLayout = Instance.new("UIListLayout")
tabLayout.Parent = tabScroll
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0,8)

--// PAGES

local pages = {}

local function createPage(name)

	local page = Instance.new("ScrollingFrame")
	page.Parent = main
	page.Position = UDim2.new(0,14,0,132)
	page.Size = UDim2.new(1,-28,1,-146)
	page.BackgroundTransparency = 1
	page.ScrollBarThickness = 2
	page.BorderSizePixel = 0
	page.Visible = false
	page.CanvasSize = UDim2.new(0,0,0,3200)

	local layout = Instance.new("UIListLayout")
	layout.Parent = page
	layout.Padding = UDim.new(0,10)

	pages[name] = page

	return page
end

local function switchPage(name)

	for n,p in pairs(pages) do
		p.Visible = n == name
	end
end

local function createTab(name)

	local button = Instance.new("TextButton")
	button.Parent = tabScroll
	button.Size = UDim2.new(0,145,1,0)
	button.BackgroundColor3 = COLORS.card
	button.BackgroundTransparency = 0.12
	button.Text = name
	button.TextColor3 = COLORS.text
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 14
	button.BorderSizePixel = 0

	Instance.new("UICorner",button).CornerRadius = UDim.new(1,0)

	button.MouseButton1Click:Connect(function()

		switchPage(name)

		for _,v in ipairs(tabScroll:GetChildren()) do

			if v:IsA("TextButton") then

				TweenService:Create(v,TweenInfo.new(0.15),{
					BackgroundColor3 = COLORS.card
				}):Play()
			end
		end

		TweenService:Create(button,TweenInfo.new(0.15),{
			BackgroundColor3 = COLORS.accent
		}):Play()
	end)
end

--// PAGES

local movementPage = createPage("Movement")
local combatPage = createPage("Combat")
local visualsPage = createPage("Visuals")
local teleportPage = createPage("Players / Teleports")
local funPage = createPage("Fun")
local utilityPage = createPage("Utility")
local settingsPage = createPage("Settings")

--// TABS

createTab("Movement")
createTab("Combat")
createTab("Visuals")
createTab("Players / Teleports")
createTab("Fun")
createTab("Utility")
createTab("Settings")

switchPage("Movement")

--// WIDGETS

local function createCard(parent,height)

	local card = Instance.new("Frame")
	card.Parent = parent
	card.Size = UDim2.new(1,0,0,height or 62)
	card.BackgroundColor3 = COLORS.card
	card.BackgroundTransparency = 0.18
	card.BorderSizePixel = 0

	Instance.new("UICorner",card).CornerRadius = UDim.new(0,16)

	return card
end

local function createButton(parent,text,callback)

	local card = createCard(parent)

	local button = Instance.new("TextButton")
	button.Parent = card
	button.Size = UDim2.new(1,0,1,0)
	button.BackgroundTransparency = 1
	button.Text = text
	button.TextColor3 = COLORS.text
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 15

	button.MouseButton1Click:Connect(callback)
end

local function createToggle(parent,text,callback)

	local card = createCard(parent)

	local label = Instance.new("TextLabel")
	label.Parent = card
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0,18,0,0)
	label.Size = UDim2.new(1,-90,1,0)
	label.Text = text
	label.TextColor3 = COLORS.text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 15
	label.TextXAlignment = Enum.TextXAlignment.Left

	local toggle = Instance.new("TextButton")
	toggle.Parent = card
	toggle.Size = UDim2.new(0,56,0,28)
	toggle.Position = UDim2.new(1,-74,0.5,-14)
	toggle.BackgroundColor3 = COLORS.off
	toggle.Text = ""
	toggle.BorderSizePixel = 0

	Instance.new("UICorner",toggle).CornerRadius = UDim.new(1,0)

	local knob = Instance.new("Frame")
	knob.Parent = toggle
	knob.Size = UDim2.new(0,24,0,24)
	knob.Position = UDim2.new(0,2,0.5,-12)
	knob.BackgroundColor3 = Color3.new(1,1,1)
	knob.BorderSizePixel = 0

	Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)

	local enabled = false

	toggle.MouseButton1Click:Connect(function()

		enabled = not enabled

		if enabled then

			TweenService:Create(toggle,TweenInfo.new(0.15),{
				BackgroundColor3 = COLORS.on
			}):Play()

			knob:TweenPosition(
				UDim2.new(1,-26,0.5,-12),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.15,
				true
			)
		else

			TweenService:Create(toggle,TweenInfo.new(0.15),{
				BackgroundColor3 = COLORS.off
			}):Play()

			knob:TweenPosition(
				UDim2.new(0,2,0.5,-12),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.15,
				true
			)
		end

		callback(enabled)
	end)
end

local function createSlider(parent,text,min,max,default,callback)

	local card = createCard(parent,78)

	local label = Instance.new("TextLabel")
	label.Parent = card
	label.BackgroundTransparency = 1
	label.Position = UDim2.new(0,18,0,6)
	label.Size = UDim2.new(1,-20,0,20)
	label.Text = text..": "..default
	label.TextColor3 = COLORS.text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 15
	label.TextXAlignment = Enum.TextXAlignment.Left

	local bar = Instance.new("Frame")
	bar.Parent = card
	bar.Position = UDim2.new(0,18,0,48)
	bar.Size = UDim2.new(1,-36,0,8)
	bar.BackgroundColor3 = COLORS.off
	bar.BorderSizePixel = 0

	Instance.new("UICorner",bar).CornerRadius = UDim.new(1,0)

	local fill = Instance.new("Frame")
	fill.Parent = bar
	fill.Size = UDim2.new((default-min)/(max-min),0,1,0)
	fill.BackgroundColor3 = COLORS.accent
	fill.BorderSizePixel = 0

	Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)

	local draggingSlider = false

	local function update(input)

		local percent = math.clamp(
			(input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
			0,
			1
		)

		fill.Size = UDim2.new(percent,0,1,0)

		local value = math.floor(min + ((max-min)*percent))

		label.Text = text..": "..value

		callback(value)
	end

	bar.InputBegan:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = true
			update(input)
		end
	end)

	UIS.InputChanged:Connect(function(input)

		if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
			update(input)
		end
	end)

	UIS.InputEnded:Connect(function(input)

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = false
		end
	end)
end

--// MOVEMENT

createToggle(movementPage,"Fly [H]",function(state)
	fly = state
end)

createToggle(movementPage,"Noclip",function(state)
	noclip = state
end)

createToggle(movementPage,"Infinite Jump",function(state)
	infJump = state
end)

createToggle(movementPage,"Click Teleport",function(state)
	clickTP = state
end)

createToggle(movementPage,"Bunny Hop",function(state)
	bhop = state
end)

createToggle(movementPage,"Auto Sprint",function(state)
	autoSprint = state
end)

createSlider(movementPage,"Walkspeed",16,200,16,function(value)

	currentWalkspeed = value

	local hum = getHum()

	if hum then
		hum.WalkSpeed = value
	end
end)

createSlider(movementPage,"Fly Speed",20,300,75,function(value)
	flySpeed = value
end)

createSlider(movementPage,"Gravity",0,300,196,function(value)
	workspace.Gravity = value
end)

--// COMBAT

createToggle(combatPage,"Shiftlock Aimbot",function(state)
	aimlock = state
end)

createButton(combatPage,"Give Sword Trail",function()

	local trail = Instance.new("Trail")
	trail.Color = ColorSequence.new(COLORS.accent)

	local a0 = Instance.new("Attachment")
	local a1 = Instance.new("Attachment")

	local root = getRoot()

	a0.Parent = root
	a1.Parent = root

	a1.Position = Vector3.new(0,2,0)

	trail.Attachment0 = a0
	trail.Attachment1 = a1
	trail.Parent = root
end)

createButton(combatPage,"Purple Forcefield",function()

	local ff = Instance.new("ForceField")
	ff.Visible = true
	ff.Parent = getChar()
end)

--// VISUALS

createToggle(visualsPage,"ESP",function(state)

	for _,v in pairs(espObjects) do
		v:Destroy()
	end

	espObjects = {}

	if state then

		for _,plr in ipairs(Players:GetPlayers()) do

			if plr ~= player and plr.Character then

				local h = Instance.new("Highlight")
				h.FillTransparency = 0.5
				h.OutlineColor = COLORS.accent
				h.Parent = plr.Character

				espObjects[plr] = h
			end
		end
	end
end)

createToggle(visualsPage,"Tracers",function(state)

	tracersEnabled = state

	for _,line in pairs(tracers) do
		line:Remove()
	end

	tracers = {}
end)

createToggle(visualsPage,"Fullbright",function(state)

	Lighting.Brightness = state and 8 or 1
	Lighting.GlobalShadows = not state
end)

createToggle(visualsPage,"Rainbow Lighting",function(state)

	if state then

		_G.rainbowLighting = RunService.RenderStepped:Connect(function()

			local hue = tick()%5/5

			Lighting.Ambient = Color3.fromHSV(hue,1,1)
		end)
	else

		if _G.rainbowLighting then
			_G.rainbowLighting:Disconnect()
		end

		Lighting.Ambient = Color3.new(1,1,1)
	end
end)

createButton(visualsPage,"Purple Sky",function()

	Lighting.Ambient = Color3.fromRGB(120,70,255)
	Lighting.OutdoorAmbient = Color3.fromRGB(100,50,200)
end)

createButton(visualsPage,"Fog World",function()
	Lighting.FogEnd = 60
end)

--// PLAYERS / TELEPORTS

createButton(teleportPage,"Stop Spectating",function()

	camera.CameraSubject = getHum()
	camera.CameraType = Enum.CameraType.Custom
end)

local function refreshPlayers()

	for _,v in ipairs(teleportPage:GetChildren()) do

		if v.Name == "PlayerCard" then
			v:Destroy()
		end
	end

	for _,plr in ipairs(Players:GetPlayers()) do

		if plr ~= player then

			local card = createCard(teleportPage,72)
			card.Name = "PlayerCard"

			local name = Instance.new("TextLabel")
			name.Parent = card
			name.BackgroundTransparency = 1
			name.Position = UDim2.new(0,18,0,0)
			name.Size = UDim2.new(0.4,0,1,0)
			name.Text = plr.Name
			name.Font = Enum.Font.GothamBold
			name.TextColor3 = COLORS.text
			name.TextSize = 16
			name.TextXAlignment = Enum.TextXAlignment.Left

			local tp = Instance.new("TextButton")
			tp.Parent = card
			tp.Size = UDim2.new(0,90,0,34)
			tp.Position = UDim2.new(1,-300,0.5,-17)
			tp.BackgroundColor3 = COLORS.accent
			tp.Text = "Teleport"
			tp.TextColor3 = Color3.new(1,1,1)
			tp.Font = Enum.Font.GothamBold
			tp.TextSize = 13
			tp.BorderSizePixel = 0

			Instance.new("UICorner",tp).CornerRadius = UDim.new(1,0)

			tp.MouseButton1Click:Connect(function()

				if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then

					getRoot().CFrame =
						plr.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
				end
			end)

			local spectate = Instance.new("TextButton")
			spectate.Parent = card
			spectate.Size = UDim2.new(0,90,0,34)
			spectate.Position = UDim2.new(1,-200,0.5,-17)
			spectate.BackgroundColor3 = Color3.fromRGB(120,85,255)
			spectate.Text = "Spectate"
			spectate.TextColor3 = Color3.new(1,1,1)
			spectate.Font = Enum.Font.GothamBold
			spectate.TextSize = 13
			spectate.BorderSizePixel = 0

			Instance.new("UICorner",spectate).CornerRadius = UDim.new(1,0)

			spectate.MouseButton1Click:Connect(function()

				if plr.Character and plr.Character:FindFirstChild("Humanoid") then

					camera.CameraSubject =
						plr.Character.Humanoid
				end
			end)

			local above = Instance.new("TextButton")
			above.Parent = card
			above.Size = UDim2.new(0,90,0,34)
			above.Position = UDim2.new(1,-100,0.5,-17)
			above.BackgroundColor3 = Color3.fromRGB(90,60,220)
			above.Text = "Above"
			above.TextColor3 = Color3.new(1,1,1)
			above.Font = Enum.Font.GothamBold
			above.TextSize = 13
			above.BorderSizePixel = 0

			Instance.new("UICorner",above).CornerRadius = UDim.new(1,0)

			above.MouseButton1Click:Connect(function()

				if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then

					getRoot().CFrame =
						plr.Character.HumanoidRootPart.CFrame + Vector3.new(0,20,0)
				end
			end)
		end
	end
end

refreshPlayers()

Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)

--// FUN

createToggle(funPage,"Spinbot",function(state)
	spinbot = state
end)

createToggle(funPage,"Floating Platform",function(state)

	if state then

		local p = Instance.new("Part")
		p.Name = "VoidPlatform"
		p.Size = Vector3.new(10,1,10)
		p.Anchored = true
		p.Material = Enum.Material.Neon
		p.Color = COLORS.accent
		p.Parent = workspace

		_G.platform = p
	else

		if _G.platform then
			_G.platform:Destroy()
		end
	end
end)

createButton(funPage,"Rainbow Character",function()

	RunService.RenderStepped:Connect(function()

		local hue = tick()%5/5

		for _,v in ipairs(getChar():GetDescendants()) do

			if v:IsA("BasePart") then
				v.Color = Color3.fromHSV(hue,1,1)
			end
		end
	end)
end)

createButton(funPage,"Fire Character",function()

	for _,v in ipairs(getChar():GetDescendants()) do

		if v:IsA("BasePart") then

			local fire = Instance.new("Fire")
			fire.Size = 8
			fire.Parent = v
		end
	end
end)

createButton(funPage,"Explode Character",function()

	for _,v in ipairs(getChar():GetDescendants()) do

		if v:IsA("BasePart") then

			local explosion = Instance.new("Explosion")
			explosion.Position = v.Position
			explosion.Parent = workspace
		end
	end
end)

createButton(funPage,"Invisible Body",function()

	for _,v in ipairs(getChar():GetDescendants()) do

		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.Transparency = 1
		end
	end
end)

--// UTILITY

createButton(utilityPage,"Rejoin Server",function()
	TeleportService:Teleport(game.PlaceId,player)
end)

createButton(utilityPage,"Reset Character",function()
	getChar():BreakJoints()
end)

createButton(utilityPage,"Anti AFK",function()

	player.Idled:Connect(function()

		VirtualUser:Button2Down(Vector2.new(0,0),camera.CFrame)
		task.wait(1)
		VirtualUser:Button2Up(Vector2.new(0,0),camera.CFrame)
	end)
end)

createButton(utilityPage,"Copy Position",function()

	if setclipboard and getRoot() then
		setclipboard(tostring(getRoot().Position))
	end
end)

--// SETTINGS

createButton(settingsPage,"FPS Boost",function()

	for _,v in ipairs(workspace:GetDescendants()) do

		if v:IsA("BasePart") then

			v.Material = Enum.Material.Plastic
			v.Reflectance = 0
		end
	end

	Lighting.GlobalShadows = false
end)

createButton(settingsPage,"Reset Lighting",function()

	Lighting.Brightness = 1
	Lighting.GlobalShadows = true
	Lighting.FogEnd = 100000
	Lighting.Ambient = Color3.new(1,1,1)
end)

createButton(settingsPage,"Night Mode",function()
	Lighting.ClockTime = 0
end)

createButton(settingsPage,"Day Mode",function()
	Lighting.ClockTime = 14
end)

createButton(settingsPage,"Purple Ambient",function()

	Lighting.Ambient = Color3.fromRGB(120,70,255)
	Lighting.OutdoorAmbient = Color3.fromRGB(90,50,200)
end)

createButton(settingsPage,"Reset Gravity",function()
	workspace.Gravity = 196.2
end)

createButton(settingsPage,"Hide UI [RightCtrl]",function()
	main.Visible = not main.Visible
end)

createButton(settingsPage,"Destroy UI",function()
	gui:Destroy()
end)

--// INPUTS

UIS.InputBegan:Connect(function(input,gp)

	if gp then return end

	if input.KeyCode == Enum.KeyCode.H then
		fly = not fly
	end

	if input.KeyCode == Enum.KeyCode.RightControl then
		main.Visible = not main.Visible
	end

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		aiming = true
	end
end)

UIS.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		aiming = false
	end
end)

UIS.JumpRequest:Connect(function()

	if infJump then

		local hum = getHum()

		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

mouse.Button1Down:Connect(function()

	if clickTP then

		getRoot().CFrame = CFrame.new(
			mouse.Hit.Position + Vector3.new(0,3,0)
		)
	end
end)

--// HELPERS

local function getClosestPlayer()

	local closest
	local shortest = math.huge

	for _,plr in ipairs(Players:GetPlayers()) do

		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then

			local pos,visible = camera:WorldToViewportPoint(
				plr.Character.HumanoidRootPart.Position
			)

			if visible then

				local dist = (
					Vector2.new(pos.X,pos.Y) -
					Vector2.new(
						camera.ViewportSize.X/2,
						camera.ViewportSize.Y/2
					)
				).Magnitude

				if dist < shortest then
					shortest = dist
					closest = plr
				end
			end
		end
	end

	return closest
end

--// LOOP

RunService.RenderStepped:Connect(function()

	-- FLY

	if fly then

		local root = getRoot()

		if root then

			local dir = Vector3.zero

			if UIS:IsKeyDown(Enum.KeyCode.W) then
				dir += camera.CFrame.LookVector
			end

			if UIS:IsKeyDown(Enum.KeyCode.S) then
				dir -= camera.CFrame.LookVector
			end

			if UIS:IsKeyDown(Enum.KeyCode.A) then
				dir -= camera.CFrame.RightVector
			end

			if UIS:IsKeyDown(Enum.KeyCode.D) then
				dir += camera.CFrame.RightVector
			end

			root.AssemblyLinearVelocity = dir.Unit * flySpeed
		end
	end

	-- NOCLIP

	if noclip then

		for _,v in ipairs(getChar():GetDescendants()) do

			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end

	-- AUTOSPRINT

	if autoSprint then

		local hum = getHum()

		if hum then
			hum.WalkSpeed = currentWalkspeed
		end
	end

	-- BUNNYHOP

	if bhop then

		local hum = getHum()

		if hum and hum.FloorMaterial ~= Enum.Material.Air then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end

	-- SPINBOT

	if spinbot then

		local root = getRoot()

		if root then
			root.CFrame *= CFrame.Angles(0,math.rad(25),0)
		end
	end

	-- PLATFORM

	if _G.platform and getRoot() then

		_G.platform.Position =
			getRoot().Position - Vector3.new(0,4,0)
	end

	-- AIMBOT

	if aimlock and aiming and UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then

		local target = getClosestPlayer()

		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then

			camera.CFrame = CFrame.new(
				camera.CFrame.Position,
				target.Character.HumanoidRootPart.Position
			)
		end
	end

	-- TRACERS

	if tracersEnabled then

		for _,plr in ipairs(Players:GetPlayers()) do

			if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then

				if not tracers[plr] then

					local line = Drawing.new("Line")
					line.Color = COLORS.accent
					line.Thickness = 1.5
					line.Transparency = 1

					tracers[plr] = line
				end

				local pos,visible = camera:WorldToViewportPoint(
					plr.Character.HumanoidRootPart.Position
				)

				if visible then

					tracers[plr].From = Vector2.new(
						camera.ViewportSize.X/2,
						camera.ViewportSize.Y
					)

					tracers[plr].To = Vector2.new(pos.X,pos.Y)

					tracers[plr].Visible = true
				else
					tracers[plr].Visible = false
				end
			end
		end
	end
end)

print("🟪 VOIDOOR SCRIPTHUB LOADED")

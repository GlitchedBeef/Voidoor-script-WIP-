--// <-- 🟪 VOIDOOR SCRIPTHUB 🟪 -->
--// Universal Admin Hub Rebuild
--// Place in StarterPlayerScripts or execute locally

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

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
	bg = Color3.fromRGB(18,14,30),
	top = Color3.fromRGB(28,22,48),
	card = Color3.fromRGB(35,28,58),
	accent = Color3.fromRGB(165,110,255),
	text = Color3.fromRGB(255,255,255),
	sub = Color3.fromRGB(200,170,255),
	toggleOff = Color3.fromRGB(70,60,110),
	toggleOn = Color3.fromRGB(160,100,255),
}

--// VARIABLES

local flySpeed = 70
local flying = false
local noclip = false
local infJump = false
local clickTP = false
local aimlock = false
local aiming = false
local spin = false

local flyConn
local noclipConn
local aimConn
local spinConn
local rainbowConn
local tracerConn
local espConn

local tracers = {}
local esps = {}

--// GUI

local gui = Instance.new("ScreenGui")
gui.Name = "VOIDOOR_HUB"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local blur = Instance.new("BlurEffect")
blur.Size = 10
blur.Parent = Lighting

local main = Instance.new("Frame")
main.Parent = gui
main.Size = UDim2.new(0,760,0,500)
main.Position = UDim2.new(0.5,-380,0.5,-250)
main.BackgroundColor3 = COLORS.bg
main.BorderSizePixel = 0
main.Active = true

Instance.new("UICorner",main).CornerRadius = UDim.new(0,18)

local stroke = Instance.new("UIStroke")
stroke.Parent = main
stroke.Color = COLORS.accent
stroke.Thickness = 1.4
stroke.Transparency = 0.3

local grad = Instance.new("UIGradient")
grad.Parent = main
grad.Rotation = 90
grad.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0,Color3.fromRGB(120,80,255)),
	ColorSequenceKeypoint.new(1,Color3.fromRGB(40,25,80))
}

--// TOPBAR

local top = Instance.new("Frame")
top.Parent = main
top.Size = UDim2.new(1,0,0,50)
top.BackgroundColor3 = COLORS.top
top.BorderSizePixel = 0

Instance.new("UICorner",top).CornerRadius = UDim.new(0,18)

local fix = Instance.new("Frame")
fix.Parent = top
fix.Position = UDim2.new(0,0,1,-18)
fix.Size = UDim2.new(1,0,0,18)
fix.BackgroundColor3 = COLORS.top
fix.BorderSizePixel = 0

local title = Instance.new("TextLabel")
title.Parent = top
title.Size = UDim2.new(1,0,1,0)
title.BackgroundTransparency = 1
title.Text = "<-- 🟪 VOIDOOR SCRIPTHUB 🟪 -->"
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextColor3 = COLORS.text

local close = Instance.new("TextButton")
close.Parent = top
close.Size = UDim2.new(0,34,0,34)
close.Position = UDim2.new(1,-42,0.5,-17)
close.Text = "X"
close.Font = Enum.Font.GothamBold
close.TextSize = 14
close.BackgroundColor3 = Color3.fromRGB(140,60,255)
close.TextColor3 = Color3.new(1,1,1)
close.BorderSizePixel = 0

Instance.new("UICorner",close).CornerRadius = UDim.new(1,0)

close.MouseButton1Click:Connect(function()
	gui:Destroy()
	blur:Destroy()
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

--// TABS

local tabBar = Instance.new("Frame")
tabBar.Parent = main
tabBar.Position = UDim2.new(0,10,0,60)
tabBar.Size = UDim2.new(1,-20,0,40)
tabBar.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout")
layout.Parent = tabBar
layout.FillDirection = Enum.FillDirection.Horizontal
layout.Padding = UDim.new(0,8)

local pages = {}

local function createPage(name)

	local page = Instance.new("ScrollingFrame")
	page.Parent = main
	page.Position = UDim2.new(0,15,0,110)
	page.Size = UDim2.new(1,-30,1,-125)
	page.BackgroundTransparency = 1
	page.ScrollBarThickness = 3
	page.CanvasSize = UDim2.new(0,0,0,1400)
	page.Visible = false
	page.BorderSizePixel = 0

	local lay = Instance.new("UIListLayout")
	lay.Parent = page
	lay.Padding = UDim.new(0,10)

	pages[name] = page

	return page
end

local function switchPage(name)
	for n,p in pairs(pages) do
		p.Visible = n == name
	end
end

local function createTab(name,emoji)

	local b = Instance.new("TextButton")
	b.Parent = tabBar
	b.Size = UDim2.new(0,110,1,0)
	b.BackgroundColor3 = COLORS.card
	b.Text = emoji.." "..name
	b.TextColor3 = COLORS.text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.BorderSizePixel = 0

	Instance.new("UICorner",b).CornerRadius = UDim.new(0,10)

	b.MouseEnter:Connect(function()
		TweenService:Create(b,TweenInfo.new(0.15),{
			BackgroundColor3 = COLORS.accent
		}):Play()
	end)

	b.MouseLeave:Connect(function()
		TweenService:Create(b,TweenInfo.new(0.15),{
			BackgroundColor3 = COLORS.card
		}):Play()
	end)

	b.MouseButton1Click:Connect(function()
		switchPage(name)
	end)
end

--// PAGES

local movementPage = createPage("Movement")
local visualsPage = createPage("Visuals")
local combatPage = createPage("Combat")
local funPage = createPage("Fun")
local utilityPage = createPage("Utility")

createTab("Movement","🏃")
createTab("Visuals","👁️")
createTab("Combat","🎯")
createTab("Fun","🎉")
createTab("Utility","⚙️")

switchPage("Movement")

--// WIDGETS

local function createCard(parent,height)

	local frame = Instance.new("Frame")
	frame.Parent = parent
	frame.Size = UDim2.new(1,0,0,height or 60)
	frame.BackgroundColor3 = COLORS.card
	frame.BorderSizePixel = 0

	Instance.new("UICorner",frame).CornerRadius = UDim.new(0,12)

	return frame
end

local function createToggle(parent,text,callback)

	local card = createCard(parent)

	local label = Instance.new("TextLabel")
	label.Parent = card
	label.Size = UDim2.new(1,-90,1,0)
	label.Position = UDim2.new(0,15,0,0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = COLORS.text
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left

	local toggle = Instance.new("TextButton")
	toggle.Parent = card
	toggle.Size = UDim2.new(0,55,0,26)
	toggle.Position = UDim2.new(1,-70,0.5,-13)
	toggle.Text = ""
	toggle.BackgroundColor3 = COLORS.toggleOff
	toggle.BorderSizePixel = 0

	Instance.new("UICorner",toggle).CornerRadius = UDim.new(1,0)

	local knob = Instance.new("Frame")
	knob.Parent = toggle
	knob.Size = UDim2.new(0,22,0,22)
	knob.Position = UDim2.new(0,2,0.5,-11)
	knob.BackgroundColor3 = Color3.new(1,1,1)
	knob.BorderSizePixel = 0

	Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)

	local enabled = false

	toggle.MouseButton1Click:Connect(function()

		enabled = not enabled

		if enabled then

			toggle.BackgroundColor3 = COLORS.toggleOn

			knob:TweenPosition(
				UDim2.new(1,-24,0.5,-11),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.15,
				true
			)
		else

			toggle.BackgroundColor3 = COLORS.toggleOff

			knob:TweenPosition(
				UDim2.new(0,2,0.5,-11),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.15,
				true
			)
		end

		callback(enabled)
	end)
end

local function createButton(parent,text,callback)

	local b = Instance.new("TextButton")
	b.Parent = createCard(parent)
	b.Size = UDim2.new(1,0,1,0)
	b.BackgroundTransparency = 1
	b.Text = text
	b.TextColor3 = COLORS.text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13

	b.MouseButton1Click:Connect(callback)
end

--// FLY

local function stopFly()
	flying = false

	if flyConn then
		flyConn:Disconnect()
	end

	local root = getRoot()

	if root then
		root.AssemblyLinearVelocity = Vector3.zero
	end
end

local function startFly()

	stopFly()

	flying = true

	flyConn = RunService.RenderStepped:Connect(function()

		local root = getRoot()

		if not root then return end

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

		if UIS:IsKeyDown(Enum.KeyCode.Space) then
			dir += Vector3.new(0,1,0)
		end

		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
			dir -= Vector3.new(0,1,0)
		end

		if dir.Magnitude > 0 then
			dir = dir.Unit
		end

		root.AssemblyLinearVelocity = dir * flySpeed
	end)
end

--// AIMLOCK

local function getClosest()

	local closest
	local dist = math.huge

	for _,plr in ipairs(Players:GetPlayers()) do

		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then

			local hum = plr.Character:FindFirstChildOfClass("Humanoid")

			if hum and hum.Health > 0 then

				local pos,visible = camera:WorldToViewportPoint(
					plr.Character.HumanoidRootPart.Position
				)

				if visible then

					local mag = (
						Vector2.new(pos.X,pos.Y) -
						Vector2.new(
							camera.ViewportSize.X/2,
							camera.ViewportSize.Y/2
						)
					).Magnitude

					if mag < dist then
						dist = mag
						closest = plr
					end
				end
			end
		end
	end

	return closest
end

--// MOVEMENT

createToggle(movementPage,"🕊️ Fly [H]",function(state)

	if state then
		startFly()
	else
		stopFly()
	end
end)

createToggle(movementPage,"🧱 Noclip",function(state)

	noclip = state

	if noclipConn then
		noclipConn:Disconnect()
	end

	if state then

		noclipConn = RunService.Stepped:Connect(function()

			for _,v in ipairs(getChar():GetDescendants()) do

				if v:IsA("BasePart") then
					v.CanCollide = false
				end
			end
		end)
	end
end)

createToggle(movementPage,"🦘 Infinite Jump",function(state)
	infJump = state
end)

createToggle(movementPage,"🖱️ Click Teleport",function(state)
	clickTP = state
end)

--// VISUALS

createToggle(visualsPage,"💡 Fullbright",function(state)

	if state then
		Lighting.Brightness = 10
		Lighting.GlobalShadows = false
	else
		Lighting.Brightness = 1
		Lighting.GlobalShadows = true
	end
end)

createToggle(visualsPage,"👁️ ESP",function(state)

	for _,v in pairs(esps) do
		v:Destroy()
	end

	esps = {}

	if espConn then
		espConn:Disconnect()
	end

	if not state then return end

	espConn = RunService.RenderStepped:Connect(function()

		for _,plr in ipairs(Players:GetPlayers()) do

			if plr ~= player and plr.Character then

				if not esps[plr] then

					local h = Instance.new("Highlight")
					h.FillTransparency = 0.5
					h.OutlineColor = COLORS.accent
					h.Parent = plr.Character

					esps[plr] = h
				end
			end
		end
	end)
end)

createToggle(visualsPage,"📍 Tracers",function(state)

	for _,line in pairs(tracers) do
		line:Remove()
	end

	tracers = {}

	if tracerConn then
		tracerConn:Disconnect()
	end

	if not state then return end

	for _,plr in ipairs(Players:GetPlayers()) do

		if plr ~= player then

			local line = Drawing.new("Line")

			line.Color = COLORS.accent
			line.Thickness = 1.5
			line.Transparency = 1

			tracers[plr] = line
		end
	end

	tracerConn = RunService.RenderStepped:Connect(function()

		for _,plr in ipairs(Players:GetPlayers()) do

			if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then

				local root = plr.Character.HumanoidRootPart

				local pos,visible = camera:WorldToViewportPoint(root.Position)

				local line = tracers[plr]

				if line then

					if visible then

						line.From = Vector2.new(
							camera.ViewportSize.X/2,
							camera.ViewportSize.Y
						)

						line.To = Vector2.new(pos.X,pos.Y)

						line.Visible = true
					else
						line.Visible = false
					end
				end
			end
		end
	end)
end)

--// COMBAT

createToggle(combatPage,"🎯 Shiftlock Aimlock",function(state)

	aimlock = state

	if aimConn then
		aimConn:Disconnect()
	end

	if state then

		aimConn = RunService.RenderStepped:Connect(function()

			if aiming then

				local target = getClosest()

				if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then

					camera.CFrame = CFrame.new(
						camera.CFrame.Position,
						target.Character.HumanoidRootPart.Position
					)
				end
			end
		end)
	end
end)

createToggle(combatPage,"✨ Spin Bot",function(state)

	spin = state

	if spinConn then
		spinConn:Disconnect()
	end

	if state then

		spinConn = RunService.RenderStepped:Connect(function()

			local root = getRoot()

			if root then
				root.CFrame *= CFrame.Angles(0,0.2,0)
			end
		end)
	end
end)

--// FUN

createToggle(funPage,"🌈 Rainbow Character",function(state)

	if rainbowConn then
		rainbowConn:Disconnect()
	end

	if state then

		rainbowConn = RunService.RenderStepped:Connect(function()

			local hue = tick()%5/5

			for _,v in ipairs(getChar():GetDescendants()) do

				if v:IsA("BasePart") then
					v.Color = Color3.fromHSV(hue,1,1)
				end
			end
		end)
	end
end)

createToggle(funPage,"🔥 Fire Character",function(state)

	for _,v in ipairs(getChar():GetDescendants()) do

		if v:IsA("BasePart") then

			local old = v:FindFirstChild("VOID_FIRE")

			if old then
				old:Destroy()
			end

			if state then

				local fire = Instance.new("Fire")
				fire.Name = "VOID_FIRE"
				fire.Size = 8
				fire.Parent = v
			end
		end
	end
end)

--// UTILITY

createButton(utilityPage,"🔄 Rejoin Server",function()

	TeleportService:Teleport(game.PlaceId,player)
end)

createButton(utilityPage,"📋 Copy JobId",function()

	if setclipboard then
		setclipboard(game.JobId)
	end
end)

createButton(utilityPage,"📋 Copy Join Script",function()

	if setclipboard then

		setclipboard(
			'game:GetService("TeleportService"):TeleportToPlaceInstance('..
			game.PlaceId..',"'
			..game.JobId..'")'
		)
	end
end)

--// INPUTS

UIS.InputBegan:Connect(function(input,gp)

	if gp then return end

	if input.KeyCode == Enum.KeyCode.H then

		if flying then
			stopFly()
		else
			startFly()
		end
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

		local root = getRoot()

		if root then
			root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0))
		end
	end
end)

Players.PlayerRemoving:Connect(function(plr)

	if tracers[plr] then
		tracers[plr]:Remove()
		tracers[plr] = nil
	end

	if esps[plr] then
		esps[plr]:Destroy()
		esps[plr] = nil
	end
end)

print("🟪 VOIDOOR SCRIPTHUB LOADED")

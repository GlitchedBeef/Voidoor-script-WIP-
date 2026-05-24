--// ◈ VOIDOOR SCRIPTHUB ◈
--// V5 — Keybinds + Toggle Visuals + Fixed Resets

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportSvc  = game:GetService("TeleportService")
local Lighting     = game:GetService("Lighting")
local VirtualUser  = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local mouse  = player:GetMouse()
local camera = workspace.CurrentCamera

local function getChar() return player.Character or player.CharacterAdded:Wait() end
local function getHum()  return getChar():FindFirstChildOfClass("Humanoid") end
local function getRoot() return getChar():FindFirstChild("HumanoidRootPart") end

-- ═══════════════════════════════════════════════════════
--  COLORS
-- ═══════════════════════════════════════════════════════
local C = {
    bg      = Color3.fromRGB(8,  6,  18),
    top     = Color3.fromRGB(14, 10, 32),
    card    = Color3.fromRGB(20, 15, 42),
    accent  = Color3.fromRGB(130,70, 255),
    accent2 = Color3.fromRGB(100,50, 220),
    text    = Color3.fromRGB(240,235,255),
    sub     = Color3.fromRGB(160,150,200),
    on      = Color3.fromRGB(140,80, 255),
    off     = Color3.fromRGB(45, 40, 65),
    red     = Color3.fromRGB(180,45, 45),
    green   = Color3.fromRGB(40, 180,100),
}

-- ═══════════════════════════════════════════════════════
--  DEFAULTS (captured at load time)
-- ═══════════════════════════════════════════════════════
local DEF = {
    gravity   = workspace.Gravity,
    ws        = 16,
    jp        = 50,
    flySpeed  = 75,
    fov       = 70,
    lighting  = {
        Brightness     = Lighting.Brightness,
        GlobalShadows  = Lighting.GlobalShadows,
        FogEnd         = Lighting.FogEnd,
        Ambient        = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        ClockTime      = Lighting.ClockTime,
    },
}

-- ═══════════════════════════════════════════════════════
--  STATE
-- ═══════════════════════════════════════════════════════
local fly       = false
local noclip    = false
local infJump   = false
local clickTP   = false
local spinbot   = false
local bhop      = false
local tracersOn = false
local flySpeed  = DEF.flySpeed
local wsValue   = DEF.ws
local tracers   = {}

-- per-tab toggle/slider registries for clean resets
local tabToggles = {}  -- tabToggles[page] = { {setFn, defaultVal}, ... }
local tabSliders = {}  -- tabSliders[page] = { {setFn, defaultVal}, ... }

local function regToggle(page, setFn, def)
    tabToggles[page] = tabToggles[page] or {}
    table.insert(tabToggles[page], {fn=setFn, def=def or false})
end
local function regSlider(page, setFn, def)
    tabSliders[page] = tabSliders[page] or {}
    table.insert(tabSliders[page], {fn=setFn, def=def})
end

local function resetToggles(page)
    if tabToggles[page] then
        for _,t in ipairs(tabToggles[page]) do t.fn(t.def) end
    end
end
local function resetSliders(page)
    if tabSliders[page] then
        for _,s in ipairs(tabSliders[page]) do s.fn(s.def) end
    end
end

-- ═══════════════════════════════════════════════════════
--  WALKSPEED LOOP (keeps ws even if game resets it)
-- ═══════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    local h = getHum()
    if h then h.WalkSpeed = wsValue end
end)

-- ═══════════════════════════════════════════════════════
--  KEYBIND TABLE  (rebindable)
-- ═══════════════════════════════════════════════════════
local KB = {
    fly       = Enum.KeyCode.M,
    void      = Enum.KeyCode.V,
    megaVoid  = Enum.KeyCode.U,
    wsToggle  = Enum.KeyCode.N,
    hideUI    = Enum.KeyCode.RightControl,
    noclip    = Enum.KeyCode.X,
}
-- ws boost toggle state
local wsBoostOn  = false
local wsSavedVal = DEF.ws   -- stores the "normal" speed so N toggles between boosted and normal

-- ═══════════════════════════════════════════════════════
--  GUI ROOT
-- ═══════════════════════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name="VOIDOOR_V5"; gui.ResetOnSpawn=false
gui.IgnoreGuiInset=true; gui.Parent=player.PlayerGui

local main = Instance.new("Frame", gui)
main.Size=UDim2.new(0,790,0,670)
main.Position=UDim2.new(0.5,-395,0.5,-335)
main.BackgroundColor3=C.bg; main.BackgroundTransparency=0.22
main.BorderSizePixel=0; main.Active=true
Instance.new("UICorner",main).CornerRadius=UDim.new(0,22)

local winStroke=Instance.new("UIStroke",main)
winStroke.Color=C.accent; winStroke.Transparency=0.35; winStroke.Thickness=1.4

local wg=Instance.new("UIGradient",main); wg.Rotation=120
wg.Color=ColorSequence.new{
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(32,18,72)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10,7, 22)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(6, 4, 16)),
}

-- ── TOPBAR ──────────────────────────────────────────────
local top=Instance.new("Frame",main)
top.Size=UDim2.new(1,0,0,58); top.BackgroundColor3=C.top
top.BackgroundTransparency=0.15; top.BorderSizePixel=0; top.Active=true
Instance.new("UICorner",top).CornerRadius=UDim.new(0,22)
local topFix=Instance.new("Frame",top)
topFix.Size=UDim2.new(1,0,0,22); topFix.Position=UDim2.new(0,0,1,-22)
topFix.BackgroundColor3=C.top; topFix.BackgroundTransparency=0.15; topFix.BorderSizePixel=0

local dot=Instance.new("Frame",top)
dot.Size=UDim2.new(0,12,0,12); dot.Position=UDim2.new(0,16,0.5,-6)
dot.BackgroundColor3=C.accent; dot.BorderSizePixel=0
Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)

local titleLbl=Instance.new("TextLabel",top)
titleLbl.BackgroundTransparency=1
titleLbl.Position=UDim2.new(0,36,0,2); titleLbl.Size=UDim2.new(1,-140,0,30)
titleLbl.Text="  VOIDOOR SCRIPTHUB"; titleLbl.Font=Enum.Font.GothamBold
titleLbl.TextSize=18; titleLbl.TextColor3=C.text; titleLbl.TextXAlignment=Enum.TextXAlignment.Left

local subLbl=Instance.new("TextLabel",top)
subLbl.BackgroundTransparency=1
subLbl.Position=UDim2.new(0,37,0,32); subLbl.Size=UDim2.new(0.6,0,0,14)
subLbl.Text="v5  |  RightCtrl = hide  |  M = fly"; subLbl.Font=Enum.Font.Gotham
subLbl.TextSize=10; subLbl.TextColor3=C.sub; subLbl.TextXAlignment=Enum.TextXAlignment.Left

local closeBtn=Instance.new("TextButton",top)
closeBtn.Size=UDim2.new(0,32,0,32); closeBtn.Position=UDim2.new(1,-46,0.5,-16)
closeBtn.BackgroundColor3=C.red; closeBtn.Text="X"
closeBtn.Font=Enum.Font.GothamBold; closeBtn.TextSize=13
closeBtn.TextColor3=Color3.new(1,1,1); closeBtn.BorderSizePixel=0
Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(1,0)
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

local minBtn=Instance.new("TextButton",top)
minBtn.Size=UDim2.new(0,32,0,32); minBtn.Position=UDim2.new(1,-86,0.5,-16)
minBtn.BackgroundColor3=C.accent2; minBtn.Text="-"
minBtn.Font=Enum.Font.GothamBold; minBtn.TextSize=18
minBtn.TextColor3=Color3.new(1,1,1); minBtn.BorderSizePixel=0
Instance.new("UICorner",minBtn).CornerRadius=UDim.new(1,0)
local minimised=false
minBtn.MouseButton1Click:Connect(function()
    minimised=not minimised
    TweenService:Create(main,TweenInfo.new(0.2),{
        Size=minimised and UDim2.new(0,790,0,58) or UDim2.new(0,790,0,670)
    }):Play()
end)

-- drag
local dragging,dragStart,startPos
top.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true; dragStart=i.Position; startPos=main.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-dragStart
        main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
end)

-- ── TAB BAR ─────────────────────────────────────────────
local tabScroll=Instance.new("ScrollingFrame",main)
tabScroll.Position=UDim2.new(0,14,0,66); tabScroll.Size=UDim2.new(1,-28,0,44)
tabScroll.CanvasSize=UDim2.new(0,1600,0,0); tabScroll.BackgroundTransparency=1
tabScroll.ScrollBarThickness=0; tabScroll.BorderSizePixel=0
tabScroll.ScrollingDirection=Enum.ScrollingDirection.X
local tabLL=Instance.new("UIListLayout",tabScroll)
tabLL.FillDirection=Enum.FillDirection.Horizontal; tabLL.Padding=UDim.new(0,7)

local divLine=Instance.new("Frame",main)
divLine.Size=UDim2.new(1,-28,0,1); divLine.Position=UDim2.new(0,14,0,112)
divLine.BackgroundColor3=C.accent; divLine.BackgroundTransparency=0.6; divLine.BorderSizePixel=0

-- ═══════════════════════════════════════════════════════
--  PAGE / TAB SYSTEM
-- ═══════════════════════════════════════════════════════
local pages={}; local tabBtns={}

local function createPage(name)
    local page=Instance.new("ScrollingFrame",main)
    page.Position=UDim2.new(0,14,0,120)
    page.Size=UDim2.new(1,-28,1,-134)
    page.BackgroundTransparency=1; page.ScrollBarThickness=3
    page.ScrollBarImageColor3=C.accent; page.BorderSizePixel=0
    page.Visible=false; page.CanvasSize=UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize=Enum.AutomaticSize.Y
    page.ScrollingDirection=Enum.ScrollingDirection.Y
    local l=Instance.new("UIListLayout",page)
    l.Padding=UDim.new(0,9); l.SortOrder=Enum.SortOrder.LayoutOrder
    local p=Instance.new("UIPadding",page)
    p.PaddingTop=UDim.new(0,8); p.PaddingBottom=UDim.new(0,14)
    pages[name]=page; return page
end

local function switchPage(name)
    for n,p in pairs(pages) do p.Visible=(n==name) end
    for n,b in pairs(tabBtns) do
        TweenService:Create(b,TweenInfo.new(0.14),{
            BackgroundColor3   = n==name and C.accent  or C.card,
            BackgroundTransparency = n==name and 0.08 or 0.3,
        }):Play()
    end
end

local function createTab(name,icon)
    local btn=Instance.new("TextButton",tabScroll)
    btn.Size=UDim2.new(0,142,1,0)
    btn.BackgroundColor3=C.card; btn.BackgroundTransparency=0.3
    btn.Text=(icon or "").."  "..name
    btn.TextColor3=C.text; btn.Font=Enum.Font.GothamMedium
    btn.TextSize=12; btn.BorderSizePixel=0
    Instance.new("UICorner",btn).CornerRadius=UDim.new(1,0)
    local bs=Instance.new("UIStroke",btn)
    bs.Color=C.accent; bs.Transparency=0.72; bs.Thickness=1
    btn.MouseButton1Click:Connect(function() switchPage(name) end)
    btn.MouseEnter:Connect(function()
        if not pages[name] or not pages[name].Visible then
            TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.accent2,BackgroundTransparency=0.45}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not pages[name] or not pages[name].Visible then
            TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.card,BackgroundTransparency=0.3}):Play()
        end
    end)
    tabBtns[name]=btn
end

-- ═══════════════════════════════════════════════════════
--  WIDGET FACTORIES
-- ═══════════════════════════════════════════════════════

local function makeCard(parent,h,order)
    local card=Instance.new("Frame",parent)
    card.Size=UDim2.new(1,0,0,h or 62)
    card.BackgroundColor3=C.card; card.BackgroundTransparency=0.28
    card.BorderSizePixel=0; card.LayoutOrder=order or 0
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,13)
    local cs=Instance.new("UIStroke",card)
    cs.Color=C.accent; cs.Transparency=0.82; cs.Thickness=1
    return card
end

local function sectionLabel(parent,text,order)
    local f=Instance.new("Frame",parent)
    f.Size=UDim2.new(1,0,0,24); f.BackgroundTransparency=1; f.LayoutOrder=order or 0
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1
    l.Font=Enum.Font.GothamBold; l.TextSize=10; l.TextColor3=C.accent
    l.Text=string.upper(text); l.TextXAlignment=Enum.TextXAlignment.Left
    local line=Instance.new("Frame",f)
    line.Size=UDim2.new(1,0,0,1); line.Position=UDim2.new(0,0,1,-1)
    line.BackgroundColor3=C.accent; line.BackgroundTransparency=0.65; line.BorderSizePixel=0
end

-- Toggle — returns setFn so caller can register it
local function makeToggle(parent,text,order,callback)
    local card=makeCard(parent,62,order)
    local lbl=Instance.new("TextLabel",card)
    lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,18,0,0)
    lbl.Size=UDim2.new(1,-90,1,0); lbl.Text=text
    lbl.TextColor3=C.text; lbl.Font=Enum.Font.GothamMedium
    lbl.TextSize=14; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextWrapped=true

    local tog=Instance.new("TextButton",card)
    tog.Size=UDim2.new(0,54,0,28); tog.Position=UDim2.new(1,-72,0.5,-14)
    tog.BackgroundColor3=C.off; tog.Text=""; tog.BorderSizePixel=0
    Instance.new("UICorner",tog).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("Frame",tog)
    knob.Size=UDim2.new(0,22,0,22); knob.Position=UDim2.new(0,3,0.5,-11)
    knob.BackgroundColor3=Color3.new(1,1,1); knob.BorderSizePixel=0
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local enabled=false
    local function set(s)
        enabled=s
        TweenService:Create(tog,TweenInfo.new(0.15),{BackgroundColor3=s and C.on or C.off}):Play()
        knob:TweenPosition(
            s and UDim2.new(1,-25,0.5,-11) or UDim2.new(0,3,0.5,-11),
            Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.15,true
        )
        callback(s)
    end
    tog.MouseButton1Click:Connect(function() set(not enabled) end)
    return set
end

local function makeSlider(parent,text,minV,maxV,defV,order,onChange)
    local card=makeCard(parent,76,order)
    local lbl=Instance.new("TextLabel",card)
    lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,18,0,8)
    lbl.Size=UDim2.new(1,-22,0,20); lbl.Text=text..": "..defV
    lbl.TextColor3=C.text; lbl.Font=Enum.Font.GothamMedium
    lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left

    local bar=Instance.new("Frame",card)
    bar.Position=UDim2.new(0,18,0,48); bar.Size=UDim2.new(1,-36,0,8)
    bar.BackgroundColor3=C.off; bar.BorderSizePixel=0; bar.Active=true
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)

    local fill=Instance.new("Frame",bar)
    fill.Size=UDim2.new((defV-minV)/(maxV-minV),0,1,0)
    fill.BackgroundColor3=C.accent; fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local thumb=Instance.new("Frame",bar)
    thumb.Size=UDim2.new(0,16,0,16); thumb.AnchorPoint=Vector2.new(0.5,0.5)
    thumb.Position=UDim2.new((defV-minV)/(maxV-minV),0,0.5,0)
    thumb.BackgroundColor3=Color3.fromRGB(200,175,255); thumb.BorderSizePixel=0
    thumb.ZIndex=3; thumb.Active=true
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)

    local dg=false
    local function update(x)
        local r=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        local v=math.floor(minV+r*(maxV-minV))
        fill.Size=UDim2.new(r,0,1,0); thumb.Position=UDim2.new(r,0,0.5,0)
        lbl.Text=text..": "..v; onChange(v)
    end
    local function setVal(v)
        local r=math.clamp((v-minV)/(maxV-minV),0,1)
        fill.Size=UDim2.new(r,0,1,0); thumb.Position=UDim2.new(r,0,0.5,0)
        lbl.Text=text..": "..v; onChange(v)
    end
    thumb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dg=true end end)
    bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dg=true; update(i.Position.X) end end)
    UIS.InputChanged:Connect(function(i) if dg and i.UserInputType==Enum.UserInputType.MouseMovement then update(i.Position.X) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dg=false end end)
    return setVal
end

local function makeButton(parent,text,color,order,callback)
    local card=makeCard(parent,54,order)
    local ind=Instance.new("Frame",card)
    ind.Size=UDim2.new(0,4,0.55,0); ind.Position=UDim2.new(0,0,0.225,0)
    ind.BackgroundColor3=color or C.accent; ind.BorderSizePixel=0
    Instance.new("UICorner",ind).CornerRadius=UDim.new(1,0)
    local btn=Instance.new("TextButton",card)
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1
    btn.Text=text; btn.Font=Enum.Font.GothamMedium
    btn.TextSize=14; btn.TextColor3=C.text
    btn.MouseButton1Click:Connect(callback)
    btn.MouseEnter:Connect(function() TweenService:Create(card,TweenInfo.new(0.1),{BackgroundTransparency=0.1}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(card,TweenInfo.new(0.1),{BackgroundTransparency=0.28}):Play() end)
end

local function makeResetBtn(parent,order,callback)
    local card=makeCard(parent,44,order)
    card.BackgroundColor3=Color3.fromRGB(10,7,24); card.BackgroundTransparency=0.15
    local cs=card:FindFirstChildOfClass("UIStroke"); if cs then cs.Color=C.red; cs.Transparency=0.6 end
    local btn=Instance.new("TextButton",card)
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1
    btn.Text="[ Reset Tab Settings ]"; btn.Font=Enum.Font.GothamBold
    btn.TextSize=12; btn.TextColor3=C.sub
    btn.MouseButton1Click:Connect(callback)
    btn.MouseEnter:Connect(function() TweenService:Create(card,TweenInfo.new(0.1),{BackgroundTransparency=0}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(card,TweenInfo.new(0.1),{BackgroundTransparency=0.15}):Play() end)
end

-- ═══════════════════════════════════════════════════════
--  PAGES
-- ═══════════════════════════════════════════════════════
local movPage  = createPage("Movement")
local combPage = createPage("Combat")
local visPage  = createPage("Visuals")
local tpPage   = createPage("Players")
local funPage  = createPage("Fun")
local utilPage = createPage("Utility")
local kbPage   = createPage("Keybinds")
local setPage  = createPage("Settings")

createTab("Movement","[M]")
createTab("Combat",  "[C]")
createTab("Visuals", "[V]")
createTab("Players", "[P]")
createTab("Fun",     "[F]")
createTab("Utility", "[U]")
createTab("Keybinds","[K]")
createTab("Settings","[S]")

switchPage("Movement")

local o=0; local function O() o=o+1; return o end

-- ═══════════════════════════════════════════════════════
--  MOVEMENT
-- ═══════════════════════════════════════════════════════
sectionLabel(movPage,"Flying",O())
local setFly = makeToggle(movPage,"Fly  (keybind: M)",O(),function(s) fly=s end)
regToggle(movPage,setFly,false)

local setFlySpd = makeSlider(movPage,"Fly Speed",20,300,DEF.flySpeed,O(),function(v) flySpeed=v end)
regSlider(movPage,setFlySpd,DEF.flySpeed)

sectionLabel(movPage,"On Foot",O())
local setNoclip = makeToggle(movPage,"Noclip  (keybind: X)",O(),function(s) noclip=s end)
regToggle(movPage,setNoclip,false)

local setInfJ = makeToggle(movPage,"Infinite Jump",O(),function(s) infJump=s end)
regToggle(movPage,setInfJ,false)

local setBhop = makeToggle(movPage,"Bunny Hop",O(),function(s) bhop=s end)
regToggle(movPage,setBhop,false)

local setClickTP = makeToggle(movPage,"Click Teleport",O(),function(s) clickTP=s end)
regToggle(movPage,setClickTP,false)

sectionLabel(movPage,"Sliders",O())
local setWS = makeSlider(movPage,"Walkspeed",16,250,DEF.ws,O(),function(v)
    wsValue=v; local h=getHum(); if h then h.WalkSpeed=v end
end)
regSlider(movPage,setWS,DEF.ws)

local setJP = makeSlider(movPage,"Jump Power",7,250,DEF.jp,O(),function(v)
    local h=getHum(); if h then h.JumpPower=v end
end)
regSlider(movPage,setJP,DEF.jp)

local setGrav = makeSlider(movPage,"Gravity",0,300,DEF.gravity,O(),function(v)
    workspace.Gravity=v
end)
regSlider(movPage,setGrav,DEF.gravity)

makeResetBtn(movPage,O(),function()
    fly=false; noclip=false; infJump=false; bhop=false; clickTP=false
    flySpeed=DEF.flySpeed; wsValue=DEF.ws; workspace.Gravity=DEF.gravity
    local h=getHum(); if h then h.WalkSpeed=DEF.ws; h.JumpPower=DEF.jp end
    resetToggles(movPage); resetSliders(movPage)
end)

-- ═══════════════════════════════════════════════════════
--  COMBAT
-- ═══════════════════════════════════════════════════════
sectionLabel(combPage,"Tools",O())
makeButton(combPage,"Give Sword",C.accent,O(),function()
    local tool=Instance.new("Tool"); tool.Name="VoidSword"; tool.RequiresHandle=false
    local blade=Instance.new("Part",tool); blade.Size=Vector3.new(0.2,4,0.2)
    blade.BrickColor=BrickColor.new("Bright violet"); blade.Material=Enum.Material.Neon
    blade.Name="Handle"; tool.Parent=player.Backpack
end)
makeButton(combPage,"Purple Forcefield  (10s)",C.accent2,O(),function()
    local ff=Instance.new("ForceField"); ff.Visible=true; ff.Parent=getChar()
    task.delay(10,function() if ff and ff.Parent then ff:Destroy() end end)
end)
makeButton(combPage,"Remove Forcefield",C.off,O(),function()
    for _,v in ipairs(getChar():GetChildren()) do
        if v:IsA("ForceField") then v:Destroy() end
    end
end)

sectionLabel(combPage,"Hitbox",O())
local setHitbox = makeSlider(combPage,"Hitbox Size",1,30,1,O(),function(v)
    local char=getChar()
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then
            p.Size=Vector3.new(v,v,v)
        end
    end
end)
regSlider(combPage,setHitbox,1)

makeResetBtn(combPage,O(),function()
    for _,v in ipairs(getChar():GetChildren()) do
        if v:IsA("ForceField") then v:Destroy() end
    end
    resetSliders(combPage)
end)

-- ═══════════════════════════════════════════════════════
--  VISUALS
-- ═══════════════════════════════════════════════════════
sectionLabel(visPage,"Player",O())

-- Sword trail toggle
local setTrail = makeToggle(visPage,"Sword Trail",O(),function(s)
    local root=getRoot(); if not root then return end
    if s then
        local a0=Instance.new("Attachment",root); a0.Name="TrailA0"
        local a1=Instance.new("Attachment",root); a1.Name="TrailA1"; a1.Position=Vector3.new(0,3,0)
        local trail=Instance.new("Trail"); trail.Name="VoidTrail"
        trail.Attachment0=a0; trail.Attachment1=a1
        trail.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,C.accent),ColorSequenceKeypoint.new(1,Color3.fromRGB(60,0,180))}
        trail.LightEmission=0.8; trail.Lifetime=0.3
        trail.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}
        trail.Parent=root
    else
        local root2=getRoot()
        if root2 then
            for _,v in ipairs(root2:GetChildren()) do
                if v:IsA("Trail") or (v:IsA("Attachment") and (v.Name=="TrailA0" or v.Name=="TrailA1")) then
                    v:Destroy()
                end
            end
        end
    end
end)
regToggle(visPage,setTrail,false)

-- Rainbow nametag toggle
local setNametag = makeToggle(visPage,"Rainbow Nametag",O(),function(s)
    if s then
        _G.nametagConn=RunService.RenderStepped:Connect(function()
            local hue=(tick()*60)%360
            local char=player.Character; if not char then return end
            local head=char:FindFirstChild("Head"); if not head then return end
            local bb=head:FindFirstChild("VoidTag") or Instance.new("BillboardGui",head)
            bb.Name="VoidTag"; bb.Size=UDim2.new(0,160,0,30)
            bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true
            local l=bb:FindFirstChildOfClass("TextLabel") or Instance.new("TextLabel",bb)
            l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1
            l.Font=Enum.Font.GothamBold; l.TextSize=14
            l.TextStrokeTransparency=0.2
            l.Text="  "..player.DisplayName.."  "
            l.TextColor3=Color3.fromHSV(hue/360,1,1)
        end)
    else
        if _G.nametagConn then _G.nametagConn:Disconnect(); _G.nametagConn=nil end
        local char=player.Character
        if char then
            local head=char:FindFirstChild("Head")
            if head then local b=head:FindFirstChild("VoidTag"); if b then b:Destroy() end end
        end
    end
end)
regToggle(visPage,setNametag,false)

sectionLabel(visPage,"World Lighting",O())

local setFullbright = makeToggle(visPage,"Fullbright",O(),function(s)
    Lighting.Brightness=s and 8 or DEF.lighting.Brightness
    Lighting.GlobalShadows=not s
end)
regToggle(visPage,setFullbright,false)

local setRainbowLighting = makeToggle(visPage,"Rainbow Lighting",O(),function(s)
    if s then
        _G.rainbowLightConn=RunService.RenderStepped:Connect(function()
            Lighting.Ambient=Color3.fromHSV(tick()%5/5,1,1)
        end)
    else
        if _G.rainbowLightConn then _G.rainbowLightConn:Disconnect(); _G.rainbowLightConn=nil end
        Lighting.Ambient=DEF.lighting.Ambient
    end
end)
regToggle(visPage,setRainbowLighting,false)

local setPurpleSky = makeToggle(visPage,"Purple Sky",O(),function(s)
    if s then
        Lighting.Ambient=Color3.fromRGB(120,70,255)
        Lighting.OutdoorAmbient=Color3.fromRGB(100,50,200)
    else
        Lighting.Ambient=DEF.lighting.Ambient
        Lighting.OutdoorAmbient=DEF.lighting.OutdoorAmbient
    end
end)
regToggle(visPage,setPurpleSky,false)

local setFogWorld = makeToggle(visPage,"Fog World",O(),function(s)
    Lighting.FogEnd=s and 60 or DEF.lighting.FogEnd
end)
regToggle(visPage,setFogWorld,false)

local setTOD = makeSlider(visPage,"Time of Day",0,24,DEF.lighting.ClockTime,O(),function(v)
    Lighting.ClockTime=v
end)
regSlider(visPage,setTOD,DEF.lighting.ClockTime)

local setFogDist = makeSlider(visPage,"Fog Distance",10,2000,DEF.lighting.FogEnd,O(),function(v)
    Lighting.FogEnd=v
end)
regSlider(visPage,setFogDist,DEF.lighting.FogEnd)

sectionLabel(visPage,"Tracers",O())
local setTracers = makeToggle(visPage,"Player Tracers",O(),function(s)
    tracersOn=s
    if not s then for _,l in pairs(tracers) do pcall(function() l:Remove() end) end; tracers={} end
end)
regToggle(visPage,setTracers,false)

makeResetBtn(visPage,O(),function()
    if _G.rainbowLightConn then _G.rainbowLightConn:Disconnect(); _G.rainbowLightConn=nil end
    tracersOn=false; for _,l in pairs(tracers) do pcall(function() l:Remove() end) end; tracers={}
    Lighting.Brightness=DEF.lighting.Brightness; Lighting.GlobalShadows=DEF.lighting.GlobalShadows
    Lighting.FogEnd=DEF.lighting.FogEnd; Lighting.Ambient=DEF.lighting.Ambient
    Lighting.OutdoorAmbient=DEF.lighting.OutdoorAmbient; Lighting.ClockTime=DEF.lighting.ClockTime
    -- remove nametag
    local char=player.Character
    if char then local h=char:FindFirstChild("Head"); if h then local b=h:FindFirstChild("VoidTag"); if b then b:Destroy() end end end
    -- remove trail
    local root=getRoot()
    if root then for _,v in ipairs(root:GetChildren()) do
        if v:IsA("Trail") or (v:IsA("Attachment") and (v.Name=="TrailA0" or v.Name=="TrailA1")) then v:Destroy() end
    end end
    resetToggles(visPage); resetSliders(visPage)
end)

-- ═══════════════════════════════════════════════════════
--  PLAYERS / TELEPORTS
-- ═══════════════════════════════════════════════════════
makeButton(tpPage,"Stop Spectating",C.accent,O(),function()
    camera.CameraSubject=getHum(); camera.CameraType=Enum.CameraType.Custom
end)

local function refreshPlayers()
    for _,v in ipairs(tpPage:GetChildren()) do
        if v.Name=="PlayerCard" then v:Destroy() end
    end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=player then
            local card=makeCard(tpPage,70,O()); card.Name="PlayerCard"
            local nm=Instance.new("TextLabel",card); nm.BackgroundTransparency=1
            nm.Position=UDim2.new(0,16,0,0); nm.Size=UDim2.new(0.36,0,1,0)
            nm.Text=plr.Name; nm.Font=Enum.Font.GothamBold; nm.TextSize=14
            nm.TextColor3=C.text; nm.TextXAlignment=Enum.TextXAlignment.Left; nm.TextTruncate=Enum.TextTruncate.AtEnd
            local function mkBtn(txt,col,xoff)
                local b=Instance.new("TextButton",card)
                b.Size=UDim2.new(0,80,0,32); b.Position=UDim2.new(1,xoff,0.5,-16)
                b.BackgroundColor3=col; b.Text=txt; b.TextColor3=Color3.new(1,1,1)
                b.Font=Enum.Font.GothamBold; b.TextSize=12; b.BorderSizePixel=0
                Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
                return b
            end
            local tp=mkBtn("Teleport",C.accent,-258)
            tp.MouseButton1Click:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    getRoot().CFrame=plr.Character.HumanoidRootPart.CFrame+Vector3.new(0,3,0)
                end
            end)
            local sp=mkBtn("Spectate",C.accent2,-168)
            sp.MouseButton1Click:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    camera.CameraSubject=plr.Character.Humanoid
                end
            end)
            local ab=mkBtn("Above",Color3.fromRGB(80,50,200),-78)
            ab.MouseButton1Click:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    getRoot().CFrame=plr.Character.HumanoidRootPart.CFrame+Vector3.new(0,22,0)
                end
            end)
        end
    end
end
refreshPlayers()
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)
makeButton(tpPage,"Refresh List",C.accent2,O(),refreshPlayers)

-- ═══════════════════════════════════════════════════════
--  FUN
-- ═══════════════════════════════════════════════════════
sectionLabel(funPage,"Void",O())
makeButton(funPage,"VOID  (keybind: V)",C.accent,O(),function()
    local root=getRoot(); if root then root.CFrame=CFrame.new(root.Position+Vector3.new(0,9e4,0)) end
end)
makeButton(funPage,"MEGA VOID  (keybind: U)",Color3.fromRGB(60,0,160),O(),function()
    local root=getRoot(); if root then root.CFrame=CFrame.new(root.Position+Vector3.new(0,9e6,0)) end
end)

sectionLabel(funPage,"Character",O())
local setSpinbot = makeToggle(funPage,"Spinbot",O(),function(s) spinbot=s end)
regToggle(funPage,setSpinbot,false)

local setPlatform = makeToggle(funPage,"Floating Platform",O(),function(s)
    if s then
        local p=Instance.new("Part",workspace); p.Name="VoidPlatform"
        p.Size=Vector3.new(12,1,12); p.Anchored=true
        p.Material=Enum.Material.Neon; p.Color=C.accent; _G.platform=p
    else
        if _G.platform then _G.platform:Destroy(); _G.platform=nil end
    end
end)
regToggle(funPage,setPlatform,false)

local setRainbowChar = makeToggle(funPage,"Rainbow Character",O(),function(s)
    if s then
        _G.rainbowCharConn=RunService.RenderStepped:Connect(function()
            for _,v in ipairs(getChar():GetDescendants()) do
                if v:IsA("BasePart") then v.Color=Color3.fromHSV(tick()%5/5,1,1) end
            end
        end)
    else
        if _G.rainbowCharConn then _G.rainbowCharConn:Disconnect(); _G.rainbowCharConn=nil end
    end
end)
regToggle(funPage,setRainbowChar,false)

local setFire = makeToggle(funPage,"Fire Character",O(),function(s)
    for _,v in ipairs(getChar():GetDescendants()) do
        if v:IsA("BasePart") then
            if s then
                local f=Instance.new("Fire",v); f.Size=7; f.Name="VoidFire"
            else
                local f=v:FindFirstChild("VoidFire"); if f then f:Destroy() end
            end
        end
    end
end)
regToggle(funPage,setFire,false)

makeButton(funPage,"Explode Character",Color3.fromRGB(180,80,0),O(),function()
    for _,v in ipairs(getChar():GetDescendants()) do
        if v:IsA("BasePart") then local e=Instance.new("Explosion",workspace); e.Position=v.Position end
    end
end)
makeButton(funPage,"Restore Body",C.off,O(),function()
    for _,v in ipairs(getChar():GetDescendants()) do
        if v:IsA("BasePart") then v.Transparency=0 end
    end
end)

makeResetBtn(funPage,O(),function()
    spinbot=false
    if _G.platform         then _G.platform:Destroy();          _G.platform=nil         end
    if _G.rainbowCharConn  then _G.rainbowCharConn:Disconnect(); _G.rainbowCharConn=nil  end
    for _,v in ipairs(getChar():GetDescendants()) do
        if v:IsA("Fire") and v.Name=="VoidFire" then v:Destroy() end
        if v:IsA("BasePart") then v.Transparency=0 end
    end
    resetToggles(funPage)
end)

-- ═══════════════════════════════════════════════════════
--  UTILITY
-- ═══════════════════════════════════════════════════════
sectionLabel(utilPage,"Actions",O())
makeButton(utilPage,"Rejoin Server",C.accent,O(),function()
    TeleportSvc:Teleport(game.PlaceId,player)
end)
makeButton(utilPage,"Copy Position",C.accent2,O(),function()
    if setclipboard and getRoot() then setclipboard(tostring(getRoot().Position)) end
end)
makeButton(utilPage,"Anti AFK",C.accent,O(),function()
    player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0),camera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0),camera.CFrame)
    end)
end)

sectionLabel(utilPage,"Camera",O())
makeButton(utilPage,"First Person",C.accent2,O(),function()
    player.CameraMinZoomDistance=0; player.CameraMaxZoomDistance=0
end)
makeButton(utilPage,"Third Person",C.off,O(),function()
    player.CameraMinZoomDistance=0.5; player.CameraMaxZoomDistance=400
end)
local setFOV=makeSlider(utilPage,"FOV",30,120,DEF.fov,O(),function(v) camera.FieldOfView=v end)
regSlider(utilPage,setFOV,DEF.fov)

makeResetBtn(utilPage,O(),function()
    camera.FieldOfView=DEF.fov
    player.CameraMinZoomDistance=0.5; player.CameraMaxZoomDistance=400
    resetSliders(utilPage)
end)

-- ═══════════════════════════════════════════════════════
--  KEYBINDS PAGE
-- ═══════════════════════════════════════════════════════
sectionLabel(kbPage,"Current Keybinds  (click to rebind)",O())

local kbDefs = {
    {label="Fly Toggle",       key="fly"},
    {label="Void",             key="void"},
    {label="Mega Void",        key="megaVoid"},
    {label="Walkspeed Boost (N)",  key="wsToggle"},
    {label="Hide UI",          key="hideUI"},
    {label="Noclip Toggle",    key="noclip"},
}

local kbLabels = {}  -- store label refs to update them
local listeningFor = nil  -- which key slot we're rebinding

local function kbName(kc)
    local s=tostring(kc)
    return s:match("KeyCode%.(.+)") or s
end

local function updateSubLbl()
    subLbl.Text="v5  |  RightCtrl = hide  |  "..kbName(KB.fly).." = fly"
end

for _,def in ipairs(kbDefs) do
    local card=makeCard(kbPage,56,O())
    local lbl=Instance.new("TextLabel",card)
    lbl.BackgroundTransparency=1; lbl.Position=UDim2.new(0,18,0,0)
    lbl.Size=UDim2.new(0.55,0,1,0); lbl.Text=def.label
    lbl.TextColor3=C.text; lbl.Font=Enum.Font.GothamMedium
    lbl.TextSize=14; lbl.TextXAlignment=Enum.TextXAlignment.Left

    local bindBtn=Instance.new("TextButton",card)
    bindBtn.Size=UDim2.new(0,120,0,34); bindBtn.Position=UDim2.new(1,-136,0.5,-17)
    bindBtn.BackgroundColor3=C.accent2; bindBtn.Text="[ "..kbName(KB[def.key]).." ]"
    bindBtn.Font=Enum.Font.GothamBold; bindBtn.TextSize=13
    bindBtn.TextColor3=C.text; bindBtn.BorderSizePixel=0
    Instance.new("UICorner",bindBtn).CornerRadius=UDim.new(1,0)

    kbLabels[def.key]=bindBtn

    bindBtn.MouseButton1Click:Connect(function()
        if listeningFor then return end
        listeningFor=def.key
        bindBtn.Text="Press a key..."
        bindBtn.BackgroundColor3=C.red
    end)
end

-- listen for rebind keypress
UIS.InputBegan:Connect(function(inp,gp)
    if listeningFor then
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            KB[listeningFor]=inp.KeyCode
            local btn=kbLabels[listeningFor]
            if btn then
                btn.Text="[ "..kbName(inp.KeyCode).." ]"
                btn.BackgroundColor3=C.accent2
            end
            listeningFor=nil
            updateSubLbl()
        end
        return  -- swallow the input
    end
end,true)

-- ═══════════════════════════════════════════════════════
--  SETTINGS
-- ═══════════════════════════════════════════════════════
sectionLabel(setPage,"Character",O())
makeButton(setPage,"Reset Character",C.red,O(),function()
    local h=getHum(); if h then h.Health=0 end
end)
makeButton(setPage,"Max Stats",C.accent,O(),function()
    local h=getHum(); if h then h.WalkSpeed=200; h.JumpPower=200 end
    flySpeed=300; workspace.Gravity=50; wsValue=200
end)
makeButton(setPage,"Default Stats",C.off,O(),function()
    local h=getHum(); if h then h.WalkSpeed=DEF.ws; h.JumpPower=DEF.jp end
    flySpeed=DEF.flySpeed; workspace.Gravity=DEF.gravity; wsValue=DEF.ws
end)

sectionLabel(setPage,"Lighting Presets",O())
makeButton(setPage,"Day Mode",C.accent,O(),function() Lighting.ClockTime=14 end)
makeButton(setPage,"Night Mode",Color3.fromRGB(30,25,80),O(),function() Lighting.ClockTime=0 end)
makeButton(setPage,"Purple Ambient",C.accent2,O(),function()
    Lighting.Ambient=Color3.fromRGB(120,70,255); Lighting.OutdoorAmbient=Color3.fromRGB(90,50,200)
end)
makeButton(setPage,"Reset Lighting",C.off,O(),function()
    Lighting.Brightness=DEF.lighting.Brightness; Lighting.GlobalShadows=DEF.lighting.GlobalShadows
    Lighting.FogEnd=DEF.lighting.FogEnd; Lighting.Ambient=DEF.lighting.Ambient
    Lighting.OutdoorAmbient=DEF.lighting.OutdoorAmbient; Lighting.ClockTime=DEF.lighting.ClockTime
end)

sectionLabel(setPage,"UI",O())
local setUITrans=makeSlider(setPage,"UI Transparency",0,90,22,O(),function(v)
    main.BackgroundTransparency=v/100
end)
regSlider(setPage,setUITrans,22)

local setUIScale=makeSlider(setPage,"UI Scale",60,130,100,O(),function(v)
    local s=main:FindFirstChildOfClass("UIScale") or Instance.new("UIScale",main)
    s.Scale=v/100
end)
regSlider(setPage,setUIScale,100)

sectionLabel(setPage,"Accent Color",O())
local accentColors={
    {"Purple",   Color3.fromRGB(130,70,255)},
    {"Blue",     Color3.fromRGB(50,120,255)},
    {"Cyan",     Color3.fromRGB(40,200,220)},
    {"Green",    Color3.fromRGB(40,200,100)},
    {"Pink",     Color3.fromRGB(230,80,180)},
    {"Red",      Color3.fromRGB(220,60,60)},
    {"Orange",   Color3.fromRGB(230,130,40)},
}
for _,ac in ipairs(accentColors) do
    makeButton(setPage,"Accent: "..ac[1],ac[2],O(),function()
        C.accent=ac[2]; winStroke.Color=ac[2]
        divLine.BackgroundColor3=ac[2]
    end)
end

sectionLabel(setPage,"Performance",O())
makeButton(setPage,"FPS Boost",C.accent2,O(),function()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then v.Material=Enum.Material.Plastic; v.Reflectance=0 end
    end
    Lighting.GlobalShadows=false
end)
makeButton(setPage,"Reset Gravity",C.off,O(),function() workspace.Gravity=DEF.gravity end)
makeButton(setPage,"Destroy UI",C.red,O(),function() gui:Destroy() end)

makeResetBtn(setPage,O(),function()
    local h=getHum(); if h then h.WalkSpeed=DEF.ws; h.JumpPower=DEF.jp end
    workspace.Gravity=DEF.gravity; camera.FieldOfView=DEF.fov; wsValue=DEF.ws
    main.BackgroundTransparency=0.22
    local sc=main:FindFirstChildOfClass("UIScale"); if sc then sc.Scale=1 end
    C.accent=Color3.fromRGB(130,70,255); winStroke.Color=C.accent; divLine.BackgroundColor3=C.accent
    Lighting.Brightness=DEF.lighting.Brightness; Lighting.GlobalShadows=DEF.lighting.GlobalShadows
    Lighting.FogEnd=DEF.lighting.FogEnd; Lighting.Ambient=DEF.lighting.Ambient
    Lighting.OutdoorAmbient=DEF.lighting.OutdoorAmbient; Lighting.ClockTime=DEF.lighting.ClockTime
    resetToggles(setPage); resetSliders(setPage)
end)

-- ═══════════════════════════════════════════════════════
--  GLOBAL KEYBIND HANDLER
-- ═══════════════════════════════════════════════════════
UIS.InputBegan:Connect(function(inp,gp)
    if gp or listeningFor then return end
    local kc=inp.KeyCode

    if kc==KB.fly then
        fly=not fly; setFly(fly)
    end
    if kc==KB.hideUI then
        main.Visible=not main.Visible
    end
    if kc==KB.void then
        local root=getRoot(); if root then root.CFrame=CFrame.new(root.Position+Vector3.new(0,9e4,0)) end
    end
    if kc==KB.megaVoid then
        local root=getRoot(); if root then root.CFrame=CFrame.new(root.Position+Vector3.new(0,9e6,0)) end
    end
    if kc==KB.wsToggle then
        wsBoostOn=not wsBoostOn
        if wsBoostOn then
            wsSavedVal=wsValue          -- save whatever the slider is currently set to
            wsValue=wsValue*2           -- boost = double whatever you already set
        else
            wsValue=wsSavedVal          -- restore the slider speed exactly
        end
        local h=getHum(); if h then h.WalkSpeed=wsValue end
    end
    if kc==KB.noclip then
        noclip=not noclip; setNoclip(noclip)
    end
    if inp.UserInputType==Enum.UserInputType.MouseButton1 and clickTP then
        getRoot().CFrame=CFrame.new(mouse.Hit.Position+Vector3.new(0,3,0))
    end
end)

UIS.JumpRequest:Connect(function()
    if infJump then local h=getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)

-- ═══════════════════════════════════════════════════════
--  MAIN LOOP
-- ═══════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function()
    if fly then
        local root=getRoot()
        if root then
            local dir=Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir+=camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir-=camera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir-=camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir+=camera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space)     then dir+=Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir-=Vector3.new(0,1,0) end
            if dir.Magnitude>0 then dir=dir.Unit end
            root.AssemblyLinearVelocity=dir*flySpeed
        end
    end

    if noclip then
        for _,v in ipairs(getChar():GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide=false end
        end
    end

    if bhop then
        local h=getHum()
        if h and h.FloorMaterial~=Enum.Material.Air then
            h:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

    if spinbot then
        local root=getRoot()
        if root then root.CFrame=root.CFrame*CFrame.Angles(0,math.rad(22),0) end
    end

    if _G.platform and getRoot() then
        _G.platform.Position=getRoot().Position-Vector3.new(0,4,0)
    end

    if tracersOn then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if not tracers[plr] then
                    local line=Drawing.new("Line")
                    line.Color=C.accent; line.Thickness=1.5; line.Transparency=1
                    tracers[plr]=line
                end
                local pos,vis=camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if vis then
                    tracers[plr].From=Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y)
                    tracers[plr].To=Vector2.new(pos.X,pos.Y)
                    tracers[plr].Visible=true
                else
                    tracers[plr].Visible=false
                end
            end
        end
    end
end)

print("  VOIDOOR SCRIPTHUB V5 LOADED")
